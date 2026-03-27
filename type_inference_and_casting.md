# Type Inference & Type Casting — Deep Reference

> Standalone companion to the main study guide.
> All behaviour described is sourced directly from `Semantic/type.h`,
> `Semantic/semantic_pass2.c`, and `Semantic/semantic_pass1.c`.

---

## 1. The `type_t` Structure in Memory

`type_t` is a tagged union. The `kind` field is the discriminant; `as` holds
the variant payload. `qualifiers` is a bitmask orthogonal to `kind`.

```
type_t
├── kind        : type_kind_t         ← which variant is live
├── qualifiers  : unsigned            ← const / volatile / signed / unsigned bits
└── as          : union
    ├── builtin : builtin_type_t      ← live when kind == TYPE_BUILTIN
    ├── pointer
    │   └── base : type_t *           ← live when kind == TYPE_POINTER
    ├── array
    │   ├── elem         : type_t *
    │   ├── size         : size_t     ← 0 when is_known_size == 0
    │   └── is_known_size: int        ← 0 for int a[] params
    ├── function
    │   ├── return_type  : type_t *
    │   ├── params       : type_t **  ← heap array, length = param_count
    │   ├── param_count  : size_t
    │   └── is_variadic  : int
    └── aggregate
        ├── tag      : char *         ← struct/union/enum name
        └── decl_node: const void *   ← back-pointer to AST declaration node
```

**Never access `as.builtin` unless `kind == TYPE_BUILTIN`.** Every check in
Pass 2 guards with `type->kind` first.

### Global singleton types

Pass 2 maintains a set of static, never-freed singletons for common scalar
types. These are returned by value from `infer_expr_type` without allocation:

```c
static const type_t g_type_char   = { TYPE_BUILTIN, 0, { .builtin = BUILTIN_CHAR   } };
static const type_t g_type_int    = { TYPE_BUILTIN, 0, { .builtin = BUILTIN_INT    } };
static const type_t g_type_float  = { TYPE_BUILTIN, 0, { .builtin = BUILTIN_FLOAT  } };
static const type_t g_type_double = { TYPE_BUILTIN, 0, { .builtin = BUILTIN_DOUBLE } };
static const type_t g_type_string = { TYPE_BUILTIN, 0, { .builtin = BUILTIN_STRING } };
static const type_t g_type_void   = { TYPE_BUILTIN, 0, { .builtin = BUILTIN_VOID   } };
static const type_t g_type_invalid = { TYPE_INVALID, 0, { .builtin = 0 } };
```

Any type that *is not* one of these singletons (e.g., a cast target type, a
pointer type inferred from `&expr`) is heap-allocated and registered in the
`pass2_state_t` temporary arena via `remember_temporary_type`. The arena is
bulk-freed at the end of Pass 2 — callers must **never** free these manually.

---

## 2. `infer_expr_type` — Complete Dispatch Table

This is the central recursive function. It never returns `NULL`; on any
failure it returns `&g_type_invalid`. The result is a **synthesised attribute**
— computed bottom-up from children.

