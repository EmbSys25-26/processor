/*
 * test_liveness.c — unit tests for Etapa 1 (Liveness Analysis)
 *
 * Builds IR functions by hand and verifies:
 *   - use[B] / def[B]
 *   - live_in[B] / live_out[B]
 *   - live_after per instruction
 *
 * Three test functions:
 *   1. linear   — straight-line code, no branches
 *   2. iftest   — if/else, cross-block propagation
 *   3. looptest — back edge, worklist convergence
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "../IR/ir.h"
#include "liveness.h"

/* ─── assertion helper ───────────────────────────────────────────────────── */

#define CHECK(expr, msg) \
    do { \
        if (!(expr)) { \
            fprintf(stderr, "FAIL [%s:%d] %s\n", __FILE__, __LINE__, (msg)); \
            exit(1); \
        } \
    } while(0)

#define PASS(name) fprintf(stdout, "  PASS  %s\n", (name))

/* ─── IR builder helpers ─────────────────────────────────────────────────── */

static ir_instr_t *mk_const(ir_function_t *f, ir_block_t *b, long val)
{
    unsigned vr = ir_new_vreg(f);
    ir_instr_t *i = ir_instr_new(IR_OP_CONST);
    i->dst    = ir_val_vreg(vr, ir_type_i16());
    i->src[0] = ir_val_imm(val, ir_type_i16());
    ir_instr_push(b, i);
    return i;  /* caller can read i->dst.as.vreg */
}

static ir_instr_t *mk_binop_imm(ir_function_t *f, ir_block_t *b,
                                  ir_opcode_t op, unsigned vr_a, long imm_b)
{
    unsigned vr = ir_new_vreg(f);
    ir_instr_t *i = ir_instr_new(op);
    i->dst    = ir_val_vreg(vr, ir_type_i16());
    i->src[0] = ir_val_vreg(vr_a, ir_type_i16());
    i->src[1] = ir_val_imm(imm_b, ir_type_i16());
    ir_instr_push(b, i);
    return i;
}

static void mk_ret(ir_block_t *b, unsigned vr)
{
    ir_instr_t *i = ir_instr_new(IR_OP_RET);
    i->src[0] = ir_val_vreg(vr, ir_type_i16());
    ir_instr_push(b, i);
}

static void mk_goto(ir_block_t *b, unsigned target_id)
{
    ir_instr_t *i = ir_instr_new(IR_OP_GOTO);
    i->as.branch.true_block = target_id;
    ir_instr_push(b, i);
}

static void mk_branch(ir_block_t *b, unsigned cond_vr,
                       unsigned true_id, unsigned false_id)
{
    ir_instr_t *i = ir_instr_new(IR_OP_BRANCH);
    i->src[0] = ir_val_vreg(cond_vr, ir_type_i1());
    i->as.branch.true_block  = true_id;
    i->as.branch.false_block = false_id;
    ir_instr_push(b, i);
}

/* ═══════════════════════════════════════════════════════════════════════════
 * TEST 1 — linear: single basic block, straight-line code
 *
 * func @linear() -> i16 {
 * bb0:
 *   %v0 = 42            (const)
 *   %v1 = %v0 add 1     (binop_imm)
 *   ret %v1
 * }
 *
 * Expected:
 *   use[bb0] = {}, def[bb0] = {v0, v1}
 *   live_in[bb0]  = {}
 *   live_out[bb0] = {}
 *   live_after[const v0]    = {v0}
 *   live_after[add → v1]    = {v1}
 *   live_after[ret]         = {}
 * ═══════════════════════════════════════════════════════════════════════════ */

