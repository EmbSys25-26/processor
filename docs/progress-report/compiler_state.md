# Compiler State

Date: 2026-05-02
Branch: `Compiler/RegisterAllocation`

## 1) Current reality: full pipeline operational

The compiler now drives a complete C-subset → assembly pipeline:

```
.c source
   → Lexer (Flex)
   → Parser (Bison) → AST
   → Semantic Analysis (pass 1 binder + pass 2 checker) → annotated AST
   → IR Lowering (3-address CFG IR with virtual registers)
   → Liveness → Interference Graph → Pre-color → Chaitin-Briggs coloring → Spill rewrite (iterative)
   → Code Generation → assembly text (output.asm)
   → Software runtime (runtime/runtime.asm) for missing __mul / __divs / __divu / __mods / __modu helpers
```

`main.c` runs each stage sequentially. IR lowering only runs if semantic
analysis returned zero errors; codegen only runs if regalloc converges.

## 2) Component status

### Done

**Frontend** — Lexer, Parser, AST core/printer, NodeTypes, semantic context with persistent + scratch arenas, diagnostics list, scope stack.

**Semantic** — Pass 1 binder (declarations bound to symbols, scopes opened/closed). Pass 2 checker (most rules in `SEMANTIC_CHECK_MATRIX.md`: assignments, lvalue/rvalue, arithmetic/bitwise/comparison/logical operators, struct/union member access, control-flow legality). Annotation table populated for every typed expression node.

**IR Lowering** — Declarations (globals + locals + initialisers, including string literal pools and constant-folding for static initialisers), expressions (all C operators including `&&` / `||` short-circuit and ternary), statements (if/while/do-while/for/switch/break/continue/return), function lowering (parameters, prologue glue, body), structure (translation unit walk). Multi-dimensional arrays and struct/union member access compute correct word offsets.

**Code Generation** — Frame layout, prologue/epilogue (with stack-passed parameter loading), arithmetic/bitwise (with immediate-form `ADDI` / `RCMPI` optimisations), comparisons (full branch ladder for both signed and unsigned), control flow (GOTO / BRANCH / SWITCH), memory (LOAD / STORE / GEP for word-addressed memory), casts (ZEXT / SEXT / TRUNC / BITCAST with constant-folding), function calls (parallel-copy register-arg setup, stack-arg writing via direct SW, return value plumbing), CALL register-arg cycle breaking via the reserved `t3` scratch.

**Register Allocation** — Liveness dataflow to a fixed point, undirected interference graph, ABI pre-coloring (call args + returns + call-live restriction to callee-saved), Chaitin-Briggs simplification, George's conservative move coalescing, forbidden-set color selection, spill rewriting with iterated re-allocation. `r7` reserved as codegen scratch.

**Runtime library** — `runtime/runtime.asm` provides `__mul` (16x16 shift-and-add), `__divu` / `__modu` (unsigned restoring long division), `__divs` / `__mods` (signed via sign normalisation + `__divu`/`__modu`).

### Known limitations / future work

1. **Function pointers / indirect calls** — IR lowering rejects them.
2. **Struct/union value copy and pass-by-value** — only field access is supported; no `s2 = s1;` block copy and no struct-by-value parameters/returns.
3. **Floating point** — semantic pass marks float/double nodes `SEM_NODE_CODEGEN_BLOCKED`; IR lowering rejects them with `IR001`.
4. **Variadic functions** — not supported.
5. **`long long` (i64)** — not supported; `long` maps to i32 but no full arithmetic.
6. **Aggregate initialisers** — `{1, 2, 3}` style brace-enclosed initialisers are not yet IR-lowered for arrays/structs (only scalar globals are initialised; arrays/structs zero-init).
7. **Spilled stack-passed parameters** — if regalloc spills a register-passed param's vreg, the spill happens after the param is in its register, so it works. Stack-passed params are loaded into their slot directly by codegen prologue, so spilling them isn't a concern.

