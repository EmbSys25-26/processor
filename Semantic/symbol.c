#include <errno.h>
#include <stdio.h>
#include <stdint.h> 
#include <stdlib.h>
#include <string.h>

#include "symbol.h"

/// @brief 32-bit FNV-1a hash modulo bucket count 
/// @param name symbol name to hash 
/// @return returns the resulting hash value
static size_t hash_name(const char *name)
{
    uint32_t hash = 2166136261u;

    if (!name) {
        return 0u;
    }

    while (*name) {
        hash ^= (unsigned char)*name;
        hash *= 16777619u;
        ++name;
    }

    return (size_t)(hash % SCOPE_BUCKET_COUNT);
}

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

static const char *symbol_kind_to_string(symbol_kind_t kind)
{
  switch (kind) {
    case SYMBOL_OBJECT:
      return "object";
    case SYMBOL_FUNCTION:
      return "function";
    case SYMBOL_PARAMETER:
      return "parameter";
    case SYMBOL_TAG_STRUCT:
      return "tag_struct";
    case SYMBOL_TAG_UNION:
      return "tag_union";
    case SYMBOL_TAG_ENUM:
      return "tag_enum";
    case SYMBOL_ENUM_CONST:
      return "enum_const";
    case SYMBOL_FIELD:
      return "field";
    default:
      return "unknown";
  }
}

static const char *storage_class_to_string(storage_class_t storage_class)
{
  switch (storage_class) {
    case STORAGE_AUTO:
      return "auto";
    case STORAGE_STATIC:
      return "static";
    case STORAGE_EXTERN:
      return "extern";
    case STORAGE_PARAMETER:
      return "parameter";
    default:
      return "unknown";
  }
}

/// @brief destroys a scope and all the local symbols within 
/// @param scope to be destroyed 
static void scope_destroy_node(scope_t *scope) 
{ 
  if (!scope) {
    return; 
  }

  for (size_t i = 0; i < SCOPE_BUCKET_COUNT; ++i) {
    symbol_t *sym = scope->buckets[i]; 
    while (sym) {
      symbol_t *next = sym->next; 
      symbol_free(sym); 
      sym = next; 
    }
  }

  free(scope); 
}

/// @brief inits the stack 
/// @param stack stack to init 
void scope_stack_init(scope_stack_t *stack)
{ 
  if (!stack) { 
    return; 
  }

  stack->current = NULL; 
  stack->next_scope_id = 0u;
}

/// @brief destroys all scopes in the stack 
/// @param stack to destroy all scopes and symbols within 
void scope_stack_destroy(scope_stack_t *stack)
{
  if (!stack) { 
    return; 
  }

  while (stack->current) {
    if (scope_pop(stack) < 0) {
      break; 
    }
  }
}

/// @brief pushes a scope to the stack 
/// @param stack to which we add the scope node
/// @return 0 on success, <0 on failure
int scope_push(scope_stack_t *stack)
{
  if (!stack) {
    return -EINVAL; 
  }

  scope_t *node = (scope_t *)calloc(1, sizeof(*node)); 
  if (!node) {
    return -ENOMEM; 
  }

  node->id = stack->next_scope_id++;
  node->parent = stack->current; 
  node->depth = node->parent ? (node->parent->depth + 1u) : 0u; 

  stack->current = node; 
  return 0; 
}

/// @brief pops an element from the stack
/// @param stack from which a node is popped
/// @return 0 on success, <0 on failure
int scope_pop(scope_stack_t *stack) 
{
  if (!stack || !stack->current) {
    return -EINVAL; 
  }

  scope_t *node = stack->current; 
  stack->current = node->parent; 
  scope_destroy_node(node);
  return 0; 
}

/// @brief Gets the top of the stack
/// @param stack 
/// @return returns the current scope on top of the stack 
scope_t *scope_current(scope_stack_t *stack)
{
  if (!stack) {
    return NULL; 
  }

  return stack->current;
}
/// @brief gets the depth of the scope
/// @param scope 
/// @return scope depth 
size_t scope_depth(const scope_t *scope)
{ 
  return scope ? scope->depth : 0u; 
}

