# Processor Architecture and Memory Notes

_Last reviewed: 2026-02-16_

## 1. System Partition
- CPU composition:
  - `cpu` in `srcs/m_cpu.v` integrates `ctrl_unit` + `datapath` and tracks interrupt nesting depth (`in_irq`).
- Datapath/control implementation files:
  - `srcs/m_ctrl_unit.v`, `srcs/m_datapath.v`, `srcs/m_alu.v`, `srcs/m_regfile16x16.v`.
- SoC top: `soc` in `srcs/m_soc.v`
  - Integrates CPU module, BRAM, peripheral bus, UART/pario pins, and I2C pins.
- Peripheral bus: `periph_bus` in `srcs/m_periph_bus.v`
  - Decodes MMIO regions, multiplexes read data and ready, instantiates IRQ controller.
- Interrupt controller: `irq_ctrl` in `srcs/m_irq_ctrl.v`
  - Pending/mask/service tracking, priority encoder, vector generation, nesting stack.

## 2. Clocking and Reset Behavior
- All major blocks are synchronous to one clock domain (`clk`).
- Reset is active-high and used synchronously in most always blocks.
- CPU reset vector target is `0x0100`.
  - Datapath initializes `pc` to `0x0100 - 2` so the first next-PC step lands at `0x0100`.

## 3. Addressing Model
- Architectural word size: 16 bits.
- BRAM storage is byte-sliced as high and low 8-bit arrays.
- Instruction addresses (PC / `i_ad`) are byte addresses.
  - Sequential fetch increments PC by 2 bytes per instruction.
- Current datapath generates data/MMIO address as `d_ad = (sum << 1)` in `srcs/m_datapath.v`.
  - Effective accesses are therefore even-byte-aligned at the SoC boundary.
- BRAM uses word index `addr[9:1]`.
- Byte lanes (big-endian within a 16-bit word):
  - high lane (MSB) and low lane (LSB) are selected in SoC glue for byte operations via `d_ad[1]`.
- `LB` returns zero-extended selected byte.
- `SB` stores `data_out[7:0]` into the selected byte lane.

## 4. Instruction Path (Harvard-style)
- BRAM Port A serves instruction fetch.
- SoC registers fetched instruction into `insn_q` (instruction latch).
- SoC treats an all-zero fetched instruction word (`0x0000`) as invalid and injects NOP in that case.
- If a branch is taken, SoC injects NOP (`0xF000`) into `insn_q` to annul fall-through.
- CPU stalls on load-use handshake using `rdy` logic.

## 5. Data Path (Memory vs MMIO)
- MMIO select is by MSB: `is_io = d_ad[15]`.
- Data returned to CPU:
  - memory read data when `is_io=0`
  - peripheral read data when `is_io=1`
- Ready returned to CPU:
  - memory ready (`mem_rdy`) for BRAM accesses
  - peripheral ready (`io_rdy`) for MMIO accesses
- Software note:
  - Assembly commonly uses pre-shift constants in the current codebase (for example, `0x4000` maps to MMIO `0x8000` after the datapath shift).

## 6. Global Address Map (byte addresses)
- `0x0000`: interrupt return stub area used by software conventions.
- `0x0020 - 0x003F`: IRQ0 vector (Timer0)
- `0x0040 - 0x005F`: IRQ1 vector (Timer1)
- `0x0060 - 0x007F`: IRQ2 vector (PARIO)
- `0x0080 - 0x009F`: IRQ3 vector (UART)
- `0x00A0 - 0x00BF`: IRQ4 vector (I2C)
- `0x0100 - 0x02FF`: main code region
- `0x0300 - 0x03FF`: stack region in bytes (128 words)
  - Recommended: keep `sp` word-aligned (even) and initialize it to one-past-end `0x0400`.
- `0x8000 - 0x8FFF`: MMIO region (`d_ad[15]=1`)
- `0x8F00 - 0x8FFF`: IRQ controller block inside MMIO

