#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "diagnostics.h"

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
  diagnostic_list_t list;
  FILE *fp;
  char out[1024];

  diag_list_init(&list);
  CHECK(list.head == NULL && list.tail == NULL, "init list pointers");
  CHECK(list.count == 0u, "init count");

  CHECK(diag_emit(NULL, "SEM001", DIAG_ERROR, 1u, 1u, "bad") == -EINVAL,
        "diag_emit rejects null list");

  CHECK(diag_emit(&list, "SEMN001", DIAG_NOTE, 1u, 1u, "note %d", 1) == 0,
        "emit note");
  CHECK(diag_emit(&list, "SEMW001", DIAG_WARNING, 11u, 2u, "warn %s", "x") == 0,
        "emit warning");
  CHECK(diag_emit(&list, "SEM001", DIAG_ERROR, 20u, 9u, "error %s", "y") == 0,
        "emit error");
  CHECK(diag_emit(&list, NULL, DIAG_ERROR, 30u, 3u, NULL) == 0,
        "emit default code/message");

  CHECK(list.count == 4u, "count increments");
  CHECK(diag_warning_count(&list) == 1u, "warning count");
  CHECK(diag_error_count(&list) == 2u, "error count");

  fp = tmpfile();
  CHECK(fp != NULL, "tmpfile");

  diag_print_all(fp, &list, "unit.c");
  CHECK(read_all(fp, out, sizeof(out)) == 0, "read output");
  CHECK(strstr(out, "unit.c:11:2: warning: SEMW001: warn x") != NULL,
        "formatted warning line");
  CHECK(strstr(out, "unit.c:20:9: error: SEM001: error y") != NULL,
        "formatted error line");
  CHECK(strstr(out, "unit.c:30:3: error: SEM000: diagnostic") != NULL,
        "default code and message");

  fclose(fp);
  diag_list_destroy(&list);
  CHECK(list.head == NULL && list.tail == NULL, "destroy clears pointers");
  CHECK(list.count == 0u && list.warning_count == 0u && list.error_count == 0u,
        "destroy clears counters");

  printf("PASS test_diagnostics_api\n");
  return 0;
}
