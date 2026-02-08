# Known Inconsistencies and Refactor Hotspots

_Last reviewed: 2026-02-08_

This index tracks only active verification hotspots and intentional design contracts that can be misread as inconsistencies.

## Active Verification Hotspots

### 1. Interrupt return PC semantics still need broader directed coverage

- `iret_detected` is encoding-specific (`16'h00E0`) and should keep coverage across deeper call/branch/stall mixes.
- Current CI coverage:
  - `sim/tb_cpu_irq_depth.v`
  - `sim/tb_anchor_preemption_abi.v`
- Suggested next expansion:
  - add directed ISR return tests where `IRET` occurs immediately after stall-release cycles.

### 2. Branch-annul corner case is CI-guarded and should remain in release gates

- SoC uses a registered instruction latch (`insn_q`) with synchronous BRAM reads.
- On cycles where branch redirect and fetch/latch interact, `insn_q` annul logic (`NOP` injection) must suppress fall-through.
- Current CI coverage:
  - `sim/tb_soc_branch_annul.v`
- Keep this bench in CI to detect one-cycle ordering regressions when CPU/SoC timing is adjusted.

## Intentional Behaviors (Not Inconsistencies)

### A. Assembler imm4 truncation permissiveness

- Intentional for nibble-based address formation workflows, especially `IMM + JAL` absolute jump/call style.
- Valid call/jump targets may require low nibble values `0x8..0xF`, so strict signed-imm4 rejection would break legal flows.
- Future improvement (optional): emit warnings (not errors) for suspicious arithmetic-style imm4 truncation.

### B. `irq_ctrl` keeps `i_in_irq` wired even when unused

- `srcs/m_irq_ctrl.v` keeps `i_in_irq` for interface compatibility and future VIC changes.
- Preemption currently relies on internal depth/priority stack only.
- Unused input is synthesis-safe (optimized away by Vivado).

### C. `imem_invalid` blocks `0x0000` instruction fetches

- `srcs/m_soc.v` injects NOP when fetched instruction equals `16'h0000`.
- Intentional trap-style guardrail for invalid/empty fetch paths.

### D. BRAM absolute fallback path outside SIM/CI

- `srcs/m_bram.v` uses developer absolute paths in the non-`SIM`/non-`CI` branch for synthesis/timing simulation workflows.
- Team contract: developers override paths locally or via `BRAM_MEM_HI_PATH`/`BRAM_MEM_LO_PATH` defines.

## Refactor Rule

- Any ISA/ABI/MMIO behavior change should update RTL, tooling, tests, and docs in the same PR.
