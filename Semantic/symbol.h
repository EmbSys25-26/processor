#ifndef SEMANTIC_SYMBOL_H
#define SEMANTIC_SYMBOL_H

#include <stddef.h>
#include <stdio.h>

#include "type.h"

#define SCOPE_BUCKET_COUNT 127u // prime no. decreases collision per insertion ratio 

/// @brief Symbol kinds to emit.
typedef enum {
  SYMBOL_OBJECT = 0,
  SYMBOL_FUNCTION,
  SYMBOL_PARAMETER,
  SYMBOL_TAG_STRUCT,
  SYMBOL_TAG_UNION,
  SYMBOL_TAG_ENUM,
  SYMBOL_ENUM_CONST,
  SYMBOL_FIELD
} symbol_kind_t;

/// @brief Symbol storage metadata.
typedef enum {
  STORAGE_AUTO = 0,
  STORAGE_STATIC,
  STORAGE_EXTERN,
  STORAGE_PARAMETER
} storage_class_t;

/// @brief Backend-oriented storage location classification.
typedef enum {
  MEMORY_CLASS_NONE = 0,
  MEMORY_CLASS_GLOBAL,
  MEMORY_CLASS_STACK,
  MEMORY_CLASS_PARAMETER
} memory_class_t;

typedef struct symbol_s symbol_t;
typedef struct scope_s scope_t;

/// @brief Manages the lexical scope stack.
typedef struct {
  scope_t *current;
  size_t next_scope_id;
} scope_stack_t;

/// @brief Symbol table entry.
/// @note Function-specific metadata parameters (arity/is_defined) are meaningful for analysing SYMBOL_FUNCTION.
struct symbol_s {
  char *name;  // set at declaration. used for lookups 
  symbol_kind_t kind; // symbol kind 
  storage_class_t storage_class; // set from specifiers in declaration  
  unsigned qualifiers; // set from specifiers in declaration 
  type_t *type; // type descriptor for type checks 

  size_t decl_line; // source line of capture
  size_t decl_col;  // source column of capture

  size_t scope_id; // scope identifier for traceability
  size_t scope_depth;  // current nesting level. use to check for redeclaration or shadowing 
  scope_t *decl_scope; // owner scope pointer

  size_t arity; // counts the no. of params in SYMBOL_FUNCTION
  int is_defined; // set when function has been defined (as opposed to declared)
  symbol_t* next; // next symbol in the same bucket entry 
};

/// @brief Scope container.
struct scope_s {
  size_t id;
  size_t depth;
  scope_t *parent;
  symbol_t *buckets[SCOPE_BUCKET_COUNT];
};

void scope_stack_init(scope_stack_t *stack);
void scope_stack_destroy(scope_stack_t *stack);

int scope_push(scope_stack_t *stack);
int scope_pop(scope_stack_t *stack);

scope_t *scope_current(scope_stack_t *stack);
size_t scope_depth(const scope_t *scope);

symbol_t *symbol_new(const char *name, symbol_kind_t kind, type_t *type, size_t decl_line, size_t decl_col);
void symbol_free(symbol_t *symbol);

int symbol_insert(scope_t *scope, symbol_t *symbol);
symbol_t *symbol_lookup_current(const scope_t *scope, const char *name);
symbol_t *symbol_lookup_visible(const scope_t *scope, const char *name);
void symbol_dump(FILE *out, const scope_t *scope);

#endif
