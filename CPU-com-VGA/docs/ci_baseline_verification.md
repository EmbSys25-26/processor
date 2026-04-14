# CI Baseline Verification (Release Gate)

_Last reviewed: 2026-02-17_

## 1. Goal

Define a deterministic CI gate for the first consolidated release so future PRs are blocked on core functional regressions across CPU, SoC integration, interrupt behavior, timer behavior, and memory byte-lane semantics.

## 2. CI Entry Points

- GitHub Actions workflow:
  - `.github/workflows/ci-baseline.yml`
- Single local/CI regression runner:
  - `scripts/ci/run_iverilog_regression.sh`

## 3. Curated Baseline Domains

| Domain | Primary Failure Concept | Test/Check | Pass Criteria |
|---|---|---|---|
| Firmware image generation | Broken assembly output, wrong ROM image shape | `tools/assembler.py` + line-count check | `mem.hex`, `mem_hi.hex`, `mem_lo.hex` each 512 lines |
| Timer register map and start/reload behavior | Timer start value not writable/readable/reloadable | `sim/tb_timer_start_reg.v` | `PASS tb_timer_start_reg` |
| Harvard ROM/RAM isolation | Data writes corrupt instruction image | `sim/tb_harvard_mem_isolation.v` | `PASS tb_harvard_mem_isolation` |
| CPU IRQ depth safety | Underflow/wrap on `IRET`, wrong `in_irq` state | `sim/tb_cpu_irq_depth.v` | `PASS tb_cpu_irq_depth` |
| Byte-lane semantics for `LB/SB` | Wrong lane chosen, wrong zero-extension | `sim/tb_soc_byte_lane.v` | `PASS tb_soc_byte_lane` |
| Word read/write semantics for `LW/SW` | Wrong word write/readback or address aliasing | `sim/tb_soc_word_rw.v` | `PASS tb_soc_word_rw` |
| SoC integration + MMIO/IRQ activity | Missing IRQ/MMIO activity after changes | `sim/tb_soc_refactor_regression.v` | `PASS tb_soc_refactor_regression` |
| Branch annul corner case | Fall-through not annulled on taken branch | `sim/tb_soc_branch_annul.v` | `PASS tb_soc_branch_annul` |
| End-to-end anchors | Lost timer preemption or ABI preservation | `sim/tb_anchor_preemption_abi.v` | `PASS tb_anchor_preemption_abi` + preemption/restore evidence lines |
| UART MMIO word alignment | UART STATUS/ACK unreachable through CPU-aligned address model | `sim/tb_uart_mmio_word_aligned.v` | `PASS tb_uart_mmio_word_aligned` |
| I2C MMIO register model | Broken control/status semantics, missing W1C or START clear | `sim/tb_i2c_mmio_regs.v` | `PASS tb_i2c_mmio_regs` |
| I2C protocol write path | Bad I2C START/address/data/STOP signaling | `sim/tb_i2c_master_write.v` | `PASS tb_i2c_master_write` |
| I2C interrupt integration | I2C completion not reaching VIC or wrong vector | `sim/tb_i2c_irq_vector.v` | `PASS tb_i2c_irq_vector` |
| Runtime guard and smoke | Open-ended simulations, deadlock | `sim/tb_Soc.v` with `+max-cycles=1200` | Observes IRQ vectors `0x0020` and `0x0040`, then exits by guard |

## 4. Methodology

1. Rebuild ROM images from canonical assembly input.
2. Compile benches with `SIM=1` and `CI=1` so ROM init paths resolve to repository-root hex files.
3. Execute fast unit-level regressions first (timers, Harvard memory split, CPU depth, lane behavior).
4. Execute SoC-level regressions next (integration + anchor behavior).
5. Execute bounded smoke run to catch lockups and keep CI runtime deterministic.
6. Fail CI on:
   - any `FAIL` in run logs,
   - missing required `PASS` markers,
   - ROM short-image symptom (`Not enough words`),
   - missing anchor evidence lines.

## 5. Local Reproduction

From repository root:

```bash
bash scripts/ci/run_iverilog_regression.sh
```

Optional custom artifact directory:

```bash
bash scripts/ci/run_iverilog_regression.sh .ci_artifacts/sim
```

Generated logs:
- `.ci_artifacts/sim/*.compile.log`
- `.ci_artifacts/sim/*.run.log`

## 6. GitHub Setup Steps

1. Ensure these files are committed and pushed:
   - `.github/workflows/ci-baseline.yml`
   - `scripts/ci/run_iverilog_regression.sh`
2. In GitHub repository settings, ensure Actions are enabled:
   - `Settings -> Actions -> General -> Allow all actions and reusable workflows`.
3. Push to a branch and open a test PR; confirm workflow `CI Baseline Verification` appears and runs.
4. Configure branch protection for your integration branch (`main`/`master`):
   - require pull requests before merging,
   - require status checks to pass,
   - mark required check: `Baseline Verification (iverilog)`.
5. Optionally require branch to be up-to-date before merge.
6. Keep `CODEOWNERS` active so RTL/docs/CI changes get reviewed by the right owners.

## 7. Scope Notes

- This CI gate is simulation-focused and lightweight (Icarus Verilog + Python).
- Vivado synthesis/implementation timing closure is intentionally out-of-scope for per-PR CI due to runtime/resource costs.
- Vivado should remain a release-candidate or nightly gate.

## 8. Release Watchpoints

- Keep `sim/tb_soc_branch_annul.v` in CI. It guards synchronous fetch/latch branch-annul ordering.
- Keep `sim/tb_anchor_preemption_abi.v` in CI. It is the anchor for timer preemption and ABI preservation.
- Keep `sim/tb_harvard_mem_isolation.v` in CI. It guards against accidental re-coupling of instruction and data memory.
- Keep `sim/tb_uart_mmio_word_aligned.v` in CI. It guards word-indexed UART register reachability and STATUS clear behavior at `0x8300`/`0x8302`.
- Keep `sim/tb_i2c_mmio_regs.v` in CI. It guards the new I2C MMIO programming contract.
- Keep `sim/tb_i2c_irq_vector.v` in CI. It guards I2C interrupt routing and vector `0x00A0`.
- Keep canonical `IRET` encoding synchronized across:
  - `srcs/constants.vh` (`CPU_IRET_INSN`)
  - `tools/abi.inc` (`IRET` macro)
  - assembly programs using ISR epilogues.

## 9. Related Docs

- `docs/architecture_and_memory.md`
- `docs/isa_reference.md`
- `docs/abi_spec.md`
- `docs/rtl_file_walkthrough.md`
- `docs/report/docs-implementation.tex`
