#!/usr/bin/env python3
import sys
import re
import argparse
from pathlib import Path

# --- opcode map (top nibble) ---
OPCODES = {
    "JAL":  0x0,
    "ADDI": 0x1,
    "RR":   0x2,     # not used as mnemonic directly
    "RI":   0x3,
    "LW":   0x4,
    "LB":   0x5,
    "SW":   0x6,
    "SB":   0x7,
    "IMM":  0x8,
    "B":    0x9,     # branch base, not used directly
    "SYS":  0xA,
    "CLI":  0xB,
    "STI":  0xC,
    "NOP":  0xF      # matches op=0xF NOP in RTL
}

# --- RI dict for op = 3 (RI) ---   
RI = {
    "RSUBI": 0x1, 
    "ANDI" : 0x2,
    "XORI" : 0x3,
    "ADCI" : 0x4, 
    "RSCBI": 0x5,
    "RCMPI": 0x6
}

# --- FN map for op = 2 (RR) / op = 3 (RI) ---
FN = {
    "ADD": 0x0,
    "SUB": 0x1,
    "AND": 0x2,
    "XOR": 0x3,
    "ADC": 0x4,
    "SBC": 0x5,
    "CMP": 0x6,
    "SRL": 0x7,
    "SRA": 0x8,
}

# --- memory ops (op = 4..7) ---
MEM = {
    "LW": 0x4,
    "LB": 0x5,
    "SW": 0x6,
    "SB": 0x7,
}

# --- branch cond map (op = 9) ---
BR_COND = {
    "BR":   0x0,  # always
    "BEQ":  0x2,
    "BC":   0x4,
    "BV":   0x6,
    "BLT":  0x8,
    "BLE":  0xA,
    "BLTU": 0xC,
    "BLEU": 0xE,
}

# -- ABI reg names -- 
ABI_REGS = {
    "a0":1, "v0":1,
    "a1":2, "v1":2,
    "a2":3,
    "t0":4,"t1":5,"t2":6,"t3":7,
    "s0":8,"s1":9,"s2":10,"s3":11,
    "fp":12,
    "sp":13,
    "lr":14,
    "gp":15,
    "zero":0
}

# regexes
reg_re   = re.compile(r"r(\d+)$", re.IGNORECASE)
label_re = re.compile(r"^([A-Za-z_]\w*):\s*(.*)$")
include_re = re.compile(r'^\s*\.include\s+"([^"]+)"\s*$', re.IGNORECASE)


# ------------- basic parsers -------------

def parse_reg(tok: str) -> int:
    name = tok.strip().lower()
    if name in ABI_REGS:
        return ABI_REGS[name]

    # fallback to normal regex patterns 
    m = reg_re.match(tok.strip())
    if not m:
        raise ValueError(f"Bad register '{tok}'")
    v = int(m.group(1))
    if not (0 <= v <= 15):
        raise ValueError(f"Reg out of range: {v}")
    return v


def parse_imm(tok: str) -> int:
    tok = tok.split(";", 1)[0]
    tok = tok.strip()
    if tok.startswith("#"):
        tok = tok[1:]
    if tok.lower().startswith("0x"):
        return int(tok, 16)
    if tok.startswith("+") or tok.startswith("-"):
        return int(tok, 10)
    return int(tok, 10)

def encode_imm4(val: int) -> int:
    """
    Encode a 4-bit two's complement nibble.

    We accept a reasonably wide integer range and just keep the low 4 bits.
    """
    if not (-128 <= val <= 127):
        raise ValueError(f"IMM4 expression too large: {val}")
    return val & 0xF

