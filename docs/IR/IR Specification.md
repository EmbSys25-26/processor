## IR Code Generator

**Input:** AST + annotation table **
Output:** Low-GIMPLE-style typed three-address CFG IR **
Purpose:** Convert the typed AST into an explicit, backend-ready intermediate representation where every operation, type, memory access, and control flow edge is stated unambiguously **Characteristics:** Top-down pre-order traversal with post-order emission on expressions. Does not receive the symbol table directly — uses it indirectly via the annotation table through `semantic_get_node_info`

---

### Pipeline position

```
semantic_analyze (pass1 + pass2)
        │
        ▼
ir_lower_translation_unit     ← entry point
        │
        ├── ir_lower_function         (Section 4 – Structure)
        │       ├── ir_lower_decl     (Section 1 – Declarations)
        │       ├── ir_lower_stmt     (Section 3 – Statements)
        │       │       └── ir_lower_expr   (Section 2 – Expressions)
        │       └── ir_lower_lvalue_addr    (lvalue address resolution)
        │
        └── ir_module_print           (§12 – Text serialiser)
```

IR lowering only executes if `semantic_analyze` returned zero errors. The entry point is:

```c
ir_module_t *ir_lower_translation_unit(const TreeNode_t   *root,
                                        semantic_context_t *sem_ctx,
                                        const char         *module_name);
```

---

### The four type systems in the pipeline

There are four completely separate notions of "type" coexisting across the pipeline:

|Type system|Defined in|What it describes|
|---|---|---|
|`NodeType_t`|`ASTree.h`|What syntactic construct a node is (`NODE_IF`, `NODE_OPERATOR`, …)|
|`VarType_t`|`ASTree.h`|Legacy parser-level type hint on `NODE_TYPE` nodes (redundant after pass 1)|
|`type_t`|`type.h`|Full semantic C type, arena-allocated, used by both passes and IR lowering|
|`ir_type_t`|`ir.h`|Flattened IR type for instruction emission (`i8`, `i16`, `ptr`, …)|

The conversion `type_t → ir_type_t` happens in `ir_type_from_sem` in `ir_lower.c`:

```
TYPE_BUILTIN + BUILTIN_INT   → IR_TYPE_I16   (target is 16-bit word)
TYPE_BUILTIN + BUILTIN_CHAR  → IR_TYPE_I8
TYPE_BUILTIN + BUILTIN_LONG  → IR_TYPE_I32
TYPE_BUILTIN + BUILTIN_VOID  → IR_TYPE_VOID
TYPE_BUILTIN + BUILTIN_STRING→ IR_TYPE_PTR   (ptr to i8, §3.6)
TYPE_POINTER                 → IR_TYPE_PTR
TYPE_ARRAY                   → IR_TYPE_ARRAY
TYPE_STRUCT_TAG              → IR_TYPE_STRUCT
```

---

### IR type system (`ir_type_t`)

```c
typedef enum {
    IR_TYPE_VOID,
    IR_TYPE_I1,    /* predicate / boolean                  */
    IR_TYPE_I8,    /* byte                                  */
    IR_TYPE_I16,   /* native word (target is 16-bit)        */
    IR_TYPE_I32,   /* extended / widened                    */
    IR_TYPE_PTR,   /* 16-bit address-space pointer          */
    IR_TYPE_ARRAY, /* arr<T, N>                             */
    IR_TYPE_STRUCT,/* struct<tag>                           */
    IR_TYPE_UNION  /* union<tag>                            */
} ir_type_kind_t;
```

These are not heap-allocated — they are small structs passed by value everywhere in the IR layer.

---

### IR module structure

