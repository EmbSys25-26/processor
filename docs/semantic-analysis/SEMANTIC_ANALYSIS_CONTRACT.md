# Semantic Analysis Contract (Subset-C Frontend)

Date: 2026-03-07

## 1. Objective
This contract defines all semantic obligations between parsing and IR generation.
Semantic analysis must:
1. Build and validate symbol and scope information.
2. Infer and validate expression/result types.
3. Enforce language legality for the chosen C subset.
4. Emit deterministic diagnostics.
5. Resolve enough symbol/type information to support later IR generation without parser ambiguity.

## 2. Current frontend surface (from parser)
Parser currently builds AST for:
1. Types and declarations: `char`, `short`, `int`, `long`, `float`, `double`, `long double`, `void`, pointers, arrays, `struct`, `union`, `enum`.
2. Qualifiers/specifiers: `signed`, `unsigned`, `const`, `volatile`, `static`, `extern`, `inline`.
3. Statements: `if/else`, `switch/case/default`, `while`, `do-while`, `for`, `break`, `continue`, `return`, block scope.
4. Expressions: arithmetic, comparison, logical, bitwise, ternary, casts, pre/post inc/dec, address-of, dereference, array access, function calls.
5. Preprocessor directives are currently excluded from the supported subset-C grammar and are rejected.

## 3. Semantic phase architecture
Two mandatory passes:

## 3.1 Pass 1: symbol binding + scope construction
Traversal: preorder (enter node before children).
Responsibilities:
1. Enter/exit lexical scopes using structural AST nodes (`NODE_BLOCK`, and `NODE_FOR` for loop-init declaration scope) plus function boundaries.
2. Register declarations in symbol tables.
3. Track prototypes and definitions for functions.
4. Bind identifier-use nodes to resolved symbol entries.
5. Emit declaration/scope diagnostics.

Outputs:
1. Symbol table stack and global symbol index.
2. Symbol pointer attached to AST nodes (implementation field may be added to `TreeNode_t`).
3. Basic declaration attributes attached (storage class, qualifiers, declared type).

## 3.2 Pass 2: type inference + rule checking
Traversal: postorder (children before parent).
Responsibilities:
1. Infer `nodeVarType` and extended type metadata for every expression node.
2. Apply operator/type legality checks.
3. Apply statement/function control checks.
4. Enforce lvalue/modifiability rules.
5. Mark nodes as codegen-eligible or codegen-blocked.

Outputs:
1. Fully typed AST.
2. Diagnostics list (errors/warnings).
3. Codegen eligibility tags per function and per node.

## 4. Symbol table and scope model

## 4.1 Symbol kinds
At minimum support:
1. `SYMBOL_OBJECT` (variables, including arrays).
2. `SYMBOL_FUNCTION` (prototype/definition).
3. `SYMBOL_PARAMETER`.
4. `SYMBOL_TAG_STRUCT`.
5. `SYMBOL_TAG_UNION`.
6. `SYMBOL_TAG_ENUM`.
7. `SYMBOL_ENUM_CONST`.
8. `SYMBOL_FIELD` (struct/union members).

## 4.2 Required symbol fields
Each symbol entry must store:
1. Name.
2. Symbol kind.
3. Type descriptor.
4. Decl scope ID and lexical depth.
5. Source location (line, optional column).
6. Storage class (`auto`, `static`, `extern`, `parameter`).
7. Qualifiers (`const`, `volatile`, sign qualifiers where relevant).
8. Function extras (param list types, arity, is_defined).
9. Memory class hint (`global`, `stack`, `param`, `none`).
10. Optional offset placeholders for backend (`stack_offset`, `global_label`).

## 4.3 Scope rules
1. Enter scope on function start and block start.
2. Leave scope on block end and function end.
3. Same-scope redeclaration of object/function/tag with incompatible type is error.
4. Shadowing in nested scope is allowed for objects and tags unless policy forbids.
5. Function definition must match prior prototype signature.
6. Identifier use resolves nearest visible declaration in lexical scope chain.

