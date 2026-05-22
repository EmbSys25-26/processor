#!/usr/bin/env bash
# =============================================================================
# verify_all.sh — single entry point for CI.
#
# Builds the compiler and the assembler, then runs the three verification
# suites in order:
#
#   A. Assembler unit tests   (assembler/tests/run_tests.sh)
#   B. End-to-end C -> hex    (scripts/test_c_to_hex.sh)
#   C. Compiler regression    (scripts/test_compile_all.sh)
#
# Exit codes:
#   0  every suite passed.
#   1  one or more suites failed (the script keeps going so the log captures
#      every failure rather than just the first).
# =============================================================================
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

# ── Build phase ──────────────────────────────────────────────────────────────
echo "::group::Build compiler"
make
echo "::endgroup::"

echo "::group::Build assembler"
make -C assembler
echo "::endgroup::"

# ── Verification phase ───────────────────────────────────────────────────────
fail=0

echo "::group::A. Assembler unit tests"
if ! assembler/tests/run_tests.sh; then
    echo "::error::Assembler unit tests failed"
    fail=1
fi
echo "::endgroup::"

echo "::group::B. End-to-end C -> hex sweep"
if ! scripts/test_c_to_hex.sh; then
    echo "::error::End-to-end C -> hex pipeline failed"
    fail=1
fi
echo "::endgroup::"

echo "::group::C. Compiler regression"
if ! scripts/test_compile_all.sh; then
    echo "::error::Compiler regression failed"
    fail=1
fi
echo "::endgroup::"

echo ""
if [[ $fail -eq 0 ]]; then
    echo "All three verification suites passed."
fi
exit $fail
