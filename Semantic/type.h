#ifndef SEMANTIC_TYPE_H
#define SEMANTIC_TYPE_H

#include <stddef.h>

#include "arena.h"

/*
What we require from types:
- Type descriptors.
- AST nodes can attach a type descriptor.
- Type comparison mechanisms for expression correctness checks.
*/

typedef enum {
  TYPE_INVALID = 0,
  TYPE_BUILTIN,
  TYPE_POINTER,
  TYPE_ARRAY,
  TYPE_FUNCTION,
  TYPE_STRUCT_TAG,
  TYPE_UNION_TAG,
  TYPE_ENUM_TAG
} type_kind_t;

typedef enum {
  BUILTIN_CHAR = 0,
  BUILTIN_SHORT,
  BUILTIN_INT,
  BUILTIN_LONG,
  BUILTIN_FLOAT,
  BUILTIN_DOUBLE,
  BUILTIN_LONG_DOUBLE,
  BUILTIN_STRING,
  BUILTIN_VOID
} builtin_type_t;

enum {
  TYPE_QUAL_CONST = (1u << 0),
  TYPE_QUAL_VOLATILE = (1u << 1),
  TYPE_QUAL_SIGNED = (1u << 2),
  TYPE_QUAL_UNSIGNED = (1u << 3)
};

typedef struct type_s type_t;

typedef struct type_context {
  sem_arena_t *arena;
} type_context_t;

struct type_s {
  type_kind_t kind;
  unsigned qualifiers;
  union {
    builtin_type_t builtin;
    struct {
      const type_t *base;
    } pointer;
    struct {
      const type_t *elem;
      size_t size;
      int is_known_size;
    } array;
    struct {
      const type_t *return_type;
      const type_t **params;
      size_t param_count;
      int is_variadic;
    } function;
    struct {
      char *tag;
      const void *decl_node;
    } aggregate;
  } as;
};

void type_context_init(type_context_t *tcx, sem_arena_t *arena);

const type_t *type_new_invalid(type_context_t *tcx);
const type_t *type_new_builtin(type_context_t *tcx, builtin_type_t builtin, unsigned qualifiers);
const type_t *type_new_pointer(type_context_t *tcx, const type_t *base, unsigned qualifiers);
const type_t *type_new_array(type_context_t *tcx, const type_t *elem, size_t size, int is_known_size, unsigned qualifiers);
const type_t *type_new_function(type_context_t *tcx, const type_t *return_type, const type_t *const *params, size_t param_count, int is_variadic, unsigned qualifiers);
const type_t *type_new_tagged(type_context_t *tcx, type_kind_t kind, const char *tag, unsigned qualifiers);
void type_set_aggregate_decl(const type_t *type, const void *decl_node);

const type_t *type_clone(type_context_t *tcx, const type_t *src);
/* Types are arena-owned. This function is intentionally a no-op.
   memory is freed via sem_arena_destroy(). */
void type_free(const type_t *type);

int type_equal(const type_t *lhs, const type_t *rhs);
int type_is_integral(const type_t *type);

#endif
