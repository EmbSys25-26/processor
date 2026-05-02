# IR Generation Contract

Date: 2026-03-07

## 1. Objective
Define a complete and stable contract from typed AST to backend-facing IR.
The IR must be explicit enough for:
1. backend instruction selection,
2. optimization passes,
3. register allocation (graph coloring or alternative),
4. final emission to the project ISA assembler.

## 2. Pipeline position
`lexer -> parser -> AST -> semantic_analyze(pass1 + pass2) -> IR lowering -> backend -> assembler`

IR lowering must only execute if semantic stage has zero errors.

## 3. Input contract from semantic stage
Lowering must consume the persistent semantic result returned by:

```c
int semantic_analyze(TreeNode_t *root,
                     const char *path,
                     semantic_context_t **out_ctx,
                     semantic_result_t *out_result);
```

Lowering requires these guarantees on the semantic context:
1. Every lowerable expression node has inferred type metadata in the semantic annotation table.
2. Every identifier/member/function reference has symbol binding in the semantic annotation table.
3. Every statement has validated control legality.
4. Unsupported features are explicitly marked and must trigger deterministic lowering errors.
5. Symbols, scopes, and semantic types remain valid until `semantic_context_destroy(...)`.
6. `BUILTIN_STRING` maps to `ptr` to `i8` with implicit `const` pointee qualifier.
7. Each `symbol_t` carries a `memory_class` field specifying IR locality
   (`MEMORY_CLASS_GLOBAL`, `MEMORY_CLASS_STACK`, `MEMORY_CLASS_PARAMETER`, or
   `MEMORY_CLASS_NONE`) for stack slot allocation, global symbol emission, or
   parameter binding.
8. Nodes with `SEM_NODE_CODEGEN_BLOCKED` set in `sem_node_info_t.flags` represent
   features unsupported by the current backend. IR lowering must check this flag
   and fail with diagnostic `IR001` when it is set.

Lowering must query semantic metadata through the semantic API, not through AST-local fields such as `nodeVarType`.

## 4. IR design choice
This contract uses a typed three-address CFG IR with virtual registers.

## 4.1 Core properties
1. Function-level control-flow graph (basic blocks + terminators).
2. Each non-terminator instruction has at most one destination virtual register.
3. Virtual register namespace is function-local.
4. No architecture-specific physical registers in frontend IR.
5. Types are explicit per instruction/result.

## 4.2 Naming conventions
1. Virtual registers: `%v<number>`.
2. Basic blocks: `bb<number>`.
3. Globals: `@name`.
4. Stack slots: `%slot<number>`.

## 5. IR type system
Minimum IR primitive types:
1. `i1` (predicate/boolean).
2. `i8` (byte scalar).
3. `i16` (native scalar for target architecture).
4. `i32` (for compile-time widening and some constant operations if needed).
5. `ptr` (16-bit address-space pointer).
6. `void`.

Derived types:
1. `arr<T, N>`.
2. `struct<tag>` handle or lowered field layout metadata.
3. `union<tag>` handle.

## 6. IR module structure

## 6.1 Module
Contains:
1. Target triple/arch metadata (project-local value).
2. Global symbol declarations.
3. Function declarations and definitions.

## 6.2 Function
Contains:
1. Signature: name, return type, params.
2. Local symbol-to-slot map.
3. Ordered basic blocks.

## 6.3 Basic block
Contains:
1. Label.
2. Zero or more non-terminator instructions.
3. Exactly one terminator instruction.

## 7. Instruction set (frontend IR)

## 7.1 Constants and moves
1. `%vdst = <imm>`                         (constant: inline literal assigned to a virtual register)
2. `%vdst = %vsrc`                         (copy/move)

## 7.2 Arithmetic and bitwise
1. `%vdst = %a + %b`  /  `%a - %b`  /  `%a * %b`  /  `%a /s %b`  /  `%a /u %b`  /  `%a %s %b`  /  `%a %u %b`
2. `%vdst = %a & %b`  /  `%a | %b`  /  `%a ^ %b`
3. `%vdst = %a << %b`  /  `%a >>u %b`  /  `%a >>s %b`    (logical / arithmetic shift)
4. `%vdst = -%a`  /  `~%a`                 (unary neg / bitwise not)