/// @brief creates a new symbol 
/// @param name symbol name 
/// @param kind symbol kind 
/// @param type symbol type 
/// @param decl_line symbol declaration line 
/// @param decl_col symbol declaration column
/// @return new symbol
symbol_t *symbol_new(const char *name, symbol_kind_t kind, type_t *type, size_t decl_line, size_t decl_col)
{
  if (!name) {
    type_free(type); 
    return NULL; 
  }

  symbol_t *symbol = (symbol_t *)calloc(1, sizeof(*symbol)); 
  if (!symbol) { 
    type_free(type);
    return NULL; 
  }

  symbol->name = dup_cstr(name); 
  if (!symbol->name) {
    type_free(type); 
    free(symbol); 
    return NULL; 
  }

  symbol->kind = kind; 
  symbol->storage_class = STORAGE_AUTO; 
  symbol->type = type ? type : type_new_invalid(); 
  symbol->decl_line = decl_line; 
  symbol->decl_col = decl_col;
  if (!symbol->type) {
    free(symbol->name);
    free(symbol);
    return NULL;
  }
  return symbol; 
}

/// @brief frees symbol struct
/// @param symbol to free
void symbol_free(symbol_t *symbol)
{
  if (!symbol) {
    return; 
  }

  free(symbol->name); 
  type_free(symbol->type);
  free(symbol); 
}

/// @brief inserts a symbol in a scope
/// @param scope in which the symbol is declared
/// @param symbol to insert in the scope 
/// @return 0 on success, <0 if symbol is invalid or already exists
int symbol_insert(scope_t *scope, symbol_t *symbol)
{
  if (!scope || !symbol || !symbol->name) {
    return -EINVAL; 
  }
  if (symbol_lookup_current(scope, symbol->name)) {
    return -EEXIST; 
  }

  size_t bucket = hash_name(symbol->name); 
  symbol->next = scope->buckets[bucket]; 
  scope->buckets[bucket] = symbol; 
  symbol->decl_scope = scope; 
  symbol->scope_id = scope->id;
  symbol->scope_depth = scope->depth;

  return 0; 
}

/// @brief looks for symbol in scope
/// @param scope in which to look for the symbol
/// @param name of the symbol to search 
/// @return symbol if found, NULL otherwise
symbol_t *symbol_lookup_current(const scope_t *scope, const char *name)
{
  if (!scope || !name) {
    return NULL; 
  }

  size_t bucket = hash_name(name); 
  symbol_t *sym = scope->buckets[bucket]; 

  while (sym) {
    if (strcmp(sym->name, name) == 0) {
      return sym; 
    }
    sym = sym->next; 
  }

  return NULL; 
}

/// @brief determines if a symbol is visible in the current scope
/// @param scope in which to look for the symbol (will traverse the parent scopes)
/// @param name of the symbol to look for
/// @return symbol if found, NULL otherwise
symbol_t *symbol_lookup_visible(const scope_t *scope, const char *name)
{
  const scope_t *it = scope; 

  while (it) {
    symbol_t *sym = symbol_lookup_current(it, name); 
    if (sym) {
      return sym; 
    }
    it = it->parent; 
  }

  return NULL; 
}

void symbol_dump(FILE *out, const scope_t *scope)
{
  if (!out || !scope) {
    return;
  }

  if (scope->parent) {
    fprintf(out,
            "scope id=%zu depth=%zu parent_id=%zu\n",
            scope->id,
            scope->depth,
            scope->parent->id);
  } else {
    fprintf(out,
            "scope id=%zu depth=%zu parent_id=none\n",
            scope->id,
            scope->depth);
  }

  for (size_t i = 0; i < SCOPE_BUCKET_COUNT; ++i) {
    const symbol_t *sym = scope->buckets[i];
    while (sym) {
      fprintf(out,
              "bucket=%03zu name=%s kind=%s storage=%s quals=0x%X decl=%zu:%zu scope_id=%zu scope_depth=%zu\n",
              i,
              sym->name ? sym->name : "<null>",
              symbol_kind_to_string(sym->kind),
              storage_class_to_string(sym->storage_class),
              sym->qualifiers,
              sym->decl_line,
              sym->decl_col,
              sym->scope_id,
              sym->scope_depth);
      sym = sym->next;
    }
  }
}
