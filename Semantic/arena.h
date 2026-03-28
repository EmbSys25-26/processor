#ifndef SEMANTIC_ARENA_H
#define SEMANTIC_ARENA_H

#include <stddef.h>

typedef struct sem_arena_block sem_arena_block_t;

typedef struct sem_arena {
  sem_arena_block_t *head;
  size_t initial_capacity;
  size_t total_bytes;
} sem_arena_t;

int sem_arena_init(sem_arena_t *arena, size_t initial_capacity);
void sem_arena_destroy(sem_arena_t *arena);
void sem_arena_reset(sem_arena_t *arena);
void *sem_arena_alloc(sem_arena_t *arena, size_t size, size_t alignment);
char *sem_arena_strdup(sem_arena_t *arena, const char *src);

#endif
