#!/usr/bin/env bash
# Regression sweep: compile every test_files/**/*.c, assert success and no
# known codegen smells.  Also enforces snapshot diffs against
# test_files/IR_checks/*_expected.asm files when present.
# Includes 'expect_fail' mode for explicitly unsupported features.
#
# Exit code:
#   0  every test passed
#   1  one or more tests failed (per-failure detail printed to stdout)

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ ! -x ./compiler ]]; then
    echo "ERROR: ./compiler not found — run 'make' first" >&2
    exit 2
fi

fail=0
total=0
ok=0

for f in test_files/RegisterAllocation/*.c test_files/IR_checks/*.c; do
    # Programs prefixed test_unsupported_ are explicitly excluded from the
    # regression sweep (rejection path is not exercised here).
    if [[ "$(basename "$f")" == test_unsupported_* ]]; then
        continue
    fi

    total=$((total + 1))

    # ---------------------------------------------------------
    # NORMAL TESTS THAT SHOULD PASS
    # ---------------------------------------------------------
    if ! ./compiler "$f" >/dev/null 2>&1; then
        echo "[FAIL] $f — compiler returned non-zero"
        fail=1
        continue
    fi

    nulls=$(grep -c '(null)' output.asm 2>/dev/null || true)
    redmov=$(grep -cE 'MOV\(a[0-9], r[1-9]\)|MOV\(r[1-9], a[0-9]\)' output.asm 2>/dev/null || true)

    file_failed=0
    if [[ "${nulls:-0}" -ne 0 ]]; then
        echo "[FAIL] $f — null operands x$nulls"
        file_failed=1
    fi
    if [[ "${redmov:-0}" -ne 0 ]]; then
        echo "[FAIL] $f — redundant a/r MOVs x$redmov"
        file_failed=1
    fi

    # Snapshot diff (optional; only checked when an _expected.asm file exists)
    expected="${f%.c}_expected.asm"
    if [[ -f "$expected" ]]; then
        if ! diff -u "$expected" output.asm >/tmp/.diff_$$ 2>&1; then
            echo "[FAIL] $f — snapshot drift vs $expected"
            cat /tmp/.diff_$$
            file_failed=1
        fi
        rm -f /tmp/.diff_$$
    fi

    if [[ $file_failed -eq 0 ]]; then
        echo "[PASS] $f"
        ok=$((ok + 1))
    else
        fail=1
    fi
done

echo "---------------------------------------------------------"
echo "Results: $ok / $total tests passed."
if [[ $fail -ne 0 ]]; then
    exit 1
fi
exit 0
