#!/usr/bin/env bash
# =============================================================================
# build_c_e2e.sh — single end-to-end builder: .c -> .hex (hi/lo pair).
#
# Stages:
#   .c  --[compiler]-->  .asm         (codegen also emits boot section:
#       --[+ runtime]-->  .full.asm     ISR IRET stubs + reset-vector stub)
#       --[m4 expand]-->  .pre.asm
#       --[assembler]-->  .hex (16-bit BE per line)
#       --[byte split]-->  _hi.hex, _lo.hex
#
# Usage:
#   scripts/build_c_e2e.sh <input.c> [--out-dir DIR] [--out-stem STEM]
#                                    [--no-runtime]
#
# Produces in <out-dir>/ (default build_c2hex/):
#   <stem>.asm        compiler output, unmodified
#   <stem>.full.asm   compiler output + runtime concatenated
#   <stem>.pre.asm    after m4 macro expansion
#   <stem>.hex        16-bit big-endian hex words, one per line
#   <stem>_hi.hex     high byte
#   <stem>_lo.hex     low byte
# where <stem> defaults to the input basename without .c, or the value of
# --out-stem if given.
#
# Exit codes:
#   0  pipeline succeeded
#   1  one of the stages reported an error
#   2  arguments or environment invalid
# =============================================================================
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPILER="$ROOT/compiler"
ASM_DIR="$ROOT/assembler"
ASM_BIN="$ASM_DIR/assembler"
ABI_M4="$ASM_DIR/Step1/abi.m4"
RUNTIME_ASM="$ROOT/runtime/runtime.asm"

OUT_DIR="$ROOT/build_c2hex"
USE_RUNTIME=1
OUT_STEM=""
INPUT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --out-dir)    OUT_DIR="$2"; shift 2 ;;
        --out-stem)   OUT_STEM="$2"; shift 2 ;;
        --no-runtime) USE_RUNTIME=0; shift ;;
        -h|--help)
            sed -n '2,28p' "$0"
            exit 0 ;;
        *)
            if [[ -z "$INPUT" ]]; then
                INPUT="$1"
            else
                echo "ERROR: unexpected argument '$1'" >&2
                exit 2
            fi
            shift ;;
    esac
done

if [[ -z "$INPUT" ]]; then
    echo "Usage: $0 <input.c> [--out-dir DIR] [--out-stem STEM] [--no-runtime]" >&2
    exit 2
fi

if [[ ! -f "$INPUT" ]]; then
    echo "ERROR: input file '$INPUT' not found" >&2
    exit 2
fi

for tool in m4 awk; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "ERROR: required tool '$tool' not on PATH" >&2
        exit 2
    fi
done

if [[ ! -x "$COMPILER" ]]; then
    echo "ERROR: compiler binary not found at $COMPILER — run 'make' at repo root" >&2
    exit 2
fi

if [[ ! -x "$ASM_BIN" ]]; then
    echo "ERROR: assembler binary not found at $ASM_BIN — run 'make' in assembler/" >&2
    exit 2
fi

if [[ $USE_RUNTIME -eq 1 ]] && [[ ! -f "$RUNTIME_ASM" ]]; then
    echo "ERROR: runtime.asm not found at $RUNTIME_ASM (use --no-runtime to skip)" >&2
    exit 2
fi

mkdir -p "$OUT_DIR"
STEM="${OUT_STEM:-$(basename "$INPUT" .c)}"

ASM_OUT="$OUT_DIR/${STEM}.asm"
FULL_ASM="$OUT_DIR/${STEM}.full.asm"
PRE_ASM="$OUT_DIR/${STEM}.pre.asm"
HEX="$OUT_DIR/${STEM}.hex"
HI_HEX="$OUT_DIR/${STEM}_hi.hex"
LO_HEX="$OUT_DIR/${STEM}_lo.hex"

echo "[1/5] compile  : $INPUT"
(cd "$ROOT" && "$COMPILER" "$INPUT") || {
    echo "  -> compiler failed" >&2
    exit 1
}
cp "$ROOT/output.asm" "$ASM_OUT"

echo "[2/5] link rt  : $([[ $USE_RUNTIME -eq 1 ]] && echo yes || echo no)"
if [[ $USE_RUNTIME -eq 1 ]]; then
    {
        cat "$ASM_OUT"
        echo ""
        echo "; ============================================================"
        echo "; Runtime library (concatenated by scripts/build_c_e2e.sh)"
        echo "; ============================================================"
        cat "$RUNTIME_ASM"
    } > "$FULL_ASM"
else
    cp "$ASM_OUT" "$FULL_ASM"
fi

echo "[3/5] m4 expand"
m4 "$ABI_M4" "$FULL_ASM" > "$PRE_ASM" || {
    echo "  -> m4 failed" >&2
    exit 1
}

echo "[4/5] assemble : $PRE_ASM"
(cd "$OUT_DIR" && "$ASM_BIN" "$PRE_ASM") || {
    echo "  -> assembler reported an error" >&2
    exit 1
}
mv "$OUT_DIR/bleh.hex" "$HEX"

echo "[5/5] hi/lo split"
awk '{ print substr($1, 1, 2) }' "$HEX" > "$HI_HEX"
awk '{ print substr($1, 3, 2) }' "$HEX" > "$LO_HEX"

words=$(wc -l < "$HEX" | tr -d ' ')
echo ""
echo "================================================================"
echo "OK  $INPUT  ->  $HEX  ($words words)"
echo "    hi: $HI_HEX"
echo "    lo: $LO_HEX"
