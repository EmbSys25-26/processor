/*
 * liveness.c — Etapa 1: Liveness Analysis
 *
 * Implements:
 *   1. use[B] / def[B] computation per basic block
 *   2. CFG successor / predecessor computation
 *   3. Reverse Post-Order (RPO) traversal
 *   4. Iterative worklist liveness (backward dataflow)
 *   5. live_after[i] computation per instruction
 */

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "liveness.h"

/* ═══════════════════════════════════════════════════════════════════════════
 * vreg_set_t — simple bitset for virtual registers
 * ═══════════════════════════════════════════════════════════════════════════ */

#define WORD_BITS 64u

/* Returns the number of 64-bit words needed to hold n_bits. */
static unsigned words_needed(unsigned n_bits)
{
    return (n_bits + WORD_BITS - 1u) / WORD_BITS;
}

/* Bitset primitives over vreg ids: init/free/clear/copy/add/remove/has/union/minus/equal/print. */
void vreg_set_init(vreg_set_t *s, unsigned n_vregs)
{
    unsigned nw = words_needed(n_vregs == 0 ? 1 : n_vregs);
    s->words = (uint64_t *)calloc(nw, sizeof(uint64_t));
    s->cap   = nw * WORD_BITS;
}

void vreg_set_free(vreg_set_t *s)
{
    free(s->words);
    s->words = NULL;
    s->cap   = 0;
}

void vreg_set_clear(vreg_set_t *s)
{
    memset(s->words, 0, words_needed(s->cap) * sizeof(uint64_t));
}

void vreg_set_copy(vreg_set_t *dst, const vreg_set_t *src)
{
    assert(dst->cap == src->cap);
    memcpy(dst->words, src->words, words_needed(dst->cap) * sizeof(uint64_t));
}

void vreg_set_add(vreg_set_t *s, unsigned vr)
{
    assert(vr < s->cap);
    s->words[vr / WORD_BITS] |= (uint64_t)1 << (vr % WORD_BITS);
}

void vreg_set_remove(vreg_set_t *s, unsigned vr)
{
    assert(vr < s->cap);
    s->words[vr / WORD_BITS] &= ~((uint64_t)1 << (vr % WORD_BITS));
}

int vreg_set_has(const vreg_set_t *s, unsigned vr)
{
    if (vr >= s->cap) return 0;
    return (s->words[vr / WORD_BITS] >> (vr % WORD_BITS)) & 1u;
}

int vreg_set_union_into(vreg_set_t *dst, const vreg_set_t *src)
{
    unsigned nw = words_needed(dst->cap);
    int changed = 0;
    for (unsigned i = 0; i < nw; i++) {
        uint64_t before = dst->words[i];
        dst->words[i] |= src->words[i];
        if (dst->words[i] != before) changed = 1;
    }
    return changed;
}

void vreg_set_minus_into(vreg_set_t *dst, const vreg_set_t *src)
{
    unsigned nw = words_needed(dst->cap);
    for (unsigned i = 0; i < nw; i++)
        dst->words[i] &= ~src->words[i];
}

int vreg_set_equal(const vreg_set_t *a, const vreg_set_t *b)
{
    unsigned nw = words_needed(a->cap);
    for (unsigned i = 0; i < nw; i++)
        if (a->words[i] != b->words[i]) return 0;
    return 1;
}

void vreg_set_print(FILE *out, const vreg_set_t *s)
{
    fprintf(out, "{");
    int first = 1;
    unsigned nw = words_needed(s->cap);
    for (unsigned w = 0; w < nw; w++) {
        uint64_t word = s->words[w];
        while (word) {
            unsigned bit = __builtin_ctzll(word);
            unsigned vr  = w * WORD_BITS + bit;
            if (!first) fprintf(out, ", ");
            fprintf(out, "%%v%u", vr);
            first = 0;
            word &= word - 1;
        }
    }
    fprintf(out, "}");
}

/* ═══════════════════════════════════════════════════════════════════════════
 * Instruction DEF / USE helpers
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Returns 1 and sets *vr if instruction defines a vreg; 0 otherwise */
/* Returns 1 and sets *vr if the instruction defines a vreg, else returns 0. */
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
        if (i->as.call.is_void_call) return 0;
        if (i->dst.kind != IR_VAL_VREG) return 0;
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