def parse_expr(tok: str, symbols=None) -> int:
    tok = tok.split(";", 1)[0]
    tok = tok.strip()
    if "#" in tok:
        tok = tok.replace("#", "")
        tok = tok.strip()

    # --- simple bit ops used by macros: "label >> 4", "label & 0xF" ---
    if ">>" in tok:
        left, right = tok.split(">>", 1)
        return parse_expr(left.strip(), symbols) >> parse_imm(right.strip())

    if "&" in tok:
        left, right = tok.split("&", 1)
        return parse_expr(left.strip(), symbols) & parse_imm(right.strip())

    if symbols:
        m = re.match(r"^([A-Za-z_]\w*)([+-].+)?$", tok)
        if m:
            name = m.group(1)
            rest = m.group(2)
            if name in symbols:
                base = symbols[name]
                if rest:
                    off = parse_imm(rest)
                    return base + off
                return base

    # fallback numeric literal or register alias
    try:
        return parse_imm(tok)
    except ValueError:
        try:
            return parse_reg(tok)
        except ValueError:
            raise

def expand_includes(lines, base_path: Path) -> list[str]:
    """
    Expand .include "*.inc" directives.

    - lines: list of input lines
    - base_path: directory of current source file 
    """
    expanded = []
    for line in lines:
        m = include_re.match(line)
        if m:
            inc_file = m.group(1)
            inc_path = (base_path.parent / inc_file).resolve()
            if not inc_path.exists():
                raise FileNotFoundError(f"Included file not found: {inc_path}")
            inc_lines = inc_path.read_text().splitlines()
            inc_expanded = expand_includes(inc_lines, inc_path)
            expanded.extend(inc_expanded)
        else:
            expanded.append(line)
    return expanded

def expand_line_macros(line: str, macros, depth: int = 0):
    """
    Expand a single line wrt macros, warning: can recurse if macro
    bodies themselves invoke other macros.

    `macros` is a dict: NAME -> (param_names, body_lines).
    """
    if depth > 20:
        raise ValueError("macro expansion recursion too deep")

    stripped = line.strip()
    if not stripped:
        return [line]

    # pure comment lines -> leave as-is
    if stripped.startswith(";") or stripped.startswith("//"):
        return [line]

    # peel off any leading labels: L1: L2: instr ...
    tmp = stripped
    labels_prefix = ""
    while True:
        m = label_re.match(tmp)
        if not m:
            break
        label = m.group(1)
        rest  = m.group(2).strip()
        labels_prefix += label + ": "
        if not rest:
            # only labels on this line
            return [labels_prefix.rstrip()]
        tmp = rest

    after_labels = tmp
    if not after_labels:
        return [labels_prefix.rstrip()]

    # lines starting with a '.' after labels are directives, not macro calls
    if after_labels.startswith("."):
        return [stripped]

    parts = after_labels.split(None, 1)
    name = parts[0]
    rest = parts[1] if len(parts) > 1 else ""

    macro = macros.get(name.upper())
    if not macro:
        # not a macro invocation
        return [stripped]

    param_names, body = macro

    # strip trailing comment from argument list
    args_text = rest.split(";", 1)[0].strip()
    if args_text:
        arg_list = [a.strip() for a in args_text.split(",") if a.strip()]
    else:
        arg_list = []

    if len(arg_list) != len(param_names):
        raise ValueError(
            f"Macro '{name}' expects {len(param_names)} args, got {len(arg_list)}"
        )

    result_lines = []
    for idx, body_line in enumerate(body):
        new_line = body_line
        # \param textual substitution
        for pname, argval in zip(param_names, arg_list):
            new_line = new_line.replace(f"\\{pname}", argval)

        # recursively expand macros that appear inside the body
        expanded_nested = expand_line_macros(new_line, macros, depth + 1)

        # first expanded line keeps labels (if any)
        if idx == 0 and labels_prefix and expanded_nested:
            expanded_nested[0] = labels_prefix + expanded_nested[0].lstrip()

        result_lines.extend(expanded_nested)

    return result_lines


