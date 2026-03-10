#include <stdio.h>
#include <stdlib.h>

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
  type_t *i16 = type_new_builtin(BUILTIN_INT, 0u);
  type_t *flt = type_new_builtin(BUILTIN_FLOAT, 0u);
  type_t *ptr_i16 = type_new_pointer(type_clone(i16), 0u);
  type_t *arr_i16 = type_new_array(type_clone(i16), 8u, 1, 0u);
  type_t *enum_tag = type_new_tagged(TYPE_ENUM_TAG, "Color", 0u);

  type_t **params = (type_t **)calloc(2u, sizeof(*params));
  type_t *fn = NULL;
  type_t *fn_clone = NULL;

  CHECK(i16 != NULL, "type_new_builtin int");
  CHECK(flt != NULL, "type_new_builtin float");
  CHECK(ptr_i16 != NULL, "type_new_pointer");
  CHECK(arr_i16 != NULL, "type_new_array");
  CHECK(enum_tag != NULL, "type_new_tagged enum");

  CHECK(params != NULL, "params alloc");
  params[0] = type_clone(i16);
  params[1] = type_new_pointer(type_clone(i16), 0u);
  CHECK(params[0] != NULL && params[1] != NULL, "param type creation");

  fn = type_new_function(type_clone(i16), params, 2u, 0, 0u);
  CHECK(fn != NULL, "type_new_function");

  fn_clone = type_clone(fn);
  CHECK(fn_clone != NULL, "type_clone function");

  CHECK(type_equal(fn, fn_clone), "type_equal clone");
  CHECK(type_is_integral(i16), "int is integral");
  CHECK(!type_is_integral(flt), "float is not integral");
  CHECK(type_is_integral(enum_tag), "enum tag is integral");

  type_free(fn_clone);
  type_free(fn);
  type_free(enum_tag);
  type_free(arr_i16);
  type_free(ptr_i16);
  type_free(flt);
  type_free(i16);

  printf("PASS test_type_api\n");
  return 0;
}