/* Fills uses[] with vreg IDs; returns count (at most max) */
/* Collects vreg-kind operands used by the instruction into uses[], returning the count. */
static unsigned instr_get_uses(const ir_instr_t *i, unsigned *uses, unsigned max)
{
    unsigned n = 0;
#define PUSH(v) do { if ((v).kind == IR_VAL_VREG && n < max) uses[n++] = (v).as.vreg; } while(0)

    switch (i->op) {
    case IR_OP_GOTO:
        break;

    case IR_OP_BRANCH:
        PUSH(i->src[0]);
        break;

    case IR_OP_SWITCH:
        PUSH(i->src[0]);
        break;

    case IR_OP_RET:
        PUSH(i->src[0]);
        break;

    case IR_OP_STORE:
        /* *src[0] = src[1]  →  both are uses */
        PUSH(i->src[0]);
        PUSH(i->src[1]);
        break;

    case IR_OP_CALL:
        for (unsigned k = 0; k < i->as.call.arg_count && n < max; k++)
            PUSH(i->as.call.args[k]);
        break;

    case IR_OP_ADDR_OF:
        /* src[0] is a slot/global, not a vreg */
        break;

    case IR_OP_CONST:
        /* src[0] is an immediate */
        break;

    default:
        /* All other ops: up to two vreg sources */
        PUSH(i->src[0]);
        PUSH(i->src[1]);
        break;
    }
#undef PUSH
    return n;
}

/* ═══════════════════════════════════════════════════════════════════════════
 * Internal CFG structure
 * ═══════════════════════════════════════════════════════════════════════════ */

typedef struct {
    unsigned *succ_ids;
    unsigned  n_succs;
    unsigned *pred_ids;
    unsigned  n_preds;
} cfg_node_t;

/* Fill out[] with successor block IDs of blk; returns count (max 2 normal, or
   up to IR_MAX_SWITCH_CASES+1 for switch) */
/* Writes the CFG successor block ids of blk into out[] and returns the count. */
static unsigned block_get_succs(const ir_block_t *blk, unsigned *out, unsigned max)
{
    const ir_instr_t *term = blk->tail;
    if (!term) return 0;
    unsigned n = 0;
    switch (term->op) {
    case IR_OP_GOTO:
        if (n < max) out[n++] = term->as.branch.true_block;
        break;
    case IR_OP_BRANCH:
        if (n < max) out[n++] = term->as.branch.true_block;
        if (n < max) out[n++] = term->as.branch.false_block;
        break;
    case IR_OP_SWITCH:
        if (n < max) out[n++] = term->as.sw.default_block;
        for (unsigned k = 0; k < term->as.sw.case_count && n < max; k++)
            out[n++] = term->as.sw.case_blocks[k];
        break;
    case IR_OP_RET:
    default:
        break;
    }
    return n;
}

/* ═══════════════════════════════════════════════════════════════════════════
 * RPO computation (DFS post-order, then reverse)
 * ═══════════════════════════════════════════════════════════════════════════ */

typedef struct {
    const ir_block_t **by_id;  /* block pointer indexed by block id */
    unsigned           n;      /* == func->next_block_id            */
} block_map_t;

/* DFS that emits block ids in postorder for later RPO reversal. */
static void dfs_postorder(unsigned id, const block_map_t *bmap,
                          const cfg_node_t *cfg,
                          int *visited,
                          unsigned *post, unsigned *post_count)
{
    if (visited[id]) return;
    visited[id] = 1;
    for (unsigned k = 0; k < cfg[id].n_succs; k++)
        dfs_postorder(cfg[id].succ_ids[k], bmap, cfg, visited, post, post_count);
    post[(*post_count)++] = id;
}

