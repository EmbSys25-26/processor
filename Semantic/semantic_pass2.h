#ifndef SEMANTIC_PASS2_H
#define SEMANTIC_PASS2_H

#include <stddef.h>

#include "../Parser/ASTree.h"
#include "semantic.h"

/*
Contrato do Passe 2
O Passe 2 trata de consumir a AST tipada pelo passe 1, e fazer todos os checkings já com os símbolos declarados na tabela de símbolos, associados aos scopes onde se encontram e onde são visíveis. 
- Input ownership: tem a AST tipada e o semantic_context_t 
- Output ownership: resultado do passe 2 com o expression count e statement count. produzir mensagens de erro quando for o caso 
- Consistency rule: pass2 consome os símbolos + scopes produzidos no passe anterior para efetuar checks.
*/

typedef struct {
  size_t expression_count;
  size_t statement_count;
} semantic_pass2_result_t;

/**
 * @brief Run pass2 over AST and enforce expression/usage semantic rules.
 * @param root AST root node.
 * @param ctx shared semantic context.
 * @param out_result output metrics for pass2.
 * @return 0 on success, negative errno-like value on fatal setup/traversal error.
 */
int semantic_pass2_run(TreeNode_t *root, semantic_context_t *ctx, semantic_pass2_result_t *out_result);

#endif
