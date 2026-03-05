# Pipeline Diagram Set

These Mermaid files document the v1 stage-module pipeline decisions and are intended as a low-friction context logger for future iterations.

## Files
- `00_pipeline_overview.mmd`: end-to-end stage composition and control hooks.
- `01_stage_interfaces.mmd`: high-level per-stage interface boundaries.
- `02_data_hazards_bubble_v1.mmd`: bubble-first hazard handling logic.
- `03_control_hazards_branch_flush.mmd`: branch-taken flush flow.
- `04_irq_precise_boundary.mmd`: IRQ acceptance and precise-boundary behavior.
- `05_mem_wait_freeze.mmd`: memory wait freeze policy.
- `06_pipeline_full_hazard_reference.mmd`: target-style full hazard handling reference (with forwarding).
- `CONTEXT_LOG.md`: chronological decision ledger.

## Usage
- Keep these diagrams aligned with RTL (`srcs/m_cpu.v` + stage modules).
- Update `CONTEXT_LOG.md` whenever hazard policy or stage ownership changes.
