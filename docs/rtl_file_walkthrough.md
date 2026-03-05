# RTL File Walkthrough (Current Pipeline Refactor)

_Last reviewed: 2026-02-18_

This walkthrough tracks the current RTL organization under `srcs/`.

## 1. CPU Top and Stage Modules

### `srcs/m_cpu.v`
- Top orchestrator for the 5-stage pipeline and IRQ depth tracking.
- Keeps the external CPU contract stable (`o_i_ad`, `o_d_ad`, `o_sw/o_lw/...`, `o_in_irq`, `o_iret_detected`).
- Owns global state:
  - PC
  - IMM prefix latch (`_imm_pre_state`, `_i12_pre_state`)
  - carry/flags
  - global interrupt enable (`_gie`)
  - IRQ depth (`_irq_depth`, saturating)

### `srcs/m_if_stage.v`
- IF front-end buffering (`o_valid`, `o_pc`, `o_insn`) with stall/flush handling.
- Supports taken-branch/IRQ redirect flush behavior.

### `srcs/m_id_stage.v`
- Decode-stage ownership of instruction interpretation.
- Instantiates:
  - `srcs/m_ctrl_unit.v` for decode/control metadata
  - `srcs/m_bdu.v` for branch condition evaluation
- Builds `imm16`, branch target, and branch-take decision.

### `srcs/m_ex_stage.v`
- ALU/execute stage:
  - operand select
  - arithmetic/logical/shift execution
  - data address generation (`o_d_ad = _sum << 1`)
  - store-data generation
  - flag/carry candidate generation

### `srcs/m_mem_stage.v`
- Memory handshake stage:
  - emits load/store strobes and address/data
  - asserts `o_mem_wait` until `i_rdy`
  - guarantees single completion (`o_mem_complete`) and WB data muxing

### `srcs/m_wb_stage.v`
- Final retire/writeback:
  - register-file write enable/address/data
  - committed flag/carry updates
  - `o_iret_event`

## 2. Pipeline Registers and Control Helpers

### Pipeline registers
- `srcs/m_pipe_if_id.v`
- `srcs/m_pipe_id_ex.v`
- `srcs/m_pipe_ex_mem.v`
- `srcs/m_pipe_mem_wb.v`

These implement stage-to-stage state transfer with explicit stall/flush/bubble controls.

### Hazard / branch / PC helpers
- `srcs/m_hazard_unit.v`
  - bubble-first hazard policy (v1)
  - decode hazards stall IF/ID and inject EX bubble
  - mem-wait freezes progression
  - branch/IRQ flush control
- `srcs/m_bdu.v`
  - branch condition decode from CC flags
- `srcs/m_pc_next.v`
  - next-PC selection (reset, IRQ vector, branch target, sequential)

## 3. Core Reusable Blocks

### `srcs/m_ctrl_unit.v`
- Pure decode/control metadata generator from `i_insn`.
- Exposes execution qualifiers (`o_is_*`) and hazard metadata (`o_reads_*`, `o_uses_*`, `o_updates_*`).

### `srcs/m_regfile16x16.v`
- 2R1W regfile API:
  - read ports: `i_ra/i_rb -> o_ra/o_rb`
  - write port: `i_we/i_wa/i_wd`
- Preserves debug mirrors (`_s0`, `_s1`, `_sp`, `_lr`, ...).

### `srcs/m_alu.v`
- Arithmetic/logical/shift combinational primitive (`alu` + `addsub`).

## 4. SoC and Peripheral Integration

### `srcs/m_soc.v`
- Top integration of CPU + BRAM + peripheral bus.
- Branch-annul behavior: injects NOP into instruction latch on taken branch.
- MMIO split by `d_ad[15]`.

### `srcs/m_bram.v`
- Unified 1KiB dual-port byte-sliced BRAM model:
  - Port A: instruction fetch
  - Port B: data read/write with per-byte enables

### `srcs/m_periph_bus.v`
- MMIO decode and peripheral mux.
- Integrates timers, PARIO, UART MMIO, and IRQ controller.

### `srcs/m_irq_ctrl.v`
- Priority IRQ control and vector selection.

## 5. Legacy Compatibility Module

### `srcs/m_datapath.v`
- Legacy pre-stage datapath module retained for compatibility/reference.
- Not the active execution owner in the current stage-module CPU path.

## 6. Simulation/Regression Anchors

Key benches in `sim/` include:
- `tb_anchor_preemption_abi.v` (preemption + ABI anchor)
- `tb_soc_branch_annul.v` (branch annul)
- `tb_soc_refactor_regression.v` (SoC integration)
- `tb_soc_byte_lane.v` (LB/SB lane behavior)
- `tb_pipe_*.v` (pipeline hazard/control focused regressions)

