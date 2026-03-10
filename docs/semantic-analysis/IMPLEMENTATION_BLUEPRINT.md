# Implementation Blueprint (Semantic + IR)

Date: 2026-03-07
Practical plan

## 1. Goals
1. Build semantic pass infrastructure with diagnostics.
2. Produce typed AST suitable for IR lowering.
3. Implement IR lowering boundary contract for backend handoff.

## 2. Proposed compiler file layout

Add these files under `compiler/`:

## 2.1 Semantic core
1. `Semantic/semantic.h`
2. `Semantic/semantic.c`
3. `Semantic/symbol.h`
4. `Semantic/symbol.c`
5. `Semantic/type.h`
6. `Semantic/type.c`
7. `Semantic/diagnostics.h`
8. `Semantic/diagnostics.c`
9. `Semantic/pass1_bind.c`
10. `Semantic/pass2_typecheck.c`
11. `Semantic/check_expr.c`
12. `Semantic/check_stmt.c`
13. `Semantic/check_decl.c`

## 2.2 IR layer
1. `IR/ir.h`
2. `IR/ir.c`
3. `IR/ir_builder.h`
4. `IR/ir_builder.c`
5. `IR/lower_expr.c`
6. `IR/lower_stmt.c`
7. `IR/lower_func.c`
8. `IR/ir_print.c`

## 2.3 Driver integration
1. Update `compiler/Parser/parser.y` main flow:
- parse
- semantic
- IR generation (optional initially, add a commented-out snippet for now)
2. Update Makefile source list.

## 3. Minimal public APIs

## 3.1 semantic.h
```c
typedef struct {
    size_t error_count;
    size_t warning_count;
    size_t scope_count;
} semantic_result_t;

semantic_result_t semantic_run(TreeNode_t *root, const char *path);
```

## 3.2 symbol.h
```c
typedef enum {
    SYMBOL_OBJECT,
    SYMBOL_FUNCTION,
    SYMBOL_PARAMETER,
    SYMBOL_TAG_STRUCT,
    SYMBOL_TAG_UNION,
    SYMBOL_TAG_ENUM,
    SYMBOL_ENUM_CONST,
    SYMBOL_FIELD
} symbol_kind_t;
```

## 3.3 ir.h
```c
typedef struct ir_module_s ir_module_t;

ir_module_t *ir_lower_translation_unit(TreeNode_t *root);
void ir_print_module(FILE *out, const ir_module_t *m);
```

## 4. AST annotation strategy
Current `TreeNode_t` has commented symbol/scope links.
Required change:
1. Add pointer fields for symbol binding and scope context.
2. Keep backward compatibility with parser actions.

Suggested additions to `TreeNode_t`:
```c
void *p_symbol;
void *p_scope;
unsigned flags;
```

`flags` can hold:
1. typed-ok
2. codegen-blocked
3. constant-expression

## 5. Semantic implementation sequence

## Step A - diagnostics first
1. Implement emitter function with stable codes (`SEM###`).
2. Add path/line/column support.
3. Add fail-fast option for debugging and full-collection mode for CI.

## Step B - pass1 binder
1. Build scope stack.
2. Register declarations.
3. Resolve uses.
4. Add function prototype/definition matching.

## Step C - pass2 checker
1. Expression typing.
2. Assignment/lvalue checks.
3. Call and return checks.
4. Loop/switch context legality checks.

## Step D - codegen eligibility tags
1. Mark parsed-but-not-yet-lowerable features.
2. Emit deterministic messages.

## Step E - IR lowering
1. Implement function CFG skeleton.
2. Lower arithmetic, assignment, if/while/for, calls, returns.
3. Emit text IR

## 6. CI requirements for semantic stage

## 6.1 Script targets
1. `compiler/scripts/run_semantic_regression.sh`
2. `compiler/scripts/run_ir_regression.sh` when IR is added 

## 6.2 Required checks
1. Build succeeds.
2. Semantic `ok/fail` matches expected.
3. IR snapshot tests stable, when implemented.

## 7. Backend handoff constraints
Backend team can rely on:
1. typed IR values,
2. explicit CFG,
3. virtual registers,
4. explicit load/store/call/branch semantics.

Backend team must handle:
1. instruction selection to ISA opcodes,
2. immediate materialization (`IMM` prefix policy),
3. branch-range policy,
4. register allocation strategy (graph coloring or equivalent).

## 8. Definition of done for semantic+IR stage
1. All mandatory `SEM` rules in matrix implemented.
2. No unresolved identifiers/types reach IR lowering.
3. IR text emitter produces deterministic output for same input.
4. CI includes semantic and IR regression jobs.
