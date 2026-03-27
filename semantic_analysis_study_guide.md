# Semantic Analysis — Complete Study Guide

> Cross-referenced from the full 72-slide presentation and the live `Semantic/` codebase.
> Organised by presentation section so you can follow along slide-by-slide.

---

## 1. Conceptual Overview

**What semantic analysis is:** The compiler phase that validates *meaning* after the parser produces an AST, and before IR code generation. It does not do frontend optimisations.

- **Input:** Parser AST (`TreeNode_t *root`)
- **Outputs:** diagnostic list (errors/warnings), scope/symbol info stored in `semantic_context_t`, inferred type annotations that the IR stage will consume.

**Two roles** (only the first is implemented):
1. Source-code correctness — type rules, scope rules, control-flow legality.
2. Frontend optimisation — intentionally skipped.

**Key mental model (the assignment example):**
`x = 1` where `x: double` and `1: int`. Pass 2's `infer_expr_type` on the assignment operator finds `lhs_type = double`, `rhs_type = int`. Both are `TYPE_BUILTIN` and `is_numeric_builtin` → `assignment_compatible` returns 1, so **no SEM011 error**. Because `builtin_rank(double=6) > builtin_rank(int=3)` and the assignment is widening, `warns_on_narrowing_assignment` also returns 0 — no SEMW001 either. Pass 2 simply synthesises `double` as the result type and records it. The `CastNode` shown in the slide is **not inserted by Pass 2** — it is a placeholder indicating what the IR generation phase will emit when it consumes the inferred type annotations from Pass 2. Pass 2 itself does not mutate the AST.

---

## 1a. Type Casting & Implicit Conversion — Deep Dive

This section fills in what the conceptual overview slide implies but does not spell out.

### The widening rank table (`builtin_rank`)

Defined in `semantic_pass2.c`. Every numeric type gets a rank; higher rank = wider.

```
BUILTIN_CHAR        → rank 1
BUILTIN_SHORT       → rank 2
BUILTIN_INT         → rank 3
BUILTIN_LONG        → rank 4
BUILTIN_FLOAT       → rank 5
BUILTIN_DOUBLE      → rank 6
BUILTIN_LONG_DOUBLE → rank 7
```

This rank is used **exclusively** by `warns_on_narrowing_assignment` to detect narrowing — it is not used to compute the result type of arithmetic operators (that uses a simpler double > float > int ladder directly).

### `assignment_compatible(lhs, rhs)` — the gate function

This is called everywhere Pass 2 needs to decide whether an implicit assignment-like conversion is allowed:

```
Rules:
  1. type_equal(lhs, rhs)  → always accepted
  2. Both TYPE_BUILTIN + both is_numeric_builtin → accepted (all numeric ↔ numeric)
  3. Anything else → rejected → SEM011
```

Concrete cases that **pass** (no SEM011):
- `int = char`, `double = int`, `float = long` — any numeric-to-numeric
- `int = int` — trivially equal

Concrete cases that **fail** (SEM011 emitted):
- `int = struct Foo` — struct is `TYPE_STRUCT_TAG`, not `TYPE_BUILTIN`
- `int *p = 3` — pointer is `TYPE_POINTER`, not numeric
- `double = "hello"` — string is `BUILTIN_STRING`, which `is_numeric_builtin` returns 0 for

### Narrowing — implicit (SEMW001, warning only)

Checked **after** `assignment_compatible` returns 1, via `warns_on_narrowing_assignment`. Three scenarios trigger it:

| Scenario | Example | Reason |
|---|---|---|
| float-family → integral | `int x = 3.14;` | `is_integral(lhs) && is_floating(rhs)` |
| wider float → narrower float | `float x = someDouble;` | `rank(lhs) < rank(rhs)`, both floating |
| wider integral → narrower integral | `char x = someInt;` | `rank(lhs) < rank(rhs)`, both integral |

**Critical guard:** if `expr_is_explicit_cast(rhs_expr)` is true (the RHS is a `NODE_TYPE_CAST` node), `warns_on_narrowing_assignment` returns 0 immediately — the programmer's explicit cast **silences** SEMW001.

**Truncation example:**
```c
double d = 3.99;
int x = d;        // SEMW001: implicit narrowing conversion
                  // x will be 3 at runtime — fractional part is discarded
int y = (int)d;   // No SEMW001 — explicit cast suppresses the warning
```

### Signed ↔ Unsigned — implicit (SEMW002, warning only)

Two distinct triggers:

