# CI Baseline Verification (Release Gate)

_Last reviewed: 2026-02-18_

## 1. Goal

Provide a deterministic CI gate that blocks regressions in:
- CPU/SoC baseline behavior
- interrupt/preemption anchors
- branch and memory corner cases
- pipeline v1 hazard/control policy

## 2. Entry Points

- GitHub workflow: `.github/workflows/ci-baseline.yml`
- Local runner: `scripts/ci/run_iverilog_regression.sh`

## 3. Curated Regression Domains

| Domain | Failure Concept | Test/Check | Pass Criteria |
|---|---|---|---|
| Firmware image generation | Broken assembler output or short BRAM image | `tools/assembler.py` + line checks | `mem.hex`, `mem_hi.hex`, `mem_lo.hex` each 512 lines |
| Timer start/reload behavior | Timer start register broken | `sim/tb_timer_start_reg.v` | `PASS tb_timer_start_reg` |
| CPU IRQ depth | Incorrect depth/underflow | `sim/tb_cpu_irq_depth.v` | `PASS tb_cpu_irq_depth` |
| Pipeline load-use hazard | Missing stall/bubble | `sim/tb_pipe_load_use_bubble.v` | `PASS tb_pipe_load_use_bubble` |
| Pipeline CC dependency | Branch-on-fresh-CC interlock broken | `sim/tb_pipe_cc_dependency.v` | `PASS tb_pipe_cc_dependency` |
| Pipeline branch flush | Wrong-path instruction not flushed | `sim/tb_pipe_branch_flush.v` | `PASS tb_pipe_branch_flush` |
| Pipeline memory wait freeze | Pipeline advances while waiting | `sim/tb_pipe_mem_wait_freeze.v` | `PASS tb_pipe_mem_wait_freeze` |
| Pipeline IRQ precision | IRQ boundary/`lr` save broken | `sim/tb_pipe_irq_precise_boundary.v` | `PASS tb_pipe_irq_precise_boundary` |
| Pipeline IMM-prefix flush | Stale IMM prefix leaks across flush | `sim/tb_pipe_imm_prefix_flush.v` | `PASS tb_pipe_imm_prefix_flush` |
| Pipeline carry dependency | Carry-latch data dependency mishandled | `sim/tb_pipe_carry_dependency.v` | `PASS tb_pipe_carry_dependency` |
| Pipeline IRQ during mem-wait | IRQ accepted while load/store wait active | `sim/tb_pipe_irq_mem_wait_deferral.v` | `PASS tb_pipe_irq_mem_wait_deferral` |
| Pipeline IMM-prefix IRQ clear | IMM prefix not cleared on IRQ accept boundary | `sim/tb_pipe_imm_prefix_irq_clear.v` | `PASS tb_pipe_imm_prefix_irq_clear` |
| Pipeline stress invariants | Silent pipeline invariant break under mixed traffic | `sim/tb_pipe_fuzz_invariants.v` | `PASS tb_pipe_fuzz_invariants` |
| Pipeline IRQ oneshot-level | Repeated accepts when IRQ line is level-high | `sim/tb_pipe_irq_oneshot_level.v` | `PASS tb_pipe_irq_oneshot_level` |
| Pipeline IRQ-vs-branch priority | Wrong priority when branch and IRQ collide in ID | `sim/tb_pipe_irq_branch_priority.v` | `PASS tb_pipe_irq_branch_priority` |
| Pipeline branch under mem-wait | Branch commits while mem-wait is active | `sim/tb_pipe_branch_memwait_defer.v` | `PASS tb_pipe_branch_memwait_defer` |
| Pipeline r0 load false hazard | False load-use interlock for producer `rd=r0` | `sim/tb_pipe_r0_load_no_hazard.v` | `PASS tb_pipe_r0_load_no_hazard` |
| SoC byte-lane semantics | `LB/SB` lane select bug | `sim/tb_soc_byte_lane.v` | `PASS tb_soc_byte_lane` |
| SoC integration | Core integration/IRQ/MMIO regressions | `sim/tb_soc_refactor_regression.v` | `PASS tb_soc_refactor_regression` |
| Branch annul corner | Fall-through not annulled | `sim/tb_soc_branch_annul.v` | `PASS tb_soc_branch_annul` |
| End-to-end anchors | Timer preemption or ABI restore broken | `sim/tb_anchor_preemption_abi.v` | `PASS tb_anchor_preemption_abi` + evidence lines |
| UART MMIO alignment | Word-indexed decode mismatch | `sim/tb_uart_mmio_word_aligned.v` | `PASS tb_uart_mmio_word_aligned` |
| Bounded smoke | Deadlock / open-ended sim | `sim/tb_Soc.v` with `+max-cycles=1200` | IRQ vectors observed + guard exit |

## 4. Method

1. Assemble firmware image.
2. Compile benches with `-DSIM=1 -DCI=1 -Isrcs`.
3. Run focused unit benches first, then SoC benches.
4. Fail run on:
   - missing required `PASS` markers,
   - any `FAIL` line,
   - BRAM short-image symptoms (`Not enough words`).

## 5. Local Reproduction

```bash
bash scripts/ci/run_iverilog_regression.sh
```

Custom artifact directory:

```bash
bash scripts/ci/run_iverilog_regression.sh .ci_artifacts/sim
```

Artifacts:
- `.ci_artifacts/sim/*.compile.log`
- `.ci_artifacts/sim/*.run.log`

## 6. Branch Protection Recommendation

Require at least:
- 1 review
- required status check: baseline CI workflow
- branch up-to-date before merge (recommended)

## 7. Scope Notes

- This CI gate is simulation-first (Icarus Verilog + assembler).
- Vivado synth/impl remains a release or nightly gate.