## 5. Type system contract

## 5.1 Base types (from current AST)
Supported type tags:
1. `TYPE_CHAR`
2. `TYPE_SHORT`
3. `TYPE_INT`
4. `TYPE_LONG`
5. `TYPE_FLOAT`
6. `TYPE_DOUBLE`
7. `TYPE_LONG_DOUBLE`
8. `TYPE_STRING` (string literal node category)
9. `TYPE_VOID`
10. `TYPE_STRUCT`
11. `TYPE_UNION`
12. `TYPE_ENUM`

## 5.2 Derived type constructors
1. Pointer: `ptr(T)`.
2. Array: `array(T, size?)`.
3. Function: `fn(return_type, [param_types], variadic?)`.

## 5.3 Qualifiers
1. `const` and `volatile` are part of type qualifiers.
2. `signed/unsigned` apply to integral families.
3. `static/extern/inline` are declaration/storage/function specifiers, not expression types.

## 6. Lvalue/rvalue contract
1. Modifiable lvalue required for assignment LHS and pre/post inc/dec operand.
2. Non-modifiable lvalue includes:
- const-qualified objects,
- function designators,
- results of non-lvalue expressions.
3. Address-of (`&`) requires lvalue operand (except function designator if policy allows).
4. Dereference (`*`) requires pointer operand.

## 7. Conversion and compatibility policy

## 7.1 Implicit conversions (subset policy)
1. Integral promotions are allowed.
2. Arithmetic usual conversions allowed within scalar numeric types.
3. Pointer-to-pointer implicit conversion allowed only when base types are compatible or one is `void*` (if enabled by policy).
4. Pointer <-> integer implicit conversion is error.
5. Struct/union assignment requires exact compatible type identity.

## 7.2 Explicit casts
1. Cast between arithmetic types is allowed.
2. Cast between compatible pointers is allowed; incompatible pointer casts may be warning or error by strictness level.
3. Cast from function pointer to data pointer is error in strict mode.
4. Cast to/from incomplete aggregate type is error.

## 8. Operator semantic checks
For all `NODE_OPERATOR` with operator enum in `NodeTypes.h`:

## 8.1 Arithmetic binary (`+ - * / %`)
1. `+ - * /` require arithmetic operands.
2. `%` requires integral operands.
3. Division/modulo by compile-time zero constant is semantic error.

## 8.2 Shifts (`<< >>`)
1. Both operands integral.
2. Shift amount negative or >= bit-width can be warning or error (define strict level).

## 8.3 Bitwise (`& | ^ ~`)
1. Integral operands only.
2. `~` unary requires integral operand.

## 8.4 Logical (`&& || !`)
1. Scalar operands (numeric or pointer) allowed by C-like semantics.
2. Result type is integral boolean-like (`int` in C semantics, can map to `i1` in IR metadata plus widened type).

## 8.5 Comparison (`== != < <= > >=`)
1. Arithmetic comparisons allowed.
2. Pointer comparisons only under compatible pointer rules.
3. Result type boolean-like (`int` semantic result).

## 8.6 Assignment (`=`, compound assignments)
1. LHS must be modifiable lvalue.
2. RHS must be assignable to LHS type under conversion policy.
3. Compound assignments apply operation check then assignment check.

## 8.7 Ternary (`?:`)
1. Condition must be scalar.
2. Branch expression types must be compatible or convertible under policy.
3. Result type follows common type resolution.

## 8.8 Pre/post increment/decrement
1. Operand must be modifiable lvalue of arithmetic or pointer type (if pointer arithmetic supported in chosen subset).
2. If pointer arithmetic unsupported for codegen stage, semantic may mark as codegen-blocked with explicit diagnostic.

## 9. Statement-level semantic checks

## 9.1 If/while/do-while/for
1. Condition expression must be scalar (not struct/union/array/function type).
2. Scope for loop init declarations must be local to loop statement body as policy defines.

