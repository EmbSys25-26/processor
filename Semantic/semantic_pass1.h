#ifndef SEMANTIC_PASS1_H
#define SEMANTIC_PASS1_H

#include <stddef.h>

#include "../Parser/ASTree.h"
#include "semantic.h"

/*
Contrato do Passe 1
O Passe 1 trata de processar as declarações + popular a tabela de símbolos em cada scope 
Pontos relevantes: 
- Ownership do input: recebe a AST, e é dono da estrutura de contexto semantic_context_t 
- Ownership do output: símbolos, scopes - pertencem à scope_stack_t que faz parte do contexto em semantic_context_t 
- Regra da travessia: nodos de declarações devem ser inseridos antes de visitar os siblings seguintes na cadeia, por forma a que estes tb tenham acesso à declaração 
*/

/// @brief result from pass 1: no. of scopes + no. of symbols 
typedef struct {
  size_t scope_count;
  size_t declaration_count;
} semantic_pass1_result_t;


/// @brief Run pass1 over AST and populate lexical scopes/symbol declarations.
/// @param root AST root node.
/// @param ctx shared semantic context.
/// @param out_result output result for pass1.
/// @return 0 on success, negative errno value on fatal setup/traversal error.
int semantic_pass1_run(TreeNode_t *root, semantic_context_t *ctx, semantic_pass1_result_t *out_result);

#endif