static void test_linear(void)
{
    ir_function_t *f = ir_function_new("linear", ir_type_i16());

    ir_block_t *bb0 = ir_block_new(f);
    ir_block_append(f, bb0);

    ir_instr_t *i_const = mk_const(f, bb0, 42);           /* v0 = 42  */
    unsigned v0 = i_const->dst.as.vreg;                   /* == 0     */

    ir_instr_t *i_add = mk_binop_imm(f, bb0, IR_OP_ADD, v0, 1); /* v1 = v0+1 */
    unsigned v1 = i_add->dst.as.vreg;                     /* == 1     */

    ir_instr_t *i_ret = ir_instr_new(IR_OP_RET);
    i_ret->src[0] = ir_val_vreg(v1, ir_type_i16());
    ir_instr_push(bb0, i_ret);

    ir_liveness_t *liv = ir_liveness_compute(f);
    assert(liv);

    /* use[bb0] = {} */
    CHECK(!vreg_set_has(&liv->blk[0].use, v0), "use[bb0] should NOT have v0");
    CHECK(!vreg_set_has(&liv->blk[0].use, v1), "use[bb0] should NOT have v1");

    /* def[bb0] = {v0, v1} */
    CHECK(vreg_set_has(&liv->blk[0].def, v0), "def[bb0] should have v0");
    CHECK(vreg_set_has(&liv->blk[0].def, v1), "def[bb0] should have v1");

    /* live_in[bb0] = {} */
    CHECK(!vreg_set_has(&liv->blk[0].live_in, v0), "live_in[bb0] should be empty");

    /* live_out[bb0] = {} */
    CHECK(!vreg_set_has(&liv->blk[0].live_out, v0), "live_out[bb0] should be empty");

    /* live_after[const]: v0 is live (used by the next instruction) */
    /* instr[0] = const, instr[1] = add, instr[2] = ret */
    CHECK( vreg_set_has(&liv->instr[0].live_after, v0), "live_after[const] should have v0");
    CHECK(!vreg_set_has(&liv->instr[0].live_after, v1), "live_after[const] should NOT have v1");

    /* live_after[add]: v1 is live (used by ret) */
    CHECK(!vreg_set_has(&liv->instr[1].live_after, v0), "live_after[add] should NOT have v0");
    CHECK( vreg_set_has(&liv->instr[1].live_after, v1), "live_after[add] should have v1");

    /* live_after[ret]: nothing live */
    CHECK(!vreg_set_has(&liv->instr[2].live_after, v0), "live_after[ret] should be empty");
    CHECK(!vreg_set_has(&liv->instr[2].live_after, v1), "live_after[ret] should be empty");

    ir_liveness_free(liv);
    ir_function_free(f);
    PASS("linear");
}

/* ═══════════════════════════════════════════════════════════════════════════
 * TEST 2 — iftest: if/else, cross-block propagation
 *
 * func @iftest() -> i16 {
 * bb0:
 *   %v0 = 1                         (const — used as branch condition)
 *   %v1 = 1                         (const — used in both branches)
 *   if %v0 goto bb1 else bb2
 * bb1:
 *   %v2 = %v1 add 1                 (USE v1 from bb0)
 *   ret %v2
 * bb2:
 *   %v3 = %v1 sub 1                 (USE v1 from bb0)
 *   ret %v3
 * }
 *
 * Expected:
 *   live_in[bb0]  = {}
 *   live_out[bb0] = {v1}   (v1 is needed by both successors)
 *   live_in[bb1]  = {v1}
 *   live_out[bb1] = {}
 *   live_in[bb2]  = {v1}
 *   live_out[bb2] = {}
 *   live_after[const v0]  = {v0, v1}  (both alive after first const)
 *   live_after[const v1]  = {v0, v1}
 *   live_after[branch]    = {}
 * ═══════════════════════════════════════════════════════════════════════════ */

