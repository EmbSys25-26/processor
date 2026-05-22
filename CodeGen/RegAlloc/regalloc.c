/*
 * regalloc.c — Etapa 4: Register Allocation (Chaitin-Briggs)
 *
 * Four-phase pipeline per function:
 *   1. Move coalescing   — George's conservative test
 *   2. Simplification    — Chaitin LIFO select-stack
 *   3. Color selection   — LIFO pop with forbidden-set masking
 *   4. Alias propagation — coalesced nodes inherit representative's color
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "regalloc.h"

/* ─── ABI constants ──────────────────────────────────────────────────────── */

#define K_FULL    11   /* r1–r11: all allocatable (r12/fp reserved)   */
#define K_CALLEE   4   /* r8–r11: callee-saved only (call-live nodes) */

/* Returns the colour-budget K for v: K_CALLEE if call-live, otherwise K_FULL. */
static int k_of(const precolor_t *pc, unsigned v)
{
    return precolor_is_call_live(pc, v) ? K_CALLEE : K_FULL;
}

/* ─── alias helpers ──────────────────────────────────────────────────────── */

/* Follows the alias chain to the representative node for v. */
static unsigned get_alias(const unsigned *alias, unsigned n, unsigned v)
{
    /* Iterative path traversal — no mutation to keep the map simple. */
    while (v < n && alias[v] != v)
        v = alias[v];
    return v;
}

/* ─── physical register names ────────────────────────────────────────────── */

/* Returns a printable register name for a phys_reg_t (or SPILL/?). */
static const char *reg_name(phys_reg_t c)
{
    static const char *names[] = {
        "r0","r1","r2","r3","r4","r5","r6","r7",
        "r8","r9","r10","r11"
    };
    if (c <= PHYS_R11) return names[c];
    if (c == REGALLOC_SPILL) return "SPILL";
    return "?";
}

/* ─── main allocator ─────────────────────────────────────────────────────── */

