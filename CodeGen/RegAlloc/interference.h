#ifndef REGALLOC_INTERFERENCE_H
#define REGALLOC_INTERFERENCE_H

/*
 * interference.h — Etapa 2: Interference Graph (IFG)
 *
 * The interference graph is an undirected graph where:
 *   - nodes are virtual registers (one per vreg in the function)
 *   - edge (a, b) means a and b are simultaneously live at some program
 *     point, therefore they cannot share the same physical register
 *
 * The graph is built from the per-instruction live_after sets produced
 * by liveness analysis (Etapa 1).
 *
 * For every instruction that defines a vreg d:
 *    for every x in live_after(instr), x != d:
 *        add edge (d, x)
 *    move exception: if the instruction is IR_OP_COPY (d = s),
 *        exclude s from live_after before adding edges and record
 *        the (d, s) pair in the move list (used for coalescing in
 *        Etapa 4 — Chaitin-Briggs).
 *
 * Representation: adjacency matrix (triangular bitset) for O(1)
 * interferes(a,b) queries, plus per-node adjacency lists for fast
 * neighbour iteration. Both are maintained in sync.
 */

#include <stdint.h>
#include <stdio.h>
#include "../../IR/ir.h"
#include "liveness.h"

/* ─── move record (dst = src copy) ─────────────────────────────────────────── */

typedef struct {
    unsigned dst;   /* vreg defined by the move                              */
    unsigned src;   /* vreg used by the move                                 */
} ifg_move_t;

/* ─── interference graph (opaque to clients) ──────────────────────────────── */

typedef struct ifg ifg_t;

/* ─── construction / destruction ──────────────────────────────────────────── */

/*
 * Build the interference graph for a function from its liveness data.
 * Both `func` and `liv` must outlive the returned graph — the graph
 * stores no copy of their contents, only derived bit/edge data.
 *
 * Returns NULL on allocation failure.
 */
ifg_t *ifg_build(const ir_function_t *func, const ir_liveness_t *liv);

void   ifg_free (ifg_t *g);

/* ─── queries ─────────────────────────────────────────────────────────────── */

/* Number of nodes (equals func->next_vreg at build time). */
unsigned ifg_num_nodes(const ifg_t *g);

/* 1 iff vregs a and b interfere. Returns 0 for a == b or out-of-range. */
int      ifg_interferes(const ifg_t *g, unsigned a, unsigned b);

/* Degree of node v (0 if v is out of range). */
unsigned ifg_degree    (const ifg_t *g, unsigned v);

/*
 * Fill out[] with neighbour ids of v in ascending order.
 * Writes at most `max` entries. Returns the actual neighbour count
 * (which may exceed `max`; in that case only the first `max` were
 * written).
 */
unsigned ifg_neighbors (const ifg_t *g, unsigned v,
                         unsigned *out, unsigned max);

/* ─── moves (for coalescing in Etapa 4) ──────────────────────────────────── */

/* Number of copy-move pairs recorded during construction. */
unsigned          ifg_num_moves(const ifg_t *g);

/* Pointer to the internal array of moves (length ifg_num_moves). */
const ifg_move_t *ifg_moves    (const ifg_t *g);

/* ─── debug ───────────────────────────────────────────────────────────────── */

/*
 * Print the graph in a human-readable form:
 *   - node / edge / move counts
 *   - edge list
 *   - adjacency list per node with degree
 */
void ifg_print(FILE *out, const char *func_name, const ifg_t *g);

#endif /* REGALLOC_INTERFERENCE_H */