```
ir_module_t                         (§6.1 — top-level container)
├── arch string
├── ir_global_t*                    (linked list of global declarations)
└── ir_function_list_t*             (linked list of functions)
        └── ir_function_t           (§6.2 — one function)
                ├── name, ret_type
                ├── param_names[], param_types[]
                ├── slot map (ir_slot_entry_t*)    ← stack allocation metadata
                ├── next_vreg counter
                └── ir_block_t*                   (§6.3 — ordered basic blocks)
                        ├── label (bbN)
                        ├── ir_instr_t* (instruction chain)
                        └── exactly one terminator
```

---

### Naming conventions

|Namespace|Syntax|Example|
|---|---|---|
|Virtual registers|`%vN`|`%v0`, `%v14`|
|Stack slots|`%slotN`|`%slot0`, `%slot2`|
|Globals|`@name`|`@g_count`, `@add`|
|Basic blocks|`bbN`|`bb0`, `bb3`|
|Immediates|raw integer|`42`, `-1`|

---

### Instruction set

#### §7.1 Constants and moves

```
%vdst = <imm>          IR_OP_CONST
%vdst = %vsrc          IR_OP_COPY
```

#### §7.2 Arithmetic and bitwise

```
%vdst = %a add %b      IR_OP_ADD
%vdst = %a sub %b      IR_OP_SUB
%vdst = %a mul %b      IR_OP_MUL
%vdst = %a divs %b     IR_OP_DIVS   (signed)
%vdst = %a divu %b     IR_OP_DIVU   (unsigned)
%vdst = %a mods %b     IR_OP_MODS   (signed remainder)
%vdst = %a modu %b     IR_OP_MODU   (unsigned remainder)
%vdst = %a and %b      IR_OP_AND
%vdst = %a or %b       IR_OP_OR
%vdst = %a xor %b      IR_OP_XOR
%vdst = %a shl %b      IR_OP_SHL
%vdst = %a shru %b     IR_OP_SHRU   (logical shift right)
%vdst = %a shrs %b     IR_OP_SHRS   (arithmetic shift right)
%vdst = -%a            IR_OP_NEG
%vdst = ~%a            IR_OP_NOT
```

The `s`/`u` suffix on `div`, `mod`, and shifts is mandatory — signed and unsigned produce different machine instructions and the backend must know which to emit.

#### §7.3 Comparisons (result type always `i1`)

```
%pdst:i1 = %a eq %b
%pdst:i1 = %a neq %b
%pdst:i1 = %a lts %b    (signed <)
%pdst:i1 = %a les %b    (signed <=)
%pdst:i1 = %a gts %b    (signed >)
%pdst:i1 = %a ges %b    (signed >=)
%pdst:i1 = %a ltu %b    (unsigned <)
...
```

#### §7.4 Memory

```
%ptr  = addr_of <symbol>           IR_OP_ADDR_OF
%vdst = *%ptr                      IR_OP_LOAD
*%ptr = %vsrc                      IR_OP_STORE
%ptr2 = gep %base + %idx * stride  IR_OP_GEP
```

`addr_of` takes a slot or global reference and produces a pointer virtual register. Every variable read and write goes through `addr_of` + `load`/`store` — there are no implicit memory accesses. `stride` in GEP is a compile-time constant equal to `sizeof(element_type)`.

#### §7.5 Casts

```
%vdst = (zext <to>) %src     IR_OP_ZEXT    (zero-extend, unsigned values)
%vdst = (sext <to>) %src     IR_OP_SEXT    (sign-extend, signed values)
%vdst = (trunc <to>) %src    IR_OP_TRUNC
%vdst = (bitcast <to>) %src  IR_OP_BITCAST
```

#### §7.6 Terminators (every basic block ends with exactly one)

```
goto bbX
if %pred goto bbTrue else bbFalse
ret void
ret %v
```

#### §7.7 Calls

```
%vdst = @func(%arg0, %arg1, ...)    (value-returning)
@func(%arg0, %arg1, ...)            (void)
@func()                             (no arguments)
```

Argument order in IR matches source order. ABI push ordering (right-to-left for C convention) is the backend's responsibility, not the IR's.

