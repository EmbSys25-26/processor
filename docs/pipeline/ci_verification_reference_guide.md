# CI Lookup Guide

Global CI rule after all runs:
- Any run log containing `FAIL` or `Not enough words` is a CI failure.

## 1. Timer / CPU Core Anchors

### `tb_timer_start_reg`
- Description: Verifies timer16/timerH start-counter register behavior and IRQ request latch/clear semantics.
- Content: Checks `CNT_INIT` readback, overflow assertion of `o_int_req`, and clear-on-write behavior for both timers.
- Outputs: OK when log contains `PASS tb_timer_start_reg`; not OK on any mismatch (`FAIL ...`) or missing PASS.

### `tb_cpu_irq_depth`
- Description: Verifies CPU IRQ depth accounting and nested entry/exit behavior.
- Content: Checks `dut._irq_depth`, `o_in_irq`, and underflow guard across single and nested IRQ sequences.
- Outputs: OK when log contains `PASS tb_cpu_irq_depth`; not OK if depth/in_irq deviates from expected transitions.

## 2. Pipeline Hazard/Control Regressions

### `tb_pipe_load_use_bubble`
- Description: Confirms load-use hazard interlock in pipeline.
- Content: Checks `dut._stall_id`, `dut._bubble_ex`, and final reg value (`dut.u_regfile._a1`) to prove bubble correctness.
- Outputs: OK on `PASS tb_pipe_load_use_bubble`; fail if no stall/bubble observed or architectural result is wrong.

### `tb_pipe_cc_dependency`
- Description: Confirms branch-on-condition stalls until CC is ready.
- Content: Checks stall window on BX (`dut._stall_id` with `dut._ifid_insn`), then validates destination registers.
- Outputs: OK on `PASS tb_pipe_cc_dependency`; fail on missing interlock or bad final register values.

### `tb_pipe_branch_flush`
- Description: Verifies IF/ID flush after taken branch.
- Content: Checks `dut._flush_ifid` and post-branch architectural state (`dut.u_regfile._a0`).
- Outputs: OK on `PASS tb_pipe_branch_flush`; fail if flush not seen or wrong final value.

### `tb_pipe_mem_wait_freeze`
- Description: Verifies pipeline freeze during memory wait.
- Content: Checks `dut._mem_wait`, PC stability while waiting, and final register correctness once `i_rdy` releases.
- Outputs: OK on `PASS tb_pipe_mem_wait_freeze`; fail on missing wait, PC drift, or wrong reg result.

### `tb_pipe_irq_precise_boundary`
- Description: Verifies precise interrupt acceptance boundary.
- Content: Checks `dut._accept_irq`, LR-save write (`dut._rf_we`/`dut._rf_wa`), `o_in_irq`, and bounded depth (`dut._irq_depth`).
- Outputs: OK on `PASS tb_pipe_irq_precise_boundary`; fail if accept/entry semantics are violated.

### `tb_pipe_imm_prefix_flush`
- Description: Verifies IMM-prefix state handling across branch flush.
- Content: Checks `dut._imm_pre_state` activation, `dut._flush_ifid`, final register value, and no stale IMM leak.
- Outputs: OK on `PASS tb_pipe_imm_prefix_flush`; fail on missing flush or stale IMM-prefix behavior.

### `tb_pipe_carry_dependency`
- Description: Verifies carry dependency interlock (ADC/SBC hazard class).
- Content: Checks stall on ADC decode (`dut._stall_id` + function decode bits) and architectural results in destination registers.
- Outputs: OK on `PASS tb_pipe_carry_dependency`; fail on missing stall or wrong values.

### `tb_pipe_irq_mem_wait_deferral`
- Description: Verifies IRQ acceptance is deferred while memory wait is active.
- Content: Checks no `dut._accept_irq` during `dut._mem_wait`, then acceptance after wait release.
- Outputs: OK on `PASS tb_pipe_irq_mem_wait_deferral`; fail if IRQ is accepted during wait or never accepted after release.

### `tb_pipe_imm_prefix_irq_clear`
- Description: Verifies IRQ accept clears IMM-prefix state.
- Content: Checks `dut._accept_irq` occurs and `dut._imm_pre_state` is cleared after acceptance.
- Outputs: OK on `PASS tb_pipe_imm_prefix_irq_clear`; fail on missing accept or uncleared prefix state.

