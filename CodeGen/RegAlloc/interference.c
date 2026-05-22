/*
 * interference.c — Etapa 2: Interference Graph construction
 *
 * Dual representation:
 *   1. Triangular adjacency bitset  -> O(1) interferes(a, b) queries
 *   2. Per-node adjacency lists     -> fast neighbour iteration for
 *                                      the colouring / spill phases
 *
 * Both structures are kept in sync by ifg_add_edge(). The adjacency
 * lists grow on demand with a geometric (doubling) strategy.
 */

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "interference.h"

/* ═══════════════════════════════════════════════════════════════════════════
 * Internal data layout
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Adjacency list for a single node: dynamic array of neighbour ids, kept
   sorted in ascending order for deterministic output. */
typedef struct {
    unsigned *ids;    /* sorted neighbour ids                                */
    unsigned  len;    /* number of valid entries                             */
    unsigned  cap;    /* allocated capacity                                  */
} adj_list_t;

struct ifg {
    unsigned    n;          /* number of nodes (= vreg count)                */

    /* Triangular adjacency bitset.
       Edge (a, b) with a < b maps to a single bit. We store rows for
       b = 1..n-1, where row b has b bits (one per possible partner
       a < b). Total bits = n*(n-1)/2. */
    uint64_t   *tri;        /* triangular bitset                             */
    size_t      tri_words;  /* total uint64_t words in tri                   */
    size_t     *row_off;    /* row_off[b] = bit offset of row b's first bit  */

    /* Per-node neighbour lists. Synchronised with tri on every add_edge. */
    adj_list_t *adj;        /* adj[n]                                        */

    /* Move pairs collected during construction. */
    ifg_move_t *moves;
    unsigned    n_moves;
    unsigned    moves_cap;
};

/* ═══════════════════════════════════════════════════════════════════════════
 * Triangular bitset helpers
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Triangular bitset accessors: bit offset for edge (lo,hi), get, and set-if-new. */
/* Return the bit offset within `tri` corresponding to edge (lo, hi),
   where lo < hi. Precondition: lo < hi < g->n. */
static size_t tri_bit(const ifg_t *g, unsigned lo, unsigned hi)
{
    /* Row `hi` starts at offset row_off[hi] and contains hi bits,
       one for each potential partner 0..hi-1. Bit lo in that row. */
    return g->row_off[hi] + lo;
}

static int tri_get(const ifg_t *g, unsigned lo, unsigned hi)
{
    size_t bit = tri_bit(g, lo, hi);
    return (g->tri[bit >> 6] >> (bit & 63u)) & 1u;
}

/* Set edge bit; returns 1 if it was newly set, 0 if already present. */
static int tri_set(ifg_t *g, unsigned lo, unsigned hi)
{
    size_t bit = tri_bit(g, lo, hi);
    uint64_t mask = (uint64_t)1 << (bit & 63u);
    uint64_t *w = &g->tri[bit >> 6];
    if (*w & mask) return 0;
    *w |= mask;
    return 1;
}

/* ═══════════════════════════════════════════════════════════════════════════
 * Adjacency list helpers (sorted insert)
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Ensures the adjacency list has capacity for `need` entries, doubling as needed. */
static int adj_grow(adj_list_t *a, unsigned need)
{
    if (a->cap >= need) return 0;
    unsigned ncap = a->cap ? a->cap * 2 : 4;
    while (ncap < need) ncap *= 2;
    unsigned *p = (unsigned *)realloc(a->ids, ncap * sizeof(unsigned));
    if (!p) return -1;
    a->ids = p;
    a->cap = ncap;
    return 0;
}

/* Insert `id` into `a` in ascending order. Assumes `id` is not already
   present (callers guarantee this by checking the triangular bitset first). */
/* Inserts id into the adjacency list, maintaining ascending sort. */
static int adj_insert_sorted(adj_list_t *a, unsigned id)
{
    if (adj_grow(a, a->len + 1) < 0) return -1;

    /* Binary search insertion point. */
    unsigned lo = 0, hi = a->len;
    while (lo < hi) {
        unsigned mid = lo + (hi - lo) / 2;
        if (a->ids[mid] < id) lo = mid + 1;
        else                  hi = mid;
    }
    if (lo < a->len) {
        memmove(&a->ids[lo + 1], &a->ids[lo],
                (a->len - lo) * sizeof(unsigned));
    }
    a->ids[lo] = id;
    a->len++;
    return 0;
}

/* ═══════════════════════════════════════════════════════════════════════════
 * Graph edge management
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Add undirected edge (a, b). Self-edges and out-of-range are silently
   ignored. Returns 1 if the edge was new, 0 if already present, -1 on
   allocation failure. */