static void test_iftest(void)
{
    ir_function_t *f = ir_function_new("iftest", ir_type_i16());

    ir_block_t *bb0 = ir_block_new(f);  /* id = 0 */
    ir_block_t *bb1 = ir_block_new(f);  /* id = 1 */
    ir_block_t *bb2 = ir_block_new(f);  /* id = 2 */
    ir_block_append(f, bb0);
    ir_block_append(f, bb1);
    ir_block_append(f, bb2);

    /* bb0 */
    ir_instr_t *i_c0 = mk_const(f, bb0, 1);       unsigned v0 = i_c0->dst.as.vreg; /* 0 */
    ir_instr_t *i_c1 = mk_const(f, bb0, 1);       unsigned v1 = i_c1->dst.as.vreg; /* 1 */
    mk_branch(bb0, v0, bb1->id, bb2->id);

    /* bb1 */
    ir_instr_t *i_add = mk_binop_imm(f, bb1, IR_OP_ADD, v1, 1); unsigned v2 = i_add->dst.as.vreg; /* 2 */
    mk_ret(bb1, v2);

    /* bb2 */
    ir_instr_t *i_sub = mk_binop_imm(f, bb2, IR_OP_SUB, v1, 1); unsigned v3 = i_sub->dst.as.vreg; /* 3 */
    mk_ret(bb2, v3);

    ir_liveness_t *liv = ir_liveness_compute(f);
    assert(liv);

    /* live_in[bb0] = {} */
    CHECK(!vreg_set_has(&liv->blk[0].live_in, v0), "live_in[bb0] should NOT have v0");
    CHECK(!vreg_set_has(&liv->blk[0].live_in, v1), "live_in[bb0] should NOT have v1");

    /* live_out[bb0] = {v1} */
    CHECK(!vreg_set_has(&liv->blk[0].live_out, v0), "live_out[bb0] should NOT have v0");
    CHECK( vreg_set_has(&liv->blk[0].live_out, v1), "live_out[bb0] should have v1");

    /* live_in[bb1] = {v1} */
    CHECK( vreg_set_has(&liv->blk[1].live_in, v1), "live_in[bb1] should have v1");
    CHECK(!vreg_set_has(&liv->blk[1].live_in, v2), "live_in[bb1] should NOT have v2");

    /* live_out[bb1] = {} */
    CHECK(!vreg_set_has(&liv->blk[1].live_out, v1), "live_out[bb1] should be empty");
    CHECK(!vreg_set_has(&liv->blk[1].live_out, v2), "live_out[bb1] should be empty");

    /* live_in[bb2] = {v1} */
    CHECK( vreg_set_has(&liv->blk[2].live_in, v1), "live_in[bb2] should have v1");

    /* live_out[bb2] = {} */
    CHECK(!vreg_set_has(&liv->blk[2].live_out, v1), "live_out[bb2] should be empty");

    /* Backward pass in bb0 from live_out={v1}:
     *   branch:   live_after={v1},    USE v0 → cur={v1,v0}
     *   const v1: live_after={v1,v0}, DEF v1 → cur={v0}
     *   const v0: live_after={v0},    DEF v0 → cur={}
     */
    /* live_after[const v0] (instr[0]) = {v0} only — v1 not yet born at this point */
    CHECK( vreg_set_has(&liv->instr[0].live_after, v0), "live_after[const v0] should have v0");
    CHECK(!vreg_set_has(&liv->instr[0].live_after, v1), "live_after[const v0] should NOT have v1");

    /* live_after[const v1] (instr[1]) = {v0, v1} */
    CHECK( vreg_set_has(&liv->instr[1].live_after, v0), "live_after[const v1] should have v0");
    CHECK( vreg_set_has(&liv->instr[1].live_after, v1), "live_after[const v1] should have v1");

    /* live_after[branch] (instr[2]) = live_out[bb0] = {v1}
     * v0 was consumed by the branch; only v1 crosses into successors */
    CHECK(!vreg_set_has(&liv->instr[2].live_after, v0), "live_after[branch] should NOT have v0");
    CHECK( vreg_set_has(&liv->instr[2].live_after, v1), "live_after[branch] should have v1");

    /* use[bb1] = {v1}, use[bb2] = {v1} */
    CHECK( vreg_set_has(&liv->blk[1].use, v1), "use[bb1] should have v1");
    CHECK( vreg_set_has(&liv->blk[2].use, v1), "use[bb2] should have v1");
    CHECK(!vreg_set_has(&liv->blk[1].use, v0), "use[bb1] should NOT have v0");

    ir_liveness_free(liv);
    ir_function_free(f);
    PASS("iftest");
}

