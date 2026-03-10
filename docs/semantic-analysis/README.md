# Semantic + IR Specification

This folder is the normative contract for the compiler frontend and IR boundary.
If implementation and this spec disagree, update code or spec in the same PR.

## What it contains 
- Subset-C semantic analysis rules.
- IR generation contract.
- Diagnostics and validation obligations.

## Inputs used to build this spec
- `compiler/Parser/parser.y`
- `compiler/Parser/ASTree.h`
- `compiler/Util/NodeTypes.h`
- `assembler/Util/asm_operations.h`
- `assembler/Step1/abi.m4`
- `previous-group/design-semantical-analysis.md`
- `previous-group/examples-semantical-analysis.md`

## Files
1. `SEMANTIC_ANALYSIS_CONTRACT.md`
- Contém o contrato completo da fase semântica, o comportamento dos passes, o modelo de símbolos/scope, as regras de tipos, e por fim os diagnósticos.

2. `IR_GENERATION_CONTRACT.md`
- Contém o contrato da IR a partir da AST já tipada semanticamente, e ainda as restrições esperadas pelo assembler.

3. `SEMANTIC_CHECK_MATRIX.md`
- Checklist de regras semânticas, com IDs e exemplos de pass/fail necessários.

4. `IMPLEMENTATION_BLUEPRINT.md`
- Detalhes da implementação, como organização de arquivos, funções, e responsabilidades.

## Enforcement
- Every semantic rule must have at least one test.
- Every IR instruction kind used by lowering must have at least one lowering test.
- Any unsupported feature must fail with a deterministic semantic or lowering error code.

## Current CI Baseline (Implemented)
- Script: `scripts/ci/run_semantic_checks.sh`
- Coverage:
1. Public header/API compile smoke.
2. Runtime API tests: `type`, `symbol`, `diagnostics`, `semantic`.
3. Frontend build smoke (`make` with lexer/parser/semantic objects).
4. Parser->semantic contract smoke (`minimal_ok.c` must pass, `syntax_fail.c` must fail).
5. Memory-safety checks with `ASan/UBSan` for all API tests.

Local run:
```bash
bash scripts/ci/run_semantic_checks.sh .ci_artifacts/semantic_checks
```

## Garantias 
- Todas as regras semânticas devem ter pelo menos um teste.
- Toda instrução de IR usada pelo lowering deve ter pelo menos um teste de lowering.
- Qualquer recurso não suportado deve falhar com um código de erro semântico ou de lowering determinístico.
