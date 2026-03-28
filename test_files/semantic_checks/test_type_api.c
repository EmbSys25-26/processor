#include <stdio.h>

#include "arena.h"
#include "type.h"

#define CHECK(cond, msg) \
  do { \
    if (!(cond)) { \
      fprintf(stderr, "FAIL: %s\n", (msg)); \
      return 1; \
    } \
  } while (0)

int main(void)
{
  sem_arena_t arena;
  type_context_t tcx;
  const type_t *i16;
  const type_t *flt;
  const type_t *ptr_i16;
  const type_t *arr_i16;
  const type_t *enum_tag;
  const type_t *params[2];
  const type_t *fn;
  const type_t *fn_clone;

  CHECK(sem_arena_init(&arena, 4096u) == 0, "arena init");
  type_context_init(&tcx, &arena);

  i16 = type_new_builtin(&tcx, BUILTIN_INT, 0u);
  flt = type_new_builtin(&tcx, BUILTIN_FLOAT, 0u);
  ptr_i16 = type_new_pointer(&tcx, i16, 0u);
  arr_i16 = type_new_array(&tcx, i16, 8u, 1, 0u);
  enum_tag = type_new_tagged(&tcx, TYPE_ENUM_TAG, "Color", 0u);

  CHECK(i16 != NULL, "type_new_builtin int");
  CHECK(flt != NULL, "type_new_builtin float");
  CHECK(ptr_i16 != NULL, "type_new_pointer");
  CHECK(arr_i16 != NULL, "type_new_array");
  CHECK(enum_tag != NULL, "type_new_tagged enum");

  params[0] = i16;
  params[1] = type_new_pointer(&tcx, i16, 0u);
  CHECK(params[1] != NULL, "param type creation");

  fn = type_new_function(&tcx, i16, params, 2u, 0, 0u);
  CHECK(fn != NULL, "type_new_function");

  fn_clone = type_clone(&tcx, fn);
  CHECK(fn_clone != NULL, "type_clone function");

  CHECK(type_equal(fn, fn_clone), "type_equal clone");
  CHECK(type_is_integral(i16), "int is integral");
  CHECK(!type_is_integral(flt), "float is not integral");
  CHECK(type_is_integral(enum_tag), "enum tag is integral");

  sem_arena_destroy(&arena);
  printf("PASS test_type_api\n");
  return 0;
}