/* Adds an undirected interference edge, updating both the bitset and adjacency lists. */
static int ifg_add_edge(ifg_t *g, unsigned a, unsigned b)
{
    if (a == b) return 0;
    if (a >= g->n || b >= g->n) return 0;

    unsigned lo = a < b ? a : b;
    unsigned hi = a < b ? b : a;

    if (!tri_set(g, lo, hi)) return 0;    /* already present */

    /* Mirror in both adjacency lists */
    if (adj_insert_sorted(&g->adj[a], b) < 0) return -1;
    if (adj_insert_sorted(&g->adj[b], a) < 0) return -1;
    return 1;
}

/* ═══════════════════════════════════════════════════════════════════════════
 * Per-instruction DEF/USE extraction
 *
 * Mirrors the logic in liveness.c. Kept local to avoid exposing internal
 * helpers across modules.
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Returns 1 and sets *vr if the instruction defines a vreg, mirroring liveness.c. */
static int instr_get_def(const ir_instr_t *i, unsigned *vr)
{
    switch (i->op) {
    case IR_OP_STORE:
    case IR_OP_GOTO:
    case IR_OP_BRANCH:
    case IR_OP_SWITCH:
    case IR_OP_RET:
        return 0;
    case IR_OP_CALL:
        if (i->as.call.is_void_call)       return 0;
        if (i->dst.kind != IR_VAL_VREG)    return 0;
        *vr = i->dst.as.vreg;
        return 1;
    default:
        if (i->dst.kind == IR_VAL_VREG) {
            *vr = i->dst.as.vreg;
            return 1;
        }
        return 0;
    }
}

/*
 * Return 1 if the instruction is a pure register-to-register move
 * (IR_OP_COPY) whose source is a vreg. Out-parameters receive the
 * destination and source vreg ids.
 *
 * Rationale: only IR_OP_COPY is a true move in this IR. IR_OP_ADDR_OF
 * takes a slot/global as source (never a vreg). LOAD/STORE go through
 * memory and are not coalescing candidates.
 */
static int instr_is_move(const ir_instr_t *i, unsigned *dst, unsigned *src)
{
    if (i->op != IR_OP_COPY)              return 0;
    if (i->dst.kind   != IR_VAL_VREG)     return 0;
    if (i->src[0].kind != IR_VAL_VREG)    return 0;
    *dst = i->dst.as.vreg;
    *src = i->src[0].as.vreg;
    return 1;
}

/* ═══════════════════════════════════════════════════════════════════════════
 * Move list management
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Records a (dst,src) move pair for later coalescing consideration. */
static int ifg_record_move(ifg_t *g, unsigned dst, unsigned src)
{
    if (g->n_moves == g->moves_cap) {
        unsigned ncap = g->moves_cap ? g->moves_cap * 2 : 8;
        ifg_move_t *p = (ifg_move_t *)realloc(g->moves,
                                               ncap * sizeof(ifg_move_t));
        if (!p) return -1;
        g->moves     = p;
        g->moves_cap = ncap;
    }
    g->moves[g->n_moves].dst = dst;
    g->moves[g->n_moves].src = src;
    g->n_moves++;
    return 0;
}

/* ═══════════════════════════════════════════════════════════════════════════
 * Construction
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Builds the interference graph by scanning each instruction's live_after set and adding edges from the def. */
ifg_t *ifg_build(const ir_function_t *func, const ir_liveness_t *liv)
{
    if (!func || !liv) return NULL;

    ifg_t *g = (ifg_t *)calloc(1, sizeof(ifg_t));
    if (!g) return NULL;

    g->n = liv->n_vregs;

    /* ── Allocate triangular bitset ─────────────────────────────────────── */
    /* Bit count = n*(n-1)/2. For n == 0 or 1 there are no edges, but we
       still allocate the row offset table so tri_bit() is never called. */
    size_t total_bits = (size_t)g->n * (g->n > 0 ? g->n - 1 : 0) / 2;
    g->tri_words = (total_bits + 63) / 64;
    if (g->tri_words == 0) g->tri_words = 1;   /* always at least one word */
    g->tri = (uint64_t *)calloc(g->tri_words, sizeof(uint64_t));
    if (!g->tri) { ifg_free(g); return NULL; }

    /* row_off[b] = number of bits reserved for rows 0..b-1 = b*(b-1)/2 */
    g->row_off = (size_t *)calloc(g->n ? g->n : 1, sizeof(size_t));
    if (!g->row_off) { ifg_free(g); return NULL; }
    for (unsigned b = 0; b < g->n; b++)
        g->row_off[b] = (size_t)b * (b - 1) / 2;

    /* ── Allocate adjacency lists ───────────────────────────────────────── */
    g->adj = (adj_list_t *)calloc(g->n ? g->n : 1, sizeof(adj_list_t));
    if (!g->adj) { ifg_free(g); return NULL; }

    /* ── Walk instructions and add interference edges ───────────────────── */
    /* We iterate blocks in the same order liveness used so that
       liv->instr[k] corresponds to the k-th instruction encountered here. */
    unsigned instr_idx = 0;
    for (const ir_block_t *b = func->entry; b; b = b->next) {
        for (const ir_instr_t *ins = b->head; ins; ins = ins->next) {
            const vreg_set_t *la = &liv->instr[instr_idx].live_after;
            instr_idx++;

            unsigned d;
            if (!instr_get_def(ins, &d)) continue;

            /* Move exception: exclude the source from live_after so
               that (dst, src) do not interfere purely due to this
               copy. Record the pair for later coalescing. */
            unsigned move_src = (unsigned)-1;
            unsigned move_dst;
            if (instr_is_move(ins, &move_dst, &move_src)) {
                if (ifg_record_move(g, move_dst, move_src) < 0) {
                    ifg_free(g); return NULL;
                }
            }

            /* For every vreg x live after this instruction with x != d
               (and x != move_src when this is a move), add edge (d, x). */
            unsigned nw = (la->cap + 63) / 64;
            for (unsigned w = 0; w < nw; w++) {
                uint64_t word = la->words[w];
                while (word) {
                    unsigned bit = __builtin_ctzll(word);
                    unsigned x   = w * 64 + bit;
                    word &= word - 1;

                    if (x == d)        continue;
                    if (x == move_src) continue;   /* move exception */

                    if (ifg_add_edge(g, d, x) < 0) {
                        ifg_free(g); return NULL;
                    }
                }
            }
        }
    }

    return g;
}