All arithmetic is typed by the operands; type annotation on the instruction
is optional in text form but required in the in-memory IR node.

The `s`/`u` suffix on `div` and `mod` is mandatory. Signed and unsigned division
produce different results and the backend must know which to emit. Shifts follow
the same convention: `>>u` is logical, `>>s` is arithmetic.

## 7.3 Comparisons and predicates
1. `%pdst:i1 = %a == %b`
2. `%pdst:i1 = %a != %b`
3. `%pdst:i1 = %a <s %b`   (signed less-than; use `<u` for unsigned)
4. `%pdst:i1 = %a <=s %b`
5. `%pdst:i1 = %a >s %b`
6. `%pdst:i1 = %a >=s %b`

Signed comparisons are the default. Append `u` suffix for unsigned variants.
The suffix convention mirrors section 7.2 for consistency.

## 7.4 Memory
1. `%ptr = addr_of <symbol>`               (take address of a named local or global)
2. `%vdst = *%ptr`                         (load)
3. `*%ptr = %vsrc`                         (store)
4. `%ptr2 = %base + %idx * <elem_size>`    (address arithmetic / GEP)

`elem_size` is in **16-bit words** (the addressing unit of the target ISA), not bytes. `i8`/`i16`/pointer = 1; `i32` = 2; `array<T, N>` = `N * size(T)`. Struct member access is lowered as `gep base + offset_words * 1` where `offset_words` is computed by walking the struct's AST decl. Unions use offset 0 for every field.

For an array variable `T arr[N]` (or sub-array `arr[i]` of type `T'[M]`), `addr_of` returns the address of the first element directly — no extra `load`. For a pointer variable `T *p`, `addr_of p` gives the slot address and a `load` reads the pointer's value before any GEP.

## 7.5 Cast / conversion
1. `%vdst = (zext <to>) %src`              (zero-extend; use for unsigned values)
2. `%vdst = (sext <to>) %src`             (sign-extend; use for signed values)
3. `%vdst = (trunc <to>) %src`
4. `%vdst = (bitcast <to>) %src`          (only when semantically legal)

## 7.6 Control flow (terminators)
1. `goto bbX`
2. `if %pred goto bbTrue else goto bbFalse`
3. `ret void`
4. `ret %v`

## 7.7 Calls
Inline argument list; argument order in IR matches source order.
ABI push ordering (right-to-left for C convention) is the backend's
responsibility, not the IR's.

1. `%vdst = @func(%arg0, %arg1, ...)`      (function with return value)
2. `@func(%arg0, %arg1, ...)`              (void function)
3. `@func()`                               (no arguments)


## 8. AST-to-IR lowering contract

## 8.1 General rules
1. Lowering is recursive per function body to CFG.
2. Every expression lowering returns a value handle (`%vN`) and type.
3. Every statement lowering returns current block tail and may create new blocks.
4. Lowering must treat semantic metadata as the source of truth:
   - `semantic_get_node_info(ctx, expr_node)->type`
   - `semantic_get_node_info(ctx, expr_node)->symbol`
   - `semantic_get_node_info(ctx, expr_node)->value_kind`

