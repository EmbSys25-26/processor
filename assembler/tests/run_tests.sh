#!/usr/bin/env bash
# =============================================================================
# Assembler regression runner.
#
# For each tests/cases/*.asm:
#   1. Expand with m4 (abi.m4 + the test source) -> tests/build/<base>.asm
#   2. Run the assembler -> tests/build/<base>.hex
#   3. Diff against tests/snapshots/<base>.hex.expected
#
# Negative tests (file name starts with NN_*** but has no snapshot AND the
# header tag "; NEGATIVE" in line 1..6) must produce a non-zero exit code from
# the assembler; that's recorded as PASS.
#
# Refresh mode:   ./run_tests.sh --update     (writes/overwrites snapshots,
#                                              reports any case that produced
#                                              no output as FAIL)
# Verbose mode:   ./run_tests.sh -v
# =============================================================================
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASES="$ROOT/tests/cases"
SNAPS="$ROOT/tests/snapshots"
BUILD="$ROOT/tests/build"
ASM="$ROOT/assembler"
M4_INC="$ROOT/Step1/abi.m4"

UPDATE=0
VERBOSE=0
for arg in "$@"; do
    case "$arg" in
        --update) UPDATE=1 ;;
        -v|--verbose) VERBOSE=1 ;;
        -h|--help)
            sed -n '2,18p' "$0"
            exit 0 ;;
    esac
done

if [[ ! -x "$ASM" ]]; then
    echo "ERROR: $ASM not found — run 'make' in $(dirname "$ASM") first" >&2
    exit 2
fi

mkdir -p "$BUILD" "$SNAPS"

pass=0
fail=0
total=0
failed_cases=()

is_negative_case() {
    head -n 8 "$1" | grep -q "NEGATIVE"
}

for src in "$CASES"/*.asm; do
    [ -f "$src" ] || continue
    total=$((total + 1))
    base="$(basename "$src" .asm)"
    pre="$BUILD/${base}.asm"
    hex="$BUILD/${base}.hex"
    snap="$SNAPS/${base}.hex.expected"

    # --- m4 expand ------------------------------------------------------------
    # Run m4 from $ROOT so that any include() paths in cases (e.g. the runtime
    # test) resolve relative to assembler/ regardless of where this script
    # itself was invoked from.
    if ! (cd "$ROOT" && m4 "$M4_INC" "$src") > "$pre" 2>"$BUILD/${base}.m4.log"; then
        echo "[FAIL] $base : m4 expansion failed"
        sed 's/^/   /' "$BUILD/${base}.m4.log" | head -5
        failed_cases+=("$base")
        fail=$((fail + 1))
        continue
    fi

    # --- assemble -------------------------------------------------------------
    (cd "$BUILD" && "$ASM" "$pre" >"${base}.asm.log" 2>&1)
    rc=$?
    if [[ -f "$BUILD/bleh.hex" ]]; then
        mv "$BUILD/bleh.hex" "$hex"
    fi

    # --- negative case branch -------------------------------------------------
    if is_negative_case "$src"; then
        if [[ $rc -ne 0 ]]; then
            echo "[PASS] $base : negative case correctly rejected (rc=$rc)"
            pass=$((pass + 1))
        else
            echo "[FAIL] $base : negative case unexpectedly succeeded (rc=0)"
            failed_cases+=("$base")
            fail=$((fail + 1))
        fi
        continue
    fi

    # --- positive case: must have produced a hex ------------------------------
    if [[ $rc -ne 0 ]] || [[ ! -f "$hex" ]]; then
        echo "[FAIL] $base : assembler exited rc=$rc, no hex produced"
        [[ $VERBOSE -eq 1 ]] && sed 's/^/   /' "$BUILD/${base}.asm.log" | head -10
        failed_cases+=("$base")
        fail=$((fail + 1))
        continue
    fi

    # --- snapshot compare / refresh ------------------------------------------
    if [[ $UPDATE -eq 1 ]]; then
        cp "$hex" "$snap"
        echo "[UPD ] $base : snapshot refreshed ($(wc -l < "$hex" | tr -d ' ') words)"
        pass=$((pass + 1))
        continue
    fi

    if [[ ! -f "$snap" ]]; then
        echo "[FAIL] $base : no snapshot at $snap — run with --update to create"
        failed_cases+=("$base")
        fail=$((fail + 1))
        continue
    fi

    if diff -u "$snap" "$hex" >"$BUILD/${base}.diff"; then
        echo "[PASS] $base"
        pass=$((pass + 1))
    else
        echo "[FAIL] $base : hex snapshot drift"
        sed 's/^/   /' "$BUILD/${base}.diff" | head -20
        failed_cases+=("$base")
        fail=$((fail + 1))
    fi
done

echo ""
echo "================================================================"
echo "Assembler tests: $pass / $total passed"
if [[ $fail -gt 0 ]]; then
    echo "Failed cases:"
    printf '    %s\n' "${failed_cases[@]}"
    exit 1
fi
exit 0
