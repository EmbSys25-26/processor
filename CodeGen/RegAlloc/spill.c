/*
 * spill.c — Stage 5: Spill Rewriting
 *
 * Transforms the IR of a function so that every vreg marked REGALLOC_SPILL
 * by the register allocator is replaced with stack-slot load/store sequences,
 * shrinking its live range to a single instruction.
 *
 * Pipeline position:
 *   [liveness] → [IFG] → [precolour] → [regalloc] → [spill] → (repeat)
 *
 * The caller loops until regalloc reports n_spills == 0.
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "spill.h"

/* ─── helpers: IR scanning ───────────────────────────────────────────────── */

/*
 * Scan every instruction in `func` for the unique definition of vreg `v`
 * and return its declared type.  Returns i16 as a safe fallback when no
 * explicit definition is found (e.g. implicit parameter vregs).
 */
static ir_type_t find_vreg_type(const ir_function_t *func, unsigned v)
{
    for (const ir_block_t *b = func->entry; b; b = b->next)
        for (const ir_instr_t *i = b->head; i; i = i->next)
            if (i->dst.kind == IR_VAL_VREG && i->dst.as.vreg == v)
                return i->dst.type;
    return ir_type_i16();
}

/*
 * Count all def and use sites of vreg `v` across the entire function.
 * Numerator of the spill cost heuristic.
 */
static unsigned count_use_def(const ir_function_t *func, unsigned v)
{
    unsigned n = 0;
    for (const ir_block_t *b = func->entry; b; b = b->next) {
        for (const ir_instr_t *i = b->head; i; i = i->next) {
            if (i->dst.kind    == IR_VAL_VREG && i->dst.as.vreg    == v) n++;
            if (i->src[0].kind == IR_VAL_VREG && i->src[0].as.vreg == v) n++;
            if (i->src[1].kind == IR_VAL_VREG && i->src[1].as.vreg == v) n++;
            if (i->op == IR_OP_CALL)
                for (unsigned k = 0; k < i->as.call.arg_count; k++)
                    if (i->as.call.args[k].kind == IR_VAL_VREG &&
                        i->as.call.args[k].as.vreg == v) n++;
        }
    }
    return n;
}

/* ─── helpers: new instruction list builder ──────────────────────────────── */

/* Append `i` to the new instruction list being constructed in-place. */
static void list_push(ir_instr_t **head, ir_instr_t **tail, ir_instr_t *i)
{
    i->next = NULL;
    if (!*head) { *head = *tail = i; }
    else        { (*tail)->next = i; *tail = i; }
}

/* ─── helpers: spill code emission ──────────────────────────────────────── */

/*
 * Emit a reload sequence into the new list being built:
 *
 *     %vPtr    = addr_of %slotS        ; PTR to the spill slot
 *     %vReload = *%vPtr                ; load the spilled value
 *
 * Returns the id of the fresh reload vreg so the caller can patch operands.
 */
static unsigned emit_reload(ir_function_t *func,
                             ir_instr_t   **head,
                             ir_instr_t   **tail,
                             unsigned       slot_id,
                             ir_type_t      vtype)
{
    unsigned    ptr_v = ir_new_vreg(func);
    ir_instr_t *addr  = ir_instr_new(IR_OP_ADDR_OF);
    addr->dst    = ir_val_vreg(ptr_v, ir_type_ptr());
    addr->src[0] = ir_val_slot(slot_id, vtype);
    list_push(head, tail, addr);

    unsigned    reload_v = ir_new_vreg(func);
    ir_instr_t *load     = ir_instr_new(IR_OP_LOAD);
    load->dst    = ir_val_vreg(reload_v, vtype);
    load->src[0] = ir_val_vreg(ptr_v, ir_type_ptr());
    list_push(head, tail, load);

    return reload_v;
}

/*
 * Emit a spill write-back sequence into the new list being built:
 *
 *     %vPtr   = addr_of %slotS        ; PTR to the spill slot
 *     *%vPtr  = %vSpilled             ; store the just-defined value
 */
static void emit_store_spill(ir_function_t *func,
                              ir_instr_t   **head,
                              ir_instr_t   **tail,
                              unsigned       slot_id,
                              unsigned       spilled_vreg,
                              ir_type_t      vtype)
{
    unsigned    ptr_v = ir_new_vreg(func);
    ir_instr_t *addr  = ir_instr_new(IR_OP_ADDR_OF);
    addr->dst    = ir_val_vreg(ptr_v, ir_type_ptr());
    addr->src[0] = ir_val_slot(slot_id, vtype);
    list_push(head, tail, addr);

    ir_instr_t *store = ir_instr_new(IR_OP_STORE);
    store->src[0] = ir_val_vreg(ptr_v, ir_type_ptr());
    store->src[1] = ir_val_vreg(spilled_vreg, vtype);
    list_push(head, tail, store);
}

/* ─── heuristic comparator ───────────────────────────────────────────────── */

/* qsort comparator: ascending cost (cheapest-to-spill first). */
static int cmp_cost(const void *a, const void *b)
{
    const spill_entry_t *ea = (const spill_entry_t *)a;
    const spill_entry_t *eb = (const spill_entry_t *)b;
    if (ea->cost < eb->cost) return -1;
    if (ea->cost > eb->cost) return  1;
    return 0;
}

/* ─── public API ─────────────────────────────────────────────────────────── */

