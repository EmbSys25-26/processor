#include "Semantic/type.h"
#include "Semantic/symbol.h"
#include "Semantic/diagnostics.h"
#include "Semantic/semantic.h"

/* Compile-time smoke only: verifies API surface and typedef consistency. */
int main(void)
{
  type_t *t = (type_t *)0;
  symbol_t *s = (symbol_t *)0;
  scope_t *sc = (scope_t *)0;
  scope_stack_t st = {0};
  diagnostic_list_t dl = {0};
  semantic_result_t sr = {0};

  (void)t;
  (void)s;
  (void)sc;
  (void)st;
  (void)dl;
  (void)sr;
  return 0;
}