| AST node type | Return value | Notes |
|---|---|---|
| `NODE_CHAR` | `&g_type_char` | Literal `'a'` |
| `NODE_INTEGER` | `&g_type_int` | Literal `42` |
| `NODE_FLOAT` | `&g_type_double` | Literal `3.14` — always `double`, never `float` |
| `NODE_STRING` | `&g_type_string` | Literal `"hello"` |
| `NODE_IDENTIFIER` (no child) | `lookup_identifier_type(name)` | Symbol table lookup via `symbol_lookup_visible` |
| `NODE_IDENTIFIER` (has child) | `infer_expr_type(firstChild)` | Delegates; handles dereferencing contexts |
| `NODE_FUNCTION_CALL` | `infer_call_type(node)` | Validates callee + arity, returns return type |
| `NODE_OPERATOR` | `infer_operator_type(node)` | See Section 3 |
| `NODE_ARRAY_ACCESS` | `base->as.array.elem` or `base->as.pointer.base` | Checks index is integral (SEM031); unwraps one level |
| `NODE_REFERENCE` (`&expr`) | `type_new_pointer(clone(base), 0)` | Allocates; stored in temporary arena |
| `NODE_POINTER_CONTENT` (`*expr`) | `ptr_type->as.pointer.base` | Unwraps one pointer level; `TYPE_INVALID` if not a pointer |
| `NODE_TYPE_CAST` | `cast_type` (heap-allocated) | See Section 5 |
| `NODE_POST_INC / PRE_INC / POST_DEC / PRE_DEC` | `operand_type` | Checks const (SEM009) and lvalue (SEM028) |
| `NODE_MEMBER_ACCESS` (`.`) | member's type | Via `infer_member_access_type(via_pointer=0)` |
| `NODE_PTR_MEMBER_ACCESS` (`->`) | member's type | Via `infer_member_access_type(via_pointer=1)` |
| `NODE_TERNARY` (`cond ? a : b`) | `true_type` or `false_type` | Uses `assignment_compatible` to pick the wider branch |
| Any other node with a child | `infer_expr_type(firstChild)` | Fallthrough delegate |
| Any other node without a child | `&g_type_invalid` | |

### `NODE_FLOAT` returns `double`, not `float`

This is a deliberate simplification. The parser cannot distinguish `3.14`
(`double`) from `3.14f` (`float`) at the AST level in this implementation.
All floating-point literals resolve to `&g_type_double`. The implication: if
you write `float x = 3.14;`, Pass 2 sees `double` on the RHS and `float` on
the LHS — `builtin_rank(float=5) < builtin_rank(double=6)`, so **SEMW001**
(narrowing) fires even though `3.14f` would have been fine.

### `NODE_IDENTIFIER` with a child

When an identifier node has a `p_firstChild`, control is passed to that child
rather than doing a symbol table lookup. This happens in pointer-dereference
contexts where the parser attaches a child sub-expression. It is **not** the
common case — most identifiers are leaf nodes resolved via `lookup_identifier_type`.

---

## 3. `infer_operator_type` — All Operators

Called for every `NODE_OPERATOR`. Pattern: infer LHS type, infer RHS type,
apply rule, synthesise result type.

### Arithmetic: `+`, `-`, `*`, `/` → SEM020

```
Precondition: both lhs_type and rhs_type must be is_numeric_builtin.
Violation: SEM020 "Arithmetic operators require arithmetic operands"

Result type ladder (simplified usual arithmetic conversions):
  if either is BUILTIN_DOUBLE      → return &g_type_double
  if either is BUILTIN_FLOAT       → return &g_type_float
  else                             → return &g_type_int

Side effect: SEMW002 if mixed signed/unsigned
```

**What this ladder misses:** `long + long` returns `&g_type_int` (not `long`).
`short + short` also returns `&g_type_int`. This is a known simplification —
the implementation does not model integer promotion exhaustively.

**Full usual arithmetic conversions table (what the code *actually* produces):**

| LHS | RHS | Result |
|---|---|---|
| `int` | `int` | `int` |
| `int` | `long` | `int` ← simplified! |
| `int` | `float` | `float` |
| `int` | `double` | `double` |
| `float` | `float` | `float` |
| `float` | `double` | `double` |
| `double` | `double` | `double` |
| `char` | `int` | `int` |

### Modulo: `%` → SEM021

```
Precondition: both must be type_is_integral (CHAR, SHORT, INT, LONG).
Violation: SEM021 "Operator '%' only for integral operands"
Result type: &g_type_int (always)
```

`3.14 % 2` → SEM021. `3 % 2` → `int`. `3.0 % 2.0` → SEM021.

### Bitwise: `<<`, `>>`, `&`, `|`, `^` → SEM023

