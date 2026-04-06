#ifndef SEMANTIC_ARENA_H
#define SEMANTIC_ARENA_H

#include <stddef.h>

/* Forward declaration of the block struct, defined in arena.c.
 * Kept opaque here so callers cannot poke at block internals directly. */
typedef struct sem_arena_block sem_arena_block_t;

/* The arena handle that callers stack- or heap-allocate and pass around.
 *
 *   head             – pointer to the most-recently-allocated block; NULL when
 *                      the arena is empty.  The block list grows by prepending,
 *                      so head is always the "current" block we bump into.
 *
 *   initial_capacity – size (in bytes) of the first block and the baseline used
 *                      when deciding how large a new block should be.  Set once
 *                      in sem_arena_init and never modified again.
 *
 *   total_bytes      – running sum of every block's data capacity (not counting
 *                      block-header overhead, and not counting padding waste
 *                      inside blocks).  Useful as a cheap high-water-mark gauge.
 */
typedef struct sem_arena {
  sem_arena_block_t *head;
  size_t initial_capacity;
  size_t total_bytes;
} sem_arena_t;

/* Initialise *arena and set the preferred block size.
 * Pass initial_capacity == 0 to use the built-in default (4096 bytes).
 * Returns 0 on success, -EINVAL if arena is NULL. */
int sem_arena_init(sem_arena_t *arena, size_t initial_capacity);

/* Free every block owned by the arena and zero out its fields.
 * After this call the arena is in the same state as before sem_arena_init. */
void sem_arena_destroy(sem_arena_t *arena);

/* Cheap bulk-free: discard all blocks except the first, then reset the first
 * block's used counter to zero so its memory can be reused immediately.
 * Avoids round-tripping back to the OS for the common "process a batch, reset,
 * process another batch" pattern. */
void sem_arena_reset(sem_arena_t *arena);

/* Bump-allocate 'size' bytes aligned to 'alignment' from the arena.
 * 'alignment' is rounded up to the next power-of-two (minimum sizeof(void*)).
 * A new block is appended automatically if the current one is full.
 * Returns NULL if arena or size is 0, or if malloc fails. */
void *sem_arena_alloc(sem_arena_t *arena, size_t size, size_t alignment);

/* Arena-backed strdup: copies src (including the NUL terminator) into memory
 * owned by the arena.  The caller must NOT free the returned pointer; its
 * lifetime is tied to the arena itself. */
char *sem_arena_strdup(sem_arena_t *arena, const char *src);

/* Allocate one T-sized, T-aligned object from the arena.
 * Mirrors LLVM BumpPtrAllocator::Allocate<T>(). */
#define SEM_ARENA_NEW(arena, T) \
  ((T *)sem_arena_alloc((arena), sizeof(T), _Alignof(T)))

/* Allocate a contiguous array of n T-sized, T-aligned objects from the arena. */
#define SEM_ARENA_NEW_ARRAY(arena, T, n) \
  ((T *)sem_arena_alloc((arena), (n) * sizeof(T), _Alignof(T)))

#endif
