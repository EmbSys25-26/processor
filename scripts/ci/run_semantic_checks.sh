#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT_DIR="${1:-$ROOT_DIR/.ci_artifacts/semantic_checks}"
mkdir -p "$OUT_DIR"

LOG="$OUT_DIR/semantic_checks.log"
: > "$LOG"

TOTAL_CHECKS=0
PASSED_CHECKS=0

ASAN_OPTIONS_VALUE="halt_on_error=1"
if [[ "$(uname -s)" != "Darwin" ]]; then
  ASAN_OPTIONS_VALUE="detect_leaks=1:$ASAN_OPTIONS_VALUE"
fi

on_exit() {
  local rc=$?
  local failed_checks=$((TOTAL_CHECKS - PASSED_CHECKS))
  local status="FAIL"

  if [[ $rc -eq 0 ]]; then
    status="PASS"
  fi

  echo "[SUMMARY] checks: total=$TOTAL_CHECKS passed=$PASSED_CHECKS failed=$failed_checks" | tee -a "$LOG"
  echo "$status semantic_checks" | tee -a "$LOG"
}

trap on_exit EXIT

run() {
  echo "[CMD] $*" | tee -a "$LOG"
  "$@" 2>&1 | tee -a "$LOG"
}

run_capture() {
  local stdout_file="$1"
  local stderr_file="$2"
  shift 2

  echo "[CMD] $*" | tee -a "$LOG"
  "$@" >"$stdout_file" 2>"$stderr_file"
  cat "$stdout_file" >>"$LOG"
  cat "$stderr_file" >>"$LOG"
}

run_expect_fail_capture() {
  local stdout_file="$1"
  local stderr_file="$2"
  shift 2

  local rc=0
  echo "[CMD-EXPECT-FAIL] $*" | tee -a "$LOG"
  set +e
  "$@" >"$stdout_file" 2>"$stderr_file"
  rc=$?
  set -e
  cat "$stdout_file" >>"$LOG"
  cat "$stderr_file" >>"$LOG"
  if [[ $rc -eq 0 ]]; then
    echo "[FAIL] command unexpectedly succeeded" | tee -a "$LOG"
    return 1
  fi
}

check_run() {
  local label="$1"
  shift

  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  echo "[CHECK $TOTAL_CHECKS] $label" | tee -a "$LOG"
  run "$@"
  PASSED_CHECKS=$((PASSED_CHECKS + 1))
}

check_run_capture() {
  local label="$1"
  shift

  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  echo "[CHECK $TOTAL_CHECKS] $label" | tee -a "$LOG"
  run_capture "$@"
  PASSED_CHECKS=$((PASSED_CHECKS + 1))
}

check_run_expect_fail_capture() {
  local label="$1"
  shift

  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  echo "[CHECK $TOTAL_CHECKS] $label" | tee -a "$LOG"
  run_expect_fail_capture "$@"
  PASSED_CHECKS=$((PASSED_CHECKS + 1))
}

compile_and_run_test() {
  local mode="$1"
  local test_name="$2"
  shift 2

  local exe="$OUT_DIR/$test_name"
  local -a cflags=(
    -std=c11
    -Wall
    -Wextra
    -Wpedantic
    -Werror
    -I"$ROOT_DIR"
    -I"$ROOT_DIR/Semantic"
    -I"$ROOT_DIR/Parser"
  )

  if [[ "$mode" == "san" ]]; then
    exe="${exe}_san"
    cflags+=(-O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer)
  fi

  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  echo "[CHECK $TOTAL_CHECKS] API test ($mode): $test_name" | tee -a "$LOG"

  run cc "${cflags[@]}" "$@" -o "$exe"

  if [[ "$mode" == "san" ]]; then
    run env ASAN_OPTIONS="$ASAN_OPTIONS_VALUE" UBSAN_OPTIONS=halt_on_error=1 "$exe"
  else
    run "$exe"
  fi

  PASSED_CHECKS=$((PASSED_CHECKS + 1))
}

