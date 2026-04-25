#ifndef REGALLOC_SPILL_H
#define REGALLOC_SPILL_H

/*
 * spill.h — Stage 5: Spill Rewriting
 *
 * When the register allocator (Stage 4) cannot assign a physical register to
 * a virtual register, it marks it REGALLOC_SPILL.  This module rewrites the
 * IR of the function so that every such vreg is replaced by stack-slot
 * accesses, reducing its live range to a single instruction.
 *
 * ── Transformation per spilled vreg %vN (slot %slotS) ────────────────────
 *
 *   At every DEFINITION site:
 *       %vN = <expr>
 *   becomes:
 *       %vN     = <expr>
 *       %vPtr   = addr_of %slotS   ; take the address of the spill slot
 *       *%vPtr  = %vN              ; write the just-computed value to stack
 *
 *   At every USE site (each src operand that reads %vN):
 *       ... = ... %vN ...
 *   becomes:
 *       %vPtr2    = addr_of %slotS ; address of the spill slot
 *       %vReload  = *%vPtr2        ; reload value from stack
 *       ... = ... %vReload ...     ; original instruction uses the reload
 *
 * After rewriting, %vN is live only from its definition to the immediately
 * following store (one instruction), and %vReload is live only from its load
 * to the immediately following use.  Both have degree ≤ 2 in the next
 * interference graph and are trivially colourable.
 *
 * ── Spill ordering heuristic ──────────────────────────────────────────────
 *
 * When multiple vregs are spilled in the same iteration, they are processed
 * in ascending cost order, where:
 *
 *     cost(v) = use_def_count(v) / degree(v)
 *
 * A low cost means few memory accesses inserted per graph edge freed.
 * Vregs with zero degree are ordered last (cost treated as very high).
 *
 * ── Convergence ───────────────────────────────────────────────────────────
 *
 * Each call to spill_rewrite() eliminates all REGALLOC_SPILL vregs from the
 * current allocation.  The caller must then re-run the full pipeline
 * (liveness → interference → precolour → regalloc).  Because every new vreg
 * introduced by spilling has a live range of at most two instructions, the
 * pipeline converges in a small number of iterations.
 */

#include <stdio.h>
#include "../IR/ir.h"
#include "regalloc.h"
#include "interference.h"

/* ─── per-spill detail record ────────────────────────────────────────────── */

typedef struct {
    unsigned  vreg;           /* original virtual register id                 */
    unsigned  slot_id;        /* stack slot allocated for this vreg (%slotN)  */
    ir_type_t vtype;          /* value type of the vreg                       */
    unsigned  use_def_count;  /* total def + use appearances in the function  */
    unsigned  degree;         /* node degree in the interference graph        */
    double    cost;           /* use_def_count / degree (lower = cheaper)     */
} spill_entry_t;

/* ─── result returned by spill_rewrite ───────────────────────────────────── */

typedef struct {
    unsigned       n_spilled; /* number of vregs spill-rewritten              */
    spill_entry_t *entries;   /* [n_spilled], sorted by cost ascending        */
} spill_result_t;

/* ─── construction / destruction ─────────────────────────────────────────── */

/*
 * Rewrite `func` in-place to eliminate every vreg marked REGALLOC_SPILL.
 *
 *   func  — the IR function to rewrite; new vregs and slots are allocated
 *            directly in this function.
 *   ra    — allocator result for the current iteration (read-only).
 *   g     — interference graph for the current iteration; used only to
 *            compute the cost/degree ordering (read-only).
 *
 * Returns a heap-allocated spill_result_t that the caller must free with
 * spill_result_free().  Returns NULL if ra->n_spills == 0 (nothing to do)
 * or on allocation failure.
 */
spill_result_t *spill_rewrite(ir_function_t    *func,
                               const regalloc_t *ra,
                               const ifg_t      *g);

void spill_result_free(spill_result_t *sr);

/* ─── debug printer ──────────────────────────────────────────────────────── */

/*
 * Print a human-readable summary of the spill rewrite:
 *   - one line per spilled vreg: id, slot, cost, refs/degree
 *   - total count and restart notice
 */
void spill_print(FILE                 *out,
                 const char           *func_name,
                 const spill_result_t *sr);

#endif /* REGALLOC_SPILL_H */
