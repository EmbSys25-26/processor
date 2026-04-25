#ifndef REGALLOC_REGALLOC_H
#define REGALLOC_REGALLOC_H

/*
 * regalloc.h — Etapa 4: Register Allocation (Chaitin-Briggs)
 *
 * Takes the outputs of the previous three stages and assigns every virtual
 * register a physical register (or marks it for spilling).
 *
 * Algorithm overview
 * ──────────────────
 *  1. Move coalescing (George's conservative test)
 *       Copy-related vregs that do not interfere are merged when safe:
 *       coalesce (a, b) iff for every heavy neighbor t of b,
 *       t already interferes with a.
 *       Produces an alias[] map: alias[b] = a means b was merged into a.
 *
 *  2. Simplification (Chaitin-style)
 *       Repeatedly push non-precolored nodes with effective degree < K onto
 *       a LIFO select-stack, decrementing their neighbours' working degrees.
 *       If no low-degree node exists, push the highest-degree node as a
 *       potential spill candidate and continue.
 *
 *  3. Color selection (LIFO pop)
 *       Pop nodes from the stack.  For each node, collect the colors already
 *       assigned to its interfering neighbours (including precolored nodes)
 *       and assign the first available color by preference order:
 *         • normal vregs:    r4–r7 → r8–r11 → r1–r3  (K = 11, r12/fp excluded)
 *         • call-live vregs: r8–r11 only               (K =  4, callee-saved)
 *       If no color is available the node is marked REGALLOC_SPILL.
 *
 *  4. Alias propagation
 *       Coalesced nodes inherit the color of their representative.
 *
 * ABI register map (from abi_spec.md):
 *   r1  (a0/v0)  1st arg / return value      caller-saved
 *   r2  (a1)     2nd arg                     caller-saved
 *   r3  (a2)     3rd arg                     caller-saved
 *   r4–r7 (t0–t3) temporaries               caller-saved
 *   r8–r11 (s0–s3) callee-saved
 *   r12 (fp)     frame pointer — NOT allocatable (reserved)
 */

#include <stdio.h>
#include "../IR/ir.h"
#include "interference.h"
#include "precolor.h"

/* ─── special color sentinels ────────────────────────────────────────────── */

/* Vreg could not be assigned any physical register — must be spilled. */
#define REGALLOC_SPILL ((phys_reg_t)254)

/* ─── result type ────────────────────────────────────────────────────────── */

typedef struct {
    unsigned    n_vregs;   /* equals func->next_vreg                         */
    phys_reg_t *color;     /* color[v]: physical reg, REGALLOC_SPILL, or
                              PHYS_NONE (node truly unused — no def/use)     */
    unsigned    n_spills;  /* number of vregs that could not be colored      */
} regalloc_t;

/* ─── construction / destruction ─────────────────────────────────────────── */

/*
 * Build the register allocation for one function.
 * All four arguments must outlive the returned result.
 * Returns NULL on allocation failure.
 */
regalloc_t *regalloc_build(const ir_function_t *func,
                            const ifg_t         *g,
                            const precolor_t    *pc);

void regalloc_free(regalloc_t *r);

/* ─── debug ──────────────────────────────────────────────────────────────── */

/*
 * Print the color assignment in human-readable form.
 * The precolor_t is used to annotate each line with how the color was
 * determined (precolored / callee-saved / allocated / coalesced).
 */
void regalloc_print(FILE *out, const char *func_name,
                    const regalloc_t *r, const precolor_t *pc);

#endif /* REGALLOC_REGALLOC_H */