spill_result_t *spill_rewrite(ir_function_t    *func,
                               const regalloc_t *ra,
                               const ifg_t      *g)
{
    if (!func || !ra || ra->n_spills == 0) return NULL;

    unsigned n = ra->n_spills;

    spill_result_t *sr = calloc(1, sizeof(*sr));
    if (!sr) return NULL;

    sr->entries = malloc(n * sizeof(*sr->entries));
    if (!sr->entries) { free(sr); return NULL; }
    sr->n_spilled = n;

    /* ── Phase A: collect spilled vregs, compute cost, allocate slots ─────
     *
     * One stack slot is allocated per spilled vreg.  The slot name encodes
     * the original vreg id so it is identifiable in IR dumps.
     * ──────────────────────────────────────────────────────────────────── */

    unsigned ei = 0;
    for (unsigned v = 0; v < ra->n_vregs; v++) {
        if (ra->color[v] != REGALLOC_SPILL) continue;

        unsigned udc = count_use_def(func, v);
        unsigned deg = ifg_degree(g, v);

        sr->entries[ei].vreg          = v;
        sr->entries[ei].vtype         = find_vreg_type(func, v);
        sr->entries[ei].use_def_count = udc;
        sr->entries[ei].degree        = deg;
        sr->entries[ei].cost          = (deg > 0)
                                        ? (double)udc / (double)deg
                                        : (double)udc * 1000.0;

        char slot_name[64];
        snprintf(slot_name, sizeof(slot_name), "__spill_v%u", v);
        sr->entries[ei].slot_id = ir_new_slot(func, slot_name,
                                               sr->entries[ei].vtype);
        ei++;
    }

    /* Sort: cheapest spill first (fewest load/stores per edge freed). */
    qsort(sr->entries, n, sizeof(*sr->entries), cmp_cost);

    /* ── Phase B: rewrite every basic block ───────────────────────────────
     *
     * For each instruction we rebuild the block's instruction list in-place:
     *
     *   1. USE pass  — for every spilled vreg read by the instruction, emit
     *                  addr_of + load into the new list and replace the
     *                  operand with the fresh reload vreg.
     *
     *   2. Append    — the (possibly modified) instruction itself.
     *
     *   3. DEF pass  — if the instruction defines a spilled vreg, emit
     *                  addr_of + store into the new list immediately after.
     *
     * This ordering guarantees:
     *   • Reloads are available before the instruction executes.
     *   • The newly computed value is stored to the slot right after the
     *     instruction, keeping the original vreg's live range to 1 instr.
     * ──────────────────────────────────────────────────────────────────── */

    for (ir_block_t *block = func->entry; block; block = block->next) {
        ir_instr_t *new_head = NULL, *new_tail = NULL;
        ir_instr_t *instr    = block->head;

        while (instr) {
            /* Save the original next pointer before list_push clobbers it. */
            ir_instr_t *next_i = instr->next;

            /* ── 1. USE pass ── */
            for (unsigned si = 0; si < n; si++) {
                unsigned  spv = sr->entries[si].vreg;
                unsigned  slt = sr->entries[si].slot_id;
                ir_type_t sty = sr->entries[si].vtype;

                /* src[0] */
                if (instr->src[0].kind == IR_VAL_VREG &&
                    instr->src[0].as.vreg == spv) {
                    unsigned rv   = emit_reload(func, &new_head, &new_tail, slt, sty);
                    instr->src[0] = ir_val_vreg(rv, sty);
                }

                /* src[1] */
                if (instr->src[1].kind == IR_VAL_VREG &&
                    instr->src[1].as.vreg == spv) {
                    unsigned rv   = emit_reload(func, &new_head, &new_tail, slt, sty);
                    instr->src[1] = ir_val_vreg(rv, sty);
                }

                /* call arguments */
                if (instr->op == IR_OP_CALL) {
                    for (unsigned k = 0; k < instr->as.call.arg_count; k++) {
                        if (instr->as.call.args[k].kind == IR_VAL_VREG &&
                            instr->as.call.args[k].as.vreg == spv) {
                            unsigned rv = emit_reload(func, &new_head, &new_tail,
                                                      slt, sty);
                            instr->as.call.args[k] = ir_val_vreg(rv, sty);
                        }
                    }
                }
            }

            /* ── 2. Append the (modified) instruction ── */
            list_push(&new_head, &new_tail, instr);

            /* ── 3. DEF pass ── */
            if (instr->dst.kind == IR_VAL_VREG) {
                for (unsigned si = 0; si < n; si++) {
                    if (instr->dst.as.vreg == sr->entries[si].vreg) {
                        emit_store_spill(func, &new_head, &new_tail,
                                         sr->entries[si].slot_id,
                                         sr->entries[si].vreg,
                                         sr->entries[si].vtype);
                        break; /* a vreg has exactly one definition */
                    }
                }
            }

            instr = next_i;
        }

        block->head = new_head;
        block->tail = new_tail;
    }

    return sr;
}

void spill_result_free(spill_result_t *sr)
{
    if (!sr) return;
    free(sr->entries);
    free(sr);
}

/* ─── debug printer ──────────────────────────────────────────────────────── */

void spill_print(FILE *out, const char *func_name, const spill_result_t *sr)
{
    if (!sr || sr->n_spilled == 0) {
        fprintf(out, "spill: @%s — no spills\n", func_name);
        return;
    }

    fprintf(out, "spill rewrite for @%s  (%u vreg(s)):\n",
            func_name, sr->n_spilled);

    for (unsigned i = 0; i < sr->n_spilled; i++) {
        const spill_entry_t *e = &sr->entries[i];
        fprintf(out,
                "  %%v%-3u  →  %%slot%-2u  (__spill_v%u)"
                "   cost=%-6.2f  [%u ref(s) / deg %u]\n",
                e->vreg, e->slot_id, e->vreg,
                e->cost, e->use_def_count, e->degree);
    }

    fprintf(out, "  restarting pipeline\n");
}
