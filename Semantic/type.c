#include <errno.h>
#include <string.h>

#include "type.h"

static type_t *type_alloc(type_context_t *tcx, type_kind_t kind, unsigned qualifiers)
{
  type_t *type;

  if (!tcx || !tcx->arena) {
    errno = EINVAL;
    return NULL;
  }

  type = SEM_ARENA_NEW(tcx->arena, type_t);
  if (!type) {
    return NULL;
  }

  (void)memset(type, 0, sizeof(*type));
  type->kind = kind;
  type->qualifiers = qualifiers;
  return type;
}

void type_context_init(type_context_t *tcx, sem_arena_t *arena)
{
  if (!tcx) {
    return;
  }

  tcx->arena = arena;
}

const type_t *type_new_invalid(type_context_t *tcx)
{
  return type_alloc(tcx, TYPE_INVALID, 0u);
}

const type_t *type_new_builtin(type_context_t *tcx, builtin_type_t builtin, unsigned qualifiers)
{
  type_t *type = type_alloc(tcx, TYPE_BUILTIN, qualifiers);
  if (!type) {
    return NULL;
  }

  type->as.builtin = builtin;
  return type;
}

const type_t *type_new_pointer(type_context_t *tcx, const type_t *base, unsigned qualifiers)
{
  type_t *type = type_alloc(tcx, TYPE_POINTER, qualifiers);
  if (!type) {
    return NULL;
  }

  type->as.pointer.base = base;
  return type;
}

const type_t *type_new_array(type_context_t *tcx,
                             const type_t *elem,
                             size_t size,
                             int is_known_size,
                             unsigned qualifiers)
{
  type_t *type = type_alloc(tcx, TYPE_ARRAY, qualifiers);
  if (!type) {
    return NULL;
  }

  type->as.array.elem = elem;
  type->as.array.size = size;
  type->as.array.is_known_size = is_known_size;
  return type;
}

const type_t *type_new_function(type_context_t *tcx,
                                const type_t *return_type,
                                const type_t *const *params,
                                size_t param_count,
                                int is_variadic,
                                unsigned qualifiers)
{
  type_t *type = type_alloc(tcx, TYPE_FUNCTION, qualifiers);
  const type_t **param_copy = NULL;

  if (!type) {
    return NULL;
  }

  if (param_count > 0u) {
    param_copy = SEM_ARENA_NEW_ARRAY(tcx->arena, const type_t *, param_count);
    if (!param_copy) {
      return NULL;
    }
    (void)memcpy(param_copy, params, param_count * sizeof(*param_copy));
  }

  type->as.function.return_type = return_type;
  type->as.function.params = param_copy;
  type->as.function.param_count = param_count;
  type->as.function.is_variadic = is_variadic;
  return type;
}

const type_t *type_new_tagged(type_context_t *tcx, type_kind_t kind, const char *tag, unsigned qualifiers)
{
  type_t *type;

  if (kind != TYPE_STRUCT_TAG && kind != TYPE_UNION_TAG && kind != TYPE_ENUM_TAG) {
    errno = EINVAL;
    return NULL;
  }

  type = type_alloc(tcx, kind, qualifiers);
  if (!type) {
    return NULL;
  }

  if (tag) {
    type->as.aggregate.tag = sem_arena_strdup(tcx->arena, tag);
    if (!type->as.aggregate.tag) {
      return NULL;
    }
  }

  return type;
}

void type_set_aggregate_decl(const type_t *type, const void *decl_node)
{
  type_t *mutable_type = (type_t *)type;

  if (!mutable_type) {
    return;
  }

  if (mutable_type->kind == TYPE_STRUCT_TAG ||
      mutable_type->kind == TYPE_UNION_TAG ||
      mutable_type->kind == TYPE_ENUM_TAG) {
    mutable_type->as.aggregate.decl_node = decl_node;
  }
}

