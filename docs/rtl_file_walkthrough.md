# RTL File Walkthrough (Current Refactor)

_Last reviewed: 2026-02-07_

This walkthrough documents the current RTL structure under:
- `srcs/`
- `sim/`

The project now uses explicit module separation:
- integrated CPU composition in `m_cpu.v` (control + datapath + IRQ depth)
- control unit in `m_ctrl_unit.v`
- datapath in `m_datapath.v`
- ALU helper in `m_alu.v`
- register file in `m_regfile16x16.v`

## 1. File: srcs/m_soc.v
**Module:** `soc`
### Purpose
- Top-level SoC integration.

### Contract
- Instantiates CPU, BRAM, and peripheral bus.
- Uses registered instruction latch (`_insn_q`) for synchronous BRAM fetch.
- Injects NOP on taken branch (fall-through annul).
- Splits data path into memory vs MMIO by `_d_ad[15]`.
- Byte-lane policy for core-generated `LB/SB`:
  - lane select from `_d_ad[1]`
  - `LB` readback is zero-extended selected byte
  - `SB` stores low byte (`_cpu_do[7:0]`) into selected lane.

## 2. File: srcs/m_cpu.v
**Module:** `cpu`
### Purpose
- Integrates control unit and datapath, and tracks interrupt nesting state exported as `o_in_irq`.

### Contract
- Saturating IRQ depth tracking (no underflow on stray `IRET`).
- `o_in_irq` reflects post-update depth state.
- Exposes memory/control pins to SoC (`o_d_ad`, `o_sw`, `o_lw`, etc.).

## 3. File: srcs/m_ctrl_unit.v
**Module:** `ctrl_unit`
### Purpose
- Decode and control generation.

### Contract
- Decodes opcode/function fields.
- Generates memory strobes (`o_lw/o_lb/o_sw/o_sb`) and writeback enable.
- Controls pipeline enables (`o_insn_ce`, `o_exec_ce`).
- Maintains IMM prefix state (`o_imm_pre`, `o_i12_pre`).
- Exports execution qualifiers (`o_is_*`) to datapath to avoid duplicate decode logic.
- Implements branch condition evaluation.
- Manages global interrupt enable (`CLI/STI` and automatic clear on interrupt accept).
- Detects `IRET` encoding (`CPU_IRET_INSN`).

## 4. File: srcs/m_datapath.v
**Module:** `datapath`
### Purpose
- Stateful execution datapath.

### Contract
- Contains PC, flags, carry latch, regfile interface, and ALU data path.
- Consumes control-provided execution qualifiers (`i_is_*`) and does not decode opcode/function fields locally.
- Handles interrupt PC save and interrupt vector redirection.
- Exports `o_i_ad` and `o_d_ad`.
- Current address formulation: `o_d_ad = (_sum << 1)`.

## 5. File: srcs/m_alu.v
**Modules:** `alu`, `addsub`
### Purpose
- Combinational ALU primitives.

### Contract
- `addsub` performs add/sub with carry-in/out/x.
- `alu` outputs arithmetic (`o_sum`), logical (`o_log`), and shift (`o_sr`) results.

## 6. File: srcs/m_regfile16x16.v
**Module:** `regfile16x16`
### Purpose
- 16x16 register file with debug mirrors.

### Contract
- Write blocked for `r0` (`i_wr_ad == 0`).
- Exposes mirrors `_r0.._gp` for debug/ILA.
- Dual read exposure: selected source (`o_o`) and write-address mirror (`o_wr_o`).

## 7. File: srcs/m_bram.v
**Module:** `bram_1kb_be`
### Purpose
- 1 KiB byte-sliced dual-port BRAM model.

### Contract
- Port A: instruction fetch.
- Port B: data access with independent hi/lo byte enables.
- Loads init files using mode-specific paths:
  - CI (`SIM+CI`): `srcs/mem/mem_hi.hex`, `srcs/mem/mem_lo.hex`
  - Vivado behavioral sim (`SIM`): `../../../../srcs/mem/mem_hi.hex`, `../../../../srcs/mem/mem_lo.hex`
  - synthesis/implementation default: absolute paths or `BRAM_MEM_HI_PATH`/`BRAM_MEM_LO_PATH` overrides.

