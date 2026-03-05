# Pipeline Context Log

## Entry 1
- date: 2026-02-18
- commit hash: b09d226
- decision changes: Introduced full stage-module CPU composition (`IF/ID/EX/MEM/WB` + pipeline registers + hazard/BDU/PC-next modules) while preserving external CPU/SoC interface.
- hazard policy version: v1 bubble-first (stall IF/ID + bubble EX on decode hazards, branch flush, mem-wait freeze).
- open risks: no forwarding yet (intentional), deeper branch/IRQ corner interactions should stay under targeted regression.
- next iteration intent: add forwarding v2 after CI stability and preserve current anchor behavior as hard gate.

## Entry 2
- date: 2026-02-19
- commit hash: uncommitted
- decision changes: Added adversarial pipeline verification set (carry dependency, IRQ deferral during mem-wait, IMM-prefix clear on IRQ, deterministic fuzz invariants) and promoted these checks into CI.
- hazard policy version: v1 bubble-first unchanged; validation depth increased.
- open risks: throughput remains conservative due no forwarding; carry-latch behavior is intentionally legacy-preserving and should stay documented.
- next iteration intent: implement forwarding v2 and split CI into baseline vs stress tiers if runtime grows.

## Entry 3
- date: 2026-02-28
- commit hash: uncommitted
- decision changes: Added extra adversarial tests for IRQ oneshot behavior, IRQ-vs-branch priority, branch commit deferral during mem-wait, and `rd=r0` load-use false-hazard guard. Fixed hazard predicate to ignore load-use hazards when producer destination is `r0`.
- hazard policy version: v1 bubble-first unchanged; correctness fix applied in hazard predicate.
- open risks: no forwarding (intentional v1), store-side repeated request semantics under external wait-state MMIO remain policy-dependent.
- next iteration intent: introduce forwarding v2 and, if needed, split CI into baseline-fast and stress-full lanes.
