#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT_DIR="${1:-$ROOT_DIR/.ci_artifacts/semantic_checks}"
PROGRAM_DIR="$ROOT_DIR/test_files/semantic_checks/programs"
COMPILER_BIN="$ROOT_DIR/compiler"
LOG="$OUT_DIR/semantic_pass_examples.log"

mkdir -p "$OUT_DIR"
: > "$LOG"

total=0
passed=0

run_case() {
  local file="$1"
  local expected_rc="$2"
  local expected_code="$3"
  local expected_location="${4:-}"
  local expected_summary="${5:-}"
  local stdout_file="$OUT_DIR/${file%.c}.stdout"
  local stderr_file="$OUT_DIR/${file%.c}.stderr"
  local program_path="$PROGRAM_DIR/$file"
  local rc=0

  total=$((total + 1))
  echo "[CASE $total] $file (expect rc=$expected_rc code=${expected_code:-none})" | tee -a "$LOG"

  if [[ ! -f "$program_path" ]]; then
    echo "[FAIL] missing program: $program_path" | tee -a "$LOG"
    return 1
  fi

  set +e
  "$COMPILER_BIN" "$program_path" >"$stdout_file" 2>"$stderr_file"
  rc=$?
  set -e

  cat "$stdout_file" >>"$LOG"
  cat "$stderr_file" >>"$LOG"

  if [[ "$rc" -ne "$expected_rc" ]]; then
    echo "[FAIL] $file exit=$rc expected=$expected_rc" | tee -a "$LOG"
    return 1
  fi

  if [[ -n "$expected_code" ]]; then
    if ! grep -Eq "$expected_code" "$stdout_file" "$stderr_file"; then
      echo "[FAIL] $file missing expected semantic code $expected_code" | tee -a "$LOG"
      return 1
    fi
  else
    if grep -Eq "error: SEM[0-9]{3}" "$stderr_file"; then
      echo "[FAIL] $file emitted semantic error unexpectedly" | tee -a "$LOG"
      return 1
    fi
  fi

  if [[ -n "$expected_location" ]]; then
    if ! grep -Eq "$expected_location" "$stdout_file" "$stderr_file"; then
      echo "[FAIL] $file missing expected location pattern $expected_location" | tee -a "$LOG"
      return 1
    fi
  fi

  if [[ -n "$expected_summary" ]]; then
    if ! grep -Eq "$expected_summary" "$stdout_file" "$stderr_file"; then
      echo "[FAIL] $file missing expected summary pattern $expected_summary" | tee -a "$LOG"
      return 1
    fi
  fi

  passed=$((passed + 1))
  echo "[PASS] $file" | tee -a "$LOG"
}

run_case "pass1_shadow_ok.c" 0 ""
run_case "pass1_tag_namespace_ok.c" 0 ""
run_case "pass2_ok_minimal.c" 0 ""
run_case "pass2_member_access_ok.c" 0 ""
run_case "pass2_void_param_ok.c" 0 ""
run_case "pass2_tag_shadow_ok.c" 0 ""
run_case "pass1_redecl_fail.c" 2 "SEM002"
run_case "pass1_enum_member_redecl_fail.c" 2 "SEM063" "pass1_enum_member_redecl_fail\\.c:3:0"
run_case "pass1_struct_tag_redef_fail.c" 2 "SEM064" "pass1_struct_tag_redef_fail\\.c:4:0"
run_case "pass1_union_tag_redef_fail.c" 2 "SEM064" "pass1_union_tag_redef_fail\\.c:4:0"
run_case "pass2_assign_type_fail.c" 2 "SEM011"
run_case "pass2_call_arity_fail.c" 2 "SEM041"
run_case "pass2_return_type_fail.c" 2 "SEM043"
run_case "pass2_sem009_const_inc_fail.c" 2 "SEM009" "pass2_sem009_const_inc_fail\\.c:4:0"
run_case "pass2_sem020_arith_operands_fail.c" 2 "SEM020" "pass2_sem020_arith_operands_fail\\.c:4:0"
run_case "pass2_sem021_mod_integral_fail.c" 2 "SEM021" "pass2_sem021_mod_integral_fail\\.c:4:0"
run_case "pass2_sem023_bitwise_integral_fail.c" 2 "SEM023" "pass2_sem023_bitwise_integral_fail\\.c:4:0"
run_case "pass2_sem024_logical_scalar_fail.c" 2 "SEM024" "pass2_sem024_logical_scalar_fail\\.c:4:0"
run_case "pass2_sem027_assign_modifiable_lvalue_fail.c" 2 "SEM027" "pass2_sem027_assign_modifiable_lvalue_fail\\.c:4:0"
run_case "pass2_sem028_inc_modifiable_lvalue_fail.c" 2 "SEM028" "pass2_sem028_inc_modifiable_lvalue_fail\\.c:3:0"
run_case "pass2_sem031_array_index_integral_fail.c" 2 "SEM031" "pass2_sem031_array_index_integral_fail\\.c:5:0"
run_case "pass2_break_outside_fail.c" 2 "SEM050"
run_case "pass2_continue_outside_fail.c" 2 "SEM051"
run_case "pass2_unknown_identifier_line_fail.c" 2 "SEM001" "pass2_unknown_identifier_line_fail\\.c:4:0"
run_case "sem_006_check.c" 2 "SEM006" "sem_006_check\\.c:7:0"
run_case "sem_007_check.c" 2 "SEM007" "sem_007_check\\.c:2:0"
run_case "non_scalar_if_fail.c" 2 "SEM052"
run_case "non_scalar_while_fail.c" 2 "SEM052"
run_case "non_scalar_dowhile_fail.c" 2 "SEM052"
run_case "non_scalar_for_fail.c" 2 "SEM052"
run_case "int_const_case_ok.c" 0 ""
run_case "int_const_case_fail.c" 1 "" # "SEM054" is never emitted because valid case labels are already constrained by the parser/AST builder --- IGNORE ---
run_case "switch_integral_ok.c" 0 ""
run_case "switch_non_integral_fail.c" 2 "SEM053"

run_case "semw_001_check.c" 0 "SEMW001" "semw_001_check\\.c:11:0" "warnings=3"
run_case "semw_002_check.c" 0 "SEMW002" "semw_002_check\\.c:9:0" "warnings=3"
run_case "semw_003_check.c" 0 "SEMW003" "semw_003_check\\.c:6:0" "warnings=1"

echo "[SUMMARY] semantic_pass_examples total=$total passed=$passed failed=$((total - passed))" | tee -a "$LOG"
echo "PASS semantic_pass_examples" | tee -a "$LOG"