### `tb_pipe_fuzz_invariants`
- Description: Deterministic fuzz test for control-safety invariants.
- Content: Checks no X on address buses, word alignment of `i_ad`, `r0` immutability, full stall bundle under `mem_wait`, and no IRQ accept during wait.
- Outputs: OK on `PASS tb_pipe_fuzz_invariants`; fail on any invariant breach.

### `tb_pipe_irq_oneshot_level`
- Description: Verifies level IRQ is consumed as one-shot per assertion window.
- Content: Counts `dut._accept_irq` events during two long IRQ-high phases.
- Outputs: OK on `PASS tb_pipe_irq_oneshot_level`; fail unless each phase yields exactly one accept.

### `tb_pipe_irq_branch_priority`
- Description: Verifies IRQ acceptance priority over concurrent branch commit.
- Content: Creates branch/IRQ conflict (`dut._id_valid && dut._id_is_bx`), checks branch suppression and vector fetch behavior.
- Outputs: OK on `PASS tb_pipe_irq_branch_priority`; fail if branch commits when IRQ should win.

### `tb_pipe_branch_memwait_defer`
- Description: Verifies branch commit is deferred during memory wait.
- Content: Checks overlap of branch-in-ID with `dut._mem_wait` and ensures `dut._branch_take_commit` only after wait drops.
- Outputs: OK on `PASS tb_pipe_branch_memwait_defer`; fail if branch commits while waiting or never commits later.

### `tb_pipe_r0_load_no_hazard`
- Description: Verifies false load-use hazard is not raised when producer writes `r0`.
- Content: Watches `dut._stall_id` under specific decode and checks final `r1` value.
- Outputs: OK on `PASS tb_pipe_r0_load_no_hazard`; fail if false stall is detected.

## 3. SoC + Peripheral Integration Regressions

### `tb_soc_byte_lane`
- Description: Verifies store-byte/load-byte lane routing through SoC memory path.
- Content: Checks bus op qualifiers (`_sw/_sb/_lw/_lb`), memory bytes (`dut.u_mem._mem_h/_mem_l`), and CPU data-in (`dut._cpu_di`).
- Outputs: OK on `PASS tb_soc_byte_lane`; fail on lane mismatch or wrong readback bytes.

### `tb_soc_refactor_regression`
- Description: Broad SoC health regression for IRQ/MMIO/UART activity.
- Content: Monitors `dut._irq_take`, `dut._in_irq`, MMIO select/write (`dut._io_sel/_io_we`), and UART pending (`dut.u_periph.u_uart._rx_pending`).
- Outputs: OK on `PASS tb_soc_refactor_regression`; fail if required activity is absent.

### `tb_soc_branch_annul`
- Description: SoC-level branch annul corner-case check.
- Content: On taken branch, next instruction queue must be NOP (`dut._insn_q` vs `CPU_NOP_INSN`), including IRQ-context coverage.
- Outputs: OK on `PASS tb_soc_branch_annul`; fail on annul violation or no branch observation.

### `tb_anchor_preemption_abi`
- Description: Main anchor test for preemption + ABI preservation.
- Content: Checks IRQ0 (`0x0020`) then IRQ1 (`0x0040`) preemption via `dut._irq_take/_irq_vector/_in_irq` and verifies `s0/s1` restoration (`dut.u_cpu.u_regfile._s0/_s1`).
- Outputs: OK on `PASS tb_anchor_preemption_abi` and anchor strings (`ANCHOR PREEMPTION observed`, `ANCHOR ABI restored`); fail otherwise.

### `tb_uart_mmio_word_aligned`
- Description: Verifies UART MMIO status/control on word-aligned decode path.
- Content: Checks UART status bits (`tx_busy`, `rx_pending`) via aligned status address and clear-on-write behavior.
- Outputs: OK on `PASS tb_uart_mmio_word_aligned`; fail if status transitions/clear semantics are wrong.

### `tb_soc_smoke` (from `tb_Soc.v`)
- Description: Bounded-runtime SoC smoke for IRQ+UART observability.
- Content: Requires logs showing `IRQ take`, `vector=0x0020`, `vector=0x0040`, and guard termination (`TB timeout/guard reached`).
- Outputs: OK when all required strings are present; fail if any required event string is missing.

## 4. How CI decides pass/fail (quick rule)

A CI run is considered OK when:
- Every benchmark run log contains its required `PASS ...` marker (or required event strings for smoke).
- No run log contains `FAIL`.
- Assembler step succeeds and generated memory HEX files have exactly 512 lines each.
