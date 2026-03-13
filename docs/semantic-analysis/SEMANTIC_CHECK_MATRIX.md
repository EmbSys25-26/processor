# Semantic Check Matrix (Subset-C)

Date: 2026-03-07

Use this file as the test obligation list.
Each implemented rule must have at least one `ok` test and one `fail` test.

## 1. Naming convention
- Semantic errors: `SEM###`
- Semantic warnings: `SEMW###`

## 1.1 Implemented now
- Pass1: `SEM002`, `SEM003`, `SEM004`, `SEM005`
- Pass2: `SEM001`, `SEM011`, `SEM040`, `SEM041`, `SEM043`, `SEM050`, `SEM051`, `SEM060`, `SEM061`, `SEM062`
- Note: `SEM001` is currently enforced in pass2 lookup flow, not in pass1 binding.

## 2. Declaration and scope checks

## SEM001 - unknown identifier
- Rule: any `NODE_IDENTIFIER` in expression/call/member context must resolve to visible symbol.
- Fail example:
```c
int main(){ return x; }
```

## SEM002 - redeclaration in same scope
- Rule: object/function/tag redeclaration in same scope with incompatible or duplicate declaration is error.
- Fail example:
```c
int main(){ int a; int a; return 0; }
```

## SEM003 - shadowing allowed in nested scope
- Rule: nested scope object may shadow outer object.
- Ok example:
```c
int a;
int main(){ int a; return a; }
```

## SEM004 - function prototype/definition mismatch
- Rule: function definition signature must match prototype.
- Fail example:
```c
int f(int a);
int f(float a){ return 0; }
```

## SEM005 - duplicate function definition
- Rule: same TU cannot define same function twice.

## SEM006 - use before declaration in same block (policy)
- Rule: identifier use before declaration in same local scope is error.

## 3. Qualifier and storage checks

## SEM007 - inline not valid for object declaration
- Rule: `inline` on variable is error.
- Fail example:
```c
inline int a;
```

## SEM008 - assignment to const object
- Rule: assignment or compound assignment to const-qualified object is error.

## SEM009 - inc/dec on const object
- Rule: pre/post inc/dec on const object is error.

## SEM010 - const qualifier drop in implicit assignment
- Rule: assigning `const T*` to `T*` without explicit cast is error (strict mode).

## 4. Type and conversion checks

## SEM011 - assignment compatibility
- Rule: RHS must be assignable to LHS according to conversion policy.

## SEM012 - pointer/int implicit conversion forbidden
- Rule: implicit pointer<->integer conversion is error.

## SEM013 - incompatible pointer assignment
- Rule: incompatible pointer base types are error unless explicit policy exception.

## SEM014 - struct/union assignment type identity
- Rule: only same compatible aggregate types assignable.

## SEM015 - cast to/from incomplete aggregate forbidden
- Rule: cast involving incomplete struct/union is error.

## SEM016 - pointer to floating cast policy
- Rule: pointer<->float cast is error in strict mode.

## 5. Expression/operator checks

## SEM020 - arithmetic operators type legality
- Rule: `+ - * /` require arithmetic operands.

## SEM021 - modulo integral only
- Rule: `%` requires integral operands.

## SEM022 - division/modulo by zero
- Rule: denominator literal/constant zero is semantic error.

## SEM023 - bitwise operators integral only
- Rule: `& | ^ ~ << >>` require integral operands.

## SEM024 - logical operators scalar only
- Rule: `&& || !` require scalar operands.

## SEM025 - comparison operand compatibility
- Rule: comparison operands must be compatible arithmetic or compatible pointers.

## SEM026 - ternary branch compatibility
- Rule: `cond ? a : b` requires type-compatible `a` and `b`.

## SEM027 - lvalue required on assignment LHS
- Rule: LHS must be modifiable lvalue.

## SEM028 - lvalue required for inc/dec
- Rule: pre/post inc/dec operand must be modifiable lvalue.

## SEM029 - address-of requires lvalue
- Rule: `&` operand must be lvalue.

## SEM030 - dereference requires pointer
- Rule: `*expr` requires pointer-typed operand.

## SEM031 - array index integral
- Rule: `arr[idx]` requires integral `idx`.

## SEM032 - array access base legality
- Rule: base of `[]` must be array or pointer.

## 6. Function and call checks

## SEM040 - call target must be function
- Rule: call expression target resolves to function symbol.

## SEM041 - argument count check
- Rule: non-variadic call arity must match signature.

## SEM042 - argument type compatibility
- Rule: each arg must be convertible to corresponding param type.

## SEM043 - return type compatibility
- Rule: return expression type must match function return type.

## SEM044 - return value in void function
- Rule: `return expr;` inside void function is error.

## SEM045 - missing return in non-void function
- Rule: function with non-void return must return value on required paths.

## SEM046 - return outside function
- Rule: return statement outside function scope is error.

## 7. Control-flow checks

## SEM050 - break context legality
- Rule: `break` valid only in loop/switch.

## SEM051 - continue context legality
- Rule: `continue` valid only in loop.

## SEM052 - if/loop condition scalar
- Rule: `if/while/do-while/for` condition must be scalar.

## SEM053 - switch expression integral-or-enum
- Rule: `switch(expr)` expr must be integral or enum.

## SEM054 - case label constant integral
- Rule: case label must be integral constant expression.

## SEM055 - duplicate case labels
- Rule: duplicate case value in same switch is error.

## SEM056 - multiple defaults in one switch
- Rule: only one `default` per switch.

## 8. Aggregate/member checks

## SEM060 - unknown struct/union member
- Rule: member access must find member in aggregate type.

## SEM061 - dot access base type check
- Rule: `a.b` requires struct/union object.

## SEM062 - arrow access base type check
- Rule: `a->b` requires pointer to struct/union.

## SEM063 - enum member redeclaration
- Rule: duplicate enum member in same enum is error.

## SEM064 - tag redefinition compatibility
- Rule: tag redefinition with incompatible layout is error.

## 9. Parser-accepted but codegen-blocked checks
These are semantic-success optional but must be deterministic if backend does not support them.

## SEM070 - floating arithmetic codegen unsupported
- Rule: if backend lacks float lowering, emit codegen-blocking error/warning with stable code.

## SEM071 - struct value return unsupported
- Rule: if backend lacks aggregate return lowering, block deterministically.

## SEM072 - variadic lowering unsupported
- Rule: if variadic call lowering not implemented, block deterministically.

## 10. Warning-level checks

## SEMW001 - truncated casting
- Example: `int x = 3.14;`

## SEMW002 - signed/unsigned very sus converssions
- Example: `unsigned u = -1;`

## SEMW003 - explicit cast dropping const
- Example: `int* p = (int*)cp;`

## 11. Required test folders
Create and maintain:
1. `compiler/test_files/semantic/ok/` to test positive programs.
2. `compiler/test_files/semantic/fail/` to test negative programs with expected error codes.
3. `compiler/test_files/semantic/warn/` to test programs that should compile but emit expected warnings.

## 12. Required fixture manifest format
Each fixture must include expected status and expected code(s).
Suggested manifest (`manifest.tsv`):

`<file>\t<expected_exit>\t<expected_codes_csv>`

Example:
`fail/redecl_01.c\t1\tSEM002`

Why this manifest? 
This will be used by CI to verify that the correct diagnostics are emitted for each test case.

## 13. Sprint minimum implementation set
Bare minimum to implement before handoff: 
1. SEM001
2. SEM002
3. SEM004
4. SEM007
5. SEM020
6. SEM023
7. SEM027
8. SEM031
9. SEM041
10. SEM043
11. SEM050
12. SEM051
13. SEM052
