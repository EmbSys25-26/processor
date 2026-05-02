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
| `r4`–`r6` | temporaries (`t0`–`t2`) | yes (caller-saved) |
| `r7` | codegen scratch (`t3`) | **no — reserved** |
| `r8`–`r11` | callee-saved (`s0`–`s3`) | yes |
| `r12` | frame pointer | no |
| `r13`–`r15` | sp / lr / gp | no |

Values live across call boundaries are restricted to `r8`–`r11` so they survive the caller-saved clobber. The spill mechanism handles cases where pressure exceeds the four available callee-saved registers.

`r7` (`t3`) is excluded from the allocator's preference list and reserved exclusively for the code generator. Codegen needs a register that is guaranteed never to hold a live virtual register so it can materialise immediates / globals, save operands across in-place SUB/SRL/SRA, and break parallel-copy cycles in CALL setup. Without this reservation, codegen would have to push/pop a temp on every materialisation; with it, those operations cost zero stack ops.

## How to Build and Run

```
make
./compiler test.c
```

## Tests

Test files are available in `test_files/RegisterAllocation/` and `test_files/IR_checks/`.

Run `scripts/test_compile_all.sh` after a build to compile every test and verify the generated assembly against per-test snapshots (`*_expected.asm`). Exits 0 when every test passes.

## Unsupported / Known Limitations

The compiler accepts a substantial C subset but rejects (or silently skips) the following:

- **Function pointers / indirect calls** — IR lowering rejects with `IR001`.
- **Struct/union pass-by-value or block copy** — only `.field` and `->field` reads/writes are lowered; `s2 = s1;`, struct-by-value parameters, and struct-returning functions are not.
- **Aggregate initialisers** — `int arr[] = {1, 2, 3}` and `struct p = {1, 2}` are not lowered (arrays/structs zero-init).
- **`long long` / 64-bit arithmetic** — `long` lowers to i32 but no full arithmetic; `long long` is not recognised.
- **Floating point** — semantic-blocked at `SEM_NODE_CODEGEN_BLOCKED`.
- **Variadic functions** — no `va_arg` machinery.

See [`docs/progress-report/compiler_state.md`](docs/progress-report/compiler_state.md) §2 for the full status and rationale.

## Documentation

- [`docs/Compiler Overview.md`](docs/Compiler%20Overview.md) — pipeline overview from lexer to codegen.
- [`docs/IR/IR Specification.md`](docs/IR/IR%20Specification.md) — full IR opcode reference, lowering contract, type system, instruction encoding.
- [`docs/CodeGen/Code Generation Specification.md`](docs/CodeGen/Code%20Generation%20Specification.md) — codegen pass: ISA cheatsheet, frame layout, register conventions, per-opcode emission strategy, CALL setup with parallel-copy, prologue/epilogue.
- [`docs/runtime/Runtime Library Specification.md`](docs/runtime/Runtime%20Library%20Specification.md) — software arithmetic helpers (`__mul`, `__divs`, `__divu`, `__mods`, `__modu`): algorithms, ABI, edge cases.
- [`docs/semantic-analysis/IR_GENERATION_CONTRACT.md`](docs/semantic-analysis/IR_GENERATION_CONTRACT.md) — the contract IR lowering must satisfy (input from semantic, output to backend).
- [`docs/progress-report/compiler_state.md`](docs/progress-report/compiler_state.md) — what's done, what's not, what landed in the current milestone.
- [`abi_spec.md`](abi_spec.md) — register and calling convention specification.
