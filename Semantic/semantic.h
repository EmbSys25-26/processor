#ifndef SEMANTIC_SEMANTIC_H
#define SEMANTIC_SEMANTIC_H

#include <stddef.h>

#include "../Parser/ASTree.h"
#include "arena.h"
#include "diagnostics.h"
#include "symbol.h"

typedef enum {
  SEM_VALUE_RVALUE = 0,
  SEM_VALUE_LVALUE,
  SEM_VALUE_FUNCTION_DESIGNATOR,
  SEM_VALUE_ADDRESS
} sem_value_kind_t;

enum {
  SEM_NODE_TYPED = (1u << 0),
  SEM_NODE_CODEGEN_BLOCKED = (1u << 1),
  SEM_NODE_CONST_EXPR = (1u << 2),
  SEM_NODE_ADDR_TAKEN = (1u << 3)
};

typedef struct {
  const type_t *type;
  symbol_t *symbol;
  sem_value_kind_t value_kind;
  unsigned flags;
} sem_node_info_t;

typedef struct sem_node_bucket_s sem_node_bucket_t;

typedef struct {
  sem_node_bucket_t *buckets;
  size_t capacity;
  size_t count;
} sem_node_map_t;

typedef struct {
  sem_arena_t persistent_arena;
  sem_arena_t scratch_arena;
  type_context_t type_context;
  scope_stack_t scope_stack;
  diagnostic_list_t diagnostics;
  sem_node_map_t node_info;
  size_t scope_enter_count;
  size_t scope_leave_count;
} semantic_context_t;

typedef struct {
  size_t error_count;
  size_t warning_count;
  size_t scope_count;
} semantic_result_t;

int semantic_context_init(semantic_context_t *ctx);
void semantic_context_destroy(semantic_context_t *ctx);

/*
 * IR pipeline entry point.  Runs both semantic passes; on success the context
 * pointed to by *out_ctx remains alive until the caller calls
 * semantic_context_destroy(ctx).  IR lowering MUST use this function — not
 * semantic_run — so that the annotation table and symbol data are still
 * accessible after the call returns.
 */
int semantic_analyze(TreeNode_t *root,
                     const char *path,
                     semantic_context_t **out_ctx,
                     semantic_result_t *out_result);

/*
 * Convenience wrapper for tests and stand-alone diagnostics ONLY.
 * Destroys the context before returning — all annotation table pointers are
 * invalid after the call.  Do NOT use in the IR lowering pipeline.
 */
semantic_result_t semantic_run(TreeNode_t *root, const char *path);

const sem_node_info_t *semantic_get_node_info(const semantic_context_t *ctx,
                                              const TreeNode_t *node);
int semantic_set_node_info(semantic_context_t *ctx,
                           const TreeNode_t *node,
                           const sem_node_info_t *info);

void semantic_dump_annotations(FILE *out, const semantic_context_t *ctx);

#endif