```
Precondition: both lhs and rhs must be type_is_integral.
Violation: SEM023 "Bitwise operators require integral operands"
Result type: lhs_type (preserves LHS type)
Side effect: SEMW002 if mixed signed/unsigned (for &, |, ^)
```

`int x = 5 << 1` → result type `int`.
`float f = 1.0; f << 1` → SEM023.

### Bitwise NOT: `~` → SEM023

Unary variant. Only checks LHS; no RHS. Returns `lhs_type`.

### Comparison: `==`, `!=`, `<`, `>`, `<=`, `>=`

```
Precondition: neither side is TYPE_INVALID.
Result type: &g_type_int  (C semantics: comparisons produce int, 0 or 1)
Side effect: SEMW002 if mixed signed/unsigned comparison
No type constraint on operands — struct comparison is currently not blocked.
```

### Logical: `&&`, `||` → SEM024

```
Precondition: both operands must be type_is_scalar (numeric OR pointer).
Violation: SEM024 "Logical operators require scalar operands"
Result type: &g_type_int
```

`struct Foo f; if (f && x)` → SEM024 because struct is not scalar.
A pointer like `if (ptr && x)` is valid — pointer is scalar.

### Logical NOT: `!` → SEM024

Unary. Same scalar precondition. Returns `&g_type_int`.

### Unary minus: `-`

```
Precondition: lhs must be type_is_numeric.
Result type: lhs_type (sign-flipped value, same type)
```

`-(5)` → `int`. `-(3.14)` → `double`. `-"hello"` → `TYPE_INVALID` (not numeric).

### `sizeof`

Returns `&g_type_int` always. No type constraint on the operand.

### Comma operator: `,`

Returns `rhs_type` — the comma expression evaluates both sides but its value
is the right operand's. E.g. `(a, b)` has the type of `b`.

### Assignment: `=` → SEM011 / SEM027 / SEM008 / SEMW001 / SEMW002

This is the most complex case. See Section 4.

### Compound assignment: `+=`, `-=`, `*=`, `/=`, `%=`, `<<=`, `>>=`, `&=`, `|=`, `^=`

```
Checks: assignment_compatible(lhs_type, rhs_type)
Violation: SEM011 "assignment type mismatch"
Result type: lhs_type
Note: SEMW001/SEMW002 are NOT checked for compound assignment — only plain =
```

---

## 4. Assignment Type Rules — `=` operator in detail

The `OP_ASSIGN` branch in `infer_operator_type` runs four independent checks
in order. All four can coexist on a single assignment node.

### Step 1: Type compatibility check (SEM011)

```c
if (!assignment_compatible(lhs_type, rhs_type))
    pass2_emit("SEM011", "assignment type mismatch");
```

`assignment_compatible(lhs, rhs)` returns 1 when:
- `type_equal(lhs, rhs)` — exact structural match, OR
- Both `TYPE_BUILTIN` AND both `is_numeric_builtin` — any numeric-to-numeric

It returns 0 for anything else: struct ↔ int, pointer ↔ struct,
numeric ↔ string, etc.

**SEM011 triggers:**
```c
int x = "hello";           // numeric ↔ string → SEM011
struct Foo s; int y = s;   // numeric ↔ struct → SEM011
int *p; int q = p;         // numeric ↔ pointer → SEM011
```

**SEM011 does NOT trigger:**
```c
int x   = 3.14;     // int ↔ double — both numeric → compatible (SEMW001 may warn)
float f = 42;       // float ↔ int — both numeric → compatible
char c  = 300;      // char ↔ int — both numeric → compatible (SEMW001 may warn)
```

### Step 2: Narrowing warning (SEMW001)

Only reached when `assignment_compatible` returned 1. Checks `warns_on_narrowing_assignment`:

