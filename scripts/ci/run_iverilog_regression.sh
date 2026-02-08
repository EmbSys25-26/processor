#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ARTIFACT_DIR="${1:-${ROOT_DIR}/.ci_artifacts/sim}"
mkdir -p "${ARTIFACT_DIR}"
cd "${ROOT_DIR}"

SOC_SRCS=(
  srcs/m_soc.v
  srcs/m_cpu.v
  srcs/m_ctrl_unit.v
  srcs/m_datapath.v
  srcs/m_alu.v
  srcs/m_regfile16x16.v
  srcs/m_irq_ctrl.v
  srcs/m_periph_bus.v
  srcs/m_timer16.v
  srcs/m_timerH.v
  srcs/m_pario.v
  srcs/m_uart_mmio.v
  srcs/m_uart_rx.v
  srcs/m_uart_tx.v
  srcs/m_bram.v
)

CPU_CORE_SRCS=(
  srcs/m_cpu.v
  srcs/m_ctrl_unit.v
  srcs/m_datapath.v
  srcs/m_alu.v
  srcs/m_regfile16x16.v
)

info() {
  printf '[ci] %s\n' "$1"
}

compile_tb() {
  local name="$1"
  shift
  local vvp="${ARTIFACT_DIR}/${name}.vvp"
  local clog="${ARTIFACT_DIR}/${name}.compile.log"
  iverilog -g2012 -DSIM=1 -DCI=1 -Isrcs -o "${vvp}" "$@" >"${clog}" 2>&1
}

run_tb() {
  local name="$1"
  shift
  local vvp="${ARTIFACT_DIR}/${name}.vvp"
  local rlog="${ARTIFACT_DIR}/${name}.run.log"
  vvp "${vvp}" "$@" >"${rlog}" 2>&1
}

require_log_contains() {
  local log="$1"
  local pattern="$2"
  if ! grep -qE "${pattern}" "${log}"; then
    printf '[ci] expected pattern not found: %s in %s\n' "${pattern}" "${log}" >&2
    exit 1
  fi
}

require_log_not_contains() {
  local log="$1"
  local pattern="$2"
  if grep -qE "${pattern}" "${log}"; then
    printf '[ci] forbidden pattern found: %s in %s\n' "${pattern}" "${log}" >&2
    exit 1
  fi
}

info "assembling firmware image with deterministic BRAM padding"
python3 tools/assembler.py -q

for hex in srcs/mem/mem.hex srcs/mem/mem_hi.hex srcs/mem/mem_lo.hex; do
  lines="$(wc -l < "${hex}" | tr -d ' ')"
  if [[ "${lines}" -ne 512 ]]; then
    printf '[ci] expected 512 lines in %s, got %s\n' "${hex}" "${lines}" >&2
    exit 1
  fi
done

info "running timer start/reload register regression"
compile_tb "tb_timer_start_reg" sim/tb_timer_start_reg.v srcs/m_timer16.v srcs/m_timerH.v
run_tb "tb_timer_start_reg"
require_log_contains "${ARTIFACT_DIR}/tb_timer_start_reg.run.log" "PASS tb_timer_start_reg"

info "running CPU irq-depth robustness regression"
compile_tb "tb_cpu_irq_depth" sim/tb_cpu_irq_depth.v "${CPU_CORE_SRCS[@]}"
run_tb "tb_cpu_irq_depth"
require_log_contains "${ARTIFACT_DIR}/tb_cpu_irq_depth.run.log" "PASS tb_cpu_irq_depth"

info "running SoC byte-lane regression"
compile_tb "tb_soc_byte_lane" sim/tb_soc_byte_lane.v "${SOC_SRCS[@]}"
run_tb "tb_soc_byte_lane"
require_log_contains "${ARTIFACT_DIR}/tb_soc_byte_lane.run.log" "PASS tb_soc_byte_lane"

info "running SoC integration regression"
compile_tb "tb_soc_refactor_regression" sim/tb_soc_refactor_regression.v "${SOC_SRCS[@]}"
run_tb "tb_soc_refactor_regression"
require_log_contains "${ARTIFACT_DIR}/tb_soc_refactor_regression.run.log" "PASS tb_soc_refactor_regression"

info "running SoC branch-annul corner regression"
compile_tb "tb_soc_branch_annul" sim/tb_soc_branch_annul.v "${SOC_SRCS[@]}"
run_tb "tb_soc_branch_annul"
require_log_contains "${ARTIFACT_DIR}/tb_soc_branch_annul.run.log" "PASS tb_soc_branch_annul"

info "running anchor regression (preemption + ABI)"
compile_tb "tb_anchor_preemption_abi" sim/tb_anchor_preemption_abi.v "${SOC_SRCS[@]}"
run_tb "tb_anchor_preemption_abi"
require_log_contains "${ARTIFACT_DIR}/tb_anchor_preemption_abi.run.log" "PASS tb_anchor_preemption_abi"
require_log_contains "${ARTIFACT_DIR}/tb_anchor_preemption_abi.run.log" "ANCHOR PREEMPTION observed"
require_log_contains "${ARTIFACT_DIR}/tb_anchor_preemption_abi.run.log" "ANCHOR ABI restored"

info "running SoC smoke with bounded runtime"
iverilog -g2012 -DSIM=1 -DCI=1 -DTB_USE_INTERNALS=1 -Isrcs -o "${ARTIFACT_DIR}/tb_soc_smoke.vvp" sim/tb_Soc.v "${SOC_SRCS[@]}" >"${ARTIFACT_DIR}/tb_soc_smoke.compile.log" 2>&1
vvp "${ARTIFACT_DIR}/tb_soc_smoke.vvp" +max-cycles=1200 >"${ARTIFACT_DIR}/tb_soc_smoke.run.log" 2>&1
require_log_contains "${ARTIFACT_DIR}/tb_soc_smoke.run.log" "IRQ take"
require_log_contains "${ARTIFACT_DIR}/tb_soc_smoke.run.log" "vector=0x0020"
require_log_contains "${ARTIFACT_DIR}/tb_soc_smoke.run.log" "vector=0x0040"
require_log_contains "${ARTIFACT_DIR}/tb_soc_smoke.run.log" "TB timeout/guard reached"

for log in "${ARTIFACT_DIR}"/*.run.log; do
  require_log_not_contains "${log}" "FAIL"
  require_log_not_contains "${log}" "Not enough words"
done

info "all CI baseline regressions passed"
