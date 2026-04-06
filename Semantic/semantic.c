#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "semantic.h"
#include "semantic_pass1.h"
#include "semantic_pass2.h"

struct sem_node_bucket_s {
  const TreeNode_t *node;
  sem_node_info_t info;
  int occupied;
};

static size_t mix_ptr(const void *ptr)
{
  uintptr_t x = (uintptr_t)ptr;
  x ^= x >> 33;
  x *= 0xff51afd7ed558ccdULL;
  x ^= x >> 33;
  x *= 0xc4ceb9fe1a85ec53ULL;
  x ^= x >> 33;
  return (size_t)x;
}

static int sem_node_map_grow(semantic_context_t *ctx, size_t min_capacity)
{
  size_t capacity = ctx->node_info.capacity ? ctx->node_info.capacity : 64u;
  sem_node_bucket_t *new_buckets;
  size_t i;

  while (capacity < min_capacity) {
    capacity <<= 1u;
  }

  new_buckets = SEM_ARENA_NEW_ARRAY(&ctx->persistent_arena, sem_node_bucket_t, capacity);
  if (!new_buckets) {
    return -ENOMEM;
  }
  (void)memset(new_buckets, 0, capacity * sizeof(*new_buckets));

  if (ctx->node_info.buckets) {
    for (i = 0u; i < ctx->node_info.capacity; ++i) {
      if (ctx->node_info.buckets[i].occupied) {
        size_t slot = mix_ptr(ctx->node_info.buckets[i].node) & (capacity - 1u);
        while (new_buckets[slot].occupied) {
          slot = (slot + 1u) & (capacity - 1u);
        }
        new_buckets[slot] = ctx->node_info.buckets[i];
      }
    }
  }

  ctx->node_info.buckets = new_buckets;
  ctx->node_info.capacity = capacity;
  return 0;
}

int semantic_context_init(semantic_context_t *ctx)
{
  int rc;

  if (!ctx) {
    return -EINVAL;
  }

  (void)memset(ctx, 0, sizeof(*ctx));
  rc = sem_arena_init(&ctx->persistent_arena, 16384u);
  if (rc < 0) {
    return rc;
  }
  rc = sem_arena_init(&ctx->scratch_arena, 4096u);
  if (rc < 0) {
    sem_arena_destroy(&ctx->persistent_arena);
    return rc;
  }
  type_context_init(&ctx->type_context, &ctx->persistent_arena);
  scope_stack_init(&ctx->scope_stack, &ctx->persistent_arena);
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
  sem_arena_destroy(&ctx->scratch_arena);
  sem_arena_destroy(&ctx->persistent_arena);
  (void)memset(ctx, 0, sizeof(*ctx));
}

const sem_node_info_t *semantic_get_node_info(const semantic_context_t *ctx,
                                              const TreeNode_t *node)
{
  size_t slot;

  if (!ctx || !node || !ctx->node_info.buckets || ctx->node_info.capacity == 0u) {
    return NULL;
  }

  slot = mix_ptr(node) & (ctx->node_info.capacity - 1u);
  while (ctx->node_info.buckets[slot].occupied) {
    if (ctx->node_info.buckets[slot].node == node) {
      return &ctx->node_info.buckets[slot].info;
    }
    slot = (slot + 1u) & (ctx->node_info.capacity - 1u);
  }

  return NULL;
}

int semantic_set_node_info(semantic_context_t *ctx,
                           const TreeNode_t *node,
                           const sem_node_info_t *info)
{
  size_t slot;

  if (!ctx || !node || !info) {
    return -EINVAL;
  }

  if (ctx->node_info.capacity == 0u ||
      (ctx->node_info.count + 1u) * 10u >= ctx->node_info.capacity * 7u) {
    int rc = sem_node_map_grow(ctx, ctx->node_info.capacity ? ctx->node_info.capacity * 2u : 64u);
    if (rc < 0) {
      return rc;
    }
  }

  slot = mix_ptr(node) & (ctx->node_info.capacity - 1u);
  while (ctx->node_info.buckets[slot].occupied) {
    if (ctx->node_info.buckets[slot].node == node) {
      ctx->node_info.buckets[slot].info = *info;
      return 0;
    }
    slot = (slot + 1u) & (ctx->node_info.capacity - 1u);
  }

  ctx->node_info.buckets[slot].node = node;
  ctx->node_info.buckets[slot].info = *info;
  ctx->node_info.buckets[slot].occupied = 1;
  ctx->node_info.count++;
  return 0;
}

