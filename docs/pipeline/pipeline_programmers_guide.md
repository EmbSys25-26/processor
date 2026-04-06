# Pipeline Programmer's Guide

quick reference notes on each module, stages, and registers
intended use: quick reference while implementing. trading teams 

still uses the old memory model (i.e. no ram+rom), so watch out 

## How to use this Guide (and maintain it)
### How to use 
This guide is organized into sections for pipeline stages, pipeline registers, and support modules. Each section lists the relevant Verilog module(s) along with a *semantic* contract (i.e. what it does). Each contract must cover the functionality, the inputs, outputs, and interactions with neighboring modules.

### How to maintain 
When implementing or modifying any part of the pipeline, refer to this guide to understand the expected behavior and interface of each component. If you make changes to the RTL that affect the contract (e.g., adding new inputs/outputs, new modules, or changing any functionality), please update this guide accordingly to keep it accurate for others to have a quick reference.


## Index

- [Pipeline Programmer's Guide](#pipeline-programmers-guide)
  - [How to use this Guide (and maintain it)](#how-to-use-this-guide-and-maintain-it)
    - [How to use](#how-to-use)
    - [How to maintain](#how-to-maintain)
  - [Index](#index)
  - [Pipeline Stages](#pipeline-stages)
    - [if\_stage Contract](#if_stage-contract)
    - [id\_stage Contract](#id_stage-contract)
    - [ex\_stage Contract](#ex_stage-contract)
    - [mem\_stage Contract](#mem_stage-contract)
    - [wb\_stage Contract](#wb_stage-contract)
  - [Pipeline Registers](#pipeline-registers)
    - [pipe\_if\_id Contract](#pipe_if_id-contract)
    - [pipe\_id\_ex Contract](#pipe_id_ex-contract)
    - [pipe\_ex\_mem Contract](#pipe_ex_mem-contract)
    - [pipe\_mem\_wb Contract](#pipe_mem_wb-contract)
  - [Support Modules](#support-modules)
    - [ctrl\_unit Contract](#ctrl_unit-contract)
    - [bdu Contract](#bdu-contract)
    - [alu Contract](#alu-contract)
    - [addsub Contract](#addsub-contract)
    - [regfile16x16 Contract](#regfile16x16-contract)
    - [pc\_next Contract](#pc_next-contract)
    - [hazard\_unit Contract](#hazard_unit-contract)
  - [Stall/Bubble/Flush Logic Contract](#stallbubbleflush-logic-contract)
  - [Suggested Next Steps (Next Rotation)](#suggested-next-steps-next-rotation)

## Pipeline Stages

### if_stage Contract

**RTL:** `srcs/m_if_stage.v`

**Semantic Contract:** Instruction Fetch stage. Emits fetch enable/valid and PC-aligned instruction bundle.

**Neighbors:** `pc_next`, `pipe_if_id`, `hazard_unit`

**Inputs**

| Name | Type | Bits |
|---|---|---|
| `i_clk` | `input wire` | `1` |
| `i_rst` | `input wire` | `1` |
| `i_hit` | `input wire` | `1` |
| `i_stall` | `input wire` | `1` |
| `i_flush` | `input wire` | `1` |
| `i_flush_pc` | `input wire` | `16` |
| `i_pc` | `input wire` | `16` |
| `i_insn` | `input wire` | `16` |

**Outputs**

| Name | Type | Bits |
|---|---|---|
| `o_insn_ce` | `output wire` | `1` |
| `o_valid` | `output wire` | `1` |
| `o_pc` | `output reg` | `16` |
| `o_insn` | `output wire` | `16` |

### id_stage Contract

**RTL:** `srcs/m_id_stage.v`

**Semantic Contract:** Instruction Decode stage. Decodes instruction, builds immediates, and evaluates branch decision.

**Neighbors:** `ctrl_unit`, `bdu`, `regfile16x16`

**Inputs**

| Name | Type | Bits |
|---|---|---|
| `i_valid` | `input wire` | `1` |
| `i_pc` | `input wire` | `16` |
| `i_insn` | `input wire` | `16` |
| `i_rd_data` | `input wire` | `16` |
| `i_rs_data` | `input wire` | `16` |
| `i_imm_pre_state` | `input wire` | `1` |
| `i_i12_pre_state` | `input wire` | `12` |
| `i_ccz` | `input wire` | `1` |
| `i_ccn` | `input wire` | `1` |
| `i_ccc` | `input wire` | `1` |
| `i_ccv` | `input wire` | `1` |

**Outputs**

| Name | Type | Bits |
|---|---|---|
| `o_valid` | `output wire` | `1` |
| `o_exec_valid` | `output wire` | `1` |
| `o_pc` | `output wire` | `16` |
| `o_rd` | `output wire` | `4` |
| `o_rs` | `output wire` | `4` |
| `o_imm` | `output wire` | `4` |
| `o_i12` | `output wire` | `12` |
| `o_rd_data` | `output wire` | `16` |
| `o_rs_data` | `output wire` | `16` |
| `o_imm16` | `output wire` | `16` |
| `o_branch_target` | `output wire` | `16` |
| `o_branch_take` | `output wire` | `1` |
| `o_is_imm` | `output wire` | `1` |
| `o_is_bx` | `output wire` | `1` |
| `o_is_cli` | `output wire` | `1` |
| `o_is_sti` | `output wire` | `1` |
| `o_is_iret` | `output wire` | `1` |
| `o_irq_interlock` | `output wire` | `1` |
| `o_rf_we` | `output wire` | `1` |
| `o_lw` | `output wire` | `1` |
| `o_lb` | `output wire` | `1` |
| `o_sw` | `output wire` | `1` |
| `o_sb` | `output wire` | `1` |
| `o_is_jal` | `output wire` | `1` |
| `o_is_addi` | `output wire` | `1` |
| `o_is_rr` | `output wire` | `1` |
| `o_is_ri` | `output wire` | `1` |
| `o_is_alu` | `output wire` | `1` |
| `o_is_sub` | `output wire` | `1` |
| `o_is_xor` | `output wire` | `1` |
| `o_is_adc` | `output wire` | `1` |
| `o_is_sbc` | `output wire` | `1` |
| `o_is_cmp` | `output wire` | `1` |
| `o_is_sra` | `output wire` | `1` |
| `o_is_sum` | `output wire` | `1` |
| `o_is_log` | `output wire` | `1` |
| `o_is_sr` | `output wire` | `1` |
| `o_is_getcc` | `output wire` | `1` |
| `o_restore_cc` | `output wire` | `1` |
| `o_reads_rd` | `output wire` | `1` |
| `o_reads_rs` | `output wire` | `1` |
| `o_writes_rd` | `output wire` | `1` |
| `o_is_load` | `output wire` | `1` |
| `o_is_store` | `output wire` | `1` |
| `o_uses_cc` | `output wire` | `1` |
| `o_uses_carry` | `output wire` | `1` |
| `o_updates_cc` | `output wire` | `1` |

**Condition-code Hazard Handling (Current v1)**
- `id_stage` only tags dependency intent (`o_uses_cc`, `o_uses_carry`) and does not resolve hazards locally.
- `hazard_unit` stalls IF/ID and inserts `bubble_ex` when CC/carry producers are still in-flight.
- This is a correctness-first policy (no CC/carry forwarding path enabled yet).
- Branches using flags (`BX*`) may therefore incur explicit interlock cycles.

### ex_stage Contract

**RTL:** `srcs/m_ex_stage.v`

**Semantic Contract:** Execute stage. Runs ALU/address generation and emits memory/writeback candidates.

**Neighbors:** `alu`, `addsub`, `pipe_ex_mem`

**Inputs**

| Name | Type | Bits |
|---|---|---|
| `i_valid` | `input wire` | `1` |
| `i_pc` | `input wire` | `16` |
| `i_rd` | `input wire` | `4` |
| `i_rd_data` | `input wire` | `16` |
| `i_rs_data` | `input wire` | `16` |
| `i_imm16` | `input wire` | `16` |
| `i_rf_we` | `input wire` | `1` |
| `i_lw` | `input wire` | `1` |
| `i_lb` | `input wire` | `1` |
| `i_sw` | `input wire` | `1` |
| `i_sb` | `input wire` | `1` |
| `i_is_jal` | `input wire` | `1` |
| `i_is_addi` | `input wire` | `1` |
| `i_is_rr` | `input wire` | `1` |
| `i_is_ri` | `input wire` | `1` |
| `i_is_alu` | `input wire` | `1` |
| `i_is_sub` | `input wire` | `1` |
| `i_is_xor` | `input wire` | `1` |
| `i_is_adc` | `input wire` | `1` |
| `i_is_sbc` | `input wire` | `1` |
| `i_is_cmp` | `input wire` | `1` |
| `i_is_sra` | `input wire` | `1` |
| `i_is_sum` | `input wire` | `1` |
| `i_is_log` | `input wire` | `1` |
| `i_is_sr` | `input wire` | `1` |
| `i_is_getcc` | `input wire` | `1` |
| `i_restore_cc` | `input wire` | `1` |
| `i_is_iret` | `input wire` | `1` |
| `i_c` | `input wire` | `1` |
| `i_ccz` | `input wire` | `1` |
| `i_ccn` | `input wire` | `1` |
| `i_ccc` | `input wire` | `1` |
| `i_ccv` | `input wire` | `1` |

**Outputs**

| Name | Type | Bits |
|---|---|---|
| `o_valid` | `output wire` | `1` |
| `o_pc` | `output wire` | `16` |
| `o_rd` | `output wire` | `4` |
| `o_rf_we` | `output wire` | `1` |
| `o_lw` | `output wire` | `1` |
| `o_lb` | `output wire` | `1` |
| `o_sw` | `output wire` | `1` |
| `o_sb` | `output wire` | `1` |
| `o_d_ad` | `output wire` | `16` |
| `o_store_data` | `output wire` | `16` |
| `o_wb_pre_data` | `output wire` | `16` |
| `o_flag_we` | `output wire` | `1` |
| `o_new_ccz` | `output wire` | `1` |
| `o_new_ccn` | `output wire` | `1` |
| `o_new_ccc` | `output wire` | `1` |
| `o_new_ccv` | `output wire` | `1` |
| `o_carry_we` | `output wire` | `1` |
| `o_new_c` | `output wire` | `1` |
| `o_updates_cc_hz` | `output wire` | `1` |
| `o_updates_carry_hz` | `output wire` | `1` |
| `o_is_load` | `output wire` | `1` |
| `o_is_iret` | `output wire` | `1` |

### mem_stage Contract

**RTL:** `srcs/m_mem_stage.v`

**Semantic Contract:** Memory stage. Performs load/store handshake and final memory data select for WB.

**Neighbors:** `pipe_ex_mem`, `pipe_mem_wb`

**Inputs**

| Name | Type | Bits |
|---|---|---|
| `i_valid` | `input wire` | `1` |
| `i_rd` | `input wire` | `4` |
| `i_rf_we` | `input wire` | `1` |
| `i_lw` | `input wire` | `1` |
| `i_lb` | `input wire` | `1` |
| `i_sw` | `input wire` | `1` |
| `i_sb` | `input wire` | `1` |
| `i_d_ad` | `input wire` | `16` |
| `i_store_data` | `input wire` | `16` |
| `i_wb_pre_data` | `input wire` | `16` |
| `i_flag_we` | `input wire` | `1` |
| `i_new_ccz` | `input wire` | `1` |
| `i_new_ccn` | `input wire` | `1` |
| `i_new_ccc` | `input wire` | `1` |
| `i_new_ccv` | `input wire` | `1` |
| `i_carry_we` | `input wire` | `1` |
| `i_new_c` | `input wire` | `1` |
| `i_updates_cc_hz` | `input wire` | `1` |
| `i_updates_carry_hz` | `input wire` | `1` |
| `i_is_load` | `input wire` | `1` |
| `i_is_iret` | `input wire` | `1` |
| `i_data_in` | `input wire` | `16` |
| `i_rdy` | `input wire` | `1` |

**Outputs**

| Name | Type | Bits |
|---|---|---|
| `o_mem_wait` | `output wire` | `1` |
| `o_mem_complete` | `output wire` | `1` |
| `o_sw` | `output wire` | `1` |
| `o_sb` | `output wire` | `1` |
| `o_lw` | `output wire` | `1` |
| `o_lb` | `output wire` | `1` |
| `o_d_ad` | `output wire` | `16` |
| `o_data_out` | `output wire` | `16` |
| `o_valid` | `output wire` | `1` |
| `o_rd` | `output wire` | `4` |
| `o_rf_we` | `output wire` | `1` |
| `o_wb_data` | `output wire` | `16` |
| `o_flag_we` | `output wire` | `1` |
| `o_new_ccz` | `output wire` | `1` |
| `o_new_ccn` | `output wire` | `1` |
| `o_new_ccc` | `output wire` | `1` |
| `o_new_ccv` | `output wire` | `1` |
| `o_carry_we` | `output wire` | `1` |
| `o_new_c` | `output wire` | `1` |
| `o_updates_cc_hz` | `output wire` | `1` |
| `o_updates_carry_hz` | `output wire` | `1` |
| `o_is_iret` | `output wire` | `1` |

**Load/Memory Wait Note (Current SoC path)**
- For memory ops, completion is gated by `i_rdy`; while low, `o_mem_wait=1` and pipeline progression is stalled.
- In the current SoC harness, `LW/LB` are effectively 2-cycle in the normal case: first cycle waits, second cycle completes.
- In general, latency is `1 + wait cycles` and depends on the `i_rdy` source behavior.
- Moreover, always add `_hz` as a suffix when the signal is hazard-related (e.g. `o_updates_cc_hz`) to clarify its purpose and avoid confusion with non-hazard signals. Also to help with the Hazard Unit's future implementation.

### wb_stage Contract

**RTL:** `srcs/m_wb_stage.v`

**Semantic Contract:** Writeback stage. Commits register writes and flag/carry updates.

**Neighbors:** `regfile16x16`

**Inputs**

| Name | Type | Bits |
|---|---|---|
| `i_valid` | `input wire` | `1` |
| `i_rd` | `input wire` | `4` |
| `i_rf_we` | `input wire` | `1` |
| `i_wb_data` | `input wire` | `16` |
| `i_flag_we` | `input wire` | `1` |
| `i_new_ccz` | `input wire` | `1` |
| `i_new_ccn` | `input wire` | `1` |
| `i_new_ccc` | `input wire` | `1` |
| `i_new_ccv` | `input wire` | `1` |
| `i_carry_we` | `input wire` | `1` |
| `i_new_c` | `input wire` | `1` |
| `i_updates_cc_hz` | `input wire` | `1` |
| `i_updates_carry_hz` | `input wire` | `1` |
| `i_is_iret` | `input wire` | `1` |

**Outputs**

| Name | Type | Bits |
|---|---|---|
| `o_rf_we` | `output wire` | `1` |
| `o_wa` | `output wire` | `4` |
| `o_wd` | `output wire` | `16` |
| `o_flag_we` | `output wire` | `1` |
| `o_new_ccz` | `output wire` | `1` |
| `o_new_ccn` | `output wire` | `1` |
| `o_new_ccc` | `output wire` | `1` |
| `o_new_ccv` | `output wire` | `1` |
| `o_carry_we` | `output wire` | `1` |
| `o_new_c` | `output wire` | `1` |
| `o_updates_cc_hz` | `output wire` | `1` |
| `o_updates_carry_hz` | `output wire` | `1` |
| `o_iret_event` | `output wire` | `1` |

## Pipeline Registers

### pipe_if_id Contract

**RTL:** `srcs/m_pipe_if_id.v`

**Semantic Contract:** IF/ID register. Supports stall and flush (NOP injection).

**Neighbors:** `if_stage`, `id_stage`, `hazard_unit`

**Inputs**

| Name | Type | Bits |
|---|---|---|
| `i_clk` | `input wire` | `1` |
| `i_rst` | `input wire` | `1` |
| `i_stall` | `input wire` | `1` |
| `i_flush` | `input wire` | `1` |
| `i_valid` | `input wire` | `1` |
| `i_pc` | `input wire` | `16` |
| `i_insn` | `input wire` | `16` |

**Outputs**

| Name | Type | Bits |
|---|---|---|
| `o_valid` | `output reg` | `1` |
| `o_pc` | `output reg` | `16` |
| `o_insn` | `output reg` | `16` |

### pipe_id_ex Contract

**RTL:** `srcs/m_pipe_id_ex.v`

**Semantic Contract:** ID/EX register. Supports stall, bubble, and flush controls.

**Neighbors:** `id_stage`, `ex_stage`, `hazard_unit`

**Inputs**

| Name | Type | Bits |
|---|---|---|
| `i_clk` | `input wire` | `1` |
| `i_rst` | `input wire` | `1` |
| `i_stall` | `input wire` | `1` |
| `i_bubble` | `input wire` | `1` |
| `i_flush` | `input wire` | `1` |
| `i_valid` | `input wire` | `1` |
| `i_pc` | `input wire` | `16` |
| `i_rd` | `input wire` | `4` |
| `i_rs` | `input wire` | `4` |
| `i_imm` | `input wire` | `4` |
| `i_i12` | `input wire` | `12` |
| `i_rd_data` | `input wire` | `16` |
| `i_rs_data` | `input wire` | `16` |
| `i_imm16` | `input wire` | `16` |
| `i_is_imm` | `input wire` | `1` |
| `i_is_bx` | `input wire` | `1` |
| `i_is_cli` | `input wire` | `1` |
| `i_is_sti` | `input wire` | `1` |
| `i_is_iret` | `input wire` | `1` |
| `i_irq_interlock` | `input wire` | `1` |
| `i_rf_we` | `input wire` | `1` |
| `i_lw` | `input wire` | `1` |
| `i_lb` | `input wire` | `1` |
| `i_sw` | `input wire` | `1` |
| `i_sb` | `input wire` | `1` |
| `i_is_jal` | `input wire` | `1` |
| `i_is_addi` | `input wire` | `1` |
| `i_is_rr` | `input wire` | `1` |
| `i_is_ri` | `input wire` | `1` |
| `i_is_alu` | `input wire` | `1` |
| `i_is_sub` | `input wire` | `1` |
| `i_is_xor` | `input wire` | `1` |
| `i_is_adc` | `input wire` | `1` |
| `i_is_sbc` | `input wire` | `1` |
| `i_is_cmp` | `input wire` | `1` |
| `i_is_sra` | `input wire` | `1` |
| `i_is_sum` | `input wire` | `1` |
| `i_is_log` | `input wire` | `1` |
| `i_is_sr` | `input wire` | `1` |
| `i_is_getcc` | `input wire` | `1` |
| `i_restore_cc` | `input wire` | `1` |
| `i_reads_rd` | `input wire` | `1` |
| `i_reads_rs` | `input wire` | `1` |
| `i_writes_rd` | `input wire` | `1` |
| `i_is_load` | `input wire` | `1` |
| `i_is_store` | `input wire` | `1` |
| `i_uses_cc` | `input wire` | `1` |
| `i_uses_carry` | `input wire` | `1` |
| `i_updates_cc` | `input wire` | `1` |

**Outputs**

| Name | Type | Bits |
|---|---|---|
| `o_valid` | `output reg` | `1` |
| `o_pc` | `output reg` | `16` |
| `o_rd` | `output reg` | `4` |
| `o_rs` | `output reg` | `4` |
| `o_imm` | `output reg` | `4` |
| `o_i12` | `output reg` | `12` |
| `o_rd_data` | `output reg` | `16` |
| `o_rs_data` | `output reg` | `16` |
| `o_imm16` | `output reg` | `16` |
| `o_is_imm` | `output reg` | `1` |
| `o_is_bx` | `output reg` | `1` |
| `o_is_cli` | `output reg` | `1` |
| `o_is_sti` | `output reg` | `1` |
| `o_is_iret` | `output reg` | `1` |
| `o_irq_interlock` | `output reg` | `1` |
| `o_rf_we` | `output reg` | `1` |
| `o_lw` | `output reg` | `1` |
| `o_lb` | `output reg` | `1` |
| `o_sw` | `output reg` | `1` |
| `o_sb` | `output reg` | `1` |
| `o_is_jal` | `output reg` | `1` |
| `o_is_addi` | `output reg` | `1` |
| `o_is_rr` | `output reg` | `1` |
| `o_is_ri` | `output reg` | `1` |
| `o_is_alu` | `output reg` | `1` |
| `o_is_sub` | `output reg` | `1` |
| `o_is_xor` | `output reg` | `1` |
| `o_is_adc` | `output reg` | `1` |
| `o_is_sbc` | `output reg` | `1` |
| `o_is_cmp` | `output reg` | `1` |
| `o_is_sra` | `output reg` | `1` |
| `o_is_sum` | `output reg` | `1` |
| `o_is_log` | `output reg` | `1` |
| `o_is_sr` | `output reg` | `1` |
| `o_is_getcc` | `output reg` | `1` |
| `o_restore_cc` | `output reg` | `1` |
| `o_reads_rd` | `output reg` | `1` |
| `o_reads_rs` | `output reg` | `1` |
| `o_writes_rd` | `output reg` | `1` |
| `o_is_load` | `output reg` | `1` |
| `o_is_store` | `output reg` | `1` |
| `o_uses_cc` | `output reg` | `1` |
| `o_uses_carry` | `output reg` | `1` |
| `o_updates_cc` | `output reg` | `1` |

### pipe_ex_mem Contract

**RTL:** `srcs/m_pipe_ex_mem.v`

**Semantic Contract:** EX/MEM register. Supports stall and flush controls.

**Neighbors:** `ex_stage`, `mem_stage`, `hazard_unit`

**Inputs**

| Name | Type | Bits |
|---|---|---|
| `i_clk` | `input wire` | `1` |
| `i_rst` | `input wire` | `1` |
| `i_stall` | `input wire` | `1` |
| `i_flush` | `input wire` | `1` |
| `i_valid` | `input wire` | `1` |
| `i_pc` | `input wire` | `16` |
| `i_rd` | `input wire` | `4` |
| `i_rf_we` | `input wire` | `1` |
| `i_lw` | `input wire` | `1` |
| `i_lb` | `input wire` | `1` |
| `i_sw` | `input wire` | `1` |
| `i_sb` | `input wire` | `1` |
| `i_d_ad` | `input wire` | `16` |
| `i_store_data` | `input wire` | `16` |
| `i_wb_pre_data` | `input wire` | `16` |
| `i_flag_we` | `input wire` | `1` |
| `i_new_ccz` | `input wire` | `1` |
| `i_new_ccn` | `input wire` | `1` |
| `i_new_ccc` | `input wire` | `1` |
| `i_new_ccv` | `input wire` | `1` |
| `i_carry_we` | `input wire` | `1` |
| `i_new_c` | `input wire` | `1` |
| `i_updates_cc_hz` | `input wire` | `1` |
| `i_updates_carry_hz` | `input wire` | `1` |
| `i_is_load` | `input wire` | `1` |
| `i_is_iret` | `input wire` | `1` |

**Outputs**

| Name | Type | Bits |
|---|---|---|
| `o_valid` | `output reg` | `1` |
| `o_pc` | `output reg` | `16` |
| `o_rd` | `output reg` | `4` |
| `o_rf_we` | `output reg` | `1` |
| `o_lw` | `output reg` | `1` |
| `o_lb` | `output reg` | `1` |
| `o_sw` | `output reg` | `1` |
| `o_sb` | `output reg` | `1` |
| `o_d_ad` | `output reg` | `16` |
| `o_store_data` | `output reg` | `16` |
| `o_wb_pre_data` | `output reg` | `16` |
| `o_flag_we` | `output reg` | `1` |
| `o_new_ccz` | `output reg` | `1` |
| `o_new_ccn` | `output reg` | `1` |
| `o_new_ccc` | `output reg` | `1` |
| `o_new_ccv` | `output reg` | `1` |
| `o_carry_we` | `output reg` | `1` |
| `o_new_c` | `output reg` | `1` |
| `o_updates_cc_hz` | `output reg` | `1` |
| `o_updates_carry_hz` | `output reg` | `1` |
| `o_is_load` | `output reg` | `1` |
| `o_is_iret` | `output reg` | `1` |

### pipe_mem_wb Contract

**RTL:** `srcs/m_pipe_mem_wb.v`

**Semantic Contract:** MEM/WB register. Supports stall and flush controls.

**Neighbors:** `mem_stage`, `wb_stage`

**Inputs**

| Name | Type | Bits |
|---|---|---|
| `i_clk` | `input wire` | `1` |
| `i_rst` | `input wire` | `1` |
| `i_stall` | `input wire` | `1` |
| `i_flush` | `input wire` | `1` |
| `i_valid` | `input wire` | `1` |
| `i_rd` | `input wire` | `4` |
| `i_rf_we` | `input wire` | `1` |
| `i_wb_data` | `input wire` | `16` |
| `i_flag_we` | `input wire` | `1` |
| `i_new_ccz` | `input wire` | `1` |
| `i_new_ccn` | `input wire` | `1` |
| `i_new_ccc` | `input wire` | `1` |
| `i_new_ccv` | `input wire` | `1` |
| `i_carry_we` | `input wire` | `1` |
| `i_new_c` | `input wire` | `1` |
| `i_updates_cc_hz` | `input wire` | `1` |
| `i_updates_carry_hz` | `input wire` | `1` |
| `i_is_iret` | `input wire` | `1` |

**Outputs**

| Name | Type | Bits |
|---|---|---|
| `o_valid` | `output reg` | `1` |
| `o_rd` | `output reg` | `4` |
| `o_rf_we` | `output reg` | `1` |
| `o_wb_data` | `output reg` | `16` |
| `o_flag_we` | `output reg` | `1` |
| `o_new_ccz` | `output reg` | `1` |
| `o_new_ccn` | `output reg` | `1` |
| `o_new_ccc` | `output reg` | `1` |
| `o_new_ccv` | `output reg` | `1` |
| `o_carry_we` | `output reg` | `1` |
| `o_new_c` | `output reg` | `1` |
| `o_updates_cc_hz` | `output reg` | `1` |
| `o_updates_carry_hz` | `output reg` | `1` |
| `o_is_iret` | `output reg` | `1` |

## Support Modules

### ctrl_unit Contract

**RTL:** `srcs/m_ctrl_unit.v`

**Semantic Contract:** Decode/control metadata generator from instruction word.

**Neighbors:** `id_stage`

**Inputs**

| Name | Type | Bits |
|---|---|---|
| `i_insn` | `input wire` | `16` |

**Outputs**

| Name | Type | Bits |
|---|---|---|
| `o_rd` | `output wire` | `4` |
| `o_rs` | `output wire` | `4` |
| `o_fn` | `output wire` | `4` |
| `o_imm` | `output wire` | `4` |
| `o_cond` | `output wire` | `4` |
| `o_disp` | `output wire` | `8` |
| `o_i12` | `output wire` | `12` |
| `o_is_imm` | `output wire` | `1` |
| `o_is_bx` | `output wire` | `1` |
| `o_is_sys` | `output wire` | `1` |
| `o_is_cli` | `output wire` | `1` |
| `o_is_sti` | `output wire` | `1` |
| `o_is_jal` | `output wire` | `1` |
| `o_is_addi` | `output wire` | `1` |
| `o_is_rr` | `output wire` | `1` |
| `o_is_ri` | `output wire` | `1` |
| `o_is_lw` | `output wire` | `1` |
| `o_is_lb` | `output wire` | `1` |
| `o_is_sw` | `output wire` | `1` |
| `o_is_sb` | `output wire` | `1` |
| `o_is_alu` | `output wire` | `1` |
| `o_is_add` | `output wire` | `1` |
| `o_is_sub` | `output wire` | `1` |
| `o_is_and` | `output wire` | `1` |
| `o_is_xor` | `output wire` | `1` |
| `o_is_adc` | `output wire` | `1` |
| `o_is_sbc` | `output wire` | `1` |
| `o_is_cmp` | `output wire` | `1` |
| `o_is_srl` | `output wire` | `1` |
| `o_is_sra` | `output wire` | `1` |
| `o_is_sum` | `output wire` | `1` |
| `o_is_log` | `output wire` | `1` |
| `o_is_sr` | `output wire` | `1` |
| `o_is_setcc` | `output wire` | `1` |
| `o_is_getcc` | `output wire` | `1` |
| `o_is_iret` | `output wire` | `1` |
| `o_reads_rd` | `output wire` | `1` |
| `o_reads_rs` | `output wire` | `1` |
| `o_writes_rd` | `output wire` | `1` |
| `o_is_load` | `output wire` | `1` |
| `o_is_store` | `output wire` | `1` |
| `o_uses_cc` | `output wire` | `1` |
| `o_uses_carry` | `output wire` | `1` |
| `o_updates_cc` | `output wire` | `1` |
| `o_irq_interlock` | `output wire` | `1` |

### bdu Contract

**RTL:** `srcs/m_bdu.v`

**Semantic Contract:** Branch Decision Unit. Evaluates branch condition nibble against CC flags.

**Neighbors:** `id_stage`

**Inputs**

| Name | Type | Bits |
|---|---|---|
| `i_cond` | `input wire` | `4` |
| `i_ccz` | `input wire` | `1` |
| `i_ccn` | `input wire` | `1` |
| `i_ccc` | `input wire` | `1` |
| `i_ccv` | `input wire` | `1` |

**Outputs**

| Name | Type | Bits |
|---|---|---|
| `o_take` | `output wire` | `1` |

### alu Contract

**RTL:** `srcs/m_alu.v`

**Semantic Contract:** ALU combinational block (sum/logical/shift outputs).

**Neighbors:** `ex_stage`

**Inputs**

| Name | Type | Bits |
|---|---|---|
| `i_is_add` | `input wire` | `1` |
| `i_a` | `input wire` | `16` |
| `i_b` | `input wire` | `16` |
| `i_ci` | `input wire` | `1` |
| `i_is_xor` | `input wire` | `1` |
| `i_is_sra` | `input wire` | `1` |

**Outputs**

| Name | Type | Bits |
|---|---|---|
| `o_sum` | `output wire` | `16` |
| `o_log` | `output wire` | `16` |
| `o_sr` | `output wire` | `16` |
| `o_co` | `output wire` | `1` |
| `o_x` | `output wire` | `1` |

### addsub Contract

**RTL:** `srcs/m_alu.v`

**Semantic Contract:** Add/Sub primitive used by ALU for arithmetic carry path.

**Neighbors:** `alu`, `ex_stage`

**Inputs**

| Name | Type | Bits |
|---|---|---|
| `i_add` | `input wire` | `1` |
| `i_ci` | `input wire` | `1` |
| `i_a` | `input wire` | `16` |
| `i_b` | `input wire` | `16` |

**Outputs**

| Name | Type | Bits |
|---|---|---|
| `o_sum` | `output wire` | `16` |
| `o_x` | `output wire` | `1` |
| `o_co` | `output wire` | `1` |

### regfile16x16 Contract

**RTL:** `srcs/m_regfile16x16.v`

**Semantic Contract:** 2R1W register file. Writes to r0 are ignored.

**Neighbors:** `id_stage`, `wb_stage`

**Inputs**

| Name | Type | Bits |
|---|---|---|
| `i_clk` | `input wire` | `1` |
| `i_we` | `input wire` | `1` |
| `i_wa` | `input wire` | `4` |
| `i_ra` | `input wire` | `4` |
| `i_rb` | `input wire` | `4` |
| `i_wd` | `input wire` | `16` |

**Outputs**

| Name | Type | Bits |
|---|---|---|
| `o_ra` | `output wire` | `16` |
| `o_rb` | `output wire` | `16` |

### pc_next Contract

**RTL:** `srcs/m_pc_next.v`

**Semantic Contract:** PC-next mux with priority reset > IRQ > branch > sequential(+2).

**Neighbors:** `if_stage`, `cpu`

**Inputs**

| Name | Type | Bits |
|---|---|---|
| `i_rst` | `input wire` | `1` |
| `i_rst_vec` | `input wire` | `16` |
| `i_pc` | `input wire` | `16` |
| `i_hit` | `input wire` | `1` |
| `i_branch_take` | `input wire` | `1` |
| `i_branch_target` | `input wire` | `16` |
| `i_irq_take` | `input wire` | `1` |
| `i_irq_vector` | `input wire` | `16` |

**Outputs**

| Name | Type | Bits |
|---|---|---|
| `o_pc_next` | `output wire` | `16` |

### hazard_unit Contract

**RTL:** `srcs/m_hazard_unit.v`

**Semantic Contract:** Hazard controller for RAW/load-use/CC/carry + mem-wait and IRQ accept gating.

**Neighbors:** `cpu`, `pipeline registers`

**Inputs**

| Name | Type | Bits |
|---|---|---|
| `i_id_valid` | `input wire` | `1` |
| `i_id_rd` | `input wire` | `4` |
| `i_id_rs` | `input wire` | `4` |
| `i_id_reads_rd` | `input wire` | `1` |
| `i_id_reads_rs` | `input wire` | `1` |
| `i_id_uses_cc` | `input wire` | `1` |
| `i_id_uses_carry` | `input wire` | `1` |
| `i_branch_take` | `input wire` | `1` |
| `i_mem_wait` | `input wire` | `1` |
| `i_irq_take` | `input wire` | `1` |
| `i_idex_valid` | `input wire` | `1` |
| `i_idex_rf_we` | `input wire` | `1` |
| `i_idex_rd` | `input wire` | `4` |
| `i_idex_is_load` | `input wire` | `1` |
| `i_idex_updates_cc` | `input wire` | `1` |
| `i_idex_updates_carry` | `input wire` | `1` |
| `i_exmem_valid` | `input wire` | `1` |
| `i_exmem_rf_we` | `input wire` | `1` |
| `i_exmem_rd` | `input wire` | `4` |
| `i_exmem_updates_cc` | `input wire` | `1` |
| `i_exmem_updates_carry` | `input wire` | `1` |
| `i_memwb_valid` | `input wire` | `1` |
| `i_memwb_rf_we` | `input wire` | `1` |
| `i_memwb_rd` | `input wire` | `4` |
| `i_memwb_updates_cc` | `input wire` | `1` |
| `i_memwb_updates_carry` | `input wire` | `1` |

**Outputs**

| Name | Type | Bits |
|---|---|---|
| `o_stall_if` | `output wire` | `1` |
| `o_stall_id` | `output wire` | `1` |
| `o_stall_ex` | `output wire` | `1` |
| `o_bubble_ex` | `output wire` | `1` |
| `o_flush_ifid` | `output wire` | `1` |
| `o_flush_idex` | `output wire` | `1` |
| `o_accept_irq` | `output wire` | `1` |

## Stall/Bubble/Flush Logic Contract

**RTL:** `srcs/m_hazard_unit.v` (integrated by `srcs/m_cpu.v`)

**Semantic Contract:**
- `stall_if` and `stall_id`: assert on `mem_wait` OR decode hazard.
- `stall_ex`: asserts only on `mem_wait`.
- `bubble_ex`: asserts only for decode hazards when `mem_wait=0`.
- `flush_ifid`: asserts on taken branch commit or accepted IRQ.
- `flush_idex`: asserts on accepted IRQ.
- `accept_irq`: `i_irq_take & ~i_mem_wait` (deferred during memory wait).

**Decode Hazard Predicates:**
- `raw_hazard`: source register dependency on pending destination in ID/EX, EX/MEM, MEM/WB.
- `load_use_hazard`: ID consumes result of load still in ID/EX.
- `cc_hazard`: ID instruction consumes CC while CC update is in-flight.
- `carry_hazard`: ID instruction consumes carry while carry update is in-flight.
- `decode_hazard = raw_hazard | load_use_hazard | cc_hazard | carry_hazard`.

**Important Guard (current):**
- `load_use_hazard` ignores producer `rd=r0` to avoid false stalls (`r0` is constant-zero).

**Current Policy/Phase of implementation:**
- Bubble-first in v1 (no forwarding in active datapath yet).

## Suggested Next Steps (Next Rotation)

1. ¡First make sure everything works :thumbsup: !
2. Implement forwarding (v2) for ALU dependencies (`EX/MEM` and `MEM/WB` to EX inputs) and keep load-use stall as fallback.
3. Add explicit CC/carry forwarding or keep current interlock path and document measured CPI impact on branch-heavy code. Por outras palavras, if it it gets too complicated, screw it all and just stall on load-use for now.
4. Finalize the decision branch-prediction strategy (e.g. static predict-not-taken cleanup is the original idea) and measure misprediction penalty with existing branch tests (how many instuctions are clobbered).

If you manage this, good work!  If not, good work! Either way, 
5. make sure to check timing after forwarding mux insertion (WNS/WHS) and update ILA probes only for critical pipeline signals.
6. Update this guide after every semantic change (ports, hazard predicates, or stage ownership) to keep biweekly handoff friction low.
