# Subset-C Profile for Frontend + IR

Date: 2026-03-07

## 1. Why this exists
Parser accepts a broad syntax set.
This profile defines what is semantically accepted and what is lowered to IR now.

## 2. Feature levels

## Level P (parser accepted)
Anything accepted by `parser.y`.

## Level S (semantic accepted)
Anything that passes semantic checks under `SEMANTIC_ANALYSIS_CONTRACT.md`.

## Level I (IR-lowerable now)
Features currently guaranteed to lower into backend IR.

## 3. Type support matrix

| Type family | P | S | I | Notes |
|---|---|---|---|---|
| `char/short/int/long` | yes | yes | yes | Primary target path |
| pointers to integral | yes | yes | yes | Baseline pointer path |
| arrays of integral | yes | yes | yes | Baseline indexing path |
| `float/double/long double` | yes | policy yes | optional/no | May be blocked for codegen |
| struct/union declarations | yes | yes | partial/no | Metadata yes, value lowering may be blocked |
| enum declarations | yes | yes | partial | Often lowered as integral constants |
| `void` | yes | yes | yes | Function return/context checks apply |

## 4. Statement support matrix

| Statement | P | S | I | Notes |
|---|---|---|---|---|
| block scope | yes | yes | yes | via scope markers |
| if/else | yes | yes | yes | baseline CFG lowering |
| while/do-while/for | yes | yes | yes | baseline CFG lowering |
| switch/case/default | yes | yes | partial | compare-chain lowering initially |
| break/continue | yes | yes | yes | context stack required |
| return | yes | yes | yes | type and path checks |

## 5. Expression/operator support matrix

| Group | P | S | I | Notes |
|---|---|---|---|---|
| arithmetic +,-,*,/,% | yes | yes | partial | mul/div/mod may lower via helper/runtime if ISA lacks direct op |
| bitwise and shifts | yes | yes | yes | maps well to integer target |
| logical/comparison | yes | yes | yes | lowered to predicate+branch patterns |
| assignment + compound | yes | yes | yes | with lvalue checks |
| pre/post inc/dec | yes | yes | yes | lvalue + pointer policy applied |
| casts | yes | yes | partial | depends on type pair and backend support |
| ternary | yes | yes | yes | requires merge strategy |
| member access . and -> | yes | yes | partial | full aggregate layout lowering may be deferred |

## 6. Preprocessor scope
Current compiler path does not do full macro preprocessing.
`#define/#undef` parsed into AST nodes are treated as metadata unless preprocessing stage is added.

## 7. Contract with team tasks
By March 16 practical sprint:
1. P-level remains broad.
2. S-level must be enforced for mandatory `SEM` checks.
3. I-level optional but serve as basis for handoff with backend team. 