**In assignments** (`warns_on_signed_to_unsigned_assignment`): fires when `lhs` is unsigned integral AND `rhs` is signed integral AND the rhs is either a non-operator expression or a unary minus. Suppressed by explicit cast.

```c
unsigned int u;
int s = -5;
u = s;       // SEMW002: implicit signed to unsigned conversion
             // At runtime: -5 becomes a large positive value (2's complement wrap)
u = (unsigned int)s;  // No SEMW002 — explicit cast
```

**In binary arithmetic** (`warns_on_mixed_signed_unsigned_operands`): fires for `+`, `-`, `*`, `/` when one operand is unsigned and the other is signed.

```c
unsigned int u = 10;
int s = -3;
int result = u + s;  // SEMW002: mixed signed and unsigned arithmetic
```

### Explicit cast — `NODE_TYPE_CAST`

The AST node `NODE_TYPE_CAST` is produced by the parser for C's `(type)expr` syntax. Structure:
```
NODE_TYPE_CAST
  └── [first child]  → type node (e.g. NODE_TYPE(int))
  └── [sibling]      → source expression
```

`infer_expr_type` handles `NODE_TYPE_CAST` as follows:
1. `semantic_ast_collect_qualifiers_from_chain(node->p_firstChild)` → get qualifiers on the cast target.
2. `semantic_ast_build_type_from_type_node(node->p_firstChild, qualifiers)` → reconstruct the cast-target `type_t *`.
3. `infer_expr_type(node->p_firstChild->p_sibling, state)` → infer source expression type.
4. If `warns_on_const_dropping_cast(cast_type, source_type)` → emit **SEMW003**.
5. Return `cast_type` via `remember_temporary_type` (temporary arena — freed after pass completes).

**No numeric compatibility check on explicit cast.** You can write `(int)somePointer` and Pass 2 accepts it — those pointer↔integer cast errors (SEM012/SEM016) are listed in the TODO comment at the bottom of `semantic_pass2.c` as not yet implemented.

### SEMW003 — const-dropping pointer cast (warning)

```c
const int x = 5;
int *p = (int *)&x;  // SEMW003: explicit cast removes const qualifier
```

