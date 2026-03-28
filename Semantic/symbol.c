#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "symbol.h"

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

static const char *symbol_kind_to_string(symbol_kind_t kind)
{
  switch (kind) {
    case SYMBOL_OBJECT: return "object";
    case SYMBOL_FUNCTION: return "function";
    case SYMBOL_PARAMETER: return "parameter";
    case SYMBOL_TAG_STRUCT: return "tag_struct";
    case SYMBOL_TAG_UNION: return "tag_union";
    case SYMBOL_TAG_ENUM: return "tag_enum";
    case SYMBOL_ENUM_CONST: return "enum_const";
    case SYMBOL_FIELD: return "field";
    default: return "unknown";
  }
}

static const char *storage_class_to_string(storage_class_t storage_class)
{
  switch (storage_class) {
    case STORAGE_AUTO: return "auto";
    case STORAGE_STATIC: return "static";
    case STORAGE_EXTERN: return "extern";
    case STORAGE_PARAMETER: return "parameter";
    default: return "unknown";
  }
}

void scope_stack_init(scope_stack_t *stack, sem_arena_t *arena)
{
  if (!stack) {
    return;
  }

  stack->current = NULL;
  stack->next_scope_id = 0u;
  stack->arena = arena;
}

void scope_stack_destroy(scope_stack_t *stack)
{
  if (!stack) {
    return;
  }

  stack->current = NULL;
  stack->next_scope_id = 0u;
  stack->arena = NULL;
}

int scope_push(scope_stack_t *stack)
{
  scope_t *node;

  if (!stack || !stack->arena) {
    return -EINVAL;
  }

  node = SEM_ARENA_NEW(stack->arena, scope_t);
  if (!node) {
    return -ENOMEM;
  }

  (void)memset(node, 0, sizeof(*node));
  node->id = stack->next_scope_id++;
  node->parent = stack->current;
  node->depth = node->parent ? (node->parent->depth + 1u) : 0u;
  stack->current = node;
  return 0;
}

int scope_pop(scope_stack_t *stack)
{
  if (!stack || !stack->current) {
    return -EINVAL;
  }

  stack->current = stack->current->parent;
  return 0;
}

scope_t *scope_current(scope_stack_t *stack)
{
  if (!stack) {
    return NULL;
  }

  return stack->current;
}

size_t scope_depth(const scope_t *scope)
{
  return scope ? scope->depth : 0u;
}

symbol_t *symbol_new(sem_arena_t *arena,
                     const char *name,
                     symbol_kind_t kind,
                     const type_t *type,
                     size_t decl_line,
                     size_t decl_col)
{
  symbol_t *symbol;

  if (!arena || !name) {
    return NULL;
  }

  symbol = SEM_ARENA_NEW(arena, symbol_t);
  if (!symbol) {
    return NULL;
  }
  (void)memset(symbol, 0, sizeof(*symbol));

  symbol->name = sem_arena_strdup(arena, name);
  if (!symbol->name) {
    return NULL;
  }

  symbol->kind = kind;
  symbol->storage_class = STORAGE_AUTO;
  symbol->memory_class = MEMORY_CLASS_NONE;
  symbol->type = type;
  symbol->decl_line = decl_line;
  symbol->decl_col = decl_col;
  return symbol;
}

void symbol_free(symbol_t *symbol)
{
  (void)symbol;
}

int symbol_insert(scope_t *scope, symbol_t *symbol)
{
  size_t bucket;

  if (!scope || !symbol || !symbol->name) {
    return -EINVAL;
  }
  if (symbol_lookup_current(scope, symbol->name)) {
    return -EEXIST;
  }

  bucket = hash_name(symbol->name);
  symbol->next = scope->buckets[bucket];
  scope->buckets[bucket] = symbol;
  symbol->decl_scope = scope;
  symbol->scope_id = scope->id;
  symbol->scope_depth = scope->depth;
  return 0;
}

symbol_t *symbol_lookup_current(const scope_t *scope, const char *name)
{
  size_t bucket;
  symbol_t *sym;

  if (!scope || !name) {
    return NULL;
  }

  bucket = hash_name(name);
  sym = scope->buckets[bucket];
  while (sym) {
    if (strcmp(sym->name, name) == 0) {
      return sym;
    }
    sym = sym->next;
  }

  return NULL;
}

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
  size_t i;

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

  for (i = 0u; i < SCOPE_BUCKET_COUNT; ++i) {
    symbol_t *sym = scope->buckets[i];
    while (sym) {
      fprintf(out,
              "  bucket=%zu name=%s kind=%s storage=%s line=%zu col=%zu scope_id=%zu depth=%zu\n",
              i,
              sym->name,
              symbol_kind_to_string(sym->kind),
              storage_class_to_string(sym->storage_class),
              sym->decl_line,
              sym->decl_col,
              sym->scope_id,
              sym->scope_depth);
      sym = sym->next;
    }
  }
}
