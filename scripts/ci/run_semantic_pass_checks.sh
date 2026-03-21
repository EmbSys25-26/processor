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

  passed=$((passed + 1))
  echo "[PASS] $file" | tee -a "$LOG"
}

run_case "pass1_shadow_ok.c" 0 ""
run_case "pass2_ok_minimal.c" 0 ""
run_case "pass2_member_access_ok.c" 0 ""
run_case "pass2_void_param_ok.c" 0 ""
run_case "pass2_tag_shadow_ok.c" 0 ""
run_case "pass1_redecl_fail.c" 2 "SEM002"
run_case "pass2_assign_type_fail.c" 2 "SEM011"
run_case "pass2_call_arity_fail.c" 2 "SEM041"
run_case "pass2_return_type_fail.c" 2 "SEM043"
run_case "pass2_break_outside_fail.c" 2 "SEM050"
run_case "pass2_continue_outside_fail.c" 2 "SEM051"
run_case "pass2_unknown_identifier_line_fail.c" 2 "SEM001" "pass2_unknown_identifier_line_fail\\.c:4:0"
run_case "sem_006_check.c" 2 "SEM006" "sem_006_check\\.c:7:0"
run_case "sem_007_check.c" 2 "SEM007" "sem_007_check\\.c:2:0"
run_case "sem_008_check.c" 2 "SEM008" "sem_008_check\\.c:2:0"
run_case "sem_009_check.c" 2 "SEM009" "sem_009_check\\.c:2:0"
run_case "sem_010_check.c" 2 "SEM010" "sem_010_check\\.c:2:0"
run_case "sem_011_check.c" 2 "SEM011" "sem_011_check\\.c:6:0"
run_case "sem_0012_check.c" 2 "SEM012"
run_case "sem_0013_check.c" 2 "SEM013"
run_case "sem_0014_check.c" 2 "SEM014"
run_case "sem_0020_check.c" 2 "SEM020"
run_case "sem_0021_check.c" 2 "SEM021"
run_case "sem_022_check.c" 2 "SEM022" "sem_022_check\\.c:5:0"
run_case "sem_022_check.c" 2 "SEM022" "sem_022_check\\.c:6:0"
run_case "sem_0023_check.c" 2 "SEM023"
run_case "sem_024_check.c" 2 "SEM024" "sem_024_check\\.c:12:0"
run_case "sem_025_check.c" 2 "SEM025" "sem_025_check\\.c:12:0"
run_case "sem_026_check.c" 2 "SEM026" "sem_026_check\\.c:13:0"
run_case "sem_027_check.c" 2 "SEM027" "sem_027_check\\.c:3:0"
run_case "sem_028_check.c" 2 "SEM028" "sem_028_check\\.c:2:0"
run_case "sem_029_check.c" 2 "SEM029" "sem_029_check\\.c:5:0"
run_case "sem_030_check.c" 2 "SEM030" "sem_030_check\\.c:2:0"
run_case "sem_0031_check.c" 2 "SEM031"
run_case "sem_0032_check.c" 2 "SEM032"
run_case "sem_060_check.c" 2 "SEM060" "sem_060_check\\.c:7:0"
run_case "sem_061_check.c" 2 "SEM061" "sem_061_check\\.c:7:0"
run_case "sem_062_check.c" 2 "SEM062" "sem_062_check\\.c:7:0"


echo "[SUMMARY] semantic_pass_examples total=$total passed=$passed failed=$((total - passed))" | tee -a "$LOG"
echo "PASS semantic_pass_examples" | tee -a "$LOG"
