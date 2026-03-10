#include <errno.h>
#include <stdio.h>
#include <string.h>

#include "semantic.h"

static int walk_scope_markers(TreeNode_t *node, semantic_context_t *ctx)
{
  TreeNode_t *it = node;

  while (it) {
    if (it->nodeType == NODE_START_SCOPE) {
      int rc = scope_push(&ctx->scope_stack);
      if (rc < 0) {
        (void)diag_emit(&ctx->diagnostics,
                        "SEM900",
                        DIAG_ERROR,
                        it->lineNumber,
                        0u,
                        "failed to enter lexical scope");
        return rc;
      }
      ctx->scope_enter_count++;
    }

    if (it->p_firstChild) {
      int rc = walk_scope_markers(it->p_firstChild, ctx);
      if (rc < 0) {
        return rc;
      }
    }

    if (it->nodeType == NODE_END_SCOPE) {
      scope_t *cur = scope_current(&ctx->scope_stack);
      if (!cur || !cur->parent) {
        (void)diag_emit(&ctx->diagnostics,
                        "SEM901",
                        DIAG_ERROR,
                        it->lineNumber,
                        0u,
                        "unmatched scope end marker");
        return -EINVAL;
      }

      if (scope_pop(&ctx->scope_stack) < 0) {
        (void)diag_emit(&ctx->diagnostics,
                        "SEM901",
                        DIAG_ERROR,
                        it->lineNumber,
                        0u,
                        "scope stack underflow while leaving scope");
        return -EINVAL;
      }
      ctx->scope_leave_count++;
    }

    it = it->p_sibling;
  }

  return 0;
}

int semantic_context_init(semantic_context_t *ctx)
{
  if (!ctx) {
    return -EINVAL;
  }

  memset(ctx, 0, sizeof(*ctx));
  scope_stack_init(&ctx->scope_stack);
  diag_list_init(&ctx->diagnostics);
  return 0;
}

void semantic_context_destroy(semantic_context_t *ctx)
{
  if (!ctx) {
    return;
  }

  scope_stack_destroy(&ctx->scope_stack);
  diag_list_destroy(&ctx->diagnostics);
  memset(ctx, 0, sizeof(*ctx));
}

semantic_result_t semantic_run(TreeNode_t *root, const char *path)
{
  semantic_context_t ctx;
  semantic_result_t result = {0u, 0u, 0u};
  int rc;

  rc = semantic_context_init(&ctx);
  if (rc < 0) {
    result.error_count = 1u;
    return result;
  }

  rc = scope_push(&ctx.scope_stack);
  if (rc < 0) {
    (void)diag_emit(&ctx.diagnostics,
                    "SEM900",
                    DIAG_ERROR,
                    0u,
                    0u,
                    "failed to create global scope");
    result.error_count = diag_error_count(&ctx.diagnostics);
    semantic_context_destroy(&ctx);
    return result;
  }
  result.scope_count = 1u;

  if (!root) {
    (void)diag_emit(&ctx.diagnostics,
                    "SEM000",
                    DIAG_ERROR,
                    0u,
                    0u,
                    "semantic analysis received empty AST");
  } else {
    rc = walk_scope_markers(root, &ctx);
    if (rc < 0 && diag_error_count(&ctx.diagnostics) == 0u) {
      (void)diag_emit(&ctx.diagnostics,
                      "SEM999",
                      DIAG_ERROR,
                      0u,
                      0u,
                      "semantic traversal failed");
    }
  }

  while (scope_current(&ctx.scope_stack) && scope_current(&ctx.scope_stack)->parent) {
    (void)diag_emit(&ctx.diagnostics,
                    "SEM902",
                    DIAG_ERROR,
                    0u,
                    0u,
                    "missing scope end marker");
    (void)scope_pop(&ctx.scope_stack);
    ctx.scope_leave_count++;
  }

  result.error_count = diag_error_count(&ctx.diagnostics);
  result.warning_count = diag_warning_count(&ctx.diagnostics);
  result.scope_count += ctx.scope_enter_count;

  if (result.error_count > 0u || result.warning_count > 0u) {
    diag_print_all(stderr, &ctx.diagnostics, path);
  }

  semantic_context_destroy(&ctx);
  return result;
}