## 3) What this means technically

The compiler is now a working end-to-end translator from a substantial C subset to the project's custom 16-bit RISC ISA. Programs exercising scalars, locals, globals, arrays (1D and N-D), structs, pointers, function calls (any arity), short-circuit logic, and the full set of arithmetic / bitwise / comparison operators compile and produce executable assembly when assembled and linked against `runtime/runtime.asm`.

The reliability target is correctness on programs the semantic pass accepts. The 35-test regression suite (`test_files/RegisterAllocation/` + `test_files/IR_checks/`) covers the major paths and runs to completion with zero `(null)` operands and zero spurious self-MOVs.

## 4) Recent significant fixes (this milestone)

1. **Immediate operands in IR codegen** — every IR opcode that could legally carry `IR_VAL_IMM_INT` / `IR_VAL_GLOBAL` operands now materialises them through `materialize_operand()` (or constant-folds when possible). Previously any binop/store/comparison with a non-VREG operand emitted `(null)` text into the assembly.
2. **ABI mnemonic mismatch** — codegen's strcmps now use `a0`/`a1`/`a2` (matching `phys_name()` output) instead of canonical `r1`/`r2`/`r3`. Eliminates `MOV(a0, r1)` self-MOV pairs after every CALL.
3. **`emit_binop_rr_nc` aliasing** — when `dst == b ≠ a` for SUB/SRL/SRA, the naive `MOV(dst, a); OP dst, b` clobbered b before reading it. SUB now uses `NEG(dst); ADD dst, a`; SRL/SRA use the reserved `t3`.
4. **Logical `&&` / `||`** — were rejected with diagnostic `IR001`. Now lowered as a control-flow diamond storing 0/1 into a result slot, with proper short-circuit semantics.
5. **Unsigned propagation** — `unsigned u / v` was emitting `__divs` because the semantic pass returns `g_type_int` (signed) for arithmetic results. IR lowering now derives `is_unsigned` from operand types, matching C's "usual arithmetic conversions".
6. **Arrays under-allocated** — `int arr[5]` reserved one slot/word. Fixed via new `ir_type_size_words()`, `ir_global_t.size_words`, multi-slot allocation in `ir_new_slot`, and removal of the spurious LOAD when an array variable is the base of an array-access lvalue.
7. **Struct member access with no offset** — `p.field` always read at offset 0 because the field name was written into a union field that overlapped `gep.width`, corrupting both. IR lowering now walks the struct's AST decl to compute true word offsets and emits `gep base + offset * 1`.
8. **CALL stack-arg ordering** — register-arg loads ran before stack-arg pushes, so a stack arg sourced from `a0`/`a1`/`a2` was clobbered. Replaced with: allocate stack space → write all stack args to `sp+i` slots first → load register args. Scratch picker avoids any vreg-arg's home register.
9. **CALL register-arg parallel copy** — sequential MOVs corrupted cycles like `(a0=a1, a1=a0)`. Replaced with Kahn-style topological order + cycle-breaking via `t3`.
10. **Stack-passed parameters not loaded** — params 4+ were being read from uninitialised registers because regalloc legitimately coalesced their colors. IR lowering now skips the STORE for stack params; codegen prologue does `LW t3, fp, #+i; SW t3, fp, #-slot` directly into the local slot.
11. **Reserved `t3` (`r7`)** — removed from regalloc's preference list. Codegen uses it as a guaranteed-safe scratch for materialisation, in-place op spilling, OR-macro internal scratch, and parallel-copy cycle breaking.

## 5) Outstanding bugs/limitations

See `docs/IR/IR Specification.md` and per-file comments for the latest. The major unsupported constructs are listed in §2 above.

## 6) TL;DR

End-to-end compilation works. Major recent work: immediate handling, parallel-copy CALL setup, stack-passed parameter loading, multi-D arrays, struct field offsets, short-circuit logical ops, unsigned dispatch, and reserving a codegen scratch register.
