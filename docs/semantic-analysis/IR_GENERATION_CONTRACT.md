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
`lexer -> parser -> AST -> semantic pass1 -> semantic pass2 -> IR lowering -> backend -> assembler`

IR lowering must only execute if semantic stage has zero errors.

## 3. Input contract from semantic stage
Lowering requires these guarantees on AST:
1. Every expression node has inferred type metadata.
2. Every identifier/member/function reference has symbol binding.
3. Every statement has validated control legality.
4. Unsupported features are explicitly marked and must trigger deterministic lowering errors.

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
1. `const <type> <imm> -> %vdst`
2. `mov <type> %vsrc -> %vdst`

## 7.2 Arithmetic and bitwise
1. `add/sub/mul/div/mod <type> %a, %b -> %vdst`
2. `and/or/xor <type> %a, %b -> %vdst`
3. `shl/shr_l/shr_a <type> %a, %b -> %vdst`
4. `neg/not <type> %a -> %vdst`

## 7.3 Comparisons and predicates
1. `cmp_eq/cmp_ne/cmp_lt/cmp_le/cmp_gt/cmp_ge <type> %a, %b -> %pdst(i1)`

## 7.4 Memory
1. `addr_of <symbol_or_slot> -> %ptr`
2. `load <type> %ptr -> %vdst`
3. `store <type> %vsrc, %ptr`
4. `gep <base_ptr>, <index>, <elem_size> -> %ptr` (or equivalent offset op)

## 7.5 Cast/conversion
1. `zext/sext/trunc <from,to> %src -> %vdst`
2. `bitcast <from,to> %src -> %vdst` (only when semantically legal)

## 7.6 Control flow
1. `br bbX` (unconditional)
2. `cbr %pred, bbTrue, bbFalse`
3. `ret void`
4. `ret <type> %v`

## 7.7 Calls
1. `call <ret_type> @func(<arg list>) -> %vdst?`
2. `call void @func(<arg list>)`

## 8. AST-to-IR lowering contract

## 8.1 General rules
1. Lowering is recursive per function body to CFG.
2. Every expression lowering returns a value handle (`%vN`) and type.
3. Every statement lowering returns current block tail and may create new blocks.

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
