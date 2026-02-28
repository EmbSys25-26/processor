# 🛠️ Custom Assembler

A two-pass assembler toolchain for a custom 16-bit RISC architecture. It uses **Flex** for lexical analysis, **Bison** for parsing, **M4** for macro preprocessing, and **C** for code generation and utilities.

---

## 📁 Project Structure
```
.
├── main.c                      # Entry point — orchestrates Pass 1 and Pass 2
├── ASM_test.asm                # Example/default input assembly file
├── Step1/
│   ├── abi.m4                  # M4 macro file — register aliases & pseudo-instructions
│   ├── lexer.l                 # Flex lexer — tokenises the assembly source
│   ├── lex.yy.c                # Auto-generated C lexer (from lexer.l)
│   ├── parser.y                # Bison grammar — builds the statement list
│   ├── parser_tab.c            # Auto-generated C parser (from parser.y)
│   └── parser_tab.h            # Auto-generated parser header
├── Step2/
│   ├── code_generator.c        # Pass 2 — walks the statement list and emits hex
│   └── code_generator.h        # code_generator public interface
├── Util/
│   ├── symbol_table.c          # Hash-table-based symbol table
│   ├── symbol_table.h          # symbol_table public interface
│   ├── statements_list.c       # Dynamic array of parsed statements
│   ├── statements_list.h       # statements_list public interface + statement_t type
│   ├── asm_operations.h        # Opcodes, fn codes, formats and directive constants
│   ├── logger.c                # Colour-coded terminal logging helpers
│   └── logger.h                # LOG_DEBUG / LOG_WARNING / LOG_ERROR macros
└── Makefile                    # Full build pipeline
```

---

## ⚙️ How It Works — Two-Pass Assembly

### Pass 1 (Lex + Parse)
The Flex lexer (`lexer.l`) tokenises the M4-expanded source file and feeds tokens to the Bison parser (`parser.y`). As instructions are recognised, the parser:
- Adds **labels** and **`.equ` constants** to the **symbol table** (`symbol_table.c`), recording their address or value.
- Appends every instruction and directive as a `statement_t` record to the **statements list** (`statements_list.c`), tracking the location counter as it goes.

### Pass 2 (Code Generation)
`code_generator.c` iterates over the statements list. For each statement it calls `encode_statement()`, which reads the format field and bit-packs the opcode, register numbers, immediate, and condition-code fields into a 16-bit word. Labels and forward references are resolved against the symbol table at this stage. The output is written to `build/<basename>.hex`. The addresses that don´t have instructions are filled with NOP's

---

## 🚀 How to Build and Use

### Prerequisites

| Tool | Purpose |
|------|---------|
| `gcc` | Compiles all C sources |
| `flex` | Regenerates `lex.yy.c` from `lexer.l` (if needed) |
| `bison` | Regenerates `parser_tab.c/.h` from `parser.y` (if needed) |
| `m4` | Expands macros in `.asm` files before assembly |
| `awk` | Splits the hex output into high/low byte files |

> **Note:** `lex.yy.c`, `parser_tab.c`, and `parser_tab.h` are already pre-generated and included in `Step1/`. You only need to re-run Flex/Bison if you modify `lexer.l` (flex lexer.l )or `parser.y` (bison -d parser.y).

---

### 1. Write your program

Open (or create) an `.asm` file and write your assembly. The default file is `ASM_test.asm`:
```asm
ADDI r1, r0, #5     ; r1 = 5
ADDI r2, r0, #3     ; r2 = 3
ADD  r3, r1         ; r3 = r1 + r2
```
IF YOU DO CHANGE THE NAME OF THE .asm FILE, CHANGE IT IN MAKEFILE!!!
---

### 2. Build the assembler and assemble your file
```bash
make
```

This runs three steps automatically:

| Step | What happens |
|------|-------------|
| **Compile** | Compiles all `.c` files into the `assembler` binary |
| **M4 expand** | Runs `m4 Step1/abi.m4 <src>` → `build/<basename>.asm` |
| **Assemble** | Runs `./assembler build/<basename>.asm` → `build/<basename>.hex` |
| **Split** | Splits hex into `build/<basename>_hi.hex` and `build/<basename>_lo.hex` |

To assemble a different file:
```bash
make SRC=my_program.asm
```

---

### 3. Output files

All outputs land in the `build/` directory:

| File | Description |
|------|-------------|
| `build/<basename>.asm` | Source after M4 macro expansion |
| `build/<basename>.hex` | 16-bit hex words, one per line |
| `build/<basename>_hi.hex` | High byte (bits 15–8) of each instruction |
| `build/<basename>_lo.hex` | Low byte (bits 7–0) of each instruction |

---

### 4. Clean up
```bash
make clean
```

Removes the `build/` directory and the `assembler` binary.

---

## 📂 Source File Descriptions

### `main.c`
Entry point. Accepts a single argument (the pre-processed `.asm` file), calls `init_symbol_table()` and `init_statements_list()`, runs `yyparse()` (Pass 1), then calls `generate_code()` (Pass 2). Frees all resources on exit.

### `Step1/abi.m4`
M4 macro definitions. Provides register name aliases (`zero`, `sp`, `lr`, etc.) and pseudo-instruction macros (`PUSH`, `POP`, `MOV`, `CALL`, `RET`, `LI`, etc.). Expanded by `m4` before the assembler sees the file.

### `Step1/lexer.l`
Flex lexer source. Defines token patterns for every instruction mnemonic, register names, numeric literals (decimal, hex), identifiers, labels, and punctuation. Sets `yylval` for tokens that carry a value and calls `yyparse()` indirectly via `yylex()`.

### `Step1/parser.y`
Bison grammar. One rule per instruction format — recognises operand patterns and calls the appropriate `add_statement_*()` function to record the instruction. Also handles `.org`, `.equ`, `.word`, and `.byte` directives, and resolves label definitions into the symbol table.

### `Step1/lex.yy.c` / `Step1/parser_tab.c` / `Step1/parser_tab.h`
Auto-generated files — do **not** edit by hand. Regenerate with:
```bash
flex  -o Step1/lex.yy.c       Step1/lexer.l
bison -d -o Step1/parser_tab.c Step1/parser.y
```

### `Step2/code_generator.c`
Pass 2 engine. Allocates a 64 KB memory image pre-filled with `NOP` (`0xF000`), walks every `statement_t`, calls `encode_statement()` to produce a 16-bit word, and writes it at the correct byte offset. Resolves branch displacements and label references against the symbol table. Writes the final hex file.

### `Step2/code_generator.h`
Declares `generate_code()`.

### `Util/symbol_table.c` / `Util/symbol_table.h`
A hash-table-backed symbol table (djb2 hash, chaining). Stores label names mapped to their 16-bit address or `.equ` value. Key functions: `add_symbol()`, `set_symbol_value()`, `get_symbol_value()`.

### `Util/statements_list.c` / `Util/statements_list.h`
A growable array (`statement_t[]`) that records every instruction and directive in program order, together with its format, opcode, register numbers, immediate, and source line number. The location counter is updated here as statements are added.

### `Util/asm_operations.h`
Central definitions header. Contains all opcode values, `fn` codes (for RR/RI formats), condition-code values (for BR format), format character constants (`FMT_RR`, `FMT_RI`, etc.), directive opcodes (`DIR_ORG`, `DIR_EQU`, `DIR_WORD`, `DIR_BYTE`), fixed encodings (`NOP_ENCODING`, `CLI_ENCODING`, `STI_ENCODING`), and `misc` type constants (`IMMEDIATE`, `LABEL`, `LINK`).

### `Util/logger.c` / `Util/logger.h`
Lightweight logging utility. Provides `LOG_DEBUG`, `LOG_WARNING`, and `LOG_ERROR` macros that print colour-coded messages to stdout with the calling function name. An optional file log (`log.txt`) can be enabled via `#define ENABLE_FILE_LOG`.

### `Makefile`
Drives the full pipeline. Targets: `all` (default — builds everything), `Compile` (builds the assembler binary), `clean` (removes all generated files). The `SRC` variable selects the input file (default: `ASM_test.asm`).

---

## 📋 Register Table (ABI)

| Register | Alias | Usage | Saved By |
|----------|-------|-------|----------|
| r0 | zero | Always reads 0, writes ignored | — |
| r1 | a0 / v0 | Argument 0 / Return value | Caller |
| r2 | a1 | Argument 1 | Caller |
| r3 | a2 | Argument 2 | Caller |
| r4–r7 | t0–t3 | Temporaries | Caller |
| r8–r11 | s0–s3 | Saved registers | Callee |
| r12 | fp | Frame pointer | Callee |
| r13 | sp | Stack pointer | Callee |
| r14 | lr | Link register (return address) | Callee |
| r15 | gp | Global pointer (unused currently) | — |

