#ifndef REGALLOC_LIVENESS_H
#define REGALLOC_LIVENESS_H

#include <stdint.h>
#include <stdio.h>
#include "../IR/ir.h"

/* ─── vreg bitset ─────────────────────────────────────────────────────────── */

typedef struct {
    uint64_t *words;
    unsigned  cap;    /* number of bits allocated (always a multiple of 64) */
} vreg_set_t;

void vreg_set_init   (vreg_set_t *s, unsigned n_vregs);
void vreg_set_free   (vreg_set_t *s);
void vreg_set_clear  (vreg_set_t *s);
void vreg_set_copy   (vreg_set_t *dst, const vreg_set_t *src);
void vreg_set_add    (vreg_set_t *s, unsigned vr);
void vreg_set_remove (vreg_set_t *s, unsigned vr);
int  vreg_set_has    (const vreg_set_t *s, unsigned vr);
/* dst |= src; returns 1 if dst changed, 0 otherwise */
int  vreg_set_union_into (vreg_set_t *dst, const vreg_set_t *src);
/* dst &= ~src */
void vreg_set_minus_into (vreg_set_t *dst, const vreg_set_t *src);
int  vreg_set_equal  (const vreg_set_t *a, const vreg_set_t *b);
/* print "{v0, v3, v7}" to out */
void vreg_set_print  (FILE *out, const vreg_set_t *s);

/* ─── per-block liveness ──────────────────────────────────────────────────── */

typedef struct {
    vreg_set_t use;       /* vregs read before being defined in this block  */
    vreg_set_t def;       /* vregs defined in this block                    */
    vreg_set_t live_in;   /* live at block entry                            */
    vreg_set_t live_out;  /* live at block exit                             */
} block_liveness_t;

/* ─── per-instruction liveness ───────────────────────────────────────────── */

typedef struct {
    const ir_instr_t *instr;       /* pointer into original IR (do not free) */
    vreg_set_t        live_after;  /* vregs live immediately after this instr */
} instr_live_t;

/* ─── full liveness result for one function ──────────────────────────────── */

typedef struct {
    unsigned          n_vregs;   /* == func->next_vreg                        */
    unsigned          n_blocks;  /* == func->next_block_id                    */
    unsigned          n_instrs;  /* total instructions across all blocks      */
    block_liveness_t *blk;       /* [n_blocks], indexed by block->id          */
    instr_live_t     *instr;     /* [n_instrs], in block-list order           */
} ir_liveness_t;

/* Compute full liveness for a function. Returns NULL on allocation failure. */
ir_liveness_t *ir_liveness_compute(const ir_function_t *func);
void           ir_liveness_free   (ir_liveness_t *liv);

/* Debug printer — prints live_in/live_out per block and live_after per instr */
void ir_liveness_print(FILE *out, const ir_function_t *func,
                       const ir_liveness_t *liv);

#endif /* REGALLOC_LIVENESS_H */