/* ═══════════════════════════════════════════════════════════════════════════
 * TEST 3 — looptest: back edge, worklist must iterate to fixpoint
 *
 * func @looptest() -> i16 {
 * bb0:
 *   %v0 = 10             (const)
 *   goto bb1
 * bb1:
 *   %v1 = %v0 sub 1      (USE v0 — live from bb0 AND from back edge)
 *   %v2 = %v1 gts 0
 *   if %v2 goto bb1 else bb2
 * bb2:
 *   ret %v1              (USE v1 — defined in bb1)
 * }
 *
 * Expected (after fixpoint):
 *   live_in[bb0]  = {}
 *   live_out[bb0] = {v0}
 *   live_in[bb1]  = {v0}
 *   live_out[bb1] = {v0, v1}   (v0: back edge needs it; v1: bb2 needs it)
 *   live_in[bb2]  = {v1}
 *   live_out[bb2] = {}
 *   live_after[v1 = v0 sub 1] = {v0, v1}
 *   live_after[v2 = v1 gts 0] = {v0, v1, v2}... wait:
 *     backward from {v0,v1}: USE v2 → {v0,v1,v2}; this is live_after for that instr
 *     DEF v2; USE v1 → live = {v0, v1}
 *     DEF v1; USE v0 → live = {v0}
 *   live_after[sub]    = {v0, v1}
 *   live_after[gts]    = {v0, v1, v2}   (before DEF v2)...
 *     No: live_after[gts] is the set AFTER the gts instr:
 *     backward from live_out:
 *       branch: live_after = {v0,v1}, adds v2 → cur={v0,v1,v2}
 *       gts:    live_after = {v0,v1,v2}, DEF v2 → cur={v0,v1}, USE v1 → already in
 *     So live_after[gts] = {v0, v1, v2}
 *   live_after[sub]    = {v0, v1}
 *   live_after[branch] = {}      (it IS a terminator, live_after = live_out[bb1]? No)
 *
 *   Actually: live_after[branch] is computed FIRST in the backward pass:
 *     live_cur = live_out[bb1] = {v0, v1}
 *     branch: live_after = {v0, v1}, USE v2 → cur = {v0, v1, v2}
 *     gts:    live_after = {v0, v1, v2}, DEF v2 → cur = {v0, v1}
 *     sub:    live_after = {v0, v1}, DEF v1 → cur = {v0}, USE v0 → already
 *   final = {v0} = live_in[bb1] ✓
 * ═══════════════════════════════════════════════════════════════════════════ */

