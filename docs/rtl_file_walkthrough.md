# RTL File Walkthrough (All Verilog Files)

_Last reviewed: 2026-02-07_

This walkthrough covers every `.v` file in:
- `srcs/`
- `sim/`

For each module: purpose, signal contract (inputs/outputs), and behavior summary.

## 1. File: srcs/m_soc.v
**Module:** soc
### Purpose
- Top-level SoC wrapper integrating CPU (`gr0041`), BRAM, MMIO peripheral bus, and board IO.

### Inputs
- `clk`, `rst`
- `par_i[3:0]` (parallel input pins)
- `uart_rx`

### Outputs
- `par_o[3:0]` (parallel output pins)
- `uart_tx`

### Contract
- Instruction fetch path is registered (`insn_q`) to match synchronous BRAM.
- `hit` is effectively constant 1 when not in reset (`hit = ~rst`), so there is no instruction-cache miss model in this harness.
- `imem_invalid` detection treats an all-zero instruction word as invalid and injects NOP in that case.
- On branch taken, inserted instruction is NOP (`0xF000`) to annul fall-through.
- `d_ad[15]` selects memory (`0`) vs MMIO (`1`).
- `cpu_di` and `rdy` are multiplexed between BRAM and MMIO domains.
- BRAM data port writes use byte enables:
  - `mem_we_h` and `mem_we_l` generated from store type and address lane bits.
- Load latency/handshake:
  - BRAM reads are registered (1-cycle). The SoC uses an internal `loaded` flag so `rdy` stalls the core on `LW/LB` until data is valid.

### Refactor hooks
- Clean insertion point for deeper fetch/decode pipeline stages.
- MMIO regioning is centralized here through `periph_bus`.

## 2. File: srcs/m_gr0041.v
**Module:** gr0041
### Purpose
- Interrupt-aware wrapper around `gr0040` CPU core.
- Tracks ISR nesting depth and exposes `in_irq` signal to SoC logic.

### Inputs
- `clk`, `rst`, `i_ad_rst`
- Instruction side: `insn`, `hit`
- Data side: `rdy`, `data_in`
- IRQ side: `irq_take`, `irq_vector`

### Outputs
- Instruction side: `insn_ce`, `i_ad`
- Data side: `d_ad`, `sw`, `sb`, `lw`, `lb`, `data_out`
- IRQ side: `in_irq`, `int_en`, `iret_detected`
- Control: `br_taken`

### Contract
- For `{irq_take, iret_detected}`:
  - `10`: depth++ (enter ISR)
  - `01`: depth-- (exit ISR)
  - `11`: depth unchanged
- `in_irq` is asserted when depth nonzero or a new IRQ is currently being taken.

## 3. File: srcs/m_gr0040.v
**Modules:** control_unit, gr0040, datapath, addsub, ram16x16d

### 3.1 Module: control_unit
### Purpose
- Instruction decode and control generation.

### Inputs
- `clk`, `rst`
- `insn[15:0]`, `hit`, `rdy`
- condition flags: `ccz`, `ccn`, `ccc`, `ccv`
- `irq_take`

### Outputs
- decoded fields: `op`, `rd`, `rs`, `fn`, `imm`, `i12`, `cond`, `disp`
- flow controls: `insn_ce`, `exec_ce`, `valid_insn_ce`, `br_taken`
- register controls: `rf_we`, `imm_pre`, `i12_pre`
- memory strobes: `lw`, `lb`, `sw`, `sb`
- interrupt controls: `int_en`, `irq_save`, `iret_detected`
- status control: `restore_cc`

### Contract
- Stalls when memory op in progress and `rdy==0`.
- Tracks IMM prefix (`imm_pre`/`i12_pre`) for wide immediate/address formation.
- Branch decision from condition nibble and flags.
- Global interrupt enable latch (`gie`):
  - reset -> enabled,
  - clear on interrupt take,
  - cleared by `CLI`, set by `STI`.
- `int_en` is masked during interlocked sequences (`IMM`, and ALU ops using carry/compare interlock path).
- `iret_detected` currently matches exact word `16'h0EE0`.

### 3.2 Module: gr0040
### Purpose
- CPU top that binds `control_unit` and `datapath`.

### Inputs
- `clk`, `rst`, `i_ad_rst`
- instruction input: `insn[15:0]`, `hit`
- memory handshake: `rdy`
- data input: `data_in[15:0]`
- IRQ control: `irq_take`, `irq_vector[15:0]`

### Outputs
- instruction side: `insn_ce`, `i_ad[15:0]`
- data side: `d_ad[15:0]`, `sw`, `sb`, `lw`, `lb`, `data_out[15:0]`
- control: `int_en`, `br_taken`, `iret_detected`

### Contract
- CPU core itself does not arbitrate memory vs MMIO; SoC provides that at higher level.

### 3.3 Module: datapath
### Purpose
- Implements PC, register file, ALU, flags/PSW, and effective address generation.

