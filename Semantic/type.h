#ifndef SEMANTIC_TYPE_H
#define SEMANTIC_TYPE_H

#include <stddef.h>

/*
What we require from types:
- Type descriptors.
- AST nodes can attach a type descriptor.
- Type comparison mechanisms for expression correctness checks.
*/

/// @brief Semantic type categories used by the frontend.
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

/// @brief Builtin scalar families supported.
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

/// @brief Type qualifier flags.
enum {
  TYPE_QUAL_CONST = (1u << 0),
  TYPE_QUAL_VOLATILE = (1u << 1),
  TYPE_QUAL_SIGNED = (1u << 2),
  TYPE_QUAL_UNSIGNED = (1u << 3)
};

/// @brief Type struct.
/// @note `kind` says which variant is active, `as` says what to interpret as.
typedef struct type_s type_t;

struct type_s {
  type_kind_t kind;
  unsigned qualifiers;
  union {
    builtin_type_t builtin;
    struct {
      type_t *base;
    } pointer;
    struct {
      type_t *elem;
      size_t size;
      int is_known_size;
    } array;
    struct {
      type_t *return_type;
      type_t **params;
      size_t param_count;
      int is_variadic;
    } function;
    struct {
      char *tag;
    } aggregate;
  } as;
};

type_t *type_new_invalid(void);
type_t *type_new_builtin(builtin_type_t builtin, unsigned qualifiers);
type_t *type_new_pointer(type_t *base, unsigned qualifiers);
type_t *type_new_array(type_t *elem, size_t size, int is_known_size, unsigned qualifiers);
type_t *type_new_function(type_t *return_type, type_t **params, size_t param_count, int is_variadic, unsigned qualifiers);
type_t *type_new_tagged(type_kind_t kind, const char *tag, unsigned qualifiers);

type_t *type_clone(const type_t *src);
void type_free(type_t *type);

int type_equal(const type_t *lhs, const type_t *rhs);
int type_is_integral(const type_t *type);

#endif