## 8.2 Expression lowering
1. Literals -> `const` (or carried inline as `IR_VAL_IMM_INT` when feeding directly into another instruction).
2. Identifier read -> `load` from symbol address/slot.
3. Assignment:
- lower RHS,
- compute LHS address,
- `store`,
- result value is assigned value (C semantics).
4. Pre/post inc/dec:
- compute address,
- load old,
- add/sub 1,
- store new,
- return old/new per pre/post form.
5. Ternary:
- lower condition to predicate,
- branch to true/false blocks,
- merge via a temporary slot (this IR is not in SSA form).
6. Logical `&&` / `||`:
- lower to a control-flow diamond writing 0 / 1 into a result slot,
- preserve C short-circuit semantics: rhs is only evaluated when its result can change the outcome.
7. Array access `arr[i]`:
- if `arr` is an array variable (or sub-array), the address of the variable IS the base of its elements — emit `addr_of` only, do **not** add a `load`.
- if `arr` is a pointer variable, `addr_of` then `load` to obtain the pointer value, then GEP.
- emit `gep base + idx * stride` where stride is the element size in 16-bit words.
8. Member access `s.f` / `p->f`:
- compute the field's word offset by walking the struct's AST decl (sum of preceding fields' word sizes; for unions every field is at offset 0),
- emit `gep base + offset * 1` where base is `addr_of s` for `.` and the loaded pointer value for `->`.
9. Unsigned dispatch — derive `is_unsigned` from operand types, NOT the result type. The semantic pass returns the static signed-int singleton for arithmetic results, so the result type alone misses unsigned operands.
10. MUL / DIV / MOD — lower as `IR_OP_CALL` to runtime helpers (`__mul`, `__divs`, `__divu`, `__mods`, `__modu`); see §13a.

## 8.3 Statement lowering
1. `if/else`: create branch and merge blocks.
2. `while`: create condition block + body + exit.
3. `do-while`: body then condition then loop/exit.
4. `for`: lower init; then while-like structure with update block.
5. `switch/case/default`: lower to compare chain and branches (or jump table later).
6. `break`/`continue`: resolve to nearest loop/switch targets via context stack.
7. `return`: lower return value if any and emit terminator.

## 8.4 Function lowering
1. Create entry block.
2. Allocate stack slots for locals and spilled temporaries representation metadata.
3. Bind params to symbols.
4. For the first 3 params (passed in `a0`/`a1`/`a2`) emit `addr_of slot` + `store %v_param` to copy the incoming register into the local slot. **Do NOT emit this STORE for stack-passed params (index ≥ 3)** — the callee's codegen prologue loads them from `fp+(i-2)` directly into the slot via `t3`. Going through a vreg would require modelling all stack params as live-in simultaneously, which the IR has no construct for; without that interference, regalloc legitimately coalesces their colors and the prologue's loads would clobber each other.
5. Ensure all paths end with terminator; inject default `ret void` only when legal.

## 9. Backend interface contract

## 9.1 Calling convention mapping (from abi.m4)
Target register ABI mapping:
1. `r0`: zero.
2. `r1-r3`: args/returns (`a0/a1/a2`, return in `a0`/`r1`).
3. `r4-r6`: temporaries caller-saved (`t0`–`t2`).
4. `r7`: codegen scratch (`t3`) — **reserved, not allocated by regalloc**.
5. `r8-r11`: callee-saved (`s0`–`s3`).
6. `r12`: frame pointer.
7. `r13`: stack pointer.
8. `r14`: link register.
9. `r15`: global pointer/reserved.

IR/backend contract:
1. Up to 3 scalar args passed in arg registers, remainder on stack (caller pushes args[N-1]..args[3] before the CALL so that args[3] sits at lowest address; codegen actually `ADDI sp, sp, #-N; SW arg, sp, #i` to keep the order without depending on push semantics).
2. Scalar return in `a0` (= `r1`).
3. Call sequence must preserve callee-saved regs.
4. Backend must honour stack discipline compatible with PUSH/POP macro convention.
5. `r7` is reserved as a codegen scratch (immediate materialisation, in-place op spilling, OR-macro internal temp, parallel-copy cycle breaking). Regalloc must not allocate it; codegen relies on it being free at every program point.
6. Stack-passed parameters (index ≥ 3) are loaded by the callee's prologue from `fp+(i-2)` into the local slot via `t3`. The IR does NOT emit a STORE for these params (going through a vreg would force an unmodellable live-in for all of them simultaneously).
7. Register-arg setup at a CALL must do a parallel copy, not sequential MOVs — sources can form cycles when regalloc colors don't match the precolor target. Cycles are broken via `t3`.

## 9.2 ISA lowering constraints
From assembler ISA:
1. Native arithmetic/logical operations mostly 16-bit integer oriented.
2. Short immediates are 4-bit in RI/RRI forms.
3. Wide immediate materialization requires `IMM` prefix + low nibble op.
4. Branch displacement is signed 8-bit relative offset.
5. Loads/stores available for word and byte (`LW/LB/SW/SB`).

Backend obligations:
1. Insert `IMM` sequences when constant cannot fit low immediate field.
2. Handle branch range overflow (error, long-branch expansion, or trampoline policy; choose one and enforce consistently).
3. Emit compare/flag setup before conditional branches.

## 10. Unsupported feature policy at IR stage
If semantic marks a node unsupported for current backend, lowering must fail with deterministic code and message.
Examples (until explicitly supported):
1. Floating-point arithmetic/codegen.
2. Full struct/union value copy/return semantics (field access via `.` / `->` IS supported).
3. Variadic call lowering.
4. Function pointers / indirect calls.
5. `long long` / 64-bit arithmetic.
6. Array / struct aggregate initialisers (`{1, 2, 3}` syntax).

These features are flagged at the semantic stage by setting `SEM_NODE_CODEGEN_BLOCKED`
in the expression's `sem_node_info_t.flags`. IR lowering must check this flag before
descending into any expression node and emit `IR001` when it is set.

Logical `&&` and `||` are supported: lowered as a control-flow diamond writing 0/1 into a result slot. Short-circuit semantics are preserved.

## 11. Canonical forms required for optimization/regalloc
1. Basic block ends with single terminator.
2. No implicit fallthrough without explicit branch in serialized IR.
3. Def-before-use in each block except phi-like merges by contract.
4. Virtual register lifetimes computable by linear scan or graph coloring.
5. Side effects explicit via `store`/`call`/terminators.

## 12. IR serialization contract
A text form is required for debugging and CI.
Minimum example:

```
module main_mod
func @sum(i16 %a, i16 %b) -> i16 {
bb0:
  %v1 = add i16 %a, %b
  ret i16 %v1
}
```

Required serializer properties:
1. Stable ordering for deterministic diffs.
2. Stable temporary numbering for identical input.
3. Parseable back into IR (optional in phase 1, required in phase 2).

## 13. Diagnostics in IR lowering
Use prefix `IR###`.
Examples:
1. `IR001`: unsupported node for lowering.
2. `IR002`: missing symbol binding on identifier.
3. `IR003`: type mismatch / unsupported initialiser after semantic stage.
4. `IR004`: unresolved control target (`break/continue`) in lowering context.

## 13a. Runtime helpers (software-emulated arithmetic)

The target ISA has no hardware multiply or divide. The IR opcodes `IR_OP_MUL`,
`IR_OP_DIVS`, `IR_OP_DIVU`, `IR_OP_MODS`, `IR_OP_MODU` are lowered (in
`ir_lower_expr.c`) as `IR_OP_CALL` with the runtime callee names below; the IR
opcodes themselves never reach the codegen.

| Helper | C operator(s) | Algorithm | ABI |
|---|---|---|---|
| `__mul`  | `*`         | 16-iter shift-and-add               | leaf, clobbers `r1`–`r6` |
| `__divu` | unsigned `/`| 16-iter restoring long division     | leaf, clobbers `r1`–`r7` |
| `__modu` | unsigned `%`| same loop, returns remainder        | leaf, clobbers `r1`–`r7` |
| `__divs` | signed `/`  | sign-normalise then `__divu`        | non-leaf, saves `r8` + `lr` |
| `__mods` | signed `%`  | sign-normalise then `__modu` (sign of result follows dividend, per C99) | non-leaf, saves `r8` + `lr` |

Per the project ISA convention, `BLEU` is **strictly less than unsigned** and
`BLETU` is **less-or-equal unsigned** (despite the suffix). The runtime helpers
rely on this; do not change either side without updating the other.

The unsigned-vs-signed dispatch is determined by the IR lowering from the
operand types, NOT the result type — the semantic pass returns the static
signed-int singleton for arithmetic results, so looking at the result alone
misses unsigned operands.

## 14. Validation obligations
Lowering implementation must include tests for:
1. arithmetic expression trees,
2. assignment and lvalue ops,
3. if/while/for CFG shape,
4. function call/return paths,
5. array indexing address calculations,
6. branch and immediate materialization boundaries.

## 15. Minimal milestone target
By first backend-ready milestone, IR must correctly represent:
1. integer scalar expressions,
2. local/global variable reads/writes,
3. function calls with <= 3 args,
4. if/while/for,
5. return and basic branch semantics.

## 16. Contract evolution rule
Any IR opcode/type/ABI contract change must include in same PR:
1. spec update in this file,
2. serializer update,
3. at least one new regression test,
4. migration note for backend consumers.
