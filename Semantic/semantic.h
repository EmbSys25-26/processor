#ifndef SEMANTIC_SEMANTIC_H
#define SEMANTIC_SEMANTIC_H

#include <stddef.h>

#include "../Parser/ASTree.h"
#include "diagnostics.h"
#include "symbol.h"

/// @brief Holds semantic pipeline context.
typedef struct {
  scope_stack_t scope_stack;
  diagnostic_list_t diagnostics;
  size_t scope_enter_count;
  size_t scope_leave_count;

  type_t *current_fn_ret; // (Current Function Return)Keeps track of the current function's return type, needed for validating return statements (SEM044 SEM046)

} semantic_context_t;

typedef struct {
  size_t error_count;
  size_t warning_count;
  size_t scope_count;
} semantic_result_t;

int semantic_context_init(semantic_context_t *ctx);
void semantic_context_destroy(semantic_context_t *ctx);

semantic_result_t semantic_run(TreeNode_t *root, const char *path);

#endif
