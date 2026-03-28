#include <errno.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "arena.h"

struct sem_arena_block {
  sem_arena_block_t *next;
  size_t used;
  size_t capacity;
  unsigned char data[];
};

static size_t normalize_alignment(size_t alignment)
{
  size_t result = sizeof(void *);

  if (alignment > result) {
    result = alignment;
  }

  if ((result & (result - 1u)) != 0u) {
    size_t p = sizeof(void *);
    while (p < result) {
      p <<= 1u;
    }
    result = p;
  }

  return result;
}

static sem_arena_block_t *arena_block_new(size_t capacity)
{
  sem_arena_block_t *block = (sem_arena_block_t *)malloc(sizeof(*block) + capacity);
  if (!block) {
    return NULL;
  }

  block->next = NULL;
  block->used = 0u;
  block->capacity = capacity;
  return block;
}

int sem_arena_init(sem_arena_t *arena, size_t initial_capacity)
{
  if (!arena) {
    return -EINVAL;
  }

  arena->head = NULL;
  arena->initial_capacity = initial_capacity ? initial_capacity : 4096u;
  arena->total_bytes = 0u;
  return 0;
}

void sem_arena_destroy(sem_arena_t *arena)
{
  sem_arena_block_t *it;
  sem_arena_block_t *next;

  if (!arena) {
    return;
  }

  it = arena->head;
  while (it) {
    next = it->next;
    free(it);
    it = next;
  }

  arena->head = NULL;
  arena->total_bytes = 0u;
}

void sem_arena_reset(sem_arena_t *arena)
{
  sem_arena_block_t *head;
  sem_arena_block_t *it;
  sem_arena_block_t *next;

  if (!arena || !arena->head) {
    return;
  }

  head = arena->head;
  it = head->next;
  while (it) {
    next = it->next;
    free(it);
    it = next;
  }

  head->next = NULL;
  head->used = 0u;
  arena->total_bytes = head->capacity;
}

void *sem_arena_alloc(sem_arena_t *arena, size_t size, size_t alignment)
{
  sem_arena_block_t *block;
  uintptr_t base;
  uintptr_t aligned;
  size_t padding;
  size_t needed;
  size_t capacity;

  if (!arena || size == 0u) {
    return NULL;
  }

  alignment = normalize_alignment(alignment);
  block = arena->head;

  if (block) {
    base = (uintptr_t)(block->data + block->used);
    aligned = (base + (alignment - 1u)) & ~(uintptr_t)(alignment - 1u);
    padding = (size_t)(aligned - base);
    needed = padding + size;
    if (needed <= (block->capacity - block->used)) {
      block->used += needed;
      return (void *)aligned;
    }
  }

  capacity = arena->initial_capacity;
  if (capacity < size + alignment) {
    capacity = size + alignment;
  }
  if (block && capacity < block->capacity * 2u) {
    capacity = block->capacity * 2u;
  }

  block = arena_block_new(capacity);
  if (!block) {
    return NULL;
  }

  block->next = arena->head;
  arena->head = block;
  arena->total_bytes += capacity;

  base = (uintptr_t)block->data;
  aligned = (base + (alignment - 1u)) & ~(uintptr_t)(alignment - 1u);
  padding = (size_t)(aligned - base);
  block->used = padding + size;
  return (void *)aligned;
}

char *sem_arena_strdup(sem_arena_t *arena, const char *src)
{
  size_t n;
  char *dst;

  if (!arena || !src) {
    return NULL;
  }

  n = strlen(src) + 1u;
  dst = (char *)sem_arena_alloc(arena, n, _Alignof(char));
  if (!dst) {
    return NULL;
  }

  (void)memcpy(dst, src, n);
  return dst;
}