---

### The `ir_instr_t` struct

```c
struct ir_instr_s {
    ir_opcode_t  op;
    ir_value_t   dst;        /* IR_VAL_NONE for stores/void calls/ret */
    ir_value_t   src[2];     /* up to two operands for most instructions */

    union {
        struct {
            long stride;     /* compile-time element size in bytes */
        } gep;

        struct {
            char       callee[128];
            ir_value_t args[IR_MAX__ARGS];
            unsigned   arg_count;
            int        is_void_call;
        } call;

        struct {
            unsigned true_block;
            unsigned false_block;
        } branch;
    } as;

    ir_instr_t *next;
};
```

`IR_MAX_ARGS` (16) bounds both the argument array in `ir_instr_t` and the parameter arrays in `ir_function_t` (`IR_MAX_PARAMS`) — they represent the same logical limit (the maximum arity of a function call contract).

`IR_OP_COUNT` is a sentinel at the end of the opcode enum whose numeric value automatically equals the total number of opcodes. It is used to dimension lookup tables and validate opcodes, never as an actual instruction opcode.

---

### Shared lowering context (`ir_lower_ctx_t`)

All four lowering sections share one mutable state struct threaded through every call:

```c
typedef struct ir_lower_ctx_s {
    ir_module_t        *module;
    semantic_context_t *sem_ctx;
    ir_function_t      *func;        /* current function being lowered */
    ir_block_t         *cur_block;   /* block currently being appended to */
    unsigned            error_count;
    ir_ctrl_frame_t     ctrl_stack[IR_CTRL_STACK_MAX];
    int                 ctrl_depth;  /* break/continue target stack */
} ir_lower_ctx_t;
```

It is zero-initialised with `memset` before use because it is declared as a local variable on the stack — without zeroing it would contain garbage from previous stack frames, causing incorrect error counts, dangling pointer dereferences, and spurious ctrl-frame entries.

---

### Section 1 — Declarations (`ir_lower_decl.c`)

Handles `NODE_VAR_DECLARATION` and `NODE_ARRAY_DECLARATION`.

**Global declarations** (`MEMORY_CLASS_GLOBAL`): emits an `ir_global_t` entry into the module. Non-constant global initialisers are flagged as a phase-1 limitation (diagnostic `IR003`); constant initialisers are recorded for the backend data emitter.

**Local declarations** (`MEMORY_CLASS_STACK` / `MEMORY_CLASS_PARAMETER`): allocates a stack slot via `ir_new_slot`, then if an initialiser expression is present lowers it with `ir_lower_expr` and emits `addr_of slot` + `store`.

The symbol is always located through the annotation table:

```c
const sem_node_info_t *info = semantic_get_node_info(lctx->sem_ctx, decl_node);
symbol_t *sym = info->symbol;
// sym->memory_class tells us where this lives
```

---

### Section 2 — Expressions (`ir_lower_expr.c`)

`ir_lower_expr` is the recursive workhorse. It is called top-down (the node is identified first) but its instruction emission is post-order (children are lowered before the parent instruction is emitted). This is **top-down traversal with bottom-up value synthesis** — the return value `ir_value_t` travels upward through the call stack.

Before descending into any node it checks:

```c
if (info->flags & SEM_NODE_CODEGEN_BLOCKED) {
    ir_diag(lctx, "IR001", ...);   /* floating-point, variadic, etc. */
    return ir_val_none();
}
```

**Key patterns:**

_Identifier read_ — look up symbol from annotation, resolve to slot or global via `resolve_symbol_ref`, emit `addr_of` + `load`:

```
%v0 = addr_of %slot0
%v1 = *%v0
return %v1
```

_Assignment_ — lower RHS, compute LHS address via `ir_lower_lvalue_addr`, emit `store`:

```
%v2 = addr_of %slot0
*%v2 = %v1
```

_Binary operator_ — lower both children first, widen if needed, emit binary instruction, return result vreg.