/* Runs the Chaitin-Briggs allocator (coalesce, simplify, select, alias) and returns the colouring. */
regalloc_t *regalloc_build(const ir_function_t *func,
                            const ifg_t         *g,
                            const precolor_t    *pc)
{
    unsigned n = func->next_vreg;

    regalloc_t *r = calloc(1, sizeof(*r));
    if (!r) return NULL;
    r->n_vregs  = n;
    r->n_spills = 0;

    if (n == 0) return r;

    r->color = malloc(n * sizeof(phys_reg_t));
    if (!r->color) { free(r); return NULL; }
    for (unsigned i = 0; i < n; i++)
        r->color[i] = PHYS_NONE;

    /* Seed with pre-colors so they are visible during color selection. */
    for (unsigned i = 0; i < n; i++) {
        phys_reg_t c = precolor_get(pc, i);
        if (c != PHYS_NONE)
            r->color[i] = c;
    }

    /* ── Phase 1: Move coalescing (George's conservative test) ────────────
     *
     * For each copy (dst ← src):
     *   - skip if they already interfere
     *   - skip if both are precolored (two fixed physical regs cannot merge)
     *   - ensure 'a' is the precolored side (or dst if neither)
     *   - George's test: every neighbor t of src with degree ≥ K(t)
     *     must also interfere with dst
     *   - if safe: alias[src] = dst
     * ─────────────────────────────────────────────────────────────────── */

    unsigned *alias = malloc(n * sizeof(unsigned));
    if (!alias) { free(r->color); free(r); return NULL; }
    for (unsigned i = 0; i < n; i++) alias[i] = i;

    {
        unsigned          nmoves = ifg_num_moves(g);
        const ifg_move_t *moves  = ifg_moves(g);

        for (unsigned m = 0; m < nmoves; m++) {
            unsigned a = get_alias(alias, n, moves[m].dst);
            unsigned b = get_alias(alias, n, moves[m].src);

            if (a == b)                          continue;
            if (ifg_interferes(g, a, b))         continue;
            if (precolor_is_fixed(pc, a) &&
                precolor_is_fixed(pc, b))        continue;

            /* Keep the precolored node as the representative. */
            if (precolor_is_fixed(pc, b) && !precolor_is_fixed(pc, a)) {
                unsigned tmp = a; a = b; b = tmp;
            }

            /* George's test: heavy neighbors of b must also touch a. */
            unsigned nbuf[512];
            unsigned nc = ifg_neighbors(g, b, nbuf, 512);
            int safe = 1;
            for (unsigned ni = 0; ni < nc && safe; ni++) {
                unsigned t = get_alias(alias, n, nbuf[ni]);
                if (t == a || t == b) continue;
                if ((int)ifg_degree(g, t) >= k_of(pc, t) &&
                    !ifg_interferes(g, t, a))
                    safe = 0;
            }
            if (!safe) continue;

            /* Coalesce b → a. */
            alias[b] = a;
            /* If b carried a precolor, propagate it to a. */
            if (precolor_is_fixed(pc, b) && r->color[a] == PHYS_NONE)
                r->color[a] = r->color[b];
        }
    }

    /* ── Phase 2: Simplification — build the LIFO select-stack ────────────
     *
     * Working degree wdeg[v] starts as the original graph degree and
     * decreases as neighbours are removed from the graph.
     * Coalesced-away nodes (alias[v] ≠ v) are pre-removed and skipped.
     * Precolored nodes are never pushed — they stay in the graph and
     * contribute to their neighbours' forbidden sets later.
     *
     * Each iteration:
     *   a) Find any non-precolored, non-removed node with wdeg < K(v).
     *      Push it and remove it (decrement neighbours' wdegs).
     *   b) If none exists, push the highest-wdeg non-precolored node as a
     *      potential spill candidate (it may still get a color in Phase 3).
     * ─────────────────────────────────────────────────────────────────── */

    int      *wdeg    = malloc(n * sizeof(int));
    int      *removed = calloc(n, sizeof(int));
    unsigned *stack   = malloc(n * sizeof(unsigned));
    unsigned  stk     = 0;

    if (!wdeg || !removed || !stack) {
        free(alias); free(wdeg); free(removed); free(stack);
        free(r->color); free(r);
        return NULL;
    }

    for (unsigned v = 0; v < n; v++)
        wdeg[v] = (int)ifg_degree(g, v);

    /* Pre-remove coalesced-away nodes. */
    for (unsigned v = 0; v < n; v++)
        if (get_alias(alias, n, v) != v)
            removed[v] = 1;

    int changed = 1;
    while (changed) {
        changed = 0;

        /* (a) Push a low-degree node. */
        for (unsigned v = 0; v < n; v++) {
            if (removed[v] || precolor_is_fixed(pc, v)) continue;
            if (wdeg[v] < k_of(pc, v)) {
                stack[stk++] = v;
                removed[v]   = 1;
                unsigned nbuf[512];
                unsigned nc = ifg_neighbors(g, v, nbuf, 512);
                for (unsigned ni = 0; ni < nc; ni++) {
                    unsigned t = get_alias(alias, n, nbuf[ni]);
                    if (!removed[t]) wdeg[t]--;
                }
                changed = 1;
                break;
            }
        }

        /* (b) No low-degree node: push the highest-degree one as spill. */
        if (!changed) {
            unsigned best     = (unsigned)-1;
            int      best_deg = -1;
            for (unsigned v = 0; v < n; v++) {
                if (removed[v] || precolor_is_fixed(pc, v)) continue;
                if (wdeg[v] > best_deg) {
                    best_deg = wdeg[v];
                    best     = v;
                }
            }
            if (best != (unsigned)-1) {
                stack[stk++]  = best;
                removed[best] = 1;
                unsigned nbuf[512];
                unsigned nc = ifg_neighbors(g, best, nbuf, 512);
                for (unsigned ni = 0; ni < nc; ni++) {
                    unsigned t = get_alias(alias, n, nbuf[ni]);
                    if (!removed[t]) wdeg[t]--;
                }
                changed = 1;
            }
        }
    }

    /* ── Phase 3: Color selection — LIFO pop ──────────────────────────────
     *
     * Process the select-stack from top (last pushed) to bottom.
     * For each node v:
     *   - Build a forbidden bitmask from the colors already assigned to
     *     every interfering neighbour (precolored + already popped).
     *   - Also check neighbours of any coalesced-away node that merged into v.
     *   - Assign the first color not in forbidden, respecting call-live.
     *   - If none: mark as REGALLOC_SPILL.
     * ─────────────────────────────────────────────────────────────────── */

    for (int si = (int)stk - 1; si >= 0; si--) {
        unsigned v  = stack[si];
        unsigned av = get_alias(alias, n, v);

        /* Safety: coalesced-away nodes should not be on the stack,
         * but if they are, skip — Phase 4 will propagate the color. */
        if (av != v) continue;

        /* Precolored nodes were never pushed; skip if somehow present. */
        if (r->color[v] != PHYS_NONE) continue;

        /* Collect forbidden colors from all interfering neighbours. */
        uint16_t forbidden = 0;

        /* Neighbours of v itself. */
        {
            unsigned nbuf[512];
            unsigned nc = ifg_neighbors(g, v, nbuf, 512);
            for (unsigned ni = 0; ni < nc; ni++) {
                unsigned  t  = get_alias(alias, n, nbuf[ni]);
                phys_reg_t tc = r->color[t];
                if (tc != PHYS_NONE && tc != REGALLOC_SPILL && tc <= PHYS_R12)
                    forbidden |= (uint16_t)(1u << tc);
            }
        }

        /* Neighbours of any coalesced-away node that became part of v. */
        for (unsigned u = 0; u < n; u++) {
            if (u == v || get_alias(alias, n, u) != v) continue;
            unsigned nbuf[512];
            unsigned nc = ifg_neighbors(g, u, nbuf, 512);
            for (unsigned ni = 0; ni < nc; ni++) {
                unsigned  t  = get_alias(alias, n, nbuf[ni]);
                phys_reg_t tc = r->color[t];
                if (tc != PHYS_NONE && tc != REGALLOC_SPILL && tc <= PHYS_R12)
                    forbidden |= (uint16_t)(1u << tc);
            }
        }

        /* Preference order (r12/fp is reserved — never allocated):
         *   non-call-live: r4–r6 (free temporaries) → r8–r11 (callee-saved)
         *                  → r1–r3 (ABI arg regs, last resort)
         *   call-live:     r8–r11 only (must survive calls)
         *
         * r7 (t3) is reserved exclusively for the codegen as a scratch when
         * it needs to materialise an immediate / global into a register that
         * is guaranteed not to clobber a live vreg.  Without per-instruction
         * liveness in codegen, picking a scratch from the allocatable set
         * produced silent miscompilations: e.g. `*p = a & 0xFF` would write
         * the masked value to address 0xFF instead of *p when t1 happened to
         * hold &p.  Reserving one register out of regalloc's reach makes the
         * codegen scratch correctness-preserving by construction.
         */
        static const phys_reg_t pref_normal[] = {
            PHYS_R4, PHYS_R5, PHYS_R6,
            PHYS_R8, PHYS_R9, PHYS_R10, PHYS_R11,
            PHYS_R1, PHYS_R2, PHYS_R3
        };
        static const phys_reg_t pref_callee[] = {
            PHYS_R8, PHYS_R9, PHYS_R10, PHYS_R11
        };

        int              cl    = precolor_is_call_live(pc, v);
        const phys_reg_t *pref = cl ? pref_callee : pref_normal;
        unsigned         nregs = (unsigned)(cl
            ? sizeof(pref_callee) / sizeof(*pref_callee)
            : sizeof(pref_normal) / sizeof(*pref_normal));
        phys_reg_t chosen = REGALLOC_SPILL;

        for (unsigned pi = 0; pi < nregs; pi++) {
            phys_reg_t c = pref[pi];
            if (!(forbidden & (uint16_t)(1u << c))) {
                chosen = c;
                break;
            }
        }

        r->color[v] = chosen;
        if (chosen == REGALLOC_SPILL)
            r->n_spills++;
    }

    /* ── Phase 4: Alias propagation ────────────────────────────────────────
     *
     * Coalesced-away nodes were not colored in Phase 3.
     * Copy the color from their representative (follow the full chain).
     * ─────────────────────────────────────────────────────────────────── */

    for (unsigned v = 0; v < n; v++) {
        unsigned av = get_alias(alias, n, v);
        if (av != v)
            r->color[v] = r->color[av];
    }

    free(alias);
    free(wdeg);
    free(removed);
    free(stack);
    return r;
}

