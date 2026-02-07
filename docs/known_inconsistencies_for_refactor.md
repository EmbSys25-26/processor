# Known Inconsistencies and Refactor Hotspots

_Last reviewed: 2026-02-07_

This file is a quick index of implementation/documentation mismatches and high-risk behaviors to address during refactor.

## Active Hotspots

### 1. Instruction fetch timing and branch annul behavior need directed regression
- SoC uses a registered instruction latch (`insn_q`) with synchronous BRAM reads.
- The exact cycle relation among `pc`, `i_ad`, `insn_q`, and branch/jump target updates should be locked down with waveform-backed tests.

### 2. Interrupt return PC semantics still need coverage
- `iret_detected` is encoding-specific (`16'h0EE0`) and interrupt return correctness should be validated across branches, calls, and memory stalls.

### 3. Assembler validation remains permissive
- Immediate nibble truncation can hide source mistakes.
- Alignment checks for word operations are not enforced.

### 4. `irq_ctrl` receives `in_irq` but does not consume it
- `srcs/m_irq_ctrl.v` has an `in_irq` input that is currently unused in take/preemption logic.
- Decide whether to remove it or explicitly incorporate it.

### 5. `timerH` reset comment does not match behavior
- `srcs/m_timerH.v` sets `int_en <= 1'b1` on reset.
- Nearby comment text implies disabled-by-default semantics.

### 6. `imem_invalid` blocks `0x0000` as an instruction word
- `srcs/m_soc.v` injects NOP when fetched instruction equals `16'h0000`.
- This masks some uninitialized-memory failures and reserves a full encoding.

### 7. Data address generation vs. lane-select contract is inconsistent
- Datapath currently emits `d_ad = (sum << 1)` (`srcs/m_gr0040.v`).
- SoC byte-lane select uses `d_ad[0]`, which stays `0` for core-generated accesses.
- Practical effect: `LB/SB` currently operate on the high lane unless address logic changes.

### 8. BRAM init paths are host-specific
- `srcs/m_bram.v` still contains hardcoded absolute `$readmemh` paths in non-`SIM` mode.
- This reduces portability across machines and CI.

### 9. Include handling is explicit-path only
- `tools/assembler.py` resolves `.include` relative to the including file.
- There is no automatic fallback to `tools/`; source files should use explicit relative paths.

## Confirmed Current State
- Canonical interrupt-return encoding is aligned: `IRET` in `tools/abi.inc` emits `JAL lr, lr, #0` (`16'h0EE0`).
- UART MMIO status/read path is reachable via `srcs/m_periph_bus.v` + `srcs/m_uart_mmio.v`.

## Refactor Rule
- Any ISA/ABI/MMIO behavior change should update RTL, assembler/tooling, and the corresponding docs in the same PR.
