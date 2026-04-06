#include <errno.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "arena.h"

/* A single contiguous slab of memory.  Blocks are linked in a singly-linked
 * list with the most-recently-allocated block at the front (arena->head).
 *
 *   next     – A pointer to the next block in a linked list. When the current block runs out of space, a new larger block is allocated and linked here. The arena walks this chain when destroying itself.
 *   used     – how many bytes of 'data' have been handed out so far.
 *   capacity – total usable bytes in 'data' (does not include this header).
 *   data[]   – flexible array member; the raw allocation region sits here,
 *              immediately after the header in the same malloc'd buffer.
 */
struct sem_arena_block {
  sem_arena_block_t *next;
  size_t used;
  size_t capacity;
  unsigned char data[];
};

/* Round 'alignment' up so it satisfies two invariants required by the bitmask
 * trick used in sem_arena_alloc:
 *
 *   1. At least sizeof(void *) — guarantees every allocation is pointer-aligned,
 *      which is the minimum safe alignment on all supported platforms.
 *
 *   2. A power of two — required because the alignment calculation uses
 *      (base + align-1) & ~(align-1), which is only correct for powers of two.
 *
 * The power-of-two rounding works by starting p at sizeof(void *) (which is
 * already a power of two) and doubling until p >= result.  Doubling a power of
 * two always yields another power of two, so p is always valid. */
static size_t normalize_alignment(size_t alignment)
{
  size_t result = sizeof(void *);

  /* Apply the minimum floor. */
  if (alignment > result) {
    result = alignment;
  }

  /* If not already a power of two, walk up the sequence 8,16,32,... until we
   * find the smallest power of two that is >= result.
   * The (x & (x-1)) != 0 test detects non-powers-of-two: a power of two has
   * exactly one bit set, so x-1 flips all lower bits and the AND is zero. */
  if ((result & (result - 1u)) != 0u) {
    size_t p = sizeof(void *);
    while (p < result) {
      p <<= 1u;
    }
    result = p;
  }

  return result;
}

/* Allocate a new block that can hold 'capacity' bytes of user data.
 * A single malloc covers both the header and the data region (flexible array).
 * Returns NULL if malloc fails. */
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

/* Prepare an arena for use.
 * Sets head to NULL (no blocks yet), stores the preferred block size, and
 * zeroes total_bytes.  initial_capacity == 0 defaults to 4096 bytes.
 * Returns -EINVAL if arena is NULL, 0 on success. */
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

/* Release every block back to the OS and zero the arena's fields.
 * Uses a two-pointer walk because we must save it->next before freeing 'it' —
 * reading freed memory is undefined behaviour. */
void sem_arena_destroy(sem_arena_t *arena)
{
  sem_arena_block_t *it;
  sem_arena_block_t *next;

  if (!arena) {
    return;
  }

  it = arena->head;
  while (it) {
    next = it->next; /* save next pointer before the free invalidates 'it' */
    free(it);
    it = next;
  }

  arena->head = NULL;
  arena->total_bytes = 0u;
}

/* Reuse the arena's memory without going back to the OS.
 * Keeps the first (oldest) block — which is typically the largest due to the
 * doubling growth policy — frees everything else, and resets its used counter
 * to zero so the whole capacity is available again.
 * total_bytes is updated to reflect only the surviving block. */
void sem_arena_reset(sem_arena_t *arena)
{
  sem_arena_block_t *head;
  sem_arena_block_t *it;
  sem_arena_block_t *next;

  if (!arena || !arena->head) {
    return;
  }

  /* Walk from the second block onward, freeing each one. */
  head = arena->head;
  it = head->next;
  while (it) {
    next = it->next;
    free(it);
    it = next;
  }

  /* Detach the freed chain and reset the surviving block. */
  head->next = NULL;
  head->used = 0u;
  arena->total_bytes = head->capacity;
}

/* Bump-allocate 'size' bytes from the arena with at least 'alignment' bytes of
 * alignment.
 *
 * Fast path — current head block has enough room:
 *   Compute the next aligned address inside the block's unused region using the
 *   bitmask trick, advance block->used by (padding + size), and return.
 *
 * Slow path — no block yet, or the current block is too full:
 *   Pick a capacity that is at least initial_capacity, at least large enough
 *   for this single allocation, and at least double the current head's capacity
 *   (geometric growth to amortise future allocations).  Allocate a new block,
 *   prepend it to the list (making it the new head), and allocate from it.
 *
 * Returns NULL if arena is NULL, size is 0, or malloc fails. */
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

  /* Fast path: try to satisfy the request from the current head block. */
  if (block) {
    base    = (uintptr_t)(block->data + block->used);
    /* Round base up to the next multiple of alignment using a bitmask.
     * Works because alignment is guaranteed to be a power of two. */
    aligned = (base + (alignment - 1u)) & ~(uintptr_t)(alignment - 1u);
    padding = (size_t)(aligned - base); /* bytes wasted to reach alignment */
    needed  = padding + size;
    if (needed <= (block->capacity - block->used)) {
      block->used += needed;
      return (void *)aligned;
    }
  }

  /* Slow path: allocate a new block.  Size it generously to reduce how often
   * we fall back here. */
  capacity = arena->initial_capacity;
  if (capacity < size + alignment) {       /* must fit this allocation */
    capacity = size + alignment;
  }
  if (block && capacity < block->capacity * 2u) { /* geometric growth */
    capacity = block->capacity * 2u;
  }

  block = arena_block_new(capacity);
  if (!block) {
    return NULL;
  }

  /* Prepend the new block so it becomes the head (current block). */
  block->next  = arena->head;
  arena->head  = block;
  arena->total_bytes += capacity;

  /* Allocate from the brand-new block (base is already block->data). */
  base    = (uintptr_t)block->data;
  aligned = (base + (alignment - 1u)) & ~(uintptr_t)(alignment - 1u);
  padding = (size_t)(aligned - base);
  block->used = padding + size;
  return (void *)aligned;
}

/* Copy src (including NUL terminator) into arena-owned memory.
 * The returned pointer must NOT be passed to free(); its lifetime is the
 * arena's lifetime. Returns NULL if either argument is NULL or alloc fails. */
char *sem_arena_strdup(sem_arena_t *arena, const char *src)
{
  size_t n;
  char *dst;

  if (!arena || !src) {
    return NULL;
  }

  n   = strlen(src) + 1u;  /* +1 for the NUL terminator */
  dst = (char *)sem_arena_alloc(arena, n, _Alignof(char));
  if (!dst) {
    return NULL;
  }

  (void)memcpy(dst, src, n);
  return dst;
}
