# Compiler Frontend State (Semantic Focus)

Date: 2026-03-08

## 1) Current reality: what is already done

### Parsing pipeline is functionally in place
1. Lexer exists and tokenizes a broad subset of C-like input.
2. Bison grammar parses declarations, statements, expressions, functions, and aggregate constructs.
3. AST is built and printed successfully.

### Implemented components
1. Lexer:
- `compiler/Lexer/lexer.l`
2. Parser:
- `compiler/Parser/parser.y`
3. AST core:
- `compiler/Parser/ASTree.h`
- `compiler/Parser/ASTree.c`
4. AST printer:
- `compiler/Parser/ASTPrint.c`
5. Node/operator/type enums:
- `compiler/Util/NodeTypes.h`

## 2) Semantic analysis status: done vs not done

## Done
1. AST has basic per-node `nodeVarType` enum field (`VarType_t`).
2. Parser emits enough structural nodes (scope markers, declarations, expressions) to support semantic passes.
3. Semantic design/spec documents exist under:
- `semantic-analysis/`

## Not done (in compiler implementation)
1. No semantic pass runner in the compile flow after parse.
2. No compiler-side symbol table for C identifiers/types/functions.
3. No lexical-scope stack for nested block/function scopes.
4. No AST binding of identifier uses to symbol entries.
5. No type descriptor system beyond coarse `VarType_t` enum.
6. No expression/statement semantic checks (type legality, lvalue rules, return/break/continue legality).
7. No deterministic semantic diagnostics layer (`SEMYYY` IDs) (here `YYY` is the ID)

## 3) What this means technically

1. Current compiler is parser-complete baseline, not frontend-complete.
2. Right now it validates syntax and builds AST, but does not enforce language meaning.
3. Invalid programs can still parse successfully because semantic constraints are not applied yet.

## 4) Suggested path

## Phase A - Semantic infrastructure
1. Create `compiler/Semantic/`.
2. Implement:
- symbol entries,
- lexical scope stack (nested linked parent chain),
- type descriptor objects,
- diagnostics emitter.

## Phase B - Pass 1 (binder)
1. Traverse AST and open/close scopes on function/block boundaries.
2. Insert declarations in current scope.
3. Resolve identifier usages through nearest-visible scope lookup.
4. Record function prototype/definition metadata.

## Phase C - Pass 2 (checker)
1. Infer expression types.
2. Enforce assignment/lvalue/operator compatibility.
3. Enforce control-flow legality (`return`, `break`, `continue`, loop/switch context).
4. Emit deterministic semantic diagnostics with stable rule IDs.

## Phase D - Intermediate Representation (IR) Gated entry
1. Only run IR lowering if semantic error count is zero.
2. Treat unsupported semantic features as explicit errors, never silent acceptance.

## 5) Practical go-forward for your team split

1. Build semantic layer as a separate module consumed by parser output.
2. Merge order should be:
- semantic core,
- binder,
- expression checks,
- control/function checks,
- IR core/lowering.

Reference tasks already created:
1. `tasks/ISSUE-SEM-01-symbol-scope-core.md`
2. `tasks/ISSUE-SEM-02-pass1-binder.md`
3. `tasks/ISSUE-SEM-03-pass2-expression-typecheck.md`
4. `tasks/ISSUE-SEM-04-pass2-control-flow-and-functions.md`

IR-related tasks might be postponed this time around, I'm not exactly sure yet. 

## 6) Bottom line / TL;DR
1. The suggested work is symbol/scoping/type-descriptor infrastructure plus two semantic passes.
2. After that, IR generation can be made reliable and contract-driven.