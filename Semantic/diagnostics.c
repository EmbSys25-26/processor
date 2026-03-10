#include <errno.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "diagnostics.h"

static const char *diag_severity_to_string(diagnostic_severity_t severity)
{
  switch (severity) {
    case DIAG_NOTE:
      return "note";
    case DIAG_WARNING:
      return "warning";
    case DIAG_ERROR:
      return "error";
    default:
      return "unknown";
  }
}

void diag_list_init(diagnostic_list_t *list)
{
  if (!list) {
    return;
  }

  memset(list, 0, sizeof(*list));
}

void diag_list_destroy(diagnostic_list_t *list)
{
  diagnostic_t *it;

  if (!list) {
    return;
  }

  it = list->head;
  while (it) {
    diagnostic_t *next = it->next;
    free(it);
    it = next;
  }

  memset(list, 0, sizeof(*list));
}

int diag_emit(diagnostic_list_t *list,
              const char *code,
              diagnostic_severity_t severity,
              size_t line,
              size_t col,
              const char *fmt,
              ...)
{
  diagnostic_t *diag;
  va_list args;

  if (!list) {
    errno = EINVAL;
    return -EINVAL;
  }

  diag = (diagnostic_t *)calloc(1, sizeof(*diag));
  if (!diag) {
    errno = ENOMEM;
    return -ENOMEM;
  }

  snprintf(diag->code, sizeof(diag->code), "%s", (code && code[0] != '\0') ? code : "SEM000");
  diag->line = line;
  diag->col = col;
  diag->severity = severity;

  if (fmt && fmt[0] != '\0') {
    va_start(args, fmt);
    (void)vsnprintf(diag->message, sizeof(diag->message), fmt, args);
    va_end(args);
  } else {
    snprintf(diag->message, sizeof(diag->message), "%s", "diagnostic");
  }

  if (!list->head) {
    list->head = diag;
    list->tail = diag;
  } else {
    list->tail->next = diag;
    list->tail = diag;
  }

  list->count++;
  if (severity == DIAG_ERROR) {
    list->error_count++;
  } else if (severity == DIAG_WARNING) {
    list->warning_count++;
  }

  return 0;
}

void diag_print_all(FILE *out, const diagnostic_list_t *list, const char *path)
{
  const diagnostic_t *it;

  if (!out || !list) {
    return;
  }

  it = list->head;
  while (it) {
    if (path && path[0] != '\0') {
      fprintf(out,
              "%s:%zu:%zu: %s: %s: %s\n",
              path,
              it->line,
              it->col,
              diag_severity_to_string(it->severity),
              it->code,
              it->message);
    } else {
      fprintf(out,
              "%zu:%zu: %s: %s: %s\n",
              it->line,
              it->col,
              diag_severity_to_string(it->severity),
              it->code,
              it->message);
    }

    it = it->next;
  }
}

size_t diag_error_count(const diagnostic_list_t *list)
{
  return list ? list->error_count : 0u;
}

size_t diag_warning_count(const diagnostic_list_t *list)
{
  return list ? list->warning_count : 0u;
}