def expand_macros(lines):
    """
    Scan for:

        .macro NAME [params...]
        ...
        .endm

    Build a macro table, remove macro definitions from the stream,
    and expand any macro invocations into plain assembly lines.
    """
    macros = {}  # NAME (upper) -> (param_names, body_lines)
    out_lines = []

    in_macro = False
    cur_name = None
    cur_params = []
    cur_body = []

    for line in lines:
        stripped = line.lstrip()
        low = stripped.lower()

        # start of macro definition
        if not in_macro and low.startswith(".macro"):
            tokens = stripped.split()
            if len(tokens) < 2:
                raise ValueError(f"Bad .macro line: {line!r}")
            cur_name = tokens[1]
            # parameters may be space or comma-separated
            if len(tokens) > 2:
                params_part = " ".join(tokens[2:])
                cur_params = [p.strip() for p in params_part.split(",") if p.strip()]
            else:
                cur_params = []
            cur_body = []
            in_macro = True
            continue

        # inside macro body
        if in_macro:
            if low.startswith(".endm"):
                if cur_name is None:
                    raise ValueError("Unexpected .endm without matching .macro")
                name_upper = cur_name.upper()
                if name_upper in macros:
                    raise ValueError(f"Macro redefined: {cur_name}")
                macros[name_upper] = (cur_params, cur_body)
                in_macro = False
                cur_name = None
                cur_params = []
                cur_body = []
                continue
            else:
                cur_body.append(line)
                continue

        # normal line (outside macro defs) -> macro expansion
        expanded = expand_line_macros(line, macros)
        out_lines.extend(expanded)

    if in_macro:
        raise ValueError("Unterminated .macro at EOF")

    return out_lines


# ------------- instruction encoder (pass 2) -------------