_Pre/post inc/dec_ — compute address, load old value, add/subtract 1, store new. Pre returns new; post returns old.

_Ternary_ — allocate a result slot, lower condition, emit `branch`, lower true/false branches each storing into the slot, emit `goto` merge, load from slot.

_Logical `&&`/`||`_ — short-circuit via branch to a shared result slot.

_Function call_ — collect argument vregs, emit `IR_OP_CALL`. Void calls set `is_void_call = 1` and return `ir_val_none()`.

`ir_lower_lvalue_addr` computes the **address** of an lvalue rather than its value. It is called from `ir_lower_expr` for assignments, compound assignments, inc/dec, address-of, array access (rvalue), and member access (rvalue). The two functions are mutually recursive — `ir_lower_lvalue_addr` calls `ir_lower_expr` for subexpressions, and `ir_lower_expr` calls `ir_lower_lvalue_addr` for lvalue contexts.

---

### Section 3 — Statements (`ir_lower_stmt.c`)

`ir_lower_stmt` iterates a sibling chain; `ir_lower_single_stmt` dispatches on node type. Statements are traversed top-down: the statement node is identified first and it controls which blocks are created and in what order.

**`if`/`else`:**

```
evaluate condition → %pred
if %pred goto bb_then else bb_else   ← terminator
bb_then: lower then-body → goto bb_merge
bb_else: lower else-body → goto bb_merge
bb_merge: (continue)
```

**`while`:**

```
goto bb_cond
bb_cond: evaluate condition → if %pred goto bb_body else bb_exit
bb_body: push ctrl(break=exit, continue=cond) → lower body → pop → goto bb_cond
bb_exit: (continue)
```

**`do-while`:**

```
goto bb_body
bb_body: push ctrl → lower body → pop → goto bb_cond
bb_cond: evaluate condition → if %pred goto bb_body else bb_exit
bb_exit: (continue)
```

**`for`:**

```
lower init
goto bb_cond
bb_cond: evaluate condition → if %pred goto bb_body else bb_exit
bb_body: push ctrl(break=exit, continue=update) → lower body → pop → goto bb_update
bb_update: lower update → goto bb_cond
bb_exit: (continue)
```

**`switch`** uses a comparison chain (phase 1): emit `eq` comparisons against each case constant, branching to pre-allocated case blocks. A `default` block is the fallthrough target at the end of the chain.

**`break`/`continue`** resolve to the nearest enclosing loop or switch via the `ctrl_stack` in `ir_lower_ctx_t`. After emitting `goto`, a dead block is created to maintain the invariant that `cur_block` is always unterminated at the start of each statement.

**`return`** lowers the return expression if present, emits `IR_OP_RET`, then creates a dead continuation block.

After a `return` or `break` the lowering creates an unreachable "dead" block. This preserves the invariant that `cur_block` always points to an open (non-terminated) block, avoiding double-terminator errors on subsequent statements.

---

### Section 4 — Structure (`ir_lower.c`)

**`ir_lower_translation_unit`** walks the `NODE_TRANSLATION_UNIT` sibling chain:

- `NODE_FUNCTION` with a body → `ir_lower_function`
- `NODE_FUNCTION` prototype only → `ir_module_add_global` with `is_extern = 1`
- `NODE_VAR_DECLARATION` / `NODE_ARRAY_DECLARATION` → `ir_lower_global_decl`
- Aggregate type declarations → metadata only, no instructions

**`ir_lower_function`** (§8.4):

1. Retrieve return type from annotation (`info->type->as.function.return_type`)
2. Extract function name from `func_node->nodeData.sVal`
3. Create `ir_function_t` and entry block `bb0`
4. Walk children for `NODE_PARAMETER` nodes; for each: register in `func->param_names/param_types`, allocate a stack slot, emit `addr_of slot` + `store` of incoming parameter vreg
5. Find `NODE_BLOCK` body child and call `ir_lower_stmt`
6. If `cur_block` has no terminator, inject `ret void` (legal for void functions; for non-void functions the semantic pass already rejected the missing return)
7. `ir_module_add_function`