You can use either the register number (`r1`) or the alias (`a0`) — they are interchangeable thanks to `abi.m4`. FOLLOW THIS CONVENTIONS!!

---

## 🔧 Instruction Set

FOR IMMEDIATE VALUES ALWAYS USE # (DECIMAL OR HEXADECIMAL).
LABELS DO NOT NEED # BEFORE THE NAME.
HEXADECIMAL VALUES ARE ONLY ACCEPTED WITH x.
INSTRUCTIONS NAMES ARE IN CAPITAL LETTERS.
USING PSEUDO-INSTRUCTIONS DO NOT FORGET OF () ITS NEEDED FOR MACRO EXPANTION.

### RR Format — Register-to-Register Operations
```
Encoding: op(4) rd(4) rs(4) fn(4)
```

| Instruction | Example | Description |
|-------------|---------|-------------|
| `ADD rd, rs` | `ADD r3, r1` | rd = rd + rs |
| `SUB rd, rs` | `SUB r3, r1` | rd = rd − rs |
| `AND rd, rs` | `AND r3, r1` | rd = rd AND rs |
| `XOR rd, rs` | `XOR r3, r1` | rd = rd XOR rs |
| `ADC rd, rs` | `ADC r3, r1` | rd = rd + rs + carry |
| `SBC rd, rs` | `SBC r3, r1` | rd = rd − rs − borrow |
| `CMP rd, rs` | `CMP r3, r1` | Set flags for rd − rs (no write) |
| `SRL rd, rs` | `SRL r3, r1` | Shift rd right logical by rs |
| `SRA rd, rs` | `SRA r3, r1` | Shift rd right arithmetic by rs |
| `GETCC rs` | `GETCC r4` | Read condition codes into rd |
| `SETCC rd` | `SETCC r4` | Write condition codes from rd |

---

### RI Format — Register-Immediate Operations
```
Encoding: op(4) rd(4) fn(4) imm(4)
imm can be #0-15 (decimal number) or #0-F (hex number)
```

| Instruction | Example | Description |
|-------------|---------|-------------|
| `RSUBI rd, #imm` | `RSUBI r1, #5` | rd = imm − rd |
| `ANDI rd, #imm` | `ANDI r1, #0xF` | rd = rd AND imm |
| `XORI rd, #imm` | `XORI r1, #3` | rd = rd XOR imm |
| `ADCI rd, #imm` | `ADCI r1, #1` | rd = rd + imm + carry |
| `RSBCI rd, #imm` | `RSBCI r1, #0` | rd = imm − rd − borrow |
| `RCMPI rd, #imm` | `RCMPI r1, #5` | Set flags for imm − rd |

---

### RRI (Memory) Format — Load/Store and Jump-and-Link
```
Encoding: op(4) rd(4) rs(4) imm(4)
imm can be #0-15 (decimal number) or #0-F (hex number)
```

| Instruction | Example | Description |
|-------------|---------|-------------|
| `ADDI rd, rs, #imm` | `ADDI r1, r0, #5` | rd = rs + imm |
| `JAL rd, rs, #imm` | `JAL r14, r0, #0` | rd = PC+1; PC = rs + imm |
| `LW rd, rs, #imm` | `LW r1, r13, #0` | rd = Mem[rs + imm] (word) |
| `LB rd, rs, #imm` | `LB r1, r13, #0` | rd = Mem[rs + imm] (byte) |
| `SW rd, rs, #imm` | `SW r1, r13, #0` | Mem[rs + imm] = rd (word) |
| `SB rd, rs, #imm` | `SB r1, r13, #0` | Mem[rs + imm] = rd (byte) |

---

### I12 Format — 12-bit Immediate Prefix
```
Encoding: op(4) imm(12)
```

| Instruction | Example | Description |
|-------------|---------|-------------|
| `IMM #imm` | `IMM #0x123` | Loads upper 12 bits for the next instruction |

---

### BR Format — Conditional Branches
```
Encoding: op(4) cond(4) disp(8)
disp can be #0-255 (decimal number) or #0-FF (hex number)
```