```
Guards (bail out immediately if any true):
  - rhs_expr is NULL
  - lhs or rhs is NULL
  - expr_is_explicit_cast(rhs_expr)  ← explicit cast suppresses the warning

Three narrowing cases:
  Case A: float-family → integral
    is_integral(lhs) && is_floating(rhs) → SEMW001
    Example: int x = 3.14;

  Case B: wider float → narrower float
    is_floating(lhs) && is_floating(rhs) && rank(lhs) < rank(rhs) → SEMW001
    Example: float f = someDouble;   (rank 5 < rank 6)

  Case C: wider integral → narrower integral
    is_integral(lhs) && is_integral(rhs) && rank(lhs) < rank(rhs) → SEMW001
    Example: char c = someInt;       (rank 1 < rank 3)
             short s = someLong;     (rank 2 < rank 4)
```

Widening (lower → higher rank) is accepted silently:
```c
double d = 42;    // int (rank 3) → double (rank 6) — widening, no warning
long x = 'a';    // char (rank 1) → long (rank 4) — widening, no warning
```

### Step 3: Signed → unsigned warning (SEMW002)

`warns_on_signed_to_unsigned_assignment` fires when:

```
lhs is unsigned integral   (TYPE_BUILTIN + TYPE_QUAL_UNSIGNED set)
rhs is signed integral     (TYPE_BUILTIN + TYPE_QUAL_UNSIGNED not set)
rhs_expr is not an explicit cast
rhs_expr is either not an operator, OR is OP_UNARY_MINUS specifically
```

```c
unsigned int u;
int s = -5;
u = s;              // SEMW002: signed to unsigned
u = (unsigned)s;    // No SEMW002 — explicit cast suppresses
```

