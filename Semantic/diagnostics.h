#ifndef SEMANTIC_DIAGNOSTICS_H
#define SEMANTIC_DIAGNOSTICS_H

#include <stddef.h>
#include <stdio.h>

typedef enum {
  DIAG_NOTE = 0,
  DIAG_WARNING,
  DIAG_ERROR
} diagnostic_severity_t;

typedef struct diagnostic_s diagnostic_t;

/// @brief Two-ended linked list holding diagnostics.
typedef struct {
  diagnostic_t *head;
  diagnostic_t *tail;
  size_t count;
  size_t warning_count;
  size_t error_count;
} diagnostic_list_t;

/// @brief Diagnostic node.
struct diagnostic_s {
  char code[16];
  char message[256];
  size_t line;
  size_t col;
  diagnostic_severity_t severity;
  diagnostic_t *next;
};

void diag_list_init(diagnostic_list_t *list);
void diag_list_destroy(diagnostic_list_t *list);

int diag_emit(diagnostic_list_t *list, const char *code, diagnostic_severity_t severity, size_t line, size_t col, const char *fmt, ...);

void diag_print_all(FILE *out, const diagnostic_list_t *list, const char *path);

size_t diag_error_count(const diagnostic_list_t *list);
size_t diag_warning_count(const diagnostic_list_t *list);

#endif