/* ─── cleanup ────────────────────────────────────────────────────────────── */

/* Releases the regalloc result and its colour array. */
void regalloc_free(regalloc_t *r)
{
    if (!r) return;
    free(r->color);
    free(r);
}

/* ─── debug printer ──────────────────────────────────────────────────────── */

/* Prints each vreg's assigned colour and any spills for debugging. */
void regalloc_print(FILE *out, const char *func_name,
                    const regalloc_t *r, const precolor_t *pc)
{
    fprintf(out, "regalloc for @%s  (%u vreg%s):\n",
            func_name, r->n_vregs, r->n_vregs == 1 ? "" : "s");

    for (unsigned v = 0; v < r->n_vregs; v++) {
        phys_reg_t c = r->color[v];

        if (c == PHYS_NONE) {
            /* Degree-zero vreg: assigned a color but happened to be unused.
             * Print as allocated with whatever color was given, or skip. */
            fprintf(out, "  %%v%-3u  →  (unused)\n", v);
            continue;
        }
        if (c == REGALLOC_SPILL) {
            fprintf(out, "  %%v%-3u  →  SPILL\n", v);
            continue;
        }

        const char *tag;
        if (precolor_is_fixed(pc, v))
            tag = "precolored";
        else if (precolor_is_call_live(pc, v))
            tag = "callee-saved";
        else
            tag = "allocated";

        fprintf(out, "  %%v%-3u  →  %-4s  [%s]\n", v, reg_name(c), tag);
    }

    if (r->n_spills > 0)
        fprintf(out, "  spills: %u\n", r->n_spills);
    else
        fprintf(out, "  spills: none\n");
}