def assemble_line(asm: str, pc_words: int, symbols=None, sym_kind=None) -> int:
    """
    Encode a single instruction (no comments).
    pc_words: PC index in *words* (pc_words*2 is byte address).
    """
    asm = asm.strip()
    if not asm:
        raise ValueError("empty instruction")

    fields = asm.split(None, 1)
    if not fields:
        raise ValueError("empty instruction")
    mnem = fields[0].upper()
    operands = []
    if len(fields) > 1:
        operands = [op.strip() for op in fields[1].split(",") if op.strip()]

    # --- CLI --- 
    if mnem == "CLI":
        if len(operands) != 0:
            raise ValueError(f"CLI takes no operands: {asm}")
        op = OPCODES["CLI"]
        return (op << 12)
    
    # --- STI ---
    if mnem == "STI":
        if len(operands) != 0:
            raise ValueError(f"STI takes no operands: {asm}")
        op = OPCODES["STI"]
        return (op << 12)

    # --- JAL rd,rs,imm4 ---
    if mnem == "JAL":
        if len(operands) != 3:
            raise ValueError(f"JAL needs rd, rs, imm4: {asm}")
        op  = OPCODES["JAL"]
        rd  = parse_reg(operands[0])
        rs  = parse_reg(operands[1])
        imm4_val = parse_expr(operands[2], symbols)
        imm4 = encode_imm4(imm4_val)
        return (op << 12) | (rd << 8) | (rs << 4) | imm4

    # --- IMM: IMM #0xABC (12-bit) ---
    if mnem == "IMM":
        if len(operands) != 1:
            raise ValueError(f"IMM needs exactly 1 operand: {asm}")
        op = OPCODES["IMM"]
        imm12 = parse_expr(operands[0], symbols)
        if not (0 <= imm12 <= 0xFFF):
            raise ValueError(f"IMM 12-bit out of range: {imm12}")
        return (op << 12) | (imm12 & 0xFFF)

    # --- ADDI rd,rs,imm4 ---
    if mnem == "ADDI":
        if len(operands) != 3:
            raise ValueError(f"ADDI needs rd, rs, imm4: {asm}")
        op  = OPCODES["ADDI"]
        rd  = parse_reg(operands[0])
        rs  = parse_reg(operands[1])
        imm4_val = parse_expr(operands[2], symbols)
        imm4 = encode_imm4(imm4_val)
        return (op << 12) | (rd << 8) | (rs << 4) | imm4

    # --- RR/RI ALU: ADD rd,rs; SUB rd,rs; ... ---
    if mnem in FN:
        if len(operands) != 2:
            raise ValueError(f"{mnem} needs rd, rs: {asm}")
        op  = 0x2
        rd  = parse_reg(operands[0])
        rs  = parse_reg(operands[1])
        fn  = FN[mnem]
        return (op << 12) | (rd << 8) | (rs << 4) | fn

    # --- RI ALU: RSUBI rd, imm4; ADCI rd, imm4; ... ---
    if mnem in RI: 
        if len(operands) != 2: 
            raise ValueError(f"RI needs rd, imm4: {asm}")
        op = 0x3
        rd = parse_reg(operands[0])
        imm4_val = parse_expr(operands[1], symbols)
        imm4 = encode_imm4(imm4_val)
        fn = RI.get(mnem)
        if fn is None:
            raise ValueError(f"Unknown RI mnemonic: {mnem}")
        return (op << 12) | (rd << 8) | (fn << 4) | imm4 

    # --- Loads/Stores: LW/LB/SW/SB rd,rs,imm4 ---
    if mnem in MEM:
        if len(operands) != 3:
            raise ValueError(f"{mnem} needs rd, rs, imm4: {asm}")
        op  = OPCODES[mnem]
        rd  = parse_reg(operands[0])
        rs  = parse_reg(operands[1])
        imm4_val = parse_expr(operands[2], symbols)
        imm4 = encode_imm4(imm4_val)
        return (op << 12) | (rd << 8) | (rs << 4) | imm4

    # --- Branches: BR/BEQ/... disp or label ---
    if mnem in BR_COND:
        if len(operands) != 1:
            raise ValueError(f"{mnem} needs 1 operand (disp or label): {asm}")
        op   = 0x9
        cond = BR_COND[mnem]
        target = operands[0]

        disp = None
        label_match = re.match(r"^([A-Za-z_]\w*)([+-].+)?$", target)
        if (symbols is not None and sym_kind is not None and label_match):
            name = label_match.group(1)
            extra = label_match.group(2)
            if name in symbols and sym_kind.get(name) == "label":
                target_byte = symbols[name]
                if extra:
                    target_byte += parse_imm(extra)
                cur_byte = pc_words * 2 + 2
                diff = target_byte - cur_byte
                if diff % 2 != 0:
                    raise ValueError(f"Branch target {target} not word aligned")
                disp = diff // 2

        if disp is None:
            disp = parse_expr(target, symbols)

        if not (-128 <= disp <= 127):
            raise ValueError(f"branch disp out of 8-bit range: {disp}")
        disp &= 0xFF
        return (op << 12) | (cond << 8) | disp
    
    # --- GETCC rd  (SYS op=0xA, fn=0x9, rs unused) ---
    if mnem == "GETCC":
        if len(operands) != 1:
            raise ValueError(f"GETCC needs rd: {asm}")
        op  = 0xA
        rd  = parse_reg(operands[0])
        rs  = 0
        fn  = 0x9  # matches `fn==9` in RTL for GETCC
        return (op << 12) | (rd << 8) | (rs << 4) | fn

    # --- SETCC rs  (SYS op=0xA, fn=0xA, rd unused) ---
    if mnem == "SETCC":
        if len(operands) != 1:
            raise ValueError(f"SETCC needs rs: {asm}")
        op  = 0xA
        rd  = 0
        rs  = parse_reg(operands[0])
        fn  = 0xA  # matches `fn==10` in RTL for SETCC
        return (op << 12) | (rd << 8) | (rs << 4) | fn

    # --- NOP ---
    if mnem == "NOP":
        op = OPCODES["NOP"]
        return (op << 12)  # 0xF000

    raise ValueError(f"Unknown mnemonic: {mnem}")