`cast_drops_const` recursively walks the pointer chain comparing `TYPE_QUAL_CONST` bits. Only fires if both target and source are `TYPE_POINTER` — scalar const drops are not warned on here (that's SEM008 on assignment).

### Arithmetic result type — how `infer_operator_type` returns a type for `+`, `-`, `*`, `/`

This is a simplified "usual arithmetic conversions" ladder (not the full C11 §6.3.1.8):

```
if either operand is double  → return &g_type_double
if either operand is float   → return &g_type_float
else                         → return &g_type_int
```

Note: `long` is not promoted to a separate result — both `long op long` and `int op int` return `&g_type_int`. This is a known simplification in the implementation.

### SEM011 vs SEM027 — know the difference

| | SEM011 | SEM027 |
|---|---|---|
| **Condition** | `!assignment_compatible(lhs_type, rhs_type)` | LHS node type is not a valid lvalue category |
| **Example** | `int x = some_struct;` | `42 = x;` |
| **What's wrong** | The *types* are incompatible | The *syntactic position* can't be assigned to |
| **Check in code** | `infer_operator_type`, OP_ASSIGN branch | Same OP_ASSIGN branch, separate `if` |

Both can fire on the same assignment node independently (though in practice, SEM027 fires on literal values which have definite types, so both rarely co-occur).

### Known open items (from `semantic_pass2.c` TODO comment)

```
[ ] SEM010 — implicit const removal in pointer assignment
[ ] SEM012 — implicit pointer ↔ integer conversion not allowed
[ ] SEM015 — cast involving incomplete struct/union
[ ] SEM016 — pointer ↔ float cast forbidden (strict mode)
```

These are explicitly listed as unimplemented. If asked during the presentation whether the codebase handles `int *p = 5`, the honest answer is: SEM012 is known-open; the current `assignment_compatible` only checks numeric builtins, so a `pointer = int` assignment would fire SEM011 (since pointer is not `TYPE_BUILTIN`), but for cases like `(float *)someIntPtr` the explicit cast path has no SEM016 check yet.

---

## 2. Strategy: Attribute Grammar Principles Applied Ad Hoc

Two strategies were evaluated:

| | Formal Attribute Grammar | Two-Pass over AST |
|---|---|---|
| **Pro** | Mathematically formal, provable correctness, explicit dependencies | Simpler, easier to debug, separation of concerns between passes |
| **Con** | High design overhead, semantic equations tied to grammar productions | Not formally verified; correctness depends on implementation discipline |

**Decision:** Two-pass ad hoc, with inherited/synthesised attribute discipline applied manually.

### Attribute Flow

| Direction | Data | Examples in code |
|---|---|---|
| **Inherited** (top-down, parent → child) | current scope, current function return type, loop/switch depth | `state->current_return_type`, `state->loop_depth`, `state->switch_depth` |
| **Synthesised** (bottom-up, children → parent) | inferred expression type, operator result type, member-access result type | return value of `infer_expr_type()` |

**Why this matters for the presentation:** When asked "why two passes?", the answer is clean separation: Pass 1 *produces* environment (scope + symbols), Pass 2 *consumes* it. If you mix them, semantic rules become jumbled with syntax rules in the parser.

---

## 3. Types — `type.h` / `type.c`

### ISO C11 N1570 §6.2.5 Compliance

Types are split into **object types** (describe data) and **function types** (describe callables). All derived types can be applied recursively.

### `type_kind_t` — the union discriminant

```c
typedef enum {
  TYPE_INVALID = 0,   // sentinel for error propagation
  TYPE_BUILTIN,       // scalar: char, int, float, void, ...
  TYPE_POINTER,       // as.pointer.base
  TYPE_ARRAY,         // as.array.{elem, size, is_known_size}
  TYPE_FUNCTION,      // as.function.{return_type, params, param_count, is_variadic}
  TYPE_STRUCT_TAG,    // as.aggregate.{tag, decl_node}
  TYPE_UNION_TAG,
  TYPE_ENUM_TAG
} type_kind_t;
```

**Know this cold.** Every `infer_expr_type` call returns a `const type_t *` and you check `->kind` before accessing `->as`.

### `builtin_type_t` — scalar leaf

```
BUILTIN_CHAR, SHORT, INT, LONG, FLOAT, DOUBLE, LONG_DOUBLE, STRING, VOID
```

Note `BUILTIN_STRING` is an extension beyond strict C11 (string literals).

### Qualifier bitmask

```c
TYPE_QUAL_CONST    = (1u << 0)
TYPE_QUAL_VOLATILE = (1u << 1)
TYPE_QUAL_SIGNED   = (1u << 2)
TYPE_QUAL_UNSIGNED = (1u << 3)
```

Stored as `unsigned qualifiers` in both `type_t` and `symbol_t`. The `TYPE_QUAL_CONST` flag is what SEM008/SEM027 check when detecting assignment to a const lvalue.

### Key API functions

| Function | Purpose |
|---|---|
| `type_new_builtin(builtin, quals)` | Allocate a scalar type |
| `type_new_pointer(base, quals)` | Wrap base in a pointer |
| `type_new_array(elem, size, known, quals)` | Array type — `is_known_size=0` for `int a[]` |
| `type_new_function(ret, params, count, variadic, quals)` | Function type used by symbol table |
| `type_new_tagged(kind, tag, quals)` | Struct/union/enum by name |
| `type_equal(lhs, rhs)` | Structural equality (recursive) |
| `type_is_integral(type)` | Returns true for CHAR, SHORT, INT, LONG |
| `type_free(type)` | Ownership release — Pass 1 calls this on failure paths |

**`TYPE_INVALID` is your error sentinel.** Any node whose type cannot be determined gets this kind. Pass 2 propagates it silently (if either operand is `TYPE_INVALID`, skip the check to avoid cascading errors — you see this pattern in every SEM02x check).

---

## 4. Symbols — `symbol.h` / `symbol.c`

### `symbol_s` — full field list (memorise this)

```c
struct symbol_s {
  char *name;
  symbol_kind_t kind;            // OBJECT, FUNCTION, PARAMETER, TAG_*, ENUM_CONST, FIELD
  storage_class_t storage_class; // AUTO, STATIC, EXTERN, PARAMETER
  unsigned qualifiers;           // same bitmask as type qualifiers
  type_t *type;                  // owned pointer

  size_t decl_line;
  size_t decl_col;

  size_t scope_id;               // which scope declared this
  size_t scope_depth;            // 0 = global
  scope_t *decl_scope;           // back-pointer to owner scope

  size_t arity;                  // meaningful only for SYMBOL_FUNCTION
  int is_defined;                // forward decl (0) vs full definition (1)
  symbol_t *next;                // chaining in hash bucket (separate chaining)
};
```

**Two symbol-table lookup functions** — know the difference:

- `symbol_lookup_current(scope, name)` — searches *only* the given scope's bucket. Used in Pass 1 to detect **redeclaration in same scope** (SEM002).
- `symbol_lookup_visible(scope, name)` — walks the `parent` chain until the root. Used in Pass 2 for **identifier resolution** (SEM001).

### `symbol_kind_t`

```
SYMBOL_OBJECT     → variable (int x, float y)
SYMBOL_FUNCTION   → function declaration/definition
SYMBOL_PARAMETER  → function parameter
SYMBOL_TAG_STRUCT → struct tag
SYMBOL_TAG_UNION  → union tag
SYMBOL_TAG_ENUM   → enum tag
SYMBOL_ENUM_CONST → enum member (e.g. RED = 0)
SYMBOL_FIELD      → struct/union member
```

### `storage_class_t`

```
STORAGE_AUTO      → local variable (default)
STORAGE_STATIC    → file/block static
STORAGE_EXTERN    → external linkage
STORAGE_PARAMETER → function parameter
```

Also note `memory_class_t` (`GLOBAL`, `STACK`, `PARAMETER`) — this is a **backend-oriented** classification added to the symbol for the upcoming IR generation phase. Not used during semantic passes but present in the header.

---

## 5. Scope — `scope_s`, `scope_stack_t`

### `scope_s`

```c
struct scope_s {
  size_t id;                              // unique monotonically-increasing ID
  size_t depth;                           // 0 = global scope
  scope_t *parent;                        // parent scope pointer → rooted tree
  symbol_t *buckets[SCOPE_BUCKET_COUNT];  // 127-bucket hash table
};
```

Scopes form a **rooted tree**: each scope has exactly one parent (except the global scope). Lookup walks up the parent chain → nearest-visible semantics (C's lexical scoping).

### `scope_stack_t`

```c
typedef struct {
  scope_t *current;      // currently active scope
  size_t next_scope_id;  // monotonic counter
} scope_stack_t;
```

The stack tracks where you are during traversal. When `scope_push` is called, a new `scope_t` is `calloc`'d, assigned the next id, and its `parent` pointer set to the previous `current`. `scope_pop` restores `current` to `parent` (but does *not* free the scope — it lives in the tree for Pass 2).

### Hash function

**FNV-1a 32-bit** over the symbol name string, result modulo `SCOPE_BUCKET_COUNT = 127`. Why 127? Prime number — minimises the birthday-paradox collision rate per insertion compared to a power-of-two bucket count.

Formula: `hash ^= (unsigned char)*name; hash *= 16777619u;` starting from `2166136261u`.

### When scopes are pushed/popped in Pass 1

Scopes are pushed for: `NODE_BLOCK`, `NODE_FOR`, `NODE_FUNCTION` (a dedicated function scope for parameters), `NODE_IF`, `NODE_WHILE`, `NODE_DO_WHILE`, `NODE_SWITCH`.

**Critical ordering for functions:** Pass 1's `handle_function_node` pushes the function scope *after* registering the function symbol in the outer scope (so recursive calls resolve). Parameters are then registered in that inner scope.

---

## 6. Two-Pass Architecture

### Pass 1 — Declaration Binding

**Traversal:** Preorder, left-to-right (first child before siblings). This guarantees declarations are seen before their later siblings can use them.

**Contract:** enters/leaves scopes, builds `scope_t` / `symbol_t` chains. It registers: variables, arrays, functions (prototype + definition), parameters, struct/union/enum tags, enum constants, struct fields.

**State struct:**
```c
typedef struct {
  semantic_context_t *ctx;
  semantic_pass1_result_t result;  // {scope_count, declaration_count}
} pass1_state_t;
```

**Errors caught in Pass 1 (SEM00x range):**

| Code | Trigger |
|---|---|
| SEM002 | Redeclaration in same scope (`symbol_lookup_current` finds existing) |
| SEM004 | Function prototype/definition type mismatch |
| SEM005 | Duplicate function definition |
| SEM006 | Use-before-declaration in same block (checked via `check_expression_identifier_uses`) |
| SEM007 | `inline` qualifier on a variable declaration |
| SEM900 | Internal/allocation failures |
| SEM901 | Scope stack underflow |
| SEM902 | Unbalanced lexical scopes after traversal |

### Pass 2 — Semantic Validation

**Traversal:** Hybrid. Top-down for context inheritance (entering scopes, tracking `current_return_type`, incrementing `loop_depth`). Bottom-up (postorder) for expression type synthesis (`infer_expr_type` recurses into children before returning the parent type).

**State struct (know all fields):**
```c
typedef struct {
  semantic_context_t *ctx;
  semantic_pass2_result_t result;     // {expression_count, statement_count}
  const type_t *current_return_type;  // inherited: set when entering a function
  int in_function;                    // inherited: guards SEM043 return checks
  size_t loop_depth;                  // inherited: guards SEM050/SEM051
  switch_ctx *sw_ctx;                 // inherited: guards SEM050 (break in switch)
  TreeNode_t *root;                   // needed for find_tag_declaration lookups
  type_t **temporary_types;           // scratch arena for inferred types
  size_t temporary_type_count;
} pass2_state_t;
```

**Errors caught in Pass 2 (SEM0xx range):**

| Code | Trigger |
|---|---|
| SEM001 | Unknown identifier (`symbol_lookup_visible` returns NULL) |
| SEM008 | Assignment to a `const`-qualified object |
| SEM020 | Arithmetic operators (+, -, *, /) on non-numeric operands |
| SEM021 | Modulo `%` on non-integral operands |
| SEM023 | Bitwise operators (<<, >>, &, \|, ^, ~) on non-integral operands |
| SEM027 | LHS of assignment is not a modifiable lvalue |
| SEM031 | Array subscript index is not an integer |
| SEM032 | Base of `[]` access is not an array or pointer |
| SEM041 | Function call arity mismatch |
| SEM043 | Return type mismatch |
| SEM050 | `break` outside loop or switch |
| SEM051 | `continue` outside loop |
| SEM052 | Loop/do-while condition is not a scalar type |
| SEM060 | Aggregate member not found (`.` or `->` access) |

---

## 7. Code Structure & File Dependency

```
semantic.c          → entry point: semantic_run(), initialises context, calls both passes
  ├── semantic_pass1.c  → walk_pass1(), handle_function_node(), handle_object_declaration(),
  │     │                  handle_tag_declaration(), handle_enum_declaration()
  │     ├── symbol.c    → scope push/pop, symbol_new/insert/lookup, hash_name
  │     └── semantic_ast_helpers.c
  └── semantic_pass2.c  → walk_pass2(), infer_expr_type(), infer_operator_type(),
        │                  infer_call_type(), validate member access
        ├── type.c      → type construction, type_equal, type_is_integral
        ├── symbol.c    (shared)
        └── semantic_ast_helpers.c (shared)
```

### `semantic_ast_helpers.c` — shared utilities

These functions decouple AST structure interpretation from both passes:

| Function | Does |
|---|---|
| `semantic_ast_collect_qualifiers_from_chain(node)` | Walks a declaration specifier sibling chain, returns qualifier bitmask |
| `semantic_ast_build_type_from_type_node(type_node, quals)` | Converts `NODE_TYPE` / `NODE_POINTER` AST nodes into `type_t *` |
| `semantic_ast_build_type_from_declaration(decl_node)` | Full type reconstruction from a `NODE_VAR_DECLARATION` or `NODE_ARRAY_DECLARATION` |
| `semantic_ast_is_param_node(node)` | Returns true if node is a parameter-like declaration |
| `semantic_ast_split_function_children(fn_node, &preamble, &param_head, &body)` | Destructures a `NODE_FUNCTION` into its three logical parts |

**Why these matter:** Both passes call `semantic_ast_build_type_from_declaration` and `semantic_ast_split_function_children`. Centralising them means a parser AST contract change is fixed in one place.

---

## 8. Pass 1 Walk — Detailed Mechanics

### `semantic_pass1_run` entry

1. `memset` state to zero.
2. `scope_stack_init` + `push_scope(state, 0u)` → global scope created.
3. `walk_pass1(root, &state)`.
4. After walk: assert no unpopped scopes remain (SEM901/SEM902 guards).
5. Return `state.result` through `out_result`.

### `walk_pass1` dispatch table (the big `while (it)` loop)

| Node type | Handler |
|---|---|
| `NODE_BLOCK` | `push_scope`, recurse into `p_firstChild`, `pop_scope` |
| `NODE_FOR` | `push_scope`, recurse `p_firstChild`, `pop_scope` |
| `NODE_FUNCTION` | `handle_function_node` |
| `NODE_ENUM_DECLARATION` | `handle_enum_declaration` |
| `NODE_STRUCT_DECLARATION` / `NODE_UNION_DECLARATION` | `handle_tag_declaration` |
| `NODE_VAR_DECLARATION` / `NODE_ARRAY_DECLARATION` | `handle_object_declaration` + `check_inline_on_object_declaration` |
| expression nodes | `check_expression_identifier_uses` (SEM006 use-before-decl) |

After each node, advance via `it = it->p_sibling` — this is the preorder left-to-right traversal.

### `handle_function_node` — three phases

**Phase 1 — preamble:**
Call `semantic_ast_split_function_children(fn_node, &preamble, &param_head, &body)`.
`is_definition = (body != NULL)`.
Call `build_function_type(fn_node, &fn_type, &arity, &is_variadic)` → allocates `type_new_function(ret_type, param_types, param_count, is_variadic, 0u)`.
Call `register_symbol(state, fn_node->nodeData.sVal, SYMBOL_FUNCTION, fn_type, fn_node->lineNumber, is_definition, arity)`.

**Phase 2 — parameter chain:**
`push_scope(state, fn_node->lineNumber)` → this is the function's own scope.
Walk `param_head` sibling chain: for each `NODE_VAR_DECLARATION` / `NODE_ARRAY_DECLARATION` in the parameter list, `semantic_ast_build_type_from_declaration` + `register_symbol(..., SYMBOL_PARAMETER, ...)`.

**Phase 3 — body:**
If `body != NULL`, `walk_pass1((TreeNode_t *)body, state)` recurses.
`pop_scope(state, fn_node->lineNumber, ...)`.

### `register_symbol` — redeclaration logic

1. `scope_current(&state->ctx->scope_stack)` — crash guard.
2. `symbol_lookup_current(scope, name)` → if found:
   - If both are `SYMBOL_FUNCTION`: check `type_equal`. Mismatch → SEM004. Already defined → SEM005. First definition → set `existing->is_defined = 1`.
   - Else (object): SEM002 redeclaration in same scope.
3. `symbol_new(name, kind, type, line, 0u)` → allocate.
4. If `SYMBOL_FUNCTION`: set `symbol->arity`, `symbol->is_defined`.
5. `symbol_insert(scope, symbol)` → FNV-1a hash, prepend to bucket chain.
6. `state->result.declaration_count++`.

---

## 9. Pass 2 Walk — Detailed Mechanics

### `infer_expr_type` — the core switch

The central function. Given an AST node, returns `const type_t *` (never NULL — returns `&g_type_invalid` on failure).

| AST node | Returns |
|---|---|
| `NODE_CHAR` | `&g_type_char` |
| `NODE_INTEGER` | `&g_type_int` |
| `NODE_FLOAT` | `&g_type_double` |
| `NODE_STRING` | `&g_type_string` |
| `NODE_IDENTIFIER` | `lookup_identifier_type(name, line, state)` |
| `NODE_FUNCTION_CALL` | `infer_call_type(node, state)` |
| `NODE_OPERATOR` | `infer_operator_type(node, state)` |
| `NODE_ARRAY_ACCESS` | checks index is integral (SEM031), base is array/pointer (SEM032), returns element type |

**Important:** `NODE_IDENTIFIER` with a `p_firstChild` delegates to `infer_expr_type(node->p_firstChild, state)` — this handles dereferencing in pointer contexts. Without a firstChild, it resolves via `symbol_lookup_visible`.

### `infer_operator_type` — arithmetic rule table

For each operator kind, the pattern is always:
1. Infer LHS type, infer RHS type.
2. If either is `TYPE_INVALID` → return `&g_type_invalid` (no cascading error).
3. Apply semantic rule, emit error if violated.
4. Return synthesised result type.

| SEM | Operators | Rule | Result type |
|---|---|---|---|
| SEM020 | `+` `-` `*` `/` | Both must be numeric | double > float > int (usual arithmetic conversions) |
| SEM021 | `%` | Both must be integral | `&g_type_int` |
| SEM023 | `<<` `>>` `&` `\|` `^` `~` | LHS integral; RHS integral (binary only) | `lhs_type` |
| SEM027 | `=` | LHS must be modifiable lvalue (IDENTIFIER, ARRAY_ACCESS, POINTER_CONTENT, MEMBER_ACCESS, PTR_MEMBER_ACCESS) | `lhs_type` |
| SEM008 | `=` | LHS qualifiers must not include `TYPE_QUAL_CONST` (unless it's the init line) | — |

### `infer_call_type` — function call validation

1. Resolve callee identifier via `lookup_identifier_type`.
2. Check callee type is `TYPE_FUNCTION` (SEM040 if not — callee is not callable).
3. `count_call_arguments(call_node)` → count actual arguments in AST.
4. If function is **not variadic** and `provided_arity != callee_type->as.function.param_count` → SEM041.
5. Return `callee_type->as.function.return_type` (or `&g_type_void` if NULL).

### Member access (`NODE_MEMBER_ACCESS` / `NODE_PTR_MEMBER_ACCESS`)

1. Infer base type.
2. For `->` (via pointer): verify `base_type->kind == TYPE_POINTER`, extract `base_type->as.pointer.base` → new `aggregate_type`.
3. Verify `aggregate_type->kind == TYPE_STRUCT_TAG || TYPE_UNION_TAG` (SEM060 if not).
4. Locate the struct/union declaration node: first try `tag_symbol->type->as.aggregate.decl_node` (from symbol table), fall back to `find_tag_declaration(state->root, kind, tag)` (AST scan).
5. If declaration not found (incomplete type) → SEM060.
6. `resolve_member_decl_type(aggregate_decl, member_name, state)` → walks struct body to find the named field.
7. If member not found → SEM060. Else return member's type.

### Control-flow state tracking

`loop_depth` and `switch_depth` (or `sw_ctx->switch_depth`) are incremented/decremented as Pass 2 enters/leaves loops and switches. `in_function` is set when entering a `NODE_FUNCTION`.

- **SEM050 (break):** `state->loop_depth == 0 && state->sw_ctx == NULL`
- **SEM051 (continue):** `state->loop_depth == 0`
- **SEM052 (loop condition scalar):** condition type must satisfy `type_is_scalar()` — fails for structs/unions
- **SEM043 (return mismatch):** `state->in_function && state->current_return_type` is set + `!assignment_compatible(current_return_type, ret_type)`

### `switch_ctx` — duplicate case detection

Pass 2 has a dedicated context for switch statements beyond just `switch_depth`. It owns a `CASE_BUCKET_COUNT = 61` bucket hash table tracking case values seen so far. The hash uses FNV-1a over the 32-bit integer case constant value. Duplicate cases within the same switch are caught via this structure.

---

## 10. Diagnostics — `diagnostics.h` / `diagnostics.c`

### `diagnostic_list_t`

A doubly-linked list (`head`/`tail` + `count`, `error_count`, `warning_count`). Lives inside `semantic_context_t`.

### `diagnostic_t`

```c
struct diagnostic_s {
  char code[16];         // e.g. "SEM020"
  char message[256];     // human-readable
  size_t line, col;
  diagnostic_severity_t severity;  // NOTE, WARNING, ERROR
  diagnostic_t *next;
};
```

### Emission macros used in passes

Pass 1 uses `pass1_emit(state, code, line, message)`.
Pass 2 uses `pass2_emit(state, code, line, message)`.
Both ultimately call `diag_emit(&state->ctx->diagnostics, code, DIAG_ERROR, line, 0, message)`.

**Key property:** errors do *not* stop traversal (except fatal `SEM900`). The walk continues to accumulate all diagnostics in one run — this is how you get multi-error output.

---

## 11. SEM Error Code Reference

### Pass 1 errors (declaration/scope phase)

| Code | Meaning | Detection point |
|---|---|---|
| SEM002 | Redeclaration in same scope | `register_symbol` → `symbol_lookup_current` |
| SEM004 | Function prototype/definition type mismatch | `register_symbol` → `type_equal` on existing SYMBOL_FUNCTION |
| SEM005 | Duplicate function definition | `register_symbol` → `existing->is_defined` already set |
| SEM006 | Use-before-declaration in same block | `check_expression_identifier_uses` called before processing sibling decl |
| SEM007 | `inline` on variable declaration | `check_inline_on_object_declaration` → `declaration_has_visibility(VIS_INLINE)` |

### Pass 2 errors (type/usage phase)

| Code | Meaning | Key condition |
|---|---|---|
| SEM001 | Unknown identifier | `symbol_lookup_visible` returns NULL |
| SEM008 | Assignment to const | `lhs->qualifiers & TYPE_QUAL_CONST` and not on decl line |
| SEM020 | Arithmetic op on non-numeric | `!type_is_numeric(lhs)` or `!type_is_numeric(rhs)` |
| SEM021 | `%` on non-integral | `!type_is_integral(lhs)` or `!type_is_integral(rhs)` |
| SEM023 | Bitwise op on non-integral | `!type_is_integral(lhs)` (and rhs for binary ops) |
| SEM027 | Assignment LHS not modifiable lvalue | LHS node type not in {IDENTIFIER, ARRAY_ACCESS, POINTER_CONTENT, MEMBER_ACCESS, PTR_MEMBER_ACCESS} |
| SEM031 | Array index not integer | `!type_is_integral(index_type)` |
| SEM032 | `[]` base not array/pointer | `base->kind != TYPE_ARRAY && base->kind != TYPE_POINTER` |
| SEM041 | Arity mismatch | `provided_arity != param_count && !is_variadic` |
| SEM043 | Return type mismatch | `!assignment_compatible(current_return_type, ret_type)` |
| SEM050 | `break` outside loop/switch | `loop_depth == 0 && sw_ctx == NULL` |
| SEM051 | `continue` outside loop | `loop_depth == 0` |
| SEM052 | Loop condition not scalar | `!type_is_scalar(cond_type)` |
| SEM060 | Aggregate member not found | member resolution fails OR aggregate type is incomplete |

---

## 12. Things the Presentation Marks as TODO / Incomplete

One slide explicitly says **"Object Type — todo, the build type from declaration part"**. This means `semantic_ast_build_type_from_declaration` for some declaration shapes may have gaps. Also noted in `semantic_pass1.h` comments:

```
// @TODO
// SEM001: Identificador desconhecido deve resolver para um símbolo visível
// SEM006: Uso de identificador antes da declaração no mesmo bloco
```

These are flagged as not fully implemented. If asked during the presentation, acknowledge these are known open items.

---

## 13. What the Presentation Emphasises That You Must Own

1. **The tradeoff argument** — why attribute grammar was rejected in favour of two-pass ad hoc. Answer: formal rigor was traded for implementation speed and modularity. You should be able to defend both sides of the table on demand.

2. **Why Pass 1 is preorder** — declarations must be visible to later siblings in the same block. In preorder, you process a node *before* its siblings, so by the time sibling `OPERATOR(=)` sees identifier `a`, the preceding `VAR_DECL(a)` has already been registered.

3. **Why Pass 2 expression type is postorder** — synthesised attribute. You must know child types before you can determine the parent expression's type. Visiting children first (postorder within expressions) is the only correct order.

4. **Why the symbol table stays alive after Pass 1** — Pass 2 consumes it. Scopes are not freed at `pop_scope` time; they remain in the `scope_stack_t` tree. `semantic_context_destroy` frees the whole tree after both passes complete.

5. **FNV-1a + SCOPE_BUCKET_COUNT = 127** — prime bucket count, not power-of-two, minimises collision rate per insertion. The same FNV-1a algorithm appears in `symbol.c` for name hashing and in `semantic_pass2.c` for case value hashing.

6. **`TYPE_INVALID` propagation** — this is the compiler's error-recovery mechanism. Once an expression resolves to `TYPE_INVALID`, downstream checks skip their error emission to avoid error storms. Know this pattern for SEM020, SEM021, SEM023, SEM027, SEM031.

7. **Variadic functions** — SEM041 does NOT fire for variadic functions (`is_variadic = 1`). The arity check is explicitly guarded: `if (!callee_type->as.function.is_variadic && provided_arity != callee_type->as.function.param_count)`.

8. **`assignment_compatible` vs `type_equal`** — used differently. `type_equal` is strict structural equality (used in SEM004 prototype matching). `assignment_compatible` allows implicit conversions (numeric widening etc.) — used in SEM043 and SEM027/SEM008 assignment validation.

9. **Next steps after semantic analysis** — the conclusion slide states IR generation (P-code or 3AC) using symbol table info from Pass 1. Be ready to say what the symbol table contributes to IR: variable names → memory addresses, function signatures → call conventions, scope depth → stack frame layout.

---

## 14. Quick-Reference: `semantic_context_t` lifecycle

```
semantic_context_init(ctx)
  └── diag_list_init(&ctx->diagnostics)
  └── scope_stack_init(&ctx->scope_stack)

semantic_pass1_run(root, ctx, &p1_result)
  └── push global scope
  └── walk_pass1 → populate scope tree + symbol tables
  └── assert scope balance

semantic_pass2_run(root, ctx, &p2_result)
  └── walk_pass2 → infer types, validate, emit diagnostics

semantic_context_destroy(ctx)
  └── diag_list_destroy
  └── scope_stack_destroy → frees entire scope tree + all symbols
```

`semantic_result_t` (returned from `semantic_run`) = `{error_count, warning_count, scope_count}` — this is what the semantic summary line prints:
`Semantic summary: errors=N warnings=M scopes=K`.
