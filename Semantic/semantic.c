#include <errno.h>
#include <stdio.h>
#include <string.h>

#include "semantic.h"
#include "semantic_pass1.h"
#include "semantic_pass2.h"

/**
 * @brief Initialize global semantic context before running passes.
 * @param ctx output context to initialize.
 * @return 0 on success, negative errno-like value on invalid input.
 */
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

/**
 * @brief Release all resources held by semantic context.
 * @param ctx context to destroy.
 */
void semantic_context_destroy(semantic_context_t *ctx)
{
  if (!ctx) {
    return;
  }

  scope_stack_destroy(&ctx->scope_stack);
  diag_list_destroy(&ctx->diagnostics);
  memset(ctx, 0, sizeof(*ctx));
}

/**
 * @brief Execute semantic pipeline in order: pass1 then pass2.
 * @param root AST root node.
 * @param path source path used in diagnostics printing.
 * @return aggregated semantic_result_t counters.
 */
semantic_result_t semantic_run(TreeNode_t *root, const char *path)
{
  semantic_context_t ctx;
  semantic_result_t result = {0u, 0u, 0u};
  semantic_pass1_result_t pass1_result = {0u, 0u};
  semantic_pass2_result_t pass2_result = {0u, 0u};
  int rc;

  rc = semantic_context_init(&ctx);
  if (rc < 0) {
    result.error_count = 1u;
    return result;
  }

  if (!root) {
    (void)diag_emit(&ctx.diagnostics,
                    "SEM000",
                    DIAG_ERROR,
                    0u,
                    0u,
                    "semantic analysis received empty AST");
  } else {
    rc = semantic_pass1_run(root, &ctx, &pass1_result);
    if (rc < 0 && diag_error_count(&ctx.diagnostics) == 0u) {
      (void)diag_emit(&ctx.diagnostics,
                      "SEM999",
                      DIAG_ERROR,
                      0u,
                      0u,
                      "semantic pass1 failed");
    }

    if (diag_error_count(&ctx.diagnostics) == 0u) {
      rc = semantic_pass2_run(root, &ctx, &pass2_result);
      if (rc < 0 && diag_error_count(&ctx.diagnostics) == 0u) {
        (void)diag_emit(&ctx.diagnostics,
                        "SEM999",
                        DIAG_ERROR,
                        0u,
                        0u,
                        "semantic pass2 failed");
      }
    }
  }

  result.error_count = diag_error_count(&ctx.diagnostics);
  result.warning_count = diag_warning_count(&ctx.diagnostics);
  result.scope_count = pass1_result.scope_count;
  (void)pass2_result;

  if (result.error_count > 0u || result.warning_count > 0u) {
    diag_print_all(stderr, &ctx.diagnostics, path);
  }

  semantic_context_destroy(&ctx);
  return result;
}