static void test_looptest(void)
{
    ir_function_t *f = ir_function_new("looptest", ir_type_i16());

    ir_block_t *bb0 = ir_block_new(f);  /* id = 0 */
    ir_block_t *bb1 = ir_block_new(f);  /* id = 1 */
    ir_block_t *bb2 = ir_block_new(f);  /* id = 2 */
    ir_block_append(f, bb0);
    ir_block_append(f, bb1);
    ir_block_append(f, bb2);

    /* bb0: v0 = 10; goto bb1 */
    ir_instr_t *i_c = mk_const(f, bb0, 10);  unsigned v0 = i_c->dst.as.vreg; /* 0 */
    mk_goto(bb0, bb1->id);

    /* bb1: v1 = v0-1; v2 = v1 gts 0; if v2 goto bb1 else bb2 */
    ir_instr_t *i_sub = mk_binop_imm(f, bb1, IR_OP_SUB, v0, 1);
    unsigned v1 = i_sub->dst.as.vreg; /* 1 */

    ir_instr_t *i_cmp = mk_binop_imm(f, bb1, IR_OP_GTS, v1, 0);
    unsigned v2 = i_cmp->dst.as.vreg; /* 2 */

    mk_branch(bb1, v2, bb1->id, bb2->id);  /* back edge to bb1 */

    /* bb2: ret v1 */
    mk_ret(bb2, v1);

    ir_liveness_t *liv = ir_liveness_compute(f);
    assert(liv);

    /* live_in[bb0]  = {} */
    CHECK(!vreg_set_has(&liv->blk[0].live_in,  v0), "live_in[bb0] empty");

    /* live_out[bb0] = {v0} */
    CHECK( vreg_set_has(&liv->blk[0].live_out, v0), "live_out[bb0] has v0");
    CHECK(!vreg_set_has(&liv->blk[0].live_out, v1), "live_out[bb0] no v1");

    /* live_in[bb1]  = {v0} */
    CHECK( vreg_set_has(&liv->blk[1].live_in,  v0), "live_in[bb1] has v0");
    CHECK(!vreg_set_has(&liv->blk[1].live_in,  v1), "live_in[bb1] no v1");
    CHECK(!vreg_set_has(&liv->blk[1].live_in,  v2), "live_in[bb1] no v2");

    /* live_out[bb1] = {v0, v1} */
    CHECK( vreg_set_has(&liv->blk[1].live_out, v0), "live_out[bb1] has v0 (back edge)");
    CHECK( vreg_set_has(&liv->blk[1].live_out, v1), "live_out[bb1] has v1 (for bb2)");
    CHECK(!vreg_set_has(&liv->blk[1].live_out, v2), "live_out[bb1] no v2");

    /* live_in[bb2]  = {v1} */
    CHECK(!vreg_set_has(&liv->blk[2].live_in,  v0), "live_in[bb2] no v0");
    CHECK( vreg_set_has(&liv->blk[2].live_in,  v1), "live_in[bb2] has v1");

    /* live_out[bb2] = {} */
    CHECK(!vreg_set_has(&liv->blk[2].live_out, v0), "live_out[bb2] empty");
    CHECK(!vreg_set_has(&liv->blk[2].live_out, v1), "live_out[bb2] empty");

    /* use[bb2] = {v1} */
    CHECK( vreg_set_has(&liv->blk[2].use, v1), "use[bb2] has v1");
    CHECK(!vreg_set_has(&liv->blk[2].use, v0), "use[bb2] no v0");

    /* live_after per instruction in bb1:
     * instr layout: [0]=const(bb0), [1]=goto(bb0), [2]=sub(bb1), [3]=gts(bb1), [4]=branch(bb1), [5]=ret(bb2)
     * sub  (instr[2]): live_after = {v0, v1}
     * gts  (instr[3]): live_after = {v0, v1, v2}  (v2 not yet defined going backward)
     * branch(instr[4]): live_after = {v0, v1}      (== live_out[bb1])
     */
    /* instr[2] = sub  → live_after = {v0, v1} */
    CHECK( vreg_set_has(&liv->instr[2].live_after, v0), "live_after[sub] has v0");
    CHECK( vreg_set_has(&liv->instr[2].live_after, v1), "live_after[sub] has v1");
    CHECK(!vreg_set_has(&liv->instr[2].live_after, v2), "live_after[sub] no v2");

    /* instr[3] = gts  → live_after = {v0, v1, v2} */
    CHECK( vreg_set_has(&liv->instr[3].live_after, v0), "live_after[gts] has v0");
    CHECK( vreg_set_has(&liv->instr[3].live_after, v1), "live_after[gts] has v1");
    CHECK( vreg_set_has(&liv->instr[3].live_after, v2), "live_after[gts] has v2");

    /* instr[4] = branch → live_after = live_out[bb1] = {v0, v1} */
    CHECK( vreg_set_has(&liv->instr[4].live_after, v0), "live_after[branch] has v0");
    CHECK( vreg_set_has(&liv->instr[4].live_after, v1), "live_after[branch] has v1");
    CHECK(!vreg_set_has(&liv->instr[4].live_after, v2), "live_after[branch] no v2");

    ir_liveness_free(liv);
    ir_function_free(f);
    PASS("looptest");
}

/* ═══════════════════════════════════════════════════════════════════════════
 * TEST 4 — store_test: STORE instruction uses both src operands
 *
 * func @store_test() -> i16 {
 * bb0:
 *   %v0 = addr_of %slot0
 *   %v1 = 99
 *   *%v0 = %v1          (STORE: USE v0 and v1)
 *   %v2 = *%v0          (LOAD: USE v0, DEF v2)
 *   ret %v2
 * }
 *
 * Expected:
 *   live_after[addr_of] = {v0, v1}  ... wait: v1 not defined yet
 *   Backward:
 *     ret v2:     live_cur = {v2}
 *     load v2:    live_after={v2}, DEF v2 → cur={}, USE v0 → cur={v0}
 *     store:      live_after={v0}, USE v0(in cur), USE v1 → cur={v0,v1}
 *     const v1:   live_after={v0,v1}, DEF v1 → cur={v0}
 *     addr_of v0: live_after={v0}, DEF v0 → cur={}
 * ═══════════════════════════════════════════════════════════════════════════ */