int semantic_analyze(TreeNode_t *root,
                     const char *path,
                     semantic_context_t **out_ctx,
                     semantic_result_t *out_result)
{
  semantic_context_t *ctx;
  semantic_pass1_result_t pass1_result = {0u, 0u};
  semantic_pass2_result_t pass2_result = {0u, 0u};
  int rc;

  if (!out_ctx || !out_result) {
    return -EINVAL;
  }

  *out_ctx = NULL;
  (void)memset(out_result, 0, sizeof(*out_result));
  ctx = (semantic_context_t *)calloc(1u, sizeof(*ctx));
  if (!ctx) {
    out_result->error_count = 1u;
    return -ENOMEM;
  }

  rc = semantic_context_init(ctx);
  if (rc < 0) {
    free(ctx);
    out_result->error_count = 1u;
    return rc;
  }

  if (!root) {
    (void)diag_emit(&ctx->diagnostics,
                    "SEM000",
                    DIAG_ERROR,
                    0u,
                    0u,
                    "semantic analysis received empty AST");
  } else {
    rc = semantic_pass1_run(root, ctx, &pass1_result);
    if (rc < 0 && diag_error_count(&ctx->diagnostics) == 0u) {
      (void)diag_emit(&ctx->diagnostics,
                      "SEM999",
                      DIAG_ERROR,
                      0u,
                      0u,
                      "semantic pass1 failed");
    }

    if (diag_error_count(&ctx->diagnostics) == 0u) {
      rc = semantic_pass2_run(root, ctx, &pass2_result);
      if (rc < 0 && diag_error_count(&ctx->diagnostics) == 0u) {
        (void)diag_emit(&ctx->diagnostics,
                        "SEM999",
                        DIAG_ERROR,
                        0u,
                        0u,
                        "semantic pass2 failed");
      }
    }
  }

  out_result->error_count = diag_error_count(&ctx->diagnostics);
  out_result->warning_count = diag_warning_count(&ctx->diagnostics);
  out_result->scope_count = pass1_result.scope_count;
  (void)pass2_result;

  if ((out_result->error_count > 0u || out_result->warning_count > 0u) && path) {
    diag_print_all(stderr, &ctx->diagnostics, path);
  }

  *out_ctx = ctx;
  return 0;
}

semantic_result_t semantic_run(TreeNode_t *root, const char *path)
{
  semantic_context_t *ctx = NULL;
  semantic_result_t result = {0u, 0u, 0u};

  (void)semantic_analyze(root, path, &ctx, &result);
  if (ctx) {
    semantic_context_destroy(ctx);
    free(ctx);
  }
  return result;
}

void semantic_dump_annotations(FILE *out, const semantic_context_t *ctx)
{
    if (!ctx || !ctx->node_info.buckets) return;
    fprintf(out, "\n=== Annotation Table (%zu entries) ===\n",
            ctx->node_info.count);
    for (size_t i = 0; i < ctx->node_info.capacity; i++) {
        sem_node_bucket_t *b = &ctx->node_info.buckets[i];
        if (!b->occupied) continue;
        fprintf(out, "node=%p  type_kind=%d  symbol=%s  flags=%u\n",
                (void *)b->node,
                b->info.type ? (int)b->info.type->kind : -1,
                b->info.symbol ? b->info.symbol->name : "(none)",
                b->info.flags);
    }
}