### Inputs
- control: `op, rd, rs, fn, imm, i12, cond, disp`
- enables: `valid_insn_ce`, `exec_ce`, `rf_we`
- prefix state: `imm_pre`, `i12_pre`
- flow/interrupt: `br_taken`, `irq_take`, `irq_save`, `irq_vector`, `restore_cc`
- data input: `data_in[15:0]`
- `clk`, `rst`, `hit`, `i_ad_rst`

### Outputs
- `data_out[15:0]` (store data)
- `i_ad[15:0]` (next instruction address)
- `d_ad[15:0]` (effective load/store address)
- flags: `ccz`, `ccn`, `ccc`, `ccv`

### Contract
- Register file writeback source select:
  - load data for `LW/LB`
  - ALU result for ALU ops
  - hardware PC save into `r14` on interrupt entry (`irq_save`)
  - PSW snapshot on `GETCC`
- PC target priority:
  1. reset vector path
  2. interrupt vector (`irq_take`)
  3. JAL target
  4. sequential/branch path
- Flags updated on arithmetic/compare class and restored on `SETCC`.
- Carry latch is managed for `ADC/SBC` chaining.
- Effective data address is computed as `d_ad = (sum << 1)`.
- Byte ops:
  - SoC lane selection uses `d_ad[0]`.
  - With current datapath shift, core-generated accesses keep `d_ad[0]=0` (high lane).

### 3.4 Module: addsub
### Purpose
- Shared adder/subtractor helper used by datapath.

### Inputs
- `add` select, carry input `ci`, operands `a[15:0]`, `b[15:0]`

### Outputs
- `sum[15:0]`, `co`, and extra `x` bit

### Contract
- Central arithmetic primitive for add/sub paths used in ALU and address generation.

### 3.5 Module: ram16x16d
### Purpose
- 16x16 register file with one read port + write port and writeback mirror.

### Inputs
- `clk`, `we`
- `wr_ad[3:0]`, `ad[3:0]`
- `d[15:0]`

### Outputs
- `wr_o[15:0]` (content at write address)
- `o[15:0]` (content at read address)

### Contract
- `r0` is read-only zero (`wr_ad==0` write is blocked).
- Includes debug mirrors for each architectural register alias.

## 4. File: srcs/m_periph_bus.v
**Module:** periph_bus
### Purpose
- MMIO fabric for timers, PARIO, UART MMIO, and IRQ controller.

### Inputs
- bus controls: `clk`, `rst`, `addr[15:0]`, `sel`, `we`, `re`, `wdata[15:0]`
- external IO: `par_i[3:0]`, `uart_rx`
- IRQ context from CPU: `int_en`, `in_irq`, `irq_ret`

### Outputs
- bus return: `rdata[15:0]`, `rdy`
- external IO: `par_o[3:0]`, `uart_tx`
- IRQ outputs to CPU: `irq_vector[15:0]`, `irq_take`

### Contract
- MMIO subregion decode by `addr[11:8]`.
- `rdy`/`rdata` are selected from active peripheral block.
- Builds `int_cause[7:0]` from peripheral interrupt request lines.
- Instantiates and wires `irq_ctrl` as interrupt arbiter/vector source.

## 5. File: srcs/m_irq_ctrl.v
**Module:** irq_ctrl
### Purpose
- Vectored interrupt controller with mask/pending logic and fixed-priority selection.

### Inputs
- MMIO bus: `clk`, `rst`, `sel`, `we`, `re`, `wdata[15:0]`, `addr[2:0]`
- IRQ sources and CPU state: `src_irq[7:0]`, `in_irq`, `int_en`, `irq_ret`

### Outputs
- MMIO response: `rdata[15:0]`, `rdy`
- interrupt outputs: `irq_take`, `irq_vector[15:0]`

### Contract
- `pending` latches masked requests; `servicing` avoids immediate re-latch while line remains asserted.
- Note: `in_irq` is currently not used by the selection logic; nesting/preemption is tracked via internal `depth`/`pri_stack`.
- Priority policy: higher source index wins (currently IRQ[3:0] actively encoded).
- IRQ is taken when pending exists, interrupts enabled, and preemption is allowed by depth/priority stack.
- Depth/priority stack supports nested interrupts up to `DEPTH=2`.
- Vector map: IRQ0->0x0020, IRQ1->0x0040, IRQ2->0x0060, IRQ3->0x0080.

### MMIO contract
- `rdy = sel` (single-cycle selected access).
- Read registers include pending/mask views.
- Write registers support mask, force, clear operations.

## 6. File: srcs/m_timer16.v
**Module:** timer16
### Purpose
- 16-bit timer peripheral with overflow interrupt latch.

### Inputs
- `clk`, `rst`, `sel`, `we`, `re`
- `addr[1:0]` register index
- `wdata[15:0]`

### Outputs
- `rdata[15:0]`, `rdy`, `int_req`

### Contract
- CR0 (`addr=0`): control (`int_en`, `timer_mode`).
- CR1 (`addr=1`): interrupt request status (write clears).
- CNT (`addr=2`): counter readback.
- `rdy = sel` (single-cycle MMIO when selected).