# ------------- first pass -------------


def _context_error(msg, line_no, line_text):
    snippet = line_text.rstrip("\n")
    raise ValueError(f"line {line_no}: {msg}\n    {snippet}")


def first_pass(lines):
    """
    First pass:
      - strip comments
      - build symbol table (labels + .equ)
      - track location counter in words
      - emit cooked list of (pc_in_words, text_without_labels_or_None)
    """
    symbols  = {}
    sym_kind = {}   # name → "label" | "equ"
    cooked   = []

    pc = 0  # in words

    for line_no, raw in enumerate(lines, start=1):
        # strip '//' and ';' comments (retain original raw for context)
        no_slash = raw.split("//", 1)[0]
        no_semicolon = no_slash.split(";", 1)[0]
        text = no_semicolon.strip()
        if not text:
            cooked.append((pc, None, line_no, raw))
            continue

        low = text.lower()

        # .equ NAME, expr
        if low.startswith(".equ"):
            parts = text.split(None, 1)
            if len(parts) < 2:
                _context_error(".equ missing operands", line_no, raw)
            rest = parts[1]
            try:
                name_part, expr_part = [p.strip() for p in rest.split(",", 1)]
            except ValueError:
                _context_error(".equ requires NAME, expr", line_no, raw)
            try:
                val = parse_expr(expr_part, symbols)
            except ValueError as exc:
                _context_error(str(exc), line_no, raw)
            if name_part in symbols:
                _context_error(f"Symbol redefined: {name_part}", line_no, raw)
            symbols[name_part]  = val       # constant, not an address
            sym_kind[name_part] = "equ"
            cooked.append((pc, None, line_no, raw))
            continue

        # one or more labels: label1: label2: instr
        while True:
            m = label_re.match(text)
            if not m:
                break
            label, rest = m.group(1), m.group(2)
            if label in symbols:
                _context_error(f"Duplicate label: {label}", line_no, raw)
            symbols[label]  = pc * 2   # store BYTE address for labels
            sym_kind[label] = "label"
            text = rest.strip()
            if not text:
                break

        if not text:
            cooked.append((pc, None, line_no, raw))
            continue

        low = text.lower()

        # .org BYTE_ADDR
        if low.startswith(".org"):
            parts = text.split(None, 1)
            if len(parts) < 2:
                _context_error(".org missing operand", line_no, raw)
            try:
                addr = parse_expr(parts[1], symbols)
            except ValueError as exc:
                _context_error(str(exc), line_no, raw)
            if addr & 1:
                _context_error(f".org address must be even: 0x{addr:04X}", line_no, raw)
            pc = addr // 2
            cooked.append((pc, text, line_no, raw))
            continue

        # .word EXPR   (1 word of data)
        if low.startswith(".word"):
            cooked.append((pc, text, line_no, raw))
            pc += 1
            continue

        # normal instruction -> 1 word
        cooked.append((pc, text, line_no, raw))
        pc += 1

    return symbols, sym_kind, cooked


# ------------- second pass -------------


def second_pass(cooked, symbols, sym_kind):
    """
    Second pass:
      - for each (pc,text) from pass1:
        * pad gaps in pc with NOP (0xF000)
        * encode .word / instructions
      - .org just affects pc from pass1; here we check it doesn't move backward
    """
    words  = []
    cur_pc = 0  # in words

    for pc_line, text, line_no, raw in cooked:
        # pad forward jumps (from .org) with NOPs
        if pc_line > cur_pc:
            while cur_pc < pc_line:
                words.append(0xF000)
                cur_pc += 1

        if text is None:
            continue

        low = text.lower()

        # .org: PC already adjusted in pass1
        if low.startswith(".org"):
            if pc_line < cur_pc:
                _context_error(".org moved PC backwards", line_no, raw)
            continue

        # .word EXPR
        if low.startswith(".word"):
            try:
                _, expr = text.split(None, 1)
            except ValueError:
                _context_error(".word requires an expression", line_no, raw)
            try:
                val = parse_expr(expr, symbols)
            except ValueError as exc:
                _context_error(str(exc), line_no, raw)
            words.append(val & 0xFFFF)
            cur_pc += 1
            continue

        # instruction
        try:
            word = assemble_line(text, pc_line, symbols, sym_kind)
        except ValueError as exc:
            _context_error(str(exc), line_no, raw)
        words.append(word & 0xFFFF)
        cur_pc += 1

    return words


