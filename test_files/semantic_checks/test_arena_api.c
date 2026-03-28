#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "arena.h"

#define CHECK(cond, msg)                                                        \
  do {                                                                          \
    if (!(cond)) {                                                              \
      fprintf(stderr, "FAIL: %s\n", (msg));                                     \
      return 1;                                                                 \
    }                                                                           \
  } while (0)

int main(void)
{
  sem_arena_t arena;
  char *s1;
  char *s2;
  void *p1;
  void *p2;
  uintptr_t addr;

  CHECK(sem_arena_init(&arena, 64u) == 0, "arena init");

  p1 = sem_arena_alloc(&arena, 3u, 1u);
  p2 = sem_arena_alloc(&arena, 16u, 16u);
  CHECK(p1 != NULL && p2 != NULL, "allocations succeed");
  addr = (uintptr_t)p2;
  CHECK((addr & 15u) == 0u, "alignment honored");

  s1 = sem_arena_strdup(&arena, "alpha");
  CHECK(s1 != NULL, "arena strdup");
  CHECK(strcmp(s1, "alpha") == 0, "arena strdup contents");

  sem_arena_reset(&arena);
  s2 = sem_arena_strdup(&arena, "beta");
  CHECK(s2 != NULL, "arena usable after reset");
  CHECK(strcmp(s2, "beta") == 0, "arena reset contents");

  sem_arena_destroy(&arena);
  printf("PASS test_arena_api\n");
  return 0;
}