## 7. File: srcs/m_timerH.v
**Module:** timerH
### Purpose
- Second timer instance used as higher-priority interrupt source for nesting tests.

### Inputs/Outputs
- Same interface contract as `timer16`.

### Contract differences vs timer16
- Different reset defaults to trigger relative timing useful for nested IRQ demos.
  - Note: `timerH` resets with `int_en` asserted (enabled) in current RTL.

## 8. File: srcs/m_pario.v
**Module:** pario
### Purpose
- Simple parallel IO block (4-bit in/out) with synthetic interrupt condition.

### Inputs
- `clk`, `rst`, `sel`, `we`, `re`
- `addr[1:0]`, `wdata[15:0]`
- external input `i[3:0]`

### Outputs
- `rdata[15:0]`, `rdy`
- output register `o[3:0]`
- interrupt request `int_req`

### Contract
- Write at `addr=0` updates output nibble.
- Read at `addr=0` returns output register; `addr=2` returns input nibble.
- `int_req` combinationally asserted when all inputs high (`i==4'hF`).

## 9. File: srcs/m_uart_tx.v
**Module:** uart_tx
### Purpose
- UART transmitter (8N1 style framing) with start/done/busy signaling.

### Inputs
- `clk`, `rst`
- `data[7:0]`
- `tx_start`

### Outputs
- `tx_out` serial line
- `tx_done` one-cycle completion pulse
- `tx_busy`
- `state_debug[1:0]`

### Contract
- FSM states: IDLE -> START -> DATA -> STOP.
- LSB-first data transmission.
- Bit timing from `CLK_FREQ` and `BAUD_RATE` parameters.

## 10. File: srcs/m_uart_rx.v
**Module:** uart_rx
### Purpose
- UART receiver with synchronizer and mid-bit sampling.

### Inputs
- `clk`, `rst`
- `rx_in`

### Outputs
- `data[7:0]`
- `data_valid` one-cycle pulse when byte accepted
- `rx_out` debug current sampled bit
- `rx_done` completion pulse
- `rx_busy`
- `state_debug[1:0]`

### Contract
- Uses 2-flop synchronizer (`rx_sync1`, `rx_sync2`) for asynchronous RX pin.
- Validates start bit mid-sample and stop bit before raising `data_valid`.

## 11. File: srcs/m_uart_mmio.v
**Module:** uart_mmio
### Purpose
- MMIO wrapper that connects UART RX/TX datapaths to CPU bus and IRQ line.

### Inputs
- `clk`, `rst`, `sel`, `we`, `re`
- `addr[1:0]`, `wdata[15:0]`
- `rx_in`

### Outputs
- `rdata[15:0]`, `rdy`
- `tx_out`
- `irq_req`

### Contract
- `rdy = sel`.
- RX path:
  - latched byte in `rx_data`
  - `rx_pending` flag set on received byte
  - reading data register or explicit status clear can clear pending
- TX path:
  - write data register triggers `tx_start` if transmitter is not busy
- `irq_req` is high whenever `rx_pending==1`.
- Addressing note:
  - UART registers are word-aligned on the system bus (offsets `+0x00` and `+0x02`).
  - `periph_bus` passes `addr[1:0]` into `uart_mmio`; `addr==2'b01` maps to byte offset `+0x02`.

## 12. File: srcs/m_bram.v
**Module:** bram_1kb_be
### Purpose
- Inferred true-dual-port 1 KiB BRAM model with separate hi/lo byte arrays.

### Inputs
- global: `clk`, `rst`
- Port A (instruction): `a_en`, `a_addr[9:1]`
- Port B (data): `b_en`, `b_we_h`, `b_we_l`, `b_addr[9:1]`, `b_din_h[7:0]`, `b_din_l[7:0]`

### Outputs
- Port A data: `a_dout_h[7:0]`, `a_dout_l[7:0]`
- Port B data: `b_dout_h[7:0]`, `b_dout_l[7:0]`

### Contract
- One-cycle registered read behavior on both ports.
- Byte-enable writes on data port.
- Initializes memory to NOP pattern (`F0 00`) and then loads hi/lo hex files with `$readmemh`.
  - Current defaults are hardcoded absolute paths in non-`SIM` builds.
  - `SIM` builds use a relative `../../../../srcs/mem/...` path.

## 13. File: sim/tb_Soc.v
**Module:** tb_Soc
### Purpose
- SoC integration testbench for top-level `soc`.

### External ports
- None (self-contained testbench).

### Behavior summary
- Instantiates full SoC and drives clock/reset.
- Optional UART stimulation via plusarg: `+UART_BYTE=xx`.
- Conditional compile regions allow:
  - direct forced MMIO tests (`TB_UART_MMIO_TEST`)
  - internal signal monitoring (`TB_USE_INTERNALS`)
- Text monitoring is always enabled (`$monitor`), with extra internal signals when `TB_USE_INTERNALS` is defined.
- VCD dump is always enabled to `waves_soc.vcd`.

## End of walkthrough
