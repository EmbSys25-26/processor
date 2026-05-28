#!/usr/bin/env bash
# =============================================================================
# run.sh — build and behaviourally simulate every C exercise.
#
# Layout assumed (resolved relative to this script):
#   ../../compiler/exercises/*.c             < source programs
#   ../../compiler/exercises/EXPECTED.txt    < manifest of expected a0 values
#   ../../compiler/scripts/build_c_e2e.sh    < .c → hi/lo hex pair
#   ../srcs/*.v                              < SoC RTL (referenced by srcs.prj)
#   ./tb_c_e2e.v                             < generic execution testbench
#   ./srcs.prj                               < xvlog project file
#
# Usage:
#   ./run.sh                run the whole bundle, one line per exercise
#   ./run.sh solE013        run only the named exercise
#   ./run.sh --clean        wipe the build dir and xsim scratch
#   ./run.sh --help         show this header
#
# Requires Xilinx xsim 2025+ on PATH (source settings64.sh).
# Build artefacts go to $EXERCISES_BUILD (default /tmp/exercises_build).
# =============================================================================
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIPELINE_ROOT="$(cd "$HERE/.." && pwd)"
COMPILER_ROOT="$(cd "$PIPELINE_ROOT/../compiler" && pwd)"
BUILD="${EXERCISES_BUILD:-/tmp/exercises_build}"

EXPECTED="$COMPILER_ROOT/exercises/EXPECTED.txt"
BUILDER="$COMPILER_ROOT/scripts/build_c_e2e.sh"

filter=""
case "${1:-}" in
    --clean)
        rm -rf "$BUILD" "$HERE/xsim.dir" "$HERE/.Xil"
        rm -f  "$HERE"/xvlog.log    "$HERE"/xvlog.pb \
               "$HERE"/xelab.log    "$HERE"/xelab.pb \
               "$HERE"/xsim.log     "$HERE"/xsim.jou \
               "$HERE"/xsim_*.backup.log "$HERE"/xsim_*.backup.jou \
               "$HERE"/webtalk*
        echo "cleaned $BUILD and xsim scratch under $HERE"
        exit 0 ;;
    --help|-h)
        sed -n '2,20p' "$0"; exit 0 ;;
    "" ) ;;
    * )
        filter="$1" ;;
esac

[[ -x "$BUILDER"  ]] || { echo "ERROR: missing $BUILDER (run 'make' in compiler/)" >&2; exit 2; }
[[ -f "$EXPECTED" ]] || { echo "ERROR: missing $EXPECTED" >&2; exit 2; }
command -v xvlog >/dev/null || { echo "ERROR: xvlog not on PATH — source Vivado settings64.sh" >&2; exit 2; }

mkdir -p "$BUILD"
cd "$HERE"

PASS=0
FAIL=0
FAILED=()

printf "%-22s  %-10s  %s\n" "exercise" "expect_a0" "outcome"
printf "%-22s  %-10s  %s\n" "----------------------" "----------" "-------------------------"

while IFS='|' read -r raw_name raw_src raw_expect _rest; do
    name=$(echo "$raw_name"   | tr -d ' ')
    src=$(echo  "$raw_src"    | tr -d ' ')
    expect=$(echo "$raw_expect" | tr -d ' ')
    [[ -z "$name" || "${name:0:1}" == "#" ]] && continue
    [[ -n "$filter" && "$name" != "$filter" ]] && continue

    src_path="$COMPILER_ROOT/exercises/$src"
    printf "%-22s  0x%-8s  " "$name" "$expect"

    if ! "$BUILDER" "$src_path" --out-dir "$BUILD" --out-stem "$name" \
            >/tmp/build_${name}.log 2>&1; then
        echo "BUILD FAIL  (see /tmp/build_${name}.log)"
        FAIL=$((FAIL+1)); FAILED+=("$name (build)"); continue
    fi

    snap="tb_x_$name"
    if ! xvlog -prj srcs.prj \
            -d GHR_W=6 -d BPU_ENTRIES=64 -d BPU_IDX_W=6 -d BPU_TAG_W=9 \
            -d "BROM_MEM_LO_PATH=\"$BUILD/${name}_lo.hex\"" \
            -d "BROM_MEM_HI_PATH=\"$BUILD/${name}_hi.hex\"" \
            -d "EXPECT_A0=16'h${expect}" \
            -d "TEST_NAME=\"$name\"" \
            -d "MAX_CYC=500000" >/tmp/xvlog_${name}.log 2>&1; then
        echo "XVLOG FAIL  (see /tmp/xvlog_${name}.log)"
        FAIL=$((FAIL+1)); FAILED+=("$name (xvlog)"); continue
    fi

    if ! xelab -s "$snap" tb_c_e2e >/tmp/xelab_${name}.log 2>&1; then
        echo "XELAB FAIL  (see /tmp/xelab_${name}.log)"
        FAIL=$((FAIL+1)); FAILED+=("$name (xelab)"); continue
    fi

    result=$(xsim "$snap" -R 2>&1 | grep -E "E2E |PASS |FAIL |TIMEOUT|WALL")
    if echo "$result" | grep -q "^PASS "; then
        line=$(echo "$result" | grep "^E2E ")
        cycles=$(echo "$line" | grep -oE "cyc=[0-9]+" | cut -d= -f2)
        a0=$(echo "$line" | grep -oE "a0=0x[0-9a-fA-F]+" | head -1 | cut -d= -f2)
        printf "PASS  a0=%s  cycles=%s\n" "$a0" "$cycles"
        PASS=$((PASS+1))
    else
        first=$(echo "$result" | head -1)
        printf "FAIL  %s\n" "$first"
        FAIL=$((FAIL+1)); FAILED+=("$name")
    fi
done < "$EXPECTED"

echo "----------------------------------------------------------------"
echo "RESULT: $PASS passed, $FAIL failed"
if [[ $FAIL -gt 0 ]]; then
    printf '   x %s\n' "${FAILED[@]}"
    exit 1
fi
exit 0
