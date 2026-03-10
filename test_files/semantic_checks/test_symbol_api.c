#include <errno.h>
#include <stdio.h>
#include <string.h>

#include "symbol.h"
#include "type.h"

#define CHECK(cond, msg)                                                        \
  do {                                                                          \
    if (!(cond)) {                                                              \
      fprintf(stderr, "FAIL: %s\n", (msg));                                     \
      return 1;                                                                 \
    }                                                                           \
  } while (0)

static int read_all(FILE *fp, char *buf, size_t cap)
{
  size_t n;

  if (!fp || !buf || cap == 0u) {
    return -1;
  }

  if (fflush(fp) != 0) {
    return -1;
  }
  if (fseek(fp, 0L, SEEK_SET) != 0) {
    return -1;
  }

  n = fread(buf, 1u, cap - 1u, fp);
  buf[n] = '\0';
  return 0;
}

int main(void)
{
  scope_stack_t stack;
  scope_t *global_scope;
  scope_t *inner_scope;
  symbol_t *outer;
  symbol_t *duplicate;
  symbol_t *shadow;
  symbol_t *invalid;
  FILE *fp;
  char dump[2048];

  scope_stack_init(&stack);
  CHECK(scope_current(&stack) == NULL, "stack starts empty");

  CHECK(scope_push(&stack) == 0, "push global scope");
  global_scope = scope_current(&stack);
  CHECK(global_scope != NULL, "global scope exists");
  CHECK(global_scope->id == 0u, "global scope id");
  CHECK(scope_depth(global_scope) == 0u, "global scope depth");

  outer = symbol_new("x", SYMBOL_OBJECT, type_new_builtin(BUILTIN_INT, 0u), 10u, 4u);
  CHECK(outer != NULL, "create outer symbol");
  CHECK(symbol_insert(global_scope, outer) == 0, "insert outer symbol");
  CHECK(outer->decl_scope == global_scope, "decl_scope set");
  CHECK(outer->scope_id == global_scope->id, "scope_id set");
  CHECK(outer->scope_depth == global_scope->depth, "scope_depth set");
  CHECK(symbol_lookup_current(global_scope, "x") == outer, "lookup current finds outer");
  CHECK(symbol_lookup_visible(global_scope, "x") == outer, "lookup visible finds outer");

  fp = tmpfile();
  CHECK(fp != NULL, "tmpfile for symbol dump");
  symbol_dump(fp, global_scope);
  CHECK(read_all(fp, dump, sizeof(dump)) == 0, "read symbol dump");
  CHECK(strstr(dump, "scope id=0 depth=0 parent_id=none") != NULL, "scope header in dump");
  CHECK(strstr(dump, "name=x kind=object storage=auto") != NULL, "symbol row in dump");
  symbol_dump(NULL, global_scope);
  symbol_dump(fp, NULL);
  fclose(fp);

  duplicate = symbol_new("x", SYMBOL_OBJECT, type_new_builtin(BUILTIN_INT, 0u), 11u, 1u);
  CHECK(duplicate != NULL, "create duplicate symbol");
  CHECK(symbol_insert(global_scope, duplicate) == -EEXIST, "duplicate rejected");
  symbol_free(duplicate);

  CHECK(scope_push(&stack) == 0, "push inner scope");
  inner_scope = scope_current(&stack);
  CHECK(inner_scope != NULL, "inner scope exists");
  CHECK(inner_scope->id == 1u, "inner scope id");
  CHECK(scope_depth(inner_scope) == 1u, "inner scope depth");
  CHECK(symbol_lookup_current(inner_scope, "x") == NULL, "current scope does not see outer directly");
  CHECK(symbol_lookup_visible(inner_scope, "x") == outer, "visible lookup reaches parent scope");

  shadow = symbol_new("x", SYMBOL_OBJECT, type_new_builtin(BUILTIN_SHORT, 0u), 20u, 2u);
  CHECK(shadow != NULL, "create shadow symbol");
  CHECK(symbol_insert(inner_scope, shadow) == 0, "insert shadow symbol");
  CHECK(symbol_lookup_current(inner_scope, "x") == shadow, "current lookup sees shadow");
  CHECK(symbol_lookup_visible(inner_scope, "x") == shadow, "visible lookup prefers nearest scope");
  CHECK(shadow->scope_id == inner_scope->id, "shadow scope id");
  CHECK(shadow->scope_depth == inner_scope->depth, "shadow scope depth");

  CHECK(scope_pop(&stack) == 0, "pop inner scope");
  CHECK(scope_current(&stack) == global_scope, "back to global scope");
  CHECK(symbol_lookup_visible(global_scope, "x") == outer, "outer symbol still visible");
  CHECK(scope_pop(&stack) == 0, "pop global scope");
  CHECK(scope_current(&stack) == NULL, "stack empty after pops");
  CHECK(scope_pop(&stack) == -EINVAL, "pop empty stack fails");

  invalid = symbol_new("invalid", SYMBOL_OBJECT, type_new_builtin(BUILTIN_INT, 0u), 1u, 1u);
  CHECK(invalid != NULL, "create standalone symbol");
  CHECK(symbol_insert(NULL, invalid) == -EINVAL, "insert with null scope rejected");
  symbol_free(invalid);

  CHECK(symbol_new(NULL, SYMBOL_OBJECT, type_new_builtin(BUILTIN_INT, 0u), 1u, 0u) == NULL,
        "null name symbol rejected");

  scope_stack_destroy(&stack);
  printf("PASS test_symbol_api\n");
  return 0;
}
