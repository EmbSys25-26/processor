#include <errno.h>
#include <stdlib.h>
#include <string.h>

#include "type.h"

static char *dup_cstr(const char *src)
{
  size_t n;
  char *dst;

  if (!src) {
    return NULL;
  }

  n = strlen(src) + 1u;
  dst = (char *)malloc(n);
  if (!dst) {
    return NULL;
  }

  (void)memcpy(dst, src, n);
  return dst;
}

static type_t *type_alloc(type_kind_t kind, unsigned qualifiers)
{
  type_t *type = (type_t *)calloc(1, sizeof(*type));
  if (!type) {
    return NULL;
  }

  type->kind = kind;
  type->qualifiers = qualifiers;
  return type;
}

type_t *type_new_invalid(void)
{
  return type_alloc(TYPE_INVALID, 0u);
}

type_t *type_new_builtin(builtin_type_t builtin, unsigned qualifiers)
{
  type_t *type = type_alloc(TYPE_BUILTIN, qualifiers);
  if (!type) {
    return NULL;
  }

  type->as.builtin = builtin;
  return type;
}

type_t *type_new_pointer(type_t *base, unsigned qualifiers)
{
  type_t *type = type_alloc(TYPE_POINTER, qualifiers);
  if (!type) {
    type_free(base);
    return NULL;
  }

  type->as.pointer.base = base;
  return type;
}

type_t *type_new_array(type_t *elem, size_t size, int is_known_size, unsigned qualifiers)
{
  type_t *type = type_alloc(TYPE_ARRAY, qualifiers);
  if (!type) {
    type_free(elem);
    return NULL;
  }

  type->as.array.elem = elem;
  type->as.array.size = size;
  type->as.array.is_known_size = is_known_size;
  return type;
}

type_t *type_new_function(type_t *return_type,
                          type_t **params,
                          size_t param_count,
                          int is_variadic,
                          unsigned qualifiers)
{
  type_t *type = type_alloc(TYPE_FUNCTION, qualifiers);
  if (!type) {
    type_free(return_type);
    if (params) {
      for (size_t i = 0; i < param_count; ++i) {
        type_free(params[i]);
      }
      free(params);
    }
    return NULL;
  }

  type->as.function.return_type = return_type;
  type->as.function.params = params;
  type->as.function.param_count = param_count;
  type->as.function.is_variadic = is_variadic;
  return type;
}

type_t *type_new_tagged(type_kind_t kind, const char *tag, unsigned qualifiers)
{
  type_t *type;

  if (kind != TYPE_STRUCT_TAG && kind != TYPE_UNION_TAG && kind != TYPE_ENUM_TAG) {
    errno = EINVAL;
    return NULL;
  }

  type = type_alloc(kind, qualifiers);
  if (!type) {
    return NULL;
  }

  if (tag) {
    type->as.aggregate.tag = dup_cstr(tag);
    if (!type->as.aggregate.tag) {
      free(type);
      return NULL;
    }
  }

  return type;
}

type_t *type_clone(const type_t *src)
{
  type_t *dst = NULL;

  if (!src) {
    return NULL;
  }

  switch (src->kind) {
    case TYPE_INVALID:
      dst = type_new_invalid();
      break;
    case TYPE_BUILTIN:
      dst = type_new_builtin(src->as.builtin, src->qualifiers);
      break;
    case TYPE_POINTER:
      dst = type_new_pointer(type_clone(src->as.pointer.base), src->qualifiers);
      break;
    case TYPE_ARRAY:
      dst = type_new_array(
          type_clone(src->as.array.elem),
          src->as.array.size,
          src->as.array.is_known_size,
          src->qualifiers);
      break;
    case TYPE_FUNCTION: {
      type_t **params = NULL;
      type_t *ret_clone = NULL;
      size_t param_count = src->as.function.param_count;

      if (param_count > 0) {
        params = (type_t **)calloc(param_count, sizeof(*params));
        if (!params) {
          return NULL;
        }

        for (size_t i = 0; i < param_count; ++i) {
          params[i] = type_clone(src->as.function.params[i]);
          if (!params[i]) {
            for (size_t j = 0; j < i; ++j) {
              type_free(params[j]);
            }
            free(params);
            return NULL;
          }
        }
      }

      ret_clone = type_clone(src->as.function.return_type);
      if (!ret_clone) {
        if (params) {
          for (size_t i = 0; i < param_count; ++i) {
            type_free(params[i]);
          }
          free(params);
        }
        return NULL;
      }

      dst = type_new_function(
          ret_clone,
          params,
          param_count,
          src->as.function.is_variadic,
          src->qualifiers);
      break;
    }
    case TYPE_STRUCT_TAG:
    case TYPE_UNION_TAG:
    case TYPE_ENUM_TAG:
      dst = type_new_tagged(src->kind, src->as.aggregate.tag, src->qualifiers);
      break;
    default:
      errno = EINVAL;
      break;
  }

  return dst;
}

void type_free(type_t *type)
{
  if (!type) {
    return;
  }

  switch (type->kind) {
    case TYPE_POINTER:
      type_free(type->as.pointer.base);
      break;
    case TYPE_ARRAY:
      type_free(type->as.array.elem);
      break;
    case TYPE_FUNCTION:
      type_free(type->as.function.return_type);
      if (type->as.function.params) {
        for (size_t i = 0; i < type->as.function.param_count; ++i) {
          type_free(type->as.function.params[i]);
        }
        free(type->as.function.params);
      }
      break;
    case TYPE_STRUCT_TAG:
    case TYPE_UNION_TAG:
    case TYPE_ENUM_TAG:
      free(type->as.aggregate.tag);
      break;
    case TYPE_INVALID:
    case TYPE_BUILTIN:
    default:
      break;
  }

  free(type);
}

int type_equal(const type_t *lhs, const type_t *rhs)
{
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

      for (size_t i = 0; i < lhs->as.function.param_count; ++i) {
        if (!type_equal(lhs->as.function.params[i], rhs->as.function.params[i])) {
          return 0;
        }
      }
      return 1;
    case TYPE_STRUCT_TAG:
    case TYPE_UNION_TAG:
    case TYPE_ENUM_TAG:
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

  if (type->kind != TYPE_BUILTIN) {
    return 0;
  }

  switch (type->as.builtin) {
    case BUILTIN_CHAR:
    case BUILTIN_SHORT:
    case BUILTIN_INT:
    case BUILTIN_LONG:
      return 1;
    case BUILTIN_FLOAT:
    case BUILTIN_DOUBLE:
    case BUILTIN_LONG_DOUBLE:
    case BUILTIN_STRING:
    case BUILTIN_VOID:
    default:
      return 0;
  }
}
