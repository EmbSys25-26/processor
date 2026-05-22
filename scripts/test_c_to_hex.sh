#!/usr/bin/env bash
# =============================================================================
# test_c_to_hex.sh — sweep test_files/**/*.c through the full backend pipeline
# (compile -> link runtime -> m4 -> assemble) and report a pass-rate.
#
# Long branches are handled by the compiler's branch-relaxation pass (see
# CodeGen/codegen.c §8.5), so every program in the corpus should assemble
# cleanly. Any failure here is a real regression.
#
# Exit codes:
#   0  every program assembled.
#   1  any failure.
# =============================================================================
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRIVER="$ROOT/scripts/build_c_to_hex.sh"

if [[ ! -x "$DRIVER" ]]; then
    echo "ERROR: $DRIVER not executable" >&2
    exit 1
fi

cd "$ROOT"
pass=0
fail=0
failed_list=()

for f in test_files/RegisterAllocation/*.c test_files/IR_checks/*.c; do
    # Programs prefixed test_unsupported_ are designed to be rejected at
    # compile time (see scripts/test_compile_all.sh — expect_fail/IR001 mode).
    # They cannot produce hex by construction, so skip them in this sweep.
    if [[ "$(basename "$f")" == test_unsupported_* ]]; then
        continue
    fi

    log=$(mktemp)
    if "$DRIVER" "$f" >"$log" 2>&1; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        failed_list+=("$f")
        echo "[FAIL] $f"
        grep -E "ERROR|out of range|Erro|fail" "$log" | head -3 | sed 's/^/   /'
    fi
    rm -f "$log"
done

total=$((pass + fail))
echo ""
echo "================================================================"
echo "C-to-hex pipeline: $pass / $total assembled"

if [[ $fail -gt 0 ]]; then
    echo "Failed cases:"
    printf '   %s\n' "${failed_list[@]}"
    exit 1
fi
exit 0