## 7. MMIO Peripheral Decode (`addr[11:8]`)
- `0x0`: Timer0 (`0x8000 - 0x80FF`)
- `0x1`: Timer1 / high-priority timer (`0x8100 - 0x81FF`)
- `0x2`: PARIO (`0x8200 - 0x82FF`)
- `0x3`: UART MMIO (`0x8300 - 0x83FF`)
- `0x4`: I2C MMIO (`0x8400 - 0x84FF`)
- `0xF`: IRQ controller (`0x8F00 - 0x8FFF`)

## 8. Timer Register View (Timer0 base `0x8000`, Timer1 base `0x8100`)
- +0x00 (CR0): control
  - bit0 = `int_en`
  - bit1 = `timer_mode`
- +0x02 (CR1): status/ack
  - bit0 = `int_req`
  - write clears request latch
- +0x04 (CNT_INIT): start/reload counter value (read/write)
  - writing also loads current counter immediately
- +0x06 (CNT): live counter readback (debug)

## 9. PARIO Register View (base `0x8200`)
- +0x00: output register write (`o[3:0]`), readback output value
- +0x02: input sample read (`i[3:0]`)
- IRQ behavior: asserts `int_req=1` when all four inputs are high (`i==4'hF`).

## 10. UART MMIO Register View (base `0x8300`, current RTL)
- UART registers are word-aligned and decoded by word index (`periph_bus` passes `i_addr[2:1]` into `uart_mmio`):
  - +0x00: RX data read / TX data write
  - +0x02: status (`tx_busy`, `rx_pending`) and clear-on-write behavior
- `irq_req` is asserted when RX pending is set.

## 11. IRQ Controller Programming Model (base `0x8F00`)
- `IRQ_PEND` (read): pending bits [7:0]
- `IRQ_MASK` (read/write): enable mask [7:0]
- `IRQ_FORCE` (write): set pending bits
- `IRQ_CLEAR` (write): clear pending bits
- Priority: fixed, higher IRQ index wins among implemented IRQ[4:0].
- Current vector mapping:
  - IRQ0 -> `0x0020` (Timer0)
  - IRQ1 -> `0x0040` (Timer1)
  - IRQ2 -> `0x0060` (PARIO)
  - IRQ3 -> `0x0080` (UART)
  - IRQ4 -> `0x00A0` (I2C)

## 12. I2C MMIO Register View (base `0x8400`)
- `i2c_mmio` is word-aligned and decoded by `i_addr[3:1]`:
  - +0x00: `I2C_CTRL` (`en`, `start`, `rw`, `irq_en`)
  - +0x02: `I2C_STATUS` (`busy`, `done`, `ack_err`, `rx_valid`, `irq_pend`)
  - +0x04: `I2C_DIV` (16-bit divider)
  - +0x06: `I2C_ADDR` (7-bit address in bits `[7:1]`)
  - +0x08: `I2C_LEN` (byte count)
  - +0x0A: `I2C_DATA` (TX push / RX pop)
- STATUS write-one-to-clear:
  - bit1 clears `done`
  - bit2 clears `ack_err`
  - bit3 flushes RX FIFO
  - bit4 clears `irq_pend`
- `irq_pend` is set on `done` or `ack_err` when `irq_en=1`.

## 13. Interrupt Acceptance Rules
- `irq_take` requires:
  - at least one pending source,
  - CPU `int_en=1`,
  - preemption allowed by current nesting priority.
- CPU interrupt entry behavior:
  - saves return PC to `r14` (`lr`) via hardware path,
  - redirects PC to `irq_vector`,
  - clears global interrupt enable latch (`gie`) until software re-enables.

## 14. SoC Contracts Relevant for Refactor
- Instruction fetch is currently one-stage registered at SoC boundary (`insn_q`).
- Memory/IO share CPU load-store path via `cpu_di` mux and `rdy` mux.
- Existing design already separates control and datapath; this is the clean insertion point for a deeper pipeline.
- MMIO decode is nibble-based (`addr[11:8]`), so adding graphics/audio/input peripherals can follow the same regioning pattern.