At runtime, `-5` assigned to `unsigned int` wraps to `4294967291`
(two's-complement bit pattern reinterpreted as unsigned). Pass 2 warns but
does not block this.

### Step 4: Const assignment checks (SEM027 / SEM008)

Two separate checks, both conditional on `lhs_type->qualifiers & TYPE_QUAL_CONST`:

**SEM027** — LHS is const AND is not a recognised lvalue category:
```
lhs node type must be one of:
  NODE_IDENTIFIER, NODE_ARRAY_ACCESS, NODE_POINTER_CONTENT,
  NODE_MEMBER_ACCESS, NODE_PTR_MEMBER_ACCESS
Otherwise: SEM027 "LHS of assignment must be a modifiable lvalue"
```

**SEM008** — LHS is const AND is a valid lvalue:
```
Look up the symbol for the LHS identifier in the current scope.
If sym->decl_line == op_node->lineNumber → this is an initialisation → skip.
Otherwise: SEM008 "Assignment to an object qualified as const"
```

The `decl_line` comparison is the mechanism for distinguishing
`const int x = 5;` (initialisation, legal) from a later `x = 10;` (illegal).

---

## 5. Explicit Cast — `NODE_TYPE_CAST`

### AST shape

```
NODE_TYPE_CAST
  └── p_firstChild   → type node (e.g. NODE_TYPE containing "int")
  └── (sibling)      → source expression node
```

The type node is the same structure used in variable declarations. Its
qualifier chain and type specifier are reconstructed by the same helpers
used in Pass 1.

### `infer_expr_type` for `NODE_TYPE_CAST`

```
1. qualifiers = semantic_ast_collect_qualifiers_from_chain(firstChild)
2. cast_type  = semantic_ast_build_type_from_type_node(firstChild, qualifiers)
   → heap-allocates a new type_t matching the cast target
   → NULL on allocation failure → SEM900

3. source_type = infer_expr_type(firstChild->p_sibling, state)
   → infers the type of the expression being cast

4. if source_type != TYPE_INVALID && warns_on_const_dropping_cast(cast_type, source_type):
       pass2_warning(SEMW003, "explicit cast removes const qualifier")

5. return remember_temporary_type(state, cast_type)
   → registers cast_type in the temporary arena; Pass 2 frees it at end
```

**The returned type is the cast target, unconditionally.** No check for numeric
compatibility, no check for pointer-vs-scalar interop. Those are in the TODO
list (SEM012, SEM015, SEM016).

### Explicit cast suppresses SEMW001 and SEMW002

`expr_is_explicit_cast(rhs_expr)` returns `rhs_expr->nodeType == NODE_TYPE_CAST`.
Both `warns_on_narrowing_assignment` and `warns_on_signed_to_unsigned_assignment`
bail out immediately when this is true. This is intentional C semantics: you
wrote the cast, you know what you're doing.

```c
int x   = (int)3.99;       // No SEMW001 — explicit cast
char c  = (char)300;       // No SEMW001 — explicit cast
unsigned u = (unsigned)-5; // No SEMW002 — explicit cast
```

---

## 6. `cast_drops_const` — Recursive Pointer Walk

Used only by `warns_on_const_dropping_cast`, which only fires on
`NODE_TYPE_CAST` where **both** target and source are `TYPE_POINTER`.

```
cast_drops_const(target, source):
  if source has TYPE_QUAL_CONST and target does not → return 1 (dropped)
  if both are TYPE_POINTER:
      recurse: cast_drops_const(target->as.pointer.base, source->as.pointer.base)
  else → return 0
```

This handles deeply nested pointer chains:

```c
const int x = 5;
int *p = (int *)&x;
// &x has type: int * with base (const int) → source = pointer to const int
// (int *) target = pointer to non-const int
// cast_drops_const sees: source->base has CONST, target->base does not → SEMW003
```

The const-drop check is **not** applied to scalar casts. `(int)someConstInt`
produces no warning — the value is copied, not aliased, so dropping const is
safe at the value level.

---

## 7. Type Truncation — Concrete Examples

Truncation occurs when a numeric value is stored in a type with insufficient
range or precision. Pass 2 **detects** it (SEMW001) but does **not** prevent
it. The IR generation phase will emit the actual truncating instruction.

### Integer truncation

```c
int big = 300;
char c = big;    // SEMW001: narrowing (rank 3 → rank 1)
                 // At runtime: char stores only 8 bits (or platform-defined)
                 // 300 = 0x12C → char gets 0x2C = 44 (modular reduction)
```

The truncation rule: the low-order N bits of the value are retained, where N
is the bit width of the target type. The high-order bits are discarded.

```
300 in binary:  0000 0001 0010 1100
                ^^^^^^^^^
                discarded by char (8-bit)
                          ^^^^ ^^^^
                          kept → 0x2C = 44
```

If the target is signed and the retained bits represent a negative value in
two's complement, the result is implementation-defined in C11. Pass 2 does
not model this — it only warns.

### Float-to-integer truncation

```c
double d = 3.99;
int x = d;       // SEMW001: narrowing (float-family → integral, rank 5/6 → 3)
                 // At runtime: fractional part is truncated toward zero
                 // x == 3 (NOT 4 — this is truncation, not rounding)

double d2 = -3.99;
int y = d2;      // y == -3 (truncation toward zero, not floor)
```

**Truncation is always toward zero** for float-to-integer in C11 §6.3.1.4.
Pass 2 does not distinguish rounding mode — it only detects that the
conversion narrows the value family (float → int).

### Double-to-float truncation

```c
double d = 1.0000000000000002;   // beyond float precision
float f = d;                      // SEMW001: narrowing (rank 6 → rank 5)
                                  // At runtime: rounded to nearest representable float
                                  // f == 1.0f (precision lost)
```

The float format has 23-bit mantissa (~7 decimal digits), double has 52-bit
mantissa (~15 decimal digits). Values beyond float's range overflow to `±Inf`.

### Widening — no truncation, no warning

```c
char c = 'A';    // 65
int  i = c;      // 65 — widened, sign-extended (char is signed on most platforms)
float f = i;     // 65.0f — exact (all int values representable in float)
double d = f;    // 65.0 — exact widening
```

Pass 2 allows all of these silently. `builtin_rank(lhs) >= builtin_rank(rhs)` → `warns_on_narrowing_assignment` returns 0.

### Signed overflow (not detected by Pass 2)

```c
int max = 2147483647;   // INT_MAX
int overflow = max + 1; // undefined behaviour in C11
```

Pass 2 does not detect signed integer overflow — that would require constant
folding, which is not implemented.

---

## 8. `builtin_rank` — The Widening Hierarchy

The rank table is the implementation of numeric type ordering used
exclusively by `warns_on_narrowing_assignment`:

```
Type             Rank    Notes
─────────────────────────────────────────────────────
BUILTIN_CHAR       1     narrowest integral
BUILTIN_SHORT      2     (not always represented separately in arithmetic)
BUILTIN_INT        3     default integral
BUILTIN_LONG       4     wider integral (64-bit on most 64-bit platforms)
BUILTIN_FLOAT      5     single precision (23-bit mantissa)
BUILTIN_DOUBLE     6     double precision (52-bit mantissa)
BUILTIN_LONG_DOUBLE 7    extended precision (platform-dependent)
BUILTIN_VOID       0     not numeric, rank meaningless
BUILTIN_STRING     0     not numeric, rank meaningless
```

Narrowing = `rank(lhs) < rank(rhs)`. Widening = `rank(lhs) >= rank(rhs)`.

**Cross-family narrowing (float → int) is special-cased separately:**
```c
if (is_integral(lhs) && is_floating(rhs)) → SEMW001
```
This fires even when the float rank (5 or 6) would appear "wider" than any
integral rank. The cross-family case is caught first before the rank comparison.

---

## 9. `remember_temporary_type` — The Temporary Arena

Any `type_t *` that is heap-allocated by Pass 2 during type inference (cast
target types, reference types from `&expr`) must not be freed by the caller.
Instead it is registered in `pass2_state_t`:

```c
type_t **temporary_types;      // resizable pointer array
size_t   temporary_type_count;
```

`remember_temporary_type(state, type)` appends the pointer to this array and
returns it. At the end of `semantic_pass2_run`, the entire array is iterated
and each entry is freed via `type_free`.

**Why this matters:** If `infer_expr_type` is called recursively for `(int)3.14`
and then the result is passed to `assignment_compatible`, the `cast_type`
pointer must remain valid for the duration of that call. The arena guarantees
this without requiring callers to manage ownership.

---

## 10. Diagnostics Reference — Type System Only

| Code | Severity | Trigger | Example |
|---|---|---|---|
| **SEM011** | error | `!assignment_compatible(lhs, rhs)` on `=` or compound `=` | `int x = "hello"` |
| **SEM020** | error | Non-numeric operand to `+`, `-`, `*`, `/` | `struct A s; s + 1` |
| **SEM021** | error | Non-integral operand to `%` | `3.14 % 2` |
| **SEM023** | error | Non-integral operand to bitwise ops | `float f; f << 1` |
| **SEM024** | error | Non-scalar operand to `&&`, `\|\|`, `!` | `struct A s; if (s)` |
| **SEM027** | error | Assignment to a `const` lvalue | `const int x; x = 5` |
| **SEM008** | error | Assignment to `const` (lvalue form, post-init) | `const int x = 1; x = 2` |
| **SEM009** | error | Increment/decrement of const object | `const int x; x++` |
| **SEM028** | error | Increment/decrement of non-lvalue | `5++` |
| **SEM040** | error | Call target is not a function type | `int x; x()` |
| **SEM041** | error | Arity mismatch (non-variadic only) | `void f(int a); f(1,2)` |
| **SEM043** | error | Return type mismatch | `int f() { return "a"; }` |
| **SEMW001** | warning | Implicit narrowing conversion | `int x = 3.99` |
| **SEMW002** | warning | Signed ↔ unsigned implicit conversion or mixed arithmetic | `unsigned u = -1` |
| **SEMW003** | warning | Explicit cast removes `const` from pointer chain | `(int *)&constInt` |

---

## 11. Open Items — What Is Not Yet Implemented

From the TODO comment at the bottom of `semantic_pass2.c`:

```
[ ] SEM010 — implicit const removal via pointer assignment
             e.g.  const int x; int *p = &x;  (pointer assignment drops const)
[ ] SEM012 — implicit pointer ↔ integer conversion
             e.g.  int *p = 5;  (no SEM011 because pointer is not builtin)
[ ] SEM015 — cast involving incomplete struct/union
             e.g.  (struct Incomplete)expr  where Incomplete has no body
[ ] SEM016 — pointer ↔ float cast (strict mode)
             e.g.  (float *)someIntPtr  (currently silently accepted)
```

The currently implemented check set (marked `[x]`) that relate to types:
```
[x] SEM011 — assignment type mismatch
[x] SEM020-024 — operator type constraints
[x] SEM027/SEM008 — const assignment
[x] SEMW001 — implicit narrowing
[x] SEMW002 — signed/unsigned conversion
[x] SEMW003 — const-dropping pointer cast
```

---

## 12. End-to-End Trace — `int x = 3.99 + (int)someDouble`

Walk through `infer_expr_type` for the RHS expression `3.99 + (int)someDouble`
where `someDouble` is a declared `double` variable, and the LHS is `int x`.

```
infer_expr_type(OPERATOR(+))
  → infer_expr_type(NODE_FLOAT 3.99)
      → return &g_type_double           ← literal always double

  → infer_expr_type(NODE_TYPE_CAST)
      → qualifiers = 0                  ← no qualifiers on (int)
      → cast_type = type_new_builtin(BUILTIN_INT, 0)  ← heap-alloc
      → source_type = infer_expr_type(IDENTIFIER someDouble)
          → lookup_identifier_type("someDouble")
          → symbol found, type = double
          → return &g_type_double
      → warns_on_const_dropping_cast(int, double): both not pointer → 0
      → remember_temporary_type(state, cast_type)
      → return cast_type  [int]

  Now in infer_operator_type for OP_PLUS:
    lhs_type = &g_type_double   [from 3.99]
    rhs_type = cast_type [int]
    type_is_numeric(double) = 1
    type_is_numeric(int)    = 1
    → no SEM020
    warns_on_mixed_signed_unsigned(double, int): double is not integral → 0
    → no SEMW002
    lhs is double → return &g_type_double

Result of RHS: double
```

Now the assignment `int x = (RHS: double)`:

```
infer_operator_type for OP_ASSIGN:
  lhs_type = &g_type_int     (from symbol x)
  rhs_type = &g_type_double  (from + expression)

  assignment_compatible(int, double):
    type_equal? No.
    Both TYPE_BUILTIN + both numeric? Yes.
    → return 1   (compatible, no SEM011)

  warns_on_narrowing_assignment(int, double, rhs_expr):
    rhs_expr is NODE_OPERATOR(+), not a NODE_TYPE_CAST
    → expr_is_explicit_cast returns 0  (not suppressed)
    is_integral(int) && is_floating(double) → Case A → return 1
    → SEMW001 emitted: "implicit narrowing conversion"

  warns_on_signed_to_unsigned_assignment(int, double, ...):
    is_unsigned_integral(int)? No (int is signed by default)
    → return 0

  int qualifiers & TYPE_QUAL_CONST? No.
  → no SEM008/SEM027

Result type: &g_type_int (the lhs_type is returned)
```

**Summary:** `int x = 3.99 + (int)someDouble` produces exactly one diagnostic:
`SEMW001` warning on the outer assignment. The inner explicit cast `(int)someDouble`
produces no warning because `expr_is_explicit_cast` suppresses SEMW001/SEMW002
on the inner cast node, and that cast result feeds the `+` as an `int`.
The `+` of `double` and `int` returns `double`. The outer assignment of
`double` to `int` is where truncation will happen at runtime.