/* ═══════════════════════════════════════════════════════════════════════════
 * ir_liveness_compute
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Computes per-block use/def/live_in/live_out and per-instruction live_after via iterative worklist. */
ir_liveness_t *ir_liveness_compute(const ir_function_t *func)
{
    if (!func) return NULL;

    unsigned nv = func->next_vreg;     /* number of virtual registers */
    unsigned nb = func->next_block_id; /* number of basic blocks      */

    if (nb == 0) return NULL;

    /* ── 1. Build block map: id → ir_block_t* ── */
    block_map_t bmap;
    bmap.n    = nb;
    bmap.by_id = (const ir_block_t **)calloc(nb, sizeof(ir_block_t *));
    if (!bmap.by_id) return NULL;

    unsigned n_instrs = 0;
    for (const ir_block_t *b = func->entry; b; b = b->next) {
        bmap.by_id[b->id] = b;
        for (const ir_instr_t *i = b->head; i; i = i->next)
            n_instrs++;
    }

    /* ── 2. Build CFG (succs + preds) ── */
    cfg_node_t *cfg = (cfg_node_t *)calloc(nb, sizeof(cfg_node_t));
    if (!cfg) { free(bmap.by_id); return NULL; }

    /* Temporary storage for predecessor counts (to allocate exact arrays) */
    unsigned *pred_count = (unsigned *)calloc(nb, sizeof(unsigned));
    if (!pred_count) { free(cfg); free(bmap.by_id); return NULL; }

    /* First pass: count successors and predecessors */
    unsigned tmp_succs[IR_MAX_SWITCH_CASES + 2];
    for (unsigned id = 0; id < nb; id++) {
        if (!bmap.by_id[id]) continue;
        unsigned ns = block_get_succs(bmap.by_id[id], tmp_succs,
                                      IR_MAX_SWITCH_CASES + 2);
        cfg[id].n_succs = ns;
        for (unsigned k = 0; k < ns; k++)
            pred_count[tmp_succs[k]]++;
    }

    /* Allocate succ and pred arrays */
    for (unsigned id = 0; id < nb; id++) {
        cfg[id].succ_ids = (unsigned *)malloc(
            (cfg[id].n_succs ? cfg[id].n_succs : 1) * sizeof(unsigned));
        cfg[id].pred_ids = (unsigned *)malloc(
            (pred_count[id] ? pred_count[id] : 1) * sizeof(unsigned));
        cfg[id].n_preds = 0; /* will be filled below */
    }
    free(pred_count);

    /* Second pass: fill succ arrays and build pred arrays */
    for (unsigned id = 0; id < nb; id++) {
        if (!bmap.by_id[id]) continue;
        unsigned ns = block_get_succs(bmap.by_id[id], cfg[id].succ_ids,
                                      IR_MAX_SWITCH_CASES + 2);
        cfg[id].n_succs = ns;
        for (unsigned k = 0; k < ns; k++) {
            unsigned sid = cfg[id].succ_ids[k];
            cfg[sid].pred_ids[cfg[sid].n_preds++] = id;
        }
    }

    /* ── 3. Compute RPO from entry block ── */
    unsigned *rpo    = (unsigned *)malloc(nb * sizeof(unsigned));
    int      *visited = (int *)calloc(nb, sizeof(int));
    unsigned  post_count = 0;

    if (!rpo || !visited) {
        free(rpo); free(visited);
        for (unsigned i = 0; i < nb; i++) {
            free(cfg[i].succ_ids); free(cfg[i].pred_ids);
        }
        free(cfg); free(bmap.by_id);
        return NULL;
    }

    /* post[] is filled in postorder; we store directly into rpo reversed */
    unsigned *post = (unsigned *)malloc(nb * sizeof(unsigned));
    if (!post) {
        free(rpo); free(visited);
        for (unsigned i = 0; i < nb; i++) {
            free(cfg[i].succ_ids); free(cfg[i].pred_ids);
        }
        free(cfg); free(bmap.by_id);
        return NULL;
    }

    dfs_postorder(func->entry->id, &bmap, cfg, visited, post, &post_count);
    /* RPO = reverse of postorder */
    for (unsigned k = 0; k < post_count; k++)
        rpo[k] = post[post_count - 1 - k];
    free(post);
    free(visited);

    /* ── 4. Allocate result ── */
    ir_liveness_t *liv = (ir_liveness_t *)calloc(1, sizeof(ir_liveness_t));
    if (!liv) {
        free(rpo);
        for (unsigned i = 0; i < nb; i++) {
            free(cfg[i].succ_ids); free(cfg[i].pred_ids);
        }
        free(cfg); free(bmap.by_id);
        return NULL;
    }
    liv->n_vregs  = nv;
    liv->n_blocks = nb;
    liv->n_instrs = n_instrs;

    liv->blk = (block_liveness_t *)calloc(nb, sizeof(block_liveness_t));
    liv->instr = (instr_live_t *)calloc(n_instrs ? n_instrs : 1,
                                        sizeof(instr_live_t));
    if (!liv->blk || !liv->instr) {
        ir_liveness_free(liv);
        free(rpo);
        for (unsigned i = 0; i < nb; i++) {
            free(cfg[i].succ_ids); free(cfg[i].pred_ids);
        }
        free(cfg); free(bmap.by_id);
        return NULL;
    }

    /* Initialise all bitsets */
    unsigned ncap = nv == 0 ? 1 : nv;
    for (unsigned id = 0; id < nb; id++) {
        vreg_set_init(&liv->blk[id].use,      ncap);
        vreg_set_init(&liv->blk[id].def,      ncap);
        vreg_set_init(&liv->blk[id].live_in,  ncap);
        vreg_set_init(&liv->blk[id].live_out, ncap);
    }
    for (unsigned k = 0; k < n_instrs; k++)
        vreg_set_init(&liv->instr[k].live_after, ncap);

    /* ── 5. Compute use[B] and def[B] for every block ── */
    unsigned use_buf[IR_MAX_ARGS + 4];
    for (unsigned id = 0; id < nb; id++) {
        if (!bmap.by_id[id]) continue;
        block_liveness_t *bl = &liv->blk[id];
        for (const ir_instr_t *ins = bmap.by_id[id]->head; ins; ins = ins->next) {
            /* USEs first: only if not already in def[B] */
            unsigned nu = instr_get_uses(ins, use_buf, IR_MAX_ARGS + 4);
            for (unsigned k = 0; k < nu; k++) {
                unsigned vr = use_buf[k];
                if (!vreg_set_has(&bl->def, vr))
                    vreg_set_add(&bl->use, vr);
            }
            /* DEF */
            unsigned vrd;
            if (instr_get_def(ins, &vrd))
                vreg_set_add(&bl->def, vrd);
        }
    }

    /* ── 6. Iterative worklist liveness ── */

    /* in_wl[id] = 1 if block is already in the worklist */
    int      *in_wl = (int *)calloc(nb, sizeof(int));
    /* worklist: simple queue backed by a circular array */
    unsigned *wl    = (unsigned *)malloc(nb * sizeof(unsigned));
    unsigned  wl_head = 0, wl_tail = 0;

    if (!in_wl || !wl) {
        free(in_wl); free(wl); free(rpo);
        for (unsigned i = 0; i < nb; i++) {
            free(cfg[i].succ_ids); free(cfg[i].pred_ids);
        }
        free(cfg); free(bmap.by_id);
        ir_liveness_free(liv);
        return NULL;
    }

    /* Initialize worklist in RPO order */
    for (unsigned k = 0; k < post_count; k++) {
        unsigned id = rpo[k];
        wl[wl_tail++ % nb] = id;  /* circular enqueue */
        in_wl[id] = 1;
    }

    /* Scratch set reused across iterations */
    vreg_set_t new_live_in, new_live_out;
    vreg_set_init(&new_live_in,  ncap);
    vreg_set_init(&new_live_out, ncap);

    while (wl_head != wl_tail) {
        unsigned id = wl[wl_head++ % nb];
        in_wl[id] = 0;
        if (!bmap.by_id[id]) continue;

        block_liveness_t *bl = &liv->blk[id];

        /* new_live_out = union of live_in[succs] */
        vreg_set_clear(&new_live_out);
        for (unsigned k = 0; k < cfg[id].n_succs; k++) {
            unsigned sid = cfg[id].succ_ids[k];
            vreg_set_union_into(&new_live_out, &liv->blk[sid].live_in);
        }

        /* new_live_in = use[B] ∪ (new_live_out - def[B]) */
        vreg_set_copy(&new_live_in, &new_live_out);
        vreg_set_minus_into(&new_live_in, &bl->def);
        vreg_set_union_into(&new_live_in, &bl->use);

        /* If live_in changed, update and re-enqueue predecessors */
        if (!vreg_set_equal(&new_live_in, &bl->live_in)) {
            vreg_set_copy(&bl->live_in,  &new_live_in);
            vreg_set_copy(&bl->live_out, &new_live_out);
            for (unsigned k = 0; k < cfg[id].n_preds; k++) {
                unsigned pid = cfg[id].pred_ids[k];
                if (!in_wl[pid]) {
                    wl[wl_tail++ % nb] = pid;
                    in_wl[pid] = 1;
                }
            }
        } else {
            /* live_in unchanged, but live_out might still need updating */
            vreg_set_copy(&bl->live_out, &new_live_out);
        }
    }

    vreg_set_free(&new_live_in);
    vreg_set_free(&new_live_out);
    free(in_wl);
    free(wl);

    /* ── 7. Compute live_after per instruction (backward within each block) ── */
    unsigned instr_idx = 0;
    for (const ir_block_t *b = func->entry; b; b = b->next) {
        /* Collect instruction pointers for this block */
        unsigned block_start = instr_idx;
        unsigned block_len   = 0;
        for (const ir_instr_t *ins = b->head; ins; ins = ins->next) {
            liv->instr[instr_idx + block_len].instr = ins;
            block_len++;
        }

        if (block_len == 0) continue;

        /* We filled instr[block_start .. block_start+block_len-1] in forward order.
           Now do backward pass using live_out[B] as initial set. */
        vreg_set_t live_cur;
        vreg_set_init(&live_cur, ncap);
        vreg_set_copy(&live_cur, &liv->blk[b->id].live_out);

        for (int k = (int)block_len - 1; k >= 0; k--) {
            instr_live_t *il = &liv->instr[block_start + k];
            const ir_instr_t *ins = il->instr;

            /* live_after[k] = current live set before processing this instr */
            vreg_set_copy(&il->live_after, &live_cur);

            /* Propagate backward: remove DEF, add USEs */
            unsigned vrd;
            if (instr_get_def(ins, &vrd))
                vreg_set_remove(&live_cur, vrd);

            unsigned ubs[IR_MAX_ARGS + 4];
            unsigned nu = instr_get_uses(ins, ubs, IR_MAX_ARGS + 4);
            for (unsigned u = 0; u < nu; u++)
                vreg_set_add(&live_cur, ubs[u]);
        }

        vreg_set_free(&live_cur);
        instr_idx += block_len;
    }

    /* ── Cleanup internal structures ── */
    for (unsigned i = 0; i < nb; i++) {
        free(cfg[i].succ_ids);
        free(cfg[i].pred_ids);
    }
    free(cfg);
    free(bmap.by_id);
    free(rpo);

    return liv;
}