echo "[INFO] Step-0 semantic API checks CI" | tee -a "$LOG"

# Local compatibility for macOS setups where system bison is too old.
if [[ -x /opt/homebrew/opt/bison/bin/bison ]]; then
  export PATH="/opt/homebrew/opt/bison/bin:$PATH"
fi

# 1) Header compile smoke (public API surface).
check_run "Header compile smoke" cc -std=c11 -Wall -Wextra -Wpedantic -Werror \
  -I"$ROOT_DIR" -I"$ROOT_DIR/Semantic" -I"$ROOT_DIR/Parser" \
  -c "$ROOT_DIR/test_files/semantic_checks/test_headers_compile.c" \
  -o "$OUT_DIR/test_headers_compile.o"

# 2) API unit checks (regular build).
compile_and_run_test regular test_type_api \
  "$ROOT_DIR/test_files/semantic_checks/test_type_api.c" \
  "$ROOT_DIR/Semantic/type.c"

compile_and_run_test regular test_symbol_api \
  "$ROOT_DIR/test_files/semantic_checks/test_symbol_api.c" \
  "$ROOT_DIR/Semantic/symbol.c" \
  "$ROOT_DIR/Semantic/type.c"

compile_and_run_test regular test_diagnostics_api \
  "$ROOT_DIR/test_files/semantic_checks/test_diagnostics_api.c" \
  "$ROOT_DIR/Semantic/diagnostics.c"

compile_and_run_test regular test_semantic_api \
  "$ROOT_DIR/test_files/semantic_checks/test_semantic_api.c" \
  "$ROOT_DIR/Semantic/semantic.c" \
  "$ROOT_DIR/Semantic/symbol.c" \
  "$ROOT_DIR/Semantic/type.c" \
  "$ROOT_DIR/Semantic/diagnostics.c"

# 3) Full frontend build smoke (lexer + parser + semantic object wiring).
run make -C "$ROOT_DIR" clean
check_run "Frontend build smoke" make -C "$ROOT_DIR"

# 4) Parser -> semantic contract smoke.
check_run_capture "Parser->semantic program (ok)" \
  "$OUT_DIR/compiler_minimal_ok.stdout" \
  "$OUT_DIR/compiler_minimal_ok.stderr" \
  "$ROOT_DIR/compiler" \
  "$ROOT_DIR/test_files/semantic_checks/programs/minimal_ok.c"

check_run_expect_fail_capture "Parser program (expected fail)" \
  "$OUT_DIR/compiler_syntax_fail.stdout" \
  "$OUT_DIR/compiler_syntax_fail.stderr" \
  "$ROOT_DIR/compiler" \
  "$ROOT_DIR/test_files/semantic_checks/programs/syntax_fail.c"

# 5) Memory safety checks with sanitizers.
compile_and_run_test san test_type_api \
  "$ROOT_DIR/test_files/semantic_checks/test_type_api.c" \
  "$ROOT_DIR/Semantic/type.c"

compile_and_run_test san test_symbol_api \
  "$ROOT_DIR/test_files/semantic_checks/test_symbol_api.c" \
  "$ROOT_DIR/Semantic/symbol.c" \
  "$ROOT_DIR/Semantic/type.c"

compile_and_run_test san test_diagnostics_api \
  "$ROOT_DIR/test_files/semantic_checks/test_diagnostics_api.c" \
  "$ROOT_DIR/Semantic/diagnostics.c"

compile_and_run_test san test_semantic_api \
  "$ROOT_DIR/test_files/semantic_checks/test_semantic_api.c" \
  "$ROOT_DIR/Semantic/semantic.c" \
  "$ROOT_DIR/Semantic/symbol.c" \
  "$ROOT_DIR/Semantic/type.c" \
  "$ROOT_DIR/Semantic/diagnostics.c"
