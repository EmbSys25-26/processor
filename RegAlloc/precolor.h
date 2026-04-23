#ifndef REGALLOC_PRECOLOR_H
#define REGALLOC_PRECOLOR_H

/*
 * precolor.h — Etapa 3: Pre-coloring
 *
 * Certain virtual registers are forced onto specific physical registers
 * by the ABI before the graph-coloring pass (Etapa 4) runs.
 *
 * ABI (abi_spec.md):
 *   r0        — hardwired zero, NOT allocatable
 *   r1 (a0)   — 1st arg / return value
 *   r2 (a1)   — 2nd arg
 *   r3 (a2)   — 3rd arg   (max 3 args in registers; remainder on stack)
 *   r4–r7     — caller-saved temporaries (t0–t3)
 *   r8–r11    — callee-saved (s0–s3)
 *   r12 (fp)  — frame pointer, callee-saved
 *   r13–r15   — sp / lr / gp, not allocatable
 *
 * Four patterns are recognised:
 *
 *   1. Function parameters
 *        The first param_count vregs (%v0, %v1, ...) hold incoming
 *        arguments.  Per ABI: 1st arg → r1, 2nd → r2, 3rd → r3.
 *        Parameters beyond the 3rd are passed on the stack — no precolor.
 *
 *   2. Return value
 *        Every "ret %vX" instruction requires %vX to be in r1 (a0).
 *
 *   3. Call result
 *        Every "%vd = call @f(...)" instruction places the return value
 *        in r1 (a0), so %vd is forced to r1.
 *
 *   4. Call arguments (Caller side)
 *        For "call @f(a0, a1, a2, ...)", the first PHYS_ARG_REGS argument
 *        vregs are forced to r1, r2, r3 respectively (ABI argument registers).
 *        If a vreg already has a conflicting precolor, the conflict is flagged
 *        and the Stage 4 coloring pass must resolve it by inserting a copy.
 *
 * Additionally, the precolor result carries a `call_live` bitset:
 *   Vregs live across ≥1 call site must NOT be assigned caller-saved
 *   registers (r1–r7); Stage 4 must restrict them to callee-saved regs
 *   (r8–r12) or spill them.
 *
 * Representation: a flat array indexed by vreg id.
 * PHYS_NONE (255) means "not pre-colored — allocator may choose freely".
 */

#include <stdio.h>
#include "../IR/ir.h"
#include "liveness.h"

/* ─── physical register identifiers ────────────────────────────────────────── */

/* Enum values equal the physical register number in the ISA. */
typedef enum {
    /* r0 is hardwired zero — never appears as a precolor target */
    PHYS_R1   = 1,   /* a0 / v0 — 1st arg, return value          */
    PHYS_R2   = 2,   /* a1      — 2nd arg                         */
    PHYS_R3   = 3,   /* a2      — 3rd arg                         */
    PHYS_R4   = 4,   /* t0      — caller-saved temporary          */
    PHYS_R5   = 5,   /* t1                                        */
    PHYS_R6   = 6,   /* t2                                        */
    PHYS_R7   = 7,   /* t3                                        */
    PHYS_R8   = 8,   /* s0      — callee-saved                    */
    PHYS_R9   = 9,   /* s1                                        */
    PHYS_R10  = 10,  /* s2                                        */
    PHYS_R11  = 11,  /* s3                                        */
    PHYS_R12  = 12,  /* fp      — frame pointer, callee-saved     */
    PHYS_NONE = 255  /* sentinel: not pre-colored                 */
} phys_reg_t;

/* r1–r12 are allocatable (r0, r13–r15 are reserved/special). */
#define PHYS_NUM_REGS   12
/* Only r1–r3 are used for argument passing. */
#define PHYS_ARG_REGS   3

/* ─── pre-color map ─────────────────────────────────────────────────────────── */

typedef struct {
    unsigned    n_vregs;     /* equals func->next_vreg at build time              */
    phys_reg_t *color;       /* color[v] for v in [0, n_vregs); PHYS_NONE if free */

    /*
     * call_live: set of vregs that are live across at least one call site.
     * These vregs must NOT be assigned a caller-saved register (r1–r7) by
     * Stage 4, because a CALL clobbers all caller-saved registers.
     * They must be placed in callee-saved registers (r8–r12) or be spilled.
     */
    vreg_set_t  call_live;
} precolor_t;

/* ─── construction / destruction ────────────────────────────────────────────── */

/*
 * Scan the function and build the pre-color map.
 * `liv` must be the liveness result for the same function; it is used to
 * populate the `call_live` set (vregs live across call boundaries).
 * Returns NULL on allocation failure.
 */
precolor_t *precolor_build(const ir_function_t *func, const ir_liveness_t *liv);

void        precolor_free(precolor_t *p);

/* ─── queries ───────────────────────────────────────────────────────────────── */

/* Returns PHYS_NONE if the vreg has no fixed physical register. */
phys_reg_t  precolor_get  (const precolor_t *p, unsigned vreg);

/* 1 iff vreg is forced to a specific physical register. */
int         precolor_is_fixed    (const precolor_t *p, unsigned vreg);

/* 1 iff the vreg is live across at least one call boundary.
 * Stage 4 must not assign this vreg to a caller-saved register (r1–r7). */
int         precolor_is_call_live(const precolor_t *p, unsigned vreg);

/* ─── debug ─────────────────────────────────────────────────────────────────── */

void precolor_print(FILE *out, const char *func_name, const precolor_t *p);

#endif /* REGALLOC_PRECOLOR_H */