## 9.2 Switch/case/default
1. Switch expression must be integral or enum.
2. Case labels must be integral constant expressions.
3. Duplicate case values in same switch are error.
4. At most one default per switch.

## 9.3 Break/continue
1. `break` valid only inside loop or switch.
2. `continue` valid only inside loop.

## 9.4 Return
1. In `void` function, `return expr;` is error.
2. In non-void function, missing value return in mandatory paths is error (for this subset, conservative check required at minimum).
3. Returned expression must be compatible with function return type.

## 10. Function and call checks
1. Function call target must resolve to function symbol.
2. Argument count must match parameter count unless variadic.
3. Argument types must be compatible with parameter types under conversion policy.
4. Multiple declarations/prototypes for same function must be compatible.
5. Exactly one function definition per function name in TU (unless external linkage policy allows and this is per-TU check).

## 11. Array and pointer checks
1. Array index expression must be integral.
2. Indexed object must be array or pointer.
3. Dereference requires pointer operand.
4. Address-of on temporary rvalue is error.
5. Pointer assignment base-type compatibility enforced.

## 12. Aggregate checks (struct/union/enum)
1. Tag redefinition with incompatible layout is error.
2. Member access by `.` requires struct/union object.
3. Member access by `->` requires pointer to struct/union.
4. Unknown member name is error.
5. Enum member redefinition in same enum is error.

## 13. Qualifier/storage checks
1. `inline` usage must follow function-declaration policy; variable declarations with `inline` are semantic error.
2. Assignment to const-qualified object is error.
3. Discarding const qualifiers in implicit assignment is error (or warning at relaxed mode).
4. `extern` declarations cannot include invalid initializers under chosen subset policy.

## 14. Preprocessor node policy
Preprocessor directives are currently rejected before AST construction.
No macro-expansion or macro-metadata semantic path exists in the current subset-C frontend.

## 15. Diagnostics contract

## 15.1 Message format
Required format:
`<severity> <code> <path>:<line>:<column>: <message>`

Example:
`error SEM023 foo.c:41:9: assignment to const-qualified object 'x'`

## 15.2 Severities
1. `error`: compilation for current TU fails.
2. `warning`: compile may continue.
3. `note`: attached context.

## 15.3 Error code namespace
Use stable IDs: `SEM001..SEM199`.
All implemented checks must map to one code in `SEMANTIC_CHECK_MATRIX.md`.

## 16. Semantic stage outputs required by IR
After semantic success (no errors), AST must contain:
1. `nodeVarType` for every expression node.
2. Symbol binding for identifier/function/member nodes.
3. Explicit codegen eligibility flags for unsupported-yet features.
4. Canonicalized block/function scope ownership information.

## 17. Unsupported or deferred features
If parsed but not yet supported for codegen, semantic stage must emit deterministic errors, not silent acceptance.
Initial deferred list can include (until backend supports):
1. Floating-point arithmetic lowering.
2. Full struct/union value passing/return.
3. Variadic function lowering.
4. Advanced pointer arithmetic beyond baseline cases.

## 18. Mandatory invariants before IR generation
1. No unresolved symbols.
2. No type-check errors.
3. Every function body has resolved local symbol table.
4. Every control statement has valid context (`break`, `continue`, `case`, `default`).
5. Every expression node has a final semantic type.

## 19. Exit policy
1. If any `error` emitted: semantic pass returns non-zero; IR generation must not run.
2. Warnings are allowed but must be stable and testable.

## 20. Minimum acceptance for current sprint
By sprint gate, semantic must at minimum correctly enforce:
1. Redeclaration and unknown identifier checks.
2. Function call arity/type baseline checks.
3. Return type checks.
4. Lvalue checks for assignment/inc/dec.
5. Condition scalar checks.
6. Array index integral checks.
7. Inline-on-variable error (`inline int a;`) as requested by prior notes.