/* ═══════════════════════════════════════════════════════════════════════════
 * ir_liveness_free
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Releases all bitsets and arrays owned by the liveness result. */
void ir_liveness_free(ir_liveness_t *liv)
{
    if (!liv) return;

    if (liv->blk) {
        for (unsigned i = 0; i < liv->n_blocks; i++) {
            vreg_set_free(&liv->blk[i].use);
            vreg_set_free(&liv->blk[i].def);
            vreg_set_free(&liv->blk[i].live_in);
            vreg_set_free(&liv->blk[i].live_out);
        }
        free(liv->blk);
    }

    if (liv->instr) {
        for (unsigned k = 0; k < liv->n_instrs; k++)
            vreg_set_free(&liv->instr[k].live_after);
        free(liv->instr);
    }

    free(liv);
}

/* ═══════════════════════════════════════════════════════════════════════════
 * ir_liveness_print — debug printer
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Prints per-block sets and per-instruction live_after for debugging. */
void ir_liveness_print(FILE *out, const ir_function_t *func,
                       const ir_liveness_t *liv)
{
    if (!liv || !func) return;
    fprintf(out, "=== liveness: @%s ===\n", func->name);

    unsigned instr_idx = 0;
    for (const ir_block_t *b = func->entry; b; b = b->next) {
        unsigned id = b->id;
        fprintf(out, "  bb%u:\n", id);
        fprintf(out, "    use      = "); vreg_set_print(out, &liv->blk[id].use);      fprintf(out, "\n");
        fprintf(out, "    def      = "); vreg_set_print(out, &liv->blk[id].def);      fprintf(out, "\n");
        fprintf(out, "    live_in  = "); vreg_set_print(out, &liv->blk[id].live_in);  fprintf(out, "\n");
        fprintf(out, "    live_out = "); vreg_set_print(out, &liv->blk[id].live_out); fprintf(out, "\n");
        fprintf(out, "    instructions:\n");
        for (const ir_instr_t *ins = b->head; ins; ins = ins->next, instr_idx++) {
            fprintf(out, "      [%3u] ", instr_idx);
            ir_instr_print(out, ins);
            fprintf(out, "           live_after = ");
            vreg_set_print(out, &liv->instr[instr_idx].live_after);
            fprintf(out, "\n");
        }
    }
}
