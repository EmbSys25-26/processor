# Register Allocation

This branch contains the backend of our compiler.
The compiler processes `.c` source files through lexical analysis, syntax parsing, semantic validation, IR generation, and the full register allocation pipeline.

## Pipeline

`main.c` drives the following stages sequentially:

1. **Frontend:** Lexical Analysis (Flex) + Syntax Analysis (Bison) → AST.
2. **Middle-end:** Semantic Analysis (type and symbol checking) → IR Lowering (3-address code, SSA-like virtual registers).
3. **Backend — Register Allocation (iterative spill loop):**
   - **Stage 1 — Liveness Analysis:** Computes precise live ranges for all virtual registers (`use`, `def`, `live_in`, `live_out`, `live_after`) via dataflow equations iterated to a fixed point.
   - **Stage 2 — Interference Graph:** Builds an undirected graph connecting every pair of virtual registers that are simultaneously live. An edge means the two vregs cannot share a physical register.
   - **Stage 3 — Pre-Coloring:** Enforces ABI constraints before graph coloring. Pins specific virtual registers to mandatory physical registers (call results → `r1`; function parameters → `r1`/`r2`/`r3`; call-live vregs restricted to callee-saved `r8`–`r11`). Cross-vreg conflict detection prevents two simultaneously-live vregs from receiving the same pre-color.
   - **Stage 4 — Graph Coloring (Chaitin-Briggs):** Assigns physical registers to all remaining virtual registers. Uses George's conservative coalescing to eliminate redundant copies, Chaitin-style simplification to build a LIFO select-stack, and forbidden-set color selection respecting the ABI preference order (`r4`–`r7` → `r8`–`r11` → `r1`–`r3` for normal vregs; `r8`–`r11` only for call-live vregs).
   - **Stage 5 — Spill Rewriting:** If Stage 4 cannot color all vregs, spills the highest-cost candidate (cost/degree heuristic) by inserting stack-slot loads and stores, shrinking its live range to a single instruction. The pipeline restarts on the rewritten IR. The loop terminates when no spills remain.
4. **Final IR (physical registers):** After allocation converges, the IR is printed with every virtual register replaced by its assigned physical register, showing the concrete register assignment ready for code generation.

## ABI Compliance

The allocator targets the project ABI (`abi_spec.md`):

| Register | Role | Allocatable |
|---|---|---|
| `r0` | hardwired zero | no |
| `r1` | arg0 / return value | yes (caller-saved) |
| `r2` | arg1 | yes (caller-saved) |
| `r3` | arg2 | yes (caller-saved) |
| `r4`–`r7` | temporaries | yes (caller-saved) |
| `r8`–`r11` | callee-saved | yes |
| `r12` | frame pointer | no |
| `r13`–`r15` | sp / lr / gp | no |

Values live across call boundaries are restricted to `r8`–`r11` so they survive the caller-saved clobber. The spill mechanism handles cases where pressure exceeds the four available callee-saved registers.

## How to Build and Run

```
make
./compiler test.c
```

## Tests

Test files are available in `test_files/RegisterAllocation/`.