## 8. File: srcs/m_periph_bus.v
**Module:** `periph_bus`
### Purpose
- MMIO decode and peripheral integration.

### Contract
- Decode by `i_addr[11:8]`:
  - `0x0`: Timer0 (`timer16`)
  - `0x1`: Timer1 (`timerH`)
  - `0x2`: PARIO
  - `0x3`: UART MMIO
  - `0xF`: IRQ controller
- Multiplexes `o_rdata` / `o_rdy` from selected block.
- Builds IRQ source vector for `irq_ctrl`.

## 9. File: srcs/m_irq_ctrl.v
**Module:** `irq_ctrl`
### Purpose
- Fixed-priority vectored IRQ controller with limited nesting.

### Contract
- Tracks `pending`, `mask`, and `servicing` bits.
- Priority encoder (higher index wins among implemented IRQs).
- Vector map:
  - IRQ0 -> `0x0020`
  - IRQ1 -> `0x0040`
  - IRQ2 -> `0x0060`
  - IRQ3 -> `0x0080`
- Maintains priority stack for nesting depth `DEPTH=2`.

## 10. File: srcs/m_timer16.v
**Module:** `timer16`
### Purpose
- Timer0 peripheral.

### Register map (`i_addr[1:0]`)
- `00`: CR0 (`int_en`, `timer_mode`)
- `01`: CR1 (`int_req`, write clears)
- `10`: CNT_INIT (start/reload value, read/write)
- `11`: CNT (live counter readback)

### Contract
- Writing CNT_INIT also updates live counter immediately.
- Overflow reloads from CNT_INIT.

## 11. File: srcs/m_timerH.v
**Module:** `timerH`
### Purpose
- Timer1 (higher-priority interrupt source).

### Contract
- Same register interface as `timer16`.
- Different reset defaults to generate earlier IRQ timing for nesting/preemption testing.

## 12. File: srcs/m_pario.v
**Module:** `pario`
### Purpose
- 4-bit parallel IO peripheral.

### Contract
- `addr=0`: read/write output nibble.
- `addr=2`: read input nibble.
- Asserts IRQ when input nibble is all ones (`i_i == 4'hF`).

## 13. File: srcs/m_uart_mmio.v
**Module:** `uart_mmio`
### Purpose
- UART RX/TX core + MMIO register interface.

### Register map (`i_addr[1:0]`)
- `00`: DATA (read RX byte / write TX byte)
- `01`: STATUS (`tx_busy`, `rx_pending`; write bit1 clears pending)

### Contract
- RX pending drives `o_irq_req`.

## 14. Files: srcs/m_uart_rx.v, srcs/m_uart_tx.v
**Modules:** `uart_rx`, `uart_tx`
### Purpose
- Standalone UART receiver/transmitter FSMs.

### Contract
- Parameterized by `CLK_FREQ`, `BAUD_RATE`.
- `uart_tx`: IDLE/START/DATA/STOP with `o_tx_busy` and `o_tx_done`.
- `uart_rx`: synchronizer + mid-bit sampling + `o_data_valid` pulse.

## 15. File: srcs/constants.vh
### Purpose
- Shared opcode/function/width/reset constants.

### Contract
- Included by CPU-related modules.
- Defines canonical values such as `CPU_RESET_VEC`, `CPU_NOP_INSN`, `CPU_IRET_INSN`.

## 16. Simulation Files
### `sim/tb_timer_start_reg.v`
- Validates timer start/reload register behavior for `timer16` and `timerH`.

### `sim/tb_anchor_preemption_abi.v`
- Verifies two anchors:
  - nested preemption (`timer1` preempts `timer0`)
  - ABI preservation/restoration (`s0=0x0123`, `s1=0x4567`).

### `sim/tb_soc_refactor_regression.v`
- SoC-level regression for IRQ/MMIO activity after refactor.

### `sim/tb_soc_branch_annul.v`
- SoC-level corner-case regression that checks fall-through annul (`insn_q` forced to NOP) after taken branches.

### `sim/tb_Soc.v`
- General SoC smoke bench with optional internal tracing and UART MMIO helper mode.
