#ifndef SEMANTIC_CHECK_STMT_H
#define SEMANTIC_CHECK_STMT_H

#include "semantic.h"
#include "../Parser/ASTree.h"

// validate the semantics of statements 
int check_stmt(TreeNode_t *node, semantic_context_t *ctx);

#endif