# ------------- main -------------


def _write_text(path: Path, content: str):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)


def main():
    parser = argparse.ArgumentParser(
        description="Assemble GR0040/GR0041 ISA programs into HEX files",
    )
    parser.add_argument(
        "input",
        nargs="?",
        default="assembly/input.asm",
        help="input assembly file (default: assembly/input.asm)",
    )
    parser.add_argument(
        "output",
        nargs="?",
        help="optional combined 16-bit hex output file (default: srcs/mem/mem.hex)",
    )
    parser.add_argument(
        "-o",
        "--out",
        dest="out",
        help="combined 16-bit hex output (overrides positional)",
    )
    parser.add_argument(
        "--hi",
        dest="hi_out",
        help="hi-byte hex output path (default srcs/mem/mem_hi.hex)",
    )
    parser.add_argument(
        "--lo",
        dest="lo_out",
        help="lo-byte hex output path (default srcs/mem/mem_lo.hex)",
    )
    parser.add_argument(
        "--pad-words",
        dest="pad_words",
        type=int,
        default=512,
        help="pad output to this many words with NOP (default 512, use 0 to disable)",
    )
    parser.add_argument("-q", "--quiet", action="store_true", help="suppress summary output")

    args = parser.parse_args()

    in_path = Path(args.input)
    if not in_path.exists():
        print(f"error: input file not found: {in_path}", file=sys.stderr)
        sys.exit(2)

    out_path = Path(args.out or args.output or "srcs/mem/mem.hex")
    hi_path = Path(args.hi_out) if args.hi_out else Path("srcs/mem/mem_hi.hex")
    lo_path = Path(args.lo_out) if args.lo_out else Path("srcs/mem/mem_lo.hex")

    # 1. Read input lines 
    raw_lines = in_path.read_text().splitlines()

    # 2. Expand includes 
    lines_with_includes = expand_includes(raw_lines, in_path.resolve())

    # 3, Expand macros 
    lines = expand_macros(lines_with_includes)

    symbols, sym_kind, cooked = first_pass(lines)
    words = second_pass(cooked, symbols, sym_kind)

    if args.pad_words < 0:
        print("error: --pad-words must be >= 0", file=sys.stderr)
        sys.exit(2)

    if args.pad_words > 0:
        if len(words) > args.pad_words:
            print(
                f"error: program length ({len(words)} words) exceeds --pad-words ({args.pad_words})",
                file=sys.stderr,
            )
            sys.exit(2)
        if len(words) < args.pad_words:
            words = words + ([0xF000] * (args.pad_words - len(words)))

    hex_lines_full = [f"{w:04X}" for w in words]
    _write_text(out_path, "\n".join(hex_lines_full) + "\n")

    hi_lines = [f"{(w >> 8) & 0xFF:02X}" for w in words]
    lo_lines = [f"{w & 0xFF:02X}" for w in words]

    _write_text(hi_path, "\n".join(hi_lines) + "\n")
    _write_text(lo_path, "\n".join(lo_lines) + "\n")

    if not args.quiet:
        print(f"Assembled {len(words)} words from {in_path}")
        print(f"  combined: {out_path}")
        print(f"  hi bytes: {hi_path}")
        print(f"  lo bytes: {lo_path}")


if __name__ == "__main__":
    main()