const type_t *type_clone(type_context_t *tcx, const type_t *src)
{
  const type_t **params = NULL;
  size_t i;

  if (!src) {
    return NULL;
  }

  switch (src->kind) {
    case TYPE_INVALID:
      return type_new_invalid(tcx);
    case TYPE_BUILTIN:
      return type_new_builtin(tcx, src->as.builtin, src->qualifiers);
    case TYPE_POINTER: {
      const type_t *base = type_clone(tcx, src->as.pointer.base);
      if (!base) {
        return NULL;
      }
      return type_new_pointer(tcx, base, src->qualifiers);
    }
    case TYPE_ARRAY: {
      const type_t *elem = type_clone(tcx, src->as.array.elem);
      if (!elem) {
        return NULL;
      }
      return type_new_array(tcx, elem, src->as.array.size, src->as.array.is_known_size, src->qualifiers);
    }
    case TYPE_FUNCTION:
      if (src->as.function.param_count > 0u) {
        params = SEM_ARENA_NEW_ARRAY(tcx->arena, const type_t *, src->as.function.param_count);
        if (!params) {
          return NULL;
        }
        for (i = 0u; i < src->as.function.param_count; ++i) {
          params[i] = type_clone(tcx, src->as.function.params[i]);
          if (!params[i]) {
            return NULL;
          }
        }
      }
      return type_new_function(tcx,
                               type_clone(tcx, src->as.function.return_type),
                               params,
                               src->as.function.param_count,
                               src->as.function.is_variadic,
                               src->qualifiers);
    case TYPE_STRUCT_TAG:
    case TYPE_UNION_TAG:
    case TYPE_ENUM_TAG: {
      const type_t *dst = type_new_tagged(tcx, src->kind, src->as.aggregate.tag, src->qualifiers);
      if (!dst) {
        return NULL;
      }
      type_set_aggregate_decl(dst, src->as.aggregate.decl_node);
      return dst;
    }
    default:
      errno = EINVAL;
      return NULL;
  }
}

/* Types are arena-owned. This function is intentionally a no-op.
   It exists for call-site symmetry; memory is freed via sem_arena_destroy(). */
void type_free(const type_t *type)
{
  (void)type;
}

int type_equal(const type_t *lhs, const type_t *rhs)
{
  size_t i;

  if (lhs == rhs) {
    return 1;
  }

  if (!lhs || !rhs) {
    return 0;
  }

  if (lhs->kind != rhs->kind || lhs->qualifiers != rhs->qualifiers) {
    return 0;
  }

  switch (lhs->kind) {
    case TYPE_INVALID:
      return 1;
    case TYPE_BUILTIN:
      return lhs->as.builtin == rhs->as.builtin;
    case TYPE_POINTER:
      return type_equal(lhs->as.pointer.base, rhs->as.pointer.base);
    case TYPE_ARRAY:
      return lhs->as.array.size == rhs->as.array.size &&
             lhs->as.array.is_known_size == rhs->as.array.is_known_size &&
             type_equal(lhs->as.array.elem, rhs->as.array.elem);
    case TYPE_FUNCTION:
      if (lhs->as.function.param_count != rhs->as.function.param_count ||
          lhs->as.function.is_variadic != rhs->as.function.is_variadic ||
          !type_equal(lhs->as.function.return_type, rhs->as.function.return_type)) {
        return 0;
      }
      for (i = 0u; i < lhs->as.function.param_count; ++i) {
        if (!type_equal(lhs->as.function.params[i], rhs->as.function.params[i])) {
          return 0;
        }
      }
      return 1;
    case TYPE_STRUCT_TAG:
    case TYPE_UNION_TAG:
    case TYPE_ENUM_TAG:
      if (lhs->as.aggregate.decl_node && rhs->as.aggregate.decl_node) {
        return lhs->as.aggregate.decl_node == rhs->as.aggregate.decl_node;
      }
      if (!lhs->as.aggregate.tag || !rhs->as.aggregate.tag) {
        return lhs->as.aggregate.tag == rhs->as.aggregate.tag;
      }
      return strcmp(lhs->as.aggregate.tag, rhs->as.aggregate.tag) == 0;
    default:
      return 0;
  }
}

int type_is_integral(const type_t *type)
{
  if (!type) {
    return 0;
  }

  if (type->kind == TYPE_ENUM_TAG) {
    return 1;
  }

  return type->kind == TYPE_BUILTIN &&
         (type->as.builtin == BUILTIN_CHAR ||
          type->as.builtin == BUILTIN_SHORT ||
          type->as.builtin == BUILTIN_INT ||
          type->as.builtin == BUILTIN_LONG);
}