/* ═══════════════════════════════════════════════════════════════════════════
 * Destruction
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Releases all storage owned by the interference graph. */
void ifg_free(ifg_t *g)
{
    if (!g) return;
    if (g->adj) {
        for (unsigned i = 0; i < g->n; i++) free(g->adj[i].ids);
        free(g->adj);
    }
    free(g->tri);
    free(g->row_off);
    free(g->moves);
    free(g);
}

/* ═══════════════════════════════════════════════════════════════════════════
 * Queries
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Trivial graph accessors: node count, edge query, degree, and neighbour copy. */
unsigned ifg_num_nodes(const ifg_t *g)
{
    return g ? g->n : 0;
}

int ifg_interferes(const ifg_t *g, unsigned a, unsigned b)
{
    if (!g || a == b)                return 0;
    if (a >= g->n || b >= g->n)      return 0;
    unsigned lo = a < b ? a : b;
    unsigned hi = a < b ? b : a;
    return tri_get(g, lo, hi);
}

unsigned ifg_degree(const ifg_t *g, unsigned v)
{
    if (!g || v >= g->n) return 0;
    return g->adj[v].len;
}

unsigned ifg_neighbors(const ifg_t *g, unsigned v,
                        unsigned *out, unsigned max)
{
    if (!g || v >= g->n) return 0;
    unsigned n = g->adj[v].len;
    unsigned to_copy = n < max ? n : max;
    if (out && to_copy) memcpy(out, g->adj[v].ids, to_copy * sizeof(unsigned));
    return n;
}

unsigned           ifg_num_moves(const ifg_t *g) { return g ? g->n_moves : 0; }
const ifg_move_t  *ifg_moves    (const ifg_t *g) { return g ? g->moves   : NULL; }

/* ═══════════════════════════════════════════════════════════════════════════
 * Debug printer
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Prints the interference graph (nodes, edges, moves, adjacency) for debugging. */
void ifg_print(FILE *out, const char *func_name, const ifg_t *g)
{
    if (!g) return;

    /* Count edges (sum of degrees / 2). */
    unsigned long edges = 0;
    for (unsigned v = 0; v < g->n; v++) edges += g->adj[v].len;
    edges /= 2;

    fprintf(out, "=== interference: @%s ===\n",
            func_name ? func_name : "<anon>");
    fprintf(out, "  nodes: %u\n", g->n);
    fprintf(out, "  edges: %lu\n", edges);
    fprintf(out, "  moves: %u\n", g->n_moves);

    if (edges > 0) {
        fprintf(out, "  edge list:\n");
        /* Print each edge once by iterating lo < hi. */
        for (unsigned hi = 1; hi < g->n; hi++) {
            for (unsigned lo = 0; lo < hi; lo++) {
                if (tri_get(g, lo, hi))
                    fprintf(out, "    %%v%u -- %%v%u\n", lo, hi);
            }
        }
    }

    if (g->n_moves > 0) {
        fprintf(out, "  move list:\n");
        for (unsigned i = 0; i < g->n_moves; i++) {
            fprintf(out, "    %%v%u <- %%v%u\n",
                    g->moves[i].dst, g->moves[i].src);
        }
    }

    fprintf(out, "  adjacency:\n");
    for (unsigned v = 0; v < g->n; v++) {
        fprintf(out, "    %%v%u (deg=%u): {", v, g->adj[v].len);
        for (unsigned k = 0; k < g->adj[v].len; k++) {
            if (k) fprintf(out, ", ");
            fprintf(out, "%%v%u", g->adj[v].ids[k]);
        }
        fprintf(out, "}\n");
    }
}
