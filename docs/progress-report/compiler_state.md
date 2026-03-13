# Compiler Frontend State (Semantic Focus)

Date: 2026-03-10

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
2. Parser emits real structural scope nodes (`NODE_BLOCK`, `NODE_FOR`) instead of synthetic scope markers.
3. Semantic core APIs exist and compile:
- `Semantic/type.[ch]`
- `Semantic/symbol.[ch]`
- `Semantic/diagnostics.[ch]`
- `Semantic/semantic.[ch]`
4. Parser main flow now executes `semantic_run(...)` after successful parse.
5. CI baseline validates API behavior and memory safety:
- `scripts/ci/run_semantic_checks.sh`
- Unit/API tests + ASan/UBSan runs.
6. Pass1 currently implements:
- `SEM002`, `SEM003`, `SEM004`, `SEM005`
7. Pass2 currently implements:
- `SEM001`, `SEM011`, `SEM040`, `SEM041`, `SEM043`, `SEM050`, `SEM051`, `SEM060`, `SEM061`, `SEM062`
8. Parser and semantic regressions now cover:
- declarator refactor
- aggregate declarations
- AST cleanup nodes
- C11 expression ladder
- targeted semantic pass examples

## Not done (in compiler implementation)
1. Pass1 binder is incomplete: no AST identifier binding to symbol entries yet.
2. Pass2 checker is incomplete: many expression/operator/statement legality rules are still missing.
3. Full semantic rule matrix (`SEM001..`) is not implemented yet; only a subset is active.
5. IR lowering gate is not integrated (semantic success does not yet trigger IR phase).

## 3) What this means technically

1. Current compiler is parser-complete with a working semantic backbone, not frontend-complete.
2. It now validates real declaration/type/control-flow cases and emits deterministic semantic diagnostics.
3. Most of the rule matrix is still pending, so semantically invalid programs can still pass outside the implemented subset.

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