**`ir_type_from_sem`** performs the `type_t → ir_type_t` conversion. Float/double types are not blocked here (they were already marked `SEM_NODE_CODEGEN_BLOCKED` by pass 2); the conversion returns a placeholder `i16` that will never be reached in valid code.

---

### §12 Text serialisation

The serialiser (`ir_module_print` → `ir_function_print` → `ir_block_print` → `ir_instr_print`) produces a stable, human-readable text form for debugging and CI diffing:

```
module main_mod

global @g_count : i16

func @add(i16 %a, i16 %b) -> i16 {
  slot %slot1 : i16  ; b
  slot %slot0 : i16  ; a

bb0:
    %v0 = addr_of %slot0
    %v1 = *%v0
    %v2 = addr_of %slot1
    %v3 = *%v2
    %v4 = %v1 add %v3
    ret %v4

bb1:
    ret void
}
```

Slot declarations appear at the top of the function body to make the stack frame visible. Basic blocks are printed in allocation order. Instruction numbering is stable for identical input.

---

### Diagnostics (§13)

All IR-stage errors use the `IR###` prefix:

|Code|Meaning|
|---|---|
|`IR001`|Unsupported node for lowering (e.g. float, variadic, `SEM_NODE_CODEGEN_BLOCKED`)|
|`IR002`|Missing symbol binding on identifier|
|`IR003`|Type mismatch after semantic stage (internal contract violation)|
|`IR004`|Unresolved control target (`break`/`continue`) outside loop/switch|

---

### How the annotation table drives IR lowering

IR lowering never calls `symbol_lookup_visible` or touches `scope_stack`. The single query it issues is:

```c
const sem_node_info_t *info = semantic_get_node_info(lctx->sem_ctx, node);
```

From the returned record it extracts:

- `info->type` → converted to `ir_type_t` via `ir_type_from_sem`
- `info->symbol->memory_class` → determines whether to emit `addr_of @global` or `addr_of %slot`
- `info->flags & SEM_NODE_CODEGEN_BLOCKED` → abort with `IR001` before descending
- `info->value_kind` → distinguishes lvalue from rvalue for assignment and address-of

The scope chain is not needed because pass 2 already resolved every name and stored a direct `symbol_t*` pointer in the annotation. That pointer remains valid because the symbol lives in the persistent arena which is not freed until after IR lowering completes.

---

### Full pipeline trace for one statement

Source: `r = add(a, b);`

**After parsing:**

```
NODE_OPERATOR(OP_ASSIGN)
  NODE_IDENTIFIER("r")
  NODE_FUNCTION_CALL
    NODE_IDENTIFIER("add")
    NODE_IDENTIFIER("a")
    NODE_IDENTIFIER("b")
```

**After pass 2 annotation table:**

```
&IDENTIFIER("r") LHS  → { type=int, symbol=&sym_r, kind=LVALUE }
&IDENTIFIER("add")    → { type=func(int,int)->int, symbol=&sym_add, kind=FUNCTION_DESIGNATOR }
&IDENTIFIER("a")      → { type=int, symbol=&sym_a, kind=LVALUE }
&IDENTIFIER("b")      → { type=int, symbol=&sym_b, kind=LVALUE }
&FUNCTION_CALL        → { type=int, symbol=NULL, kind=RVALUE }
&OP_ASSIGN            → { type=int, symbol=NULL, kind=RVALUE }
```

**IR lowering emits:**

```
%v0 = addr_of %slot_a
%v1 = *%v0
%v2 = addr_of %slot_b
%v3 = *%v2
%v4 = @add(%v1, %v3)
%v5 = addr_of %slot_r
*%v5 = %v4
```