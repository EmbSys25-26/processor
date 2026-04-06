# Pipeline Report Notes

Date: 2026-04-06

Purpose: preserve the analysis record used to write the LaTeX report so later edits can distinguish current implementation facts from previous project material.

## Current implementation facts

- Active CPU path is the stage-based core in `srcs/m_cpu.v`.
- Current pipeline is `IF -> ID -> EX -> MEM`.
- There is no explicit WB stage anymore. MEM writes back directly to the regfile.
- `m_datapath.v` still exists, but it is not instantiated by the active `m_cpu.v`.
- Forwarding is explicit from EX/MEM into EX for both operands.
- The regfile is write-first on matching read/write addresses, which covers same-cycle MEM-to-ID visibility.
- Load-use hazards are detected between ID and ID/EX.
- End-to-end load latency at SoC level still includes one memory-ready wait cycle for synchronous BRAM loads.
- Branches are resolved in ID with predict-not-taken behaviour.
- Taken branch and accepted IRQ both flush IF/ID; IF also injects a two-cycle post-flush bubble window.
- Interrupts are deferred during `mem_wait`.
- Interrupt acceptance is suppressed while an `IMM`, `ADC`, `SBC`, or `CMP` is in ID.
- Current CC and carry handling is combinational from EX outputs, so old tests that expect visible CC/carry stalls are stale.

## Pipeline-focused test status against current RTL

Recompiled with:

`iverilog -g2012 -DSIM=1 -Isrcs sim/tb_pipe_*.v ...stage modules...`

Passing:

- `tb_pipe_branch_flush`
- `tb_pipe_branch_memwait_defer`
- `tb_pipe_fuzz_invariants`
- `tb_pipe_imm_prefix_flush`
- `tb_pipe_imm_prefix_irq_clear`
- `tb_pipe_irq_branch_priority`
- `tb_pipe_irq_mem_wait_deferral`
- `tb_pipe_irq_oneshot_level`
- `tb_pipe_irq_precise_boundary`
- `tb_pipe_mem_wait_freeze`
- `tb_pipe_r0_load_no_hazard`

Failing because expectations are stale:

- `tb_pipe_cc_dependency`
- `tb_pipe_carry_dependency`

Compile failure because signal no longer exists:

- `tb_pipe_load_use_bubble` references `dut._bubble_ex`

## Documentation drift found locally

- `docs/architecture_and_memory.md` still describes the active CPU as integrated `ctrl_unit + datapath`.
- `docs/references.md` points at `docs/report/docs.tex`, but that path is currently deleted and replaced by `docs/old-report/`.
- `docs/pipeline/pipeline-second.pptx.pdf` is useful for design intent, but not as a faithful description of current RTL.
- Old assembly comments still mention WB-to-EX forwarding.
- `scripts/ci/run_iverilog_regression.sh` no longer compiles the active CPU because it omits the stage modules instantiated by `m_cpu.v`.

## Local PDF takeaways

### `docs/pipeline/pipeline-second.pptx.pdf`

- Historical slide deck for the pipeline project.
- Valuable for original design intent:
  - separate stage modules;
  - hazard unit;
  - predict-not-taken branch handling;
  - removal of WB as a project goal.
- Outdated assumptions:
  - repeated five-stage framing;
  - WB forwarding;
  - explicit CC/carry stall story;
  - visible `o_bubble_ex`.

### `docs/pipeline/CPI.pdf`

- Only a lightweight CPI reminder.
- Safe use: define CPI and remind that stalls/flushes raise CPI above 1.

### `docs/pipeline/processor_non_pipeline_cpi_report.pdf`

- Baseline methodology for non-pipelined CPI.
- Useful contrast source.
- Not reusable as current pipelined evidence without rerunning measurements.

### `docs/pipeline/1996.05.Comparison-Of-Two-Common-Pipeline-Structures_Proc_Comps_Digital_Techs.pdf`

- OCR confirms this is the Golden/Mudge LUI vs AGI paper.
- Main relevant conclusions:
  - AGI removes load-use interlocks by moving address generation later.
  - AGI introduces address-generation hazards and later branch penalties.
  - Under perfect branch prediction AGI can win, especially with longer data-cache access.
  - With branch prediction included, AGI needs roughly 80%+ prediction accuracy to stay ahead.
  - Local compiler rescheduling gives only modest additional gain.
- Key interpretation for this repo:
  - current project is still LUI-like, not AGI-like;
  - the project's stage reduction came from removing WB, not by moving address generation after cache lookup.

## External sources consulted

- Brown CSCI1952y notes on five-stage pipelined CPU hazards:
  - <https://browncs1952y.github.io/notes/pipelined_cpu_3.html>
- LSU EE 4720 lecture slides on pipelined MIPS hazards:
  - <https://www.ece.lsu.edu/ee4720/2021/lsli06.pdf>
- Golden and Mudge LUI/AGI paper:
  - local PDF under `docs/pipeline/`
- Representative open-source pipeline implementations:
  - <https://github.com/cgsdfc/mips-pipeline-cpu.verilog>
  - <https://github.com/emilbiju/emil-risc-v>
  - <https://kevin71104.github.io/CA_PIPELINED_CPU/>
  - <https://kevin71104.github.io/assets/document/CA_Pipelined_CPU.pdf>