| Instruction | Example | Description |
|-------------|---------|-------------|
| `BR #disp` | `BR #4` | Unconditional branch (offset) |
| `BEQ #disp` | `BEQ #-2` | Branch if equal (Z=1) |
| `BC #disp` | `BC #2` | Branch if carry |
| `BV #disp` | `BV #2` | Branch if overflow |
| `BLT #disp` | `BLT #-4` | Branch if less than (signed) |
| `BLE #disp` | `BLE #-4` | Branch if less than or equal (signed) |
| `BLETU #disp` | `BLETU #-4` | Branch if less than or equal (unsigned) |
| `BLEU #disp` | `BLEU #-4` | Branch if less than (unsigned) |

---

### Fixed-Encoding Instructions
```
No operands needed — output a fixed hex word
```

| Instruction | Output | Description |
|-------------|--------|-------------|
| `CLI` | `B000` | Clear interrupt enable flag |
| `STI` | `C000` | Set interrupt enable flag |
| `NOP` | `F000` | No operation |

---

## 🧩 Macros (defined in `abi.m4`)

Macros are expanded by M4 before assembling. They generate multiple real instructions and are visible in `build/<basename>.asm`.

### Stack Operations

| Macro | Expands To | Description |
|-------|-----------|-------------|
| `PUSH(reg)` | `ADDI sp, sp, #-1` + `SW reg, sp, #0` | Push register onto stack |
| `POP(reg)` | `LW reg, sp, #0` + `ADDI sp, sp, #1` | Pop register from stack |
```asm
PUSH(r1)   ; save r1
POP(r1)    ; restore r1
```

### Pseudo-Instructions

| Macro | Expands To | Description |
|-------|-----------|-------------|
| `MOV(rd,rs)` | `ADDI dst, src, #0` | Copy register |
| `SUBI(rd,rs,imm)` | `ADDI rd, rs, #-imm` | Subtract immediate |
| `NEG(rd)` | `RSUBI rd, #0` | Negate register |
| `COM(rd)` | `IMM #0xFFF` + `XORI rd, #-1` | Bitwise complement |
| `SLL(rd)` | `ADD rd, rd` | Shift left logical by 1 |
| `LEA(rd,rs,imm)` | `ADDI rd, rs, #imm` | Load effective address |
| `OR(rd,rs)` | `MOV(t0, rd)` + `AND t0, rs` + `XOR rd, rs` + `XOR rd, t0` | Bitwise OR |
| `LBS(rd,rs,imm)` | `LB` + sign-extend sequence | Load byte signed |
```asm
MOV(r2, r1)      ; r2 = r1
SUBI(r3, r1, 4)  ; r3 = r1 - 4
NEG(r1)          ; r1 = -r1
SLL(r2)          ; r2 = r2 << 1
OR(r1, r2)       ; r1 = r1 | r2
```

### Jump and Call

| Macro | Expands To | Description |
|-------|-----------|-------------|
| `J(addr)` | `IMM` + `JAL r0, r0, #...` | Unconditional jump to absolute address |
| `CALL(addr)` | `IMM` + `JAL lr, r0, #...` | Call subroutine (saves return address in `lr`) |
| `RET` | `JAL r0, lr, #0` | Return from subroutine |
```asm
CALL(0x050)   ; call subroutine at address 0x050
RET           ; return from subroutine
J(0x010)      ; jump to address 0x010
```

### Interrupt Handling

| Macro | Description |
|-------|-------------|
| `ISR_PROLOGUE` | Saves s0–s3, fp, sp onto the stack |
| `ISR_EPILOGUE` | Restores sp, fp, s3–s0 from stack, then returns |
| `ISR_PRO` | Saves lr and condition codes, enables interrupts (STI) |
| `IRET` | Restores condition codes, restores lr, returns |
| `PUSH_CC` | Saves condition codes register (via t0) onto stack |
| `POP_CC` | Pops condition codes register from stack (via t0) |
```asm
; Full interrupt service routine:
ISR_PRO        ; save lr, CC, enable interrupts
; ... ISR body here ...
IRET           ; restore CC, lr, return
```

### Load Immediate (Large Values)

| Macro | Description |
|-------|-------------|
| `LI(rd, imm)` | Load a full 16-bit immediate into `rd` using `IMM` prefix + `ADDI` |
```asm
LI(r1, 0x1A3)   ; r1 = 0x1A3 (uses IMM for upper bits, ADDI for lower)
```
