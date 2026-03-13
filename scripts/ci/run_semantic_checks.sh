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

check_ast_order() {
  local file="$1"
  shift

  local last_line=0
  local pattern=""
  local next_line=""

  for pattern in "$@"; do
    next_line="$(awk -v start="$last_line" -v pat="$pattern" 'NR > start && index($0, pat) > 0 { print NR; exit }' "$file")"
    if [[ -z "$next_line" ]]; then
      return 1
    fi
    last_line="$next_line"
  done

  return 0
}

check_run_ast_order() {
  local label="$1"
  shift

  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  echo "[CHECK $TOTAL_CHECKS] $label" | tee -a "$LOG"
  echo "[CMD] check_ast_order $*" | tee -a "$LOG"
  check_ast_order "$@"
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
  "$ROOT_DIR/Semantic/semantic_ast_helpers.c" \
  "$ROOT_DIR/Semantic/semantic_pass1.c" \
  "$ROOT_DIR/Semantic/semantic_pass2.c" \
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

check_run_capture "Parser declarator+matrix smoke" \
  "$OUT_DIR/compiler_decl_refactor_ok.stdout" \
  "$OUT_DIR/compiler_decl_refactor_ok.stderr" \
  "$ROOT_DIR/compiler" \
  "$ROOT_DIR/test_files/semantic_checks/programs/declarator_pointer_matrix_ok.c"

check_run_capture "Parser for-init repeated pointer declarator smoke" \
  "$OUT_DIR/compiler_for_pointer_decl_ok.stdout" \
  "$OUT_DIR/compiler_for_pointer_decl_ok.stderr" \
  "$ROOT_DIR/compiler" \
  "$ROOT_DIR/test_files/semantic_checks/programs/for_pointer_decl_list_ok.c"

check_run_capture "Parser struct-member declarator smoke" \
  "$OUT_DIR/compiler_struct_member_decl_ok.stdout" \
  "$OUT_DIR/compiler_struct_member_decl_ok.stderr" \
  "$ROOT_DIR/compiler" \
  "$ROOT_DIR/test_files/semantic_checks/programs/struct_member_decl_ok.c"

check_run_capture "Parser function prototype declaration smoke" \
  "$OUT_DIR/compiler_function_prototype_decl_ok.stdout" \
  "$OUT_DIR/compiler_function_prototype_decl_ok.stderr" \
  "$ROOT_DIR/compiler" \
  "$ROOT_DIR/test_files/semantic_checks/programs/function_prototype_decl_ok.c"

check_run_capture "Parser recursive declaration-specifiers smoke" \
  "$OUT_DIR/compiler_declspec_recursive_ok.stdout" \
  "$OUT_DIR/compiler_declspec_recursive_ok.stderr" \
  "$ROOT_DIR/compiler" \
  "$ROOT_DIR/test_files/semantic_checks/programs/declaration_specifiers_recursive_ok.c"

check_run_capture "Parser aggregate declaration smoke" \
  "$OUT_DIR/compiler_aggregate_declaration_ok.stdout" \
  "$OUT_DIR/compiler_aggregate_declaration_ok.stderr" \
  "$ROOT_DIR/compiler" \
  "$ROOT_DIR/test_files/semantic_checks/programs/aggregate_declaration_ok.c"

check_run_capture "Parser aggregate inline declarator smoke" \
  "$OUT_DIR/compiler_aggregate_inline_decl_ok.stdout" \
  "$OUT_DIR/compiler_aggregate_inline_decl_ok.stderr" \
  "$ROOT_DIR/compiler" \
  "$ROOT_DIR/test_files/semantic_checks/programs/aggregate_inline_decl_ok.c"

check_run_capture "Parser AST cleanup block smoke" \
  "$OUT_DIR/compiler_ast_cleanup_block.stdout" \
  "$OUT_DIR/compiler_ast_cleanup_block.stderr" \
  "$ROOT_DIR/compiler" \
  "$ROOT_DIR/test_files/semantic_checks/programs/ast_cleanup_block_ok.c"

check_run_capture "Parser AST cleanup for smoke" \
  "$OUT_DIR/compiler_ast_cleanup_for.stdout" \
  "$OUT_DIR/compiler_ast_cleanup_for.stderr" \
  "$ROOT_DIR/compiler" \
  "$ROOT_DIR/test_files/semantic_checks/programs/ast_cleanup_for_ok.c"

check_run_capture "Parser AST cleanup member smoke" \
  "$OUT_DIR/compiler_ast_cleanup_member.stdout" \
  "$OUT_DIR/compiler_ast_cleanup_member.stderr" \
  "$ROOT_DIR/compiler" \
  "$ROOT_DIR/test_files/semantic_checks/programs/ast_cleanup_member_ok.c"

check_run_capture "Parser C11 expression ladder smoke" \
  "$OUT_DIR/compiler_expression_ladder_ok.stdout" \
  "$OUT_DIR/compiler_expression_ladder_ok.stderr" \
  "$ROOT_DIR/compiler" \
  "$ROOT_DIR/test_files/semantic_checks/programs/expression_ladder_ok.c"

check_run "Declarator smoke AST contains repeated pointer decl" \
  grep -q "VAR_DECL (q)" "$OUT_DIR/compiler_decl_refactor_ok.stdout"

check_run "Declarator smoke AST contains pointer node" \
  grep -q "POINTER" "$OUT_DIR/compiler_decl_refactor_ok.stdout"

check_run "Declarator smoke AST contains multidim array decl" \
  grep -q "ARRAY_DECL (matrix)" "$OUT_DIR/compiler_decl_refactor_ok.stdout"

check_run "For-init smoke AST contains repeated pointer decl" \
  grep -q "VAR_DECL (q)" "$OUT_DIR/compiler_for_pointer_decl_ok.stdout"

check_run "Struct-member smoke AST contains pointer member" \
  grep -q "STRUCT_MEMBER (next)" "$OUT_DIR/compiler_struct_member_decl_ok.stdout"

check_run "Struct-member smoke AST contains multidim array member" \
  grep -q "ARRAY_DECL (dims)" "$OUT_DIR/compiler_struct_member_decl_ok.stdout"

check_run "Function prototype declaration smoke contains function node" \
  grep -q "FUNCTION (sum)" "$OUT_DIR/compiler_function_prototype_decl_ok.stdout"

check_run "Recursive declaration-specifiers smoke contains implicit signed-int declaration" \
  grep -q "VAR_DECL (counter)" "$OUT_DIR/compiler_declspec_recursive_ok.stdout"

check_run "Recursive declaration-specifiers smoke contains long-int split specifiers" \
  grep -q "VAR_DECL (total)" "$OUT_DIR/compiler_declspec_recursive_ok.stdout"

check_run "Recursive declaration-specifiers smoke contains long-double split specifiers" \
  grep -q "VAR_DECL (weight)" "$OUT_DIR/compiler_declspec_recursive_ok.stdout"

check_run "Aggregate declaration smoke contains struct declaration node" \
  grep -q "STRUCT_DECL (Point)" "$OUT_DIR/compiler_aggregate_declaration_ok.stdout"

check_run "Aggregate declaration smoke contains union declaration node" \
  grep -q "UNION_DECL (Data)" "$OUT_DIR/compiler_aggregate_declaration_ok.stdout"

check_run "Aggregate declaration smoke contains enum declaration node" \
  grep -q "ENUM_DECL (Color)" "$OUT_DIR/compiler_aggregate_declaration_ok.stdout"

check_run "Aggregate inline declarator smoke contains variable declaration" \
  grep -q "VAR_DECL (point)" "$OUT_DIR/compiler_aggregate_inline_decl_ok.stdout"

check_run "Aggregate inline declarator smoke preserves embedded struct declaration" \
  grep -q "STRUCT_DECL (Point)" "$OUT_DIR/compiler_aggregate_inline_decl_ok.stdout"

check_run "Aggregate inline declarator smoke preserves embedded union declaration" \
  grep -q "UNION_DECL (Data)" "$OUT_DIR/compiler_aggregate_inline_decl_ok.stdout"

check_run "Aggregate inline declarator smoke preserves embedded enum declaration" \
  grep -q "ENUM_DECL (Color)" "$OUT_DIR/compiler_aggregate_inline_decl_ok.stdout"

check_run "AST cleanup smoke contains translation unit root" \
  grep -q "TRANSLATION_UNIT" "$OUT_DIR/compiler_ast_cleanup_block.stdout"

check_run "AST cleanup smoke contains block node" \
  grep -q "BLOCK" "$OUT_DIR/compiler_ast_cleanup_block.stdout"

check_run "AST cleanup smoke contains for node" \
  grep -q "FOR" "$OUT_DIR/compiler_ast_cleanup_for.stdout"

check_run "AST cleanup smoke contains member access node" \
  grep -q "MEMBER_ACCESS" "$OUT_DIR/compiler_ast_cleanup_member.stdout"

check_run "AST cleanup smoke contains pointer member access node" \
  grep -q "PTR_MEMBER_ACCESS" "$OUT_DIR/compiler_ast_cleanup_member.stdout"

check_run_ast_order "Expression ladder smoke contains nested assignment" \
  "$OUT_DIR/compiler_expression_ladder_ok.stdout" \
  "OPERATOR (=)" \
  "IDENTIFIER (x)" \
  "OPERATOR (=)"

check_run_ast_order "Expression ladder smoke keeps additive under shift" \
  "$OUT_DIR/compiler_expression_ladder_ok.stdout" \
  "OPERATOR (<<)" \
  "IDENTIFIER (a)" \
  "OPERATOR (+)"

check_run_ast_order "Expression ladder smoke keeps equality under bitwise and" \
  "$OUT_DIR/compiler_expression_ladder_ok.stdout" \
  "OPERATOR (&)" \
  "IDENTIFIER (a)" \
  "OPERATOR (==)"

check_run_ast_order "Expression ladder smoke keeps bitwise not under multiply" \
  "$OUT_DIR/compiler_expression_ladder_ok.stdout" \
  "OPERATOR (*)" \
  "OPERATOR (~)"

check_run "Expression ladder smoke contains comma expression" \
  grep -q "OPERATOR (,)" "$OUT_DIR/compiler_expression_ladder_ok.stdout"

check_run_ast_order "Expression ladder smoke supports sizeof unary-expression" \
  "$OUT_DIR/compiler_expression_ladder_ok.stdout" \
  "OPERATOR (sizeof)" \
  "IDENTIFIER (x)"

check_run_ast_order "Expression ladder smoke preserves postfix array over member access" \
  "$OUT_DIR/compiler_expression_ladder_ok.stdout" \
  "ARRAY_ACCESS" \
  "PTR_MEMBER_ACCESS"

check_run_ast_order "Expression ladder smoke preserves assignment-expression argument" \
  "$OUT_DIR/compiler_expression_ladder_ok.stdout" \
  "FUNC_CALL (sum)" \
  "OPERATOR (=)"

check_run_expect_fail_capture "Parser program (expected fail)" \
  "$OUT_DIR/compiler_syntax_fail.stdout" \
  "$OUT_DIR/compiler_syntax_fail.stderr" \
  "$ROOT_DIR/compiler" \
  "$ROOT_DIR/test_files/semantic_checks/programs/syntax_fail.c"

check_run_expect_fail_capture "Preprocessor directive program (expected fail)" \
  "$OUT_DIR/compiler_preprocessor_fail.stdout" \
  "$OUT_DIR/compiler_preprocessor_fail.stderr" \
  "$ROOT_DIR/compiler" \
  "$ROOT_DIR/test_files/semantic_checks/programs/preprocessor_directive_fail.c"

# 4.1) Semantic pass fixture checks (expected SEM codes).
check_run "Semantic pass examples" \
  bash "$ROOT_DIR/scripts/ci/run_semantic_pass_checks.sh" "$OUT_DIR"

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
  "$ROOT_DIR/Semantic/semantic_ast_helpers.c" \
  "$ROOT_DIR/Semantic/semantic_pass1.c" \
  "$ROOT_DIR/Semantic/semantic_pass2.c" \
  "$ROOT_DIR/Semantic/semantic.c" \
  "$ROOT_DIR/Semantic/symbol.c" \
  "$ROOT_DIR/Semantic/type.c" \
  "$ROOT_DIR/Semantic/diagnostics.c"
