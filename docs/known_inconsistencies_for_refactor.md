# Known Inconsistencies and Refactor Hotspots

_Last reviewed: 2026-02-07_

This index tracks implementation/documentation mismatches and verification-risk areas.

## Active Hotspots

### 1. Instruction fetch timing and branch annul behavior need directed regression

- SoC uses a registered instruction latch (`insn_q`) with synchronous BRAM reads.
- The exact cycle relation among `pc`, `i_ad`, `insn_q`, and branch/jump updates should remain covered by waveform-backed tests.

### 2. Interrupt return PC semantics still need broader coverage

- `iret_detected` is encoding-specific (`16'h0EE0`) and should be validated across deeper call/branch/stall mixes.

### 3. Assembler validation remains permissive for imm4 truncation

- Immediate nibble encoding keeps low 4 bits; this can hide source mistakes.
- Consider stricter diagnostics for out-of-contract immediates.

### 4. `irq_ctrl` receives `in_irq` but does not consume it

- `srcs/m_irq_ctrl.v` keeps `i_in_irq` only for interface compatibility.
- Preemption currently relies on internal depth/priority stack only.

### 5. `imem_invalid` blocks `0x0000` as an instruction word

- `srcs/m_soc.v` injects NOP when fetched instruction equals `16'h0000`.
- This masks some uninitialized-memory failures and reserves one encoding.

## Resolved in Current Refactor

### A. IRQ depth underflow in CPU module

- `srcs/m_cpu.v` now uses saturating depth updates and post-update `in_irq` derivation.

### B. LB/SB lane-select mismatch

- Datapath still emits `d_ad = (sum << 1)` (`srcs/m_datapath.v`).
- SoC now uses `d_ad[1]` for byte-lane select, with explicit `LB` zero-extension and `SB` low-byte lane writes (`srcs/m_soc.v`).

### C. BRAM init warning due to short hex files

- `tools/assembler.py` now pads output to 512 words by default (`--pad-words`), aligning with BRAM depth.

## Refactor Rule

- Any ISA/ABI/MMIO behavior change should update RTL, tooling, tests, and corresponding docs in the same PR.
