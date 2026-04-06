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
1. Literals -> `const`.
2. Identifier read -> `load` from symbol address/slot unless held in current SSA-like map.
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
- merge with value move strategy (phi-like handling can be explicit pseudo-phi or temporary slot if SSA is not yet implemented).

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
4. Ensure all paths end with terminator; inject default return only when legal.

## 9. Backend interface contract

## 9.1 Calling convention mapping (from abi.m4)
Target register ABI mapping:
1. `r0`: zero.
2. `r1-r3`: args/returns (`a0/a1/a2`, return in `r1`).
3. `r4-r7`: temporaries caller-saved.
4. `r8-r11`: callee-saved.
5. `r12`: frame pointer.
6. `r13`: stack pointer.
7. `r14`: link register.
8. `r15`: global pointer/reserved.

IR/backend contract:
1. Up to 3 scalar args passed in arg registers, remainder on stack.
2. Scalar return in `r1`.
3. Call sequence must preserve callee-saved regs.
4. Backend must honor stack discipline compatible with PUSH/POP macro convention.

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
2. Full struct/union value copy/return semantics.
3. Variadic call lowering.

These features are flagged at the semantic stage by setting `SEM_NODE_CODEGEN_BLOCKED`
in the expression's `sem_node_info_t.flags`. IR lowering must check this flag before
descending into any expression node and emit `IR001` when it is set.

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
3. `IR003`: type mismatch after semantic stage (internal contract violation).
4. `IR004`: unresolved control target (`break/continue`) in lowering context.

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
