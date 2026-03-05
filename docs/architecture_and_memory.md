# Processor Architecture and Memory Notes

_Last reviewed: 2026-02-18_

## 1. System Partition

- CPU core: `srcs/m_cpu.v` (5-stage orchestrator)
  - IF: `m_if_stage.v`
  - ID: `m_id_stage.v`
  - EX: `m_ex_stage.v`
  - MEM: `m_mem_stage.v`
  - WB: `m_wb_stage.v`
  - pipeline regs: `m_pipe_if_id.v`, `m_pipe_id_ex.v`, `m_pipe_ex_mem.v`, `m_pipe_mem_wb.v`
  - helpers: `m_hazard_unit.v`, `m_bdu.v`, `m_pc_next.v`
- SoC top: `srcs/m_soc.v`
- Memory model: `srcs/m_bram.v` (unified dual-port BRAM)
- MMIO fabric: `srcs/m_periph_bus.v`
- IRQ controller: `srcs/m_irq_ctrl.v`

## 2. Pipeline Semantics (v1)

- Stage order: IF -> ID -> EX -> MEM -> WB.
- Branches are resolved in ID via `m_bdu.v`.
- On taken branch:
  - `flush_ifid=1`
  - PC redirects through `m_pc_next.v`
  - SoC annuls fall-through by injecting NOP in instruction latch.

### Hazard policy (bubble-first)
- Data/CC/carry decode hazards:
  - stall IF + ID
  - bubble EX (NOP injection into ID/EX)
- Memory wait (`mem_wait=1`):
  - freeze IF/ID/EX progression
  - hold memory transaction stable
  - avoid duplicate retire

### Interrupt precision
- IRQ accepted only when not in memory wait (`accept_irq = irq_take & ~mem_wait`).
- On accept:
  - younger state is flushed
  - `lr` is saved by hardware path
  - PC redirects to `irq_vector`
- IRQ depth tracking remains saturating and exported as `o_in_irq`.

## 3. Clocking and Reset

- Single synchronous clock domain.
- Active-high reset.
- CPU reset vector constant: `0x0100`.

## 4. Addressing and Data Path Rules

- ISA width: 16-bit words.
- PC and bus addresses are byte addresses.
- Sequential fetch advances by 2 bytes per instruction.
- EX stage effective address is currently `d_ad = (_sum << 1)`.
- Byte-lane behavior for core-generated `LB/SB` is selected by `d_ad[1]`:
  - `LB`: zero-extend selected byte
  - `SB`: writes low byte (`cpu_do[7:0]`) to selected lane

## 5. Memory Path

Current implementation uses one physical BRAM module with two ports:
- Port A: instruction fetch
- Port B: data load/store

SoC split:
- `is_io = d_ad[15]`
- `is_io=0`: BRAM data path
- `is_io=1`: MMIO peripheral bus path

## 6. MMIO Decode (`addr[11:8]`)

- `0x0`: Timer0 (`0x8000-0x80FF`)
- `0x1`: Timer1 (`0x8100-0x81FF`)
- `0x2`: PARIO (`0x8200-0x82FF`)
- `0x3`: UART MMIO (`0x8300-0x83FF`)
- `0xF`: IRQ controller (`0x8F00-0x8FFF`)

## 7. IRQ Vector Map

- IRQ0 -> `0x0020`
- IRQ1 -> `0x0040`
- IRQ2 -> `0x0060`
- IRQ3 -> `0x0080`

## 8. Practical Watchpoints

- Keep branch-annul regression (`tb_soc_branch_annul.v`) mandatory.
- Keep preemption/ABI anchor (`tb_anchor_preemption_abi.v`) mandatory.
- Keep pipeline hazard regressions (`tb_pipe_*.v`) mandatory while forwarding is deferred.