static void test_store(void)
{
    ir_function_t *f = ir_function_new("store_test", ir_type_i16());

    ir_block_t *bb0 = ir_block_new(f);
    ir_block_append(f, bb0);

    unsigned slot0 = ir_new_slot(f, "x", ir_type_i16());

    /* v0 = addr_of slot0 */
    unsigned v0 = ir_new_vreg(f);
    ir_instr_t *i_addr = ir_instr_new(IR_OP_ADDR_OF);
    i_addr->dst    = ir_val_vreg(v0, ir_type_ptr());
    i_addr->src[0] = ir_val_slot(slot0, ir_type_i16());
    ir_instr_push(bb0, i_addr);

    /* v1 = 99 */
    ir_instr_t *i_const = mk_const(f, bb0, 99);
    unsigned v1 = i_const->dst.as.vreg;

    /* *v0 = v1 */
    ir_instr_t *i_store = ir_instr_new(IR_OP_STORE);
    i_store->dst    = ir_val_none();
    i_store->src[0] = ir_val_vreg(v0, ir_type_ptr());
    i_store->src[1] = ir_val_vreg(v1, ir_type_i16());
    ir_instr_push(bb0, i_store);

    /* v2 = *v0 */
    unsigned v2 = ir_new_vreg(f);
    ir_instr_t *i_load = ir_instr_new(IR_OP_LOAD);
    i_load->dst    = ir_val_vreg(v2, ir_type_i16());
    i_load->src[0] = ir_val_vreg(v0, ir_type_ptr());
    ir_instr_push(bb0, i_load);

    /* ret v2 */
    mk_ret(bb0, v2);

    ir_liveness_t *liv = ir_liveness_compute(f);
    assert(liv);

    /* instr order: [0]=addr_of, [1]=const, [2]=store, [3]=load, [4]=ret */

    /* live_after[addr_of] (instr[0]) = {v0} — v0 live, v1 not yet born */
    CHECK( vreg_set_has(&liv->instr[0].live_after, v0), "live_after[addr_of] has v0");
    CHECK(!vreg_set_has(&liv->instr[0].live_after, v1), "live_after[addr_of] no v1");
    CHECK(!vreg_set_has(&liv->instr[0].live_after, v2), "live_after[addr_of] no v2");

    /* live_after[const v1] (instr[1]) = {v0, v1} */
    CHECK( vreg_set_has(&liv->instr[1].live_after, v0), "live_after[const] has v0");
    CHECK( vreg_set_has(&liv->instr[1].live_after, v1), "live_after[const] has v1");

    /* live_after[store] (instr[2]) = {v0} — store consumes v0 and v1;
     * v0 is still needed by the subsequent load */
    CHECK( vreg_set_has(&liv->instr[2].live_after, v0), "live_after[store] has v0");
    CHECK(!vreg_set_has(&liv->instr[2].live_after, v1), "live_after[store] no v1");
    CHECK(!vreg_set_has(&liv->instr[2].live_after, v2), "live_after[store] no v2");

    /* live_after[load] (instr[3]) = {v2} */
    CHECK(!vreg_set_has(&liv->instr[3].live_after, v0), "live_after[load] no v0");
    CHECK( vreg_set_has(&liv->instr[3].live_after, v2), "live_after[load] has v2");

    /* live_after[ret] (instr[4]) = {} */
    CHECK(!vreg_set_has(&liv->instr[4].live_after, v2), "live_after[ret] empty");

    ir_liveness_free(liv);
    ir_function_free(f);
    PASS("store_test");
}

/* ─── main ───────────────────────────────────────────────────────────────── */

int main(void)
{
    fprintf(stdout, "=== Etapa 1 — Liveness Analysis tests ===\n");
    test_linear();
    test_iftest();
    test_looptest();
    test_store();
    fprintf(stdout, "All tests passed.\n");
    return 0;
}
