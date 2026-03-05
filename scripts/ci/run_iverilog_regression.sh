#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ARTIFACT_DIR="${1:-${ROOT_DIR}/.ci_artifacts/sim}"
mkdir -p "${ARTIFACT_DIR}"
cd "${ROOT_DIR}"

PIPELINE_SRCS=(
  srcs/m_if_stage.v
  srcs/m_id_stage.v
  srcs/m_ex_stage.v
  srcs/m_mem_stage.v
  srcs/m_wb_stage.v
  srcs/m_pipe_if_id.v
  srcs/m_pipe_id_ex.v
  srcs/m_pipe_ex_mem.v
  srcs/m_pipe_mem_wb.v
  srcs/m_hazard_unit.v
  srcs/m_bdu.v
  srcs/m_pc_next.v
)

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
  "${PIPELINE_SRCS[@]}"
)

CPU_CORE_SRCS=(
  srcs/m_cpu.v
  srcs/m_ctrl_unit.v
  srcs/m_datapath.v
  srcs/m_alu.v
  srcs/m_regfile16x16.v
  "${PIPELINE_SRCS[@]}"
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

info "running pipeline load-use bubble regression"
compile_tb "tb_pipe_load_use_bubble" sim/tb_pipe_load_use_bubble.v "${CPU_CORE_SRCS[@]}"
run_tb "tb_pipe_load_use_bubble"
require_log_contains "${ARTIFACT_DIR}/tb_pipe_load_use_bubble.run.log" "PASS tb_pipe_load_use_bubble"

info "running pipeline CC dependency regression"
compile_tb "tb_pipe_cc_dependency" sim/tb_pipe_cc_dependency.v "${CPU_CORE_SRCS[@]}"
run_tb "tb_pipe_cc_dependency"
require_log_contains "${ARTIFACT_DIR}/tb_pipe_cc_dependency.run.log" "PASS tb_pipe_cc_dependency"

info "running pipeline branch flush regression"
compile_tb "tb_pipe_branch_flush" sim/tb_pipe_branch_flush.v "${CPU_CORE_SRCS[@]}"
run_tb "tb_pipe_branch_flush"
require_log_contains "${ARTIFACT_DIR}/tb_pipe_branch_flush.run.log" "PASS tb_pipe_branch_flush"

info "running pipeline memory-wait freeze regression"
compile_tb "tb_pipe_mem_wait_freeze" sim/tb_pipe_mem_wait_freeze.v "${CPU_CORE_SRCS[@]}"
run_tb "tb_pipe_mem_wait_freeze"
require_log_contains "${ARTIFACT_DIR}/tb_pipe_mem_wait_freeze.run.log" "PASS tb_pipe_mem_wait_freeze"

info "running pipeline IRQ precise-boundary regression"
compile_tb "tb_pipe_irq_precise_boundary" sim/tb_pipe_irq_precise_boundary.v "${CPU_CORE_SRCS[@]}"
run_tb "tb_pipe_irq_precise_boundary"
require_log_contains "${ARTIFACT_DIR}/tb_pipe_irq_precise_boundary.run.log" "PASS tb_pipe_irq_precise_boundary"

info "running pipeline IMM-prefix flush regression"
compile_tb "tb_pipe_imm_prefix_flush" sim/tb_pipe_imm_prefix_flush.v "${CPU_CORE_SRCS[@]}"
run_tb "tb_pipe_imm_prefix_flush"
require_log_contains "${ARTIFACT_DIR}/tb_pipe_imm_prefix_flush.run.log" "PASS tb_pipe_imm_prefix_flush"

info "running pipeline carry dependency regression"
compile_tb "tb_pipe_carry_dependency" sim/tb_pipe_carry_dependency.v "${CPU_CORE_SRCS[@]}"
run_tb "tb_pipe_carry_dependency"
require_log_contains "${ARTIFACT_DIR}/tb_pipe_carry_dependency.run.log" "PASS tb_pipe_carry_dependency"

info "running pipeline IRQ-deferral on mem-wait regression"
compile_tb "tb_pipe_irq_mem_wait_deferral" sim/tb_pipe_irq_mem_wait_deferral.v "${CPU_CORE_SRCS[@]}"
run_tb "tb_pipe_irq_mem_wait_deferral"
require_log_contains "${ARTIFACT_DIR}/tb_pipe_irq_mem_wait_deferral.run.log" "PASS tb_pipe_irq_mem_wait_deferral"

info "running pipeline IMM-prefix IRQ-clear regression"
compile_tb "tb_pipe_imm_prefix_irq_clear" sim/tb_pipe_imm_prefix_irq_clear.v "${CPU_CORE_SRCS[@]}"
run_tb "tb_pipe_imm_prefix_irq_clear"
require_log_contains "${ARTIFACT_DIR}/tb_pipe_imm_prefix_irq_clear.run.log" "PASS tb_pipe_imm_prefix_irq_clear"

info "running pipeline deterministic fuzz-invariant regression"
compile_tb "tb_pipe_fuzz_invariants" sim/tb_pipe_fuzz_invariants.v "${CPU_CORE_SRCS[@]}"
run_tb "tb_pipe_fuzz_invariants"
require_log_contains "${ARTIFACT_DIR}/tb_pipe_fuzz_invariants.run.log" "PASS tb_pipe_fuzz_invariants"

info "running pipeline IRQ oneshot-level regression"
compile_tb "tb_pipe_irq_oneshot_level" sim/tb_pipe_irq_oneshot_level.v "${CPU_CORE_SRCS[@]}"
run_tb "tb_pipe_irq_oneshot_level"
require_log_contains "${ARTIFACT_DIR}/tb_pipe_irq_oneshot_level.run.log" "PASS tb_pipe_irq_oneshot_level"

info "running pipeline IRQ-vs-branch priority regression"
compile_tb "tb_pipe_irq_branch_priority" sim/tb_pipe_irq_branch_priority.v "${CPU_CORE_SRCS[@]}"
run_tb "tb_pipe_irq_branch_priority"
require_log_contains "${ARTIFACT_DIR}/tb_pipe_irq_branch_priority.run.log" "PASS tb_pipe_irq_branch_priority"

info "running pipeline branch defer-under-memwait regression"
compile_tb "tb_pipe_branch_memwait_defer" sim/tb_pipe_branch_memwait_defer.v "${CPU_CORE_SRCS[@]}"
run_tb "tb_pipe_branch_memwait_defer"
require_log_contains "${ARTIFACT_DIR}/tb_pipe_branch_memwait_defer.run.log" "PASS tb_pipe_branch_memwait_defer"

info "running pipeline r0 load-nohazard regression"
compile_tb "tb_pipe_r0_load_no_hazard" sim/tb_pipe_r0_load_no_hazard.v "${CPU_CORE_SRCS[@]}"
run_tb "tb_pipe_r0_load_no_hazard"
require_log_contains "${ARTIFACT_DIR}/tb_pipe_r0_load_no_hazard.run.log" "PASS tb_pipe_r0_load_no_hazard"

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

info "running peripheral-bus UART MMIO word-aligned decode regression"
compile_tb "tb_uart_mmio_word_aligned" sim/tb_uart_mmio_word_aligned.v srcs/m_periph_bus.v srcs/m_timer16.v srcs/m_timerH.v srcs/m_pario.v srcs/m_uart_mmio.v srcs/m_uart_rx.v srcs/m_uart_tx.v srcs/m_irq_ctrl.v
run_tb "tb_uart_mmio_word_aligned"
require_log_contains "${ARTIFACT_DIR}/tb_uart_mmio_word_aligned.run.log" "PASS tb_uart_mmio_word_aligned"

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
