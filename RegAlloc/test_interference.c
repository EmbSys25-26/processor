/*
 * test_interference.c — unit tests for Etapa 2 (Interference Graph)
 *
 * Builds IR functions by hand, runs liveness (Etapa 1), then builds
 * the interference graph and verifies:
 *   - edge presence / absence
 *   - node degrees
 *   - move list recording
 *   - move source-exclusion semantics
 *
 * Four test functions:
 *   1. linear_no_overlap      — straight-line code, no vregs overlap
 *   2. overlap_simple         — two vregs simultaneously live
 *   3. ifbranch_crossblock    — live set crosses a control-flow merge
 *   4. move_coalescing_setup  — IR_OP_COPY recorded in move list,
 *                               (dst, src) do NOT interfere
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "../IR/ir.h"
#include "liveness.h"
#include "interference.h"

/* ─── assertion helpers ─────────────────────────────────────────────────── */

#define CHECK(expr, msg)                                                    \
    do {                                                                    \
        if (!(expr)) {                                                      \
            fprintf(stderr, "FAIL [%s:%d] %s\n", __FILE__, __LINE__, (msg));\
            exit(1);                                                        \
        }                                                                   \
    } while (0)

#define PASS(name) fprintf(stdout, "  PASS  %s\n", (name))

/* ─── IR builder helpers (same shape as test_liveness.c) ────────────────── */

static ir_instr_t *mk_const(ir_function_t *f, ir_block_t *b, long val)
{
    unsigned vr = ir_new_vreg(f);
    ir_instr_t *i = ir_instr_new(IR_OP_CONST);
    i->dst    = ir_val_vreg(vr, ir_type_i16());
    i->src[0] = ir_val_imm(val, ir_type_i16());
    ir_instr_push(b, i);
    return i;
}

static ir_instr_t *mk_binop(ir_function_t *f, ir_block_t *b,
                             ir_opcode_t op, unsigned va, unsigned vb)
{
    unsigned vr = ir_new_vreg(f);
    ir_instr_t *i = ir_instr_new(op);
    i->dst    = ir_val_vreg(vr, ir_type_i16());
    i->src[0] = ir_val_vreg(va, ir_type_i16());
    i->src[1] = ir_val_vreg(vb, ir_type_i16());
    ir_instr_push(b, i);
    return i;
}

static ir_instr_t *mk_binop_imm(ir_function_t *f, ir_block_t *b,
                                  ir_opcode_t op, unsigned va, long imm)
{
    unsigned vr = ir_new_vreg(f);
    ir_instr_t *i = ir_instr_new(op);
    i->dst    = ir_val_vreg(vr, ir_type_i16());
    i->src[0] = ir_val_vreg(va, ir_type_i16());
    i->src[1] = ir_val_imm(imm, ir_type_i16());
    ir_instr_push(b, i);
    return i;
}

static ir_instr_t *mk_copy(ir_function_t *f, ir_block_t *b, unsigned src_vr)
{
    unsigned vr = ir_new_vreg(f);
    ir_instr_t *i = ir_instr_new(IR_OP_COPY);
    i->dst    = ir_val_vreg(vr, ir_type_i16());
    i->src[0] = ir_val_vreg(src_vr, ir_type_i16());
    ir_instr_push(b, i);
    return i;
}

static void mk_ret(ir_block_t *b, unsigned vr)
{
    ir_instr_t *i = ir_instr_new(IR_OP_RET);
    i->src[0] = ir_val_vreg(vr, ir_type_i16());
    ir_instr_push(b, i);
}

static void mk_branch(ir_block_t *b, unsigned cond_vr,
                       unsigned t_id, unsigned f_id)
{
    ir_instr_t *i = ir_instr_new(IR_OP_BRANCH);
    i->src[0] = ir_val_vreg(cond_vr, ir_type_i1());
    i->as.branch.true_block  = t_id;
    i->as.branch.false_block = f_id;
    ir_instr_push(b, i);
}

/* ═══════════════════════════════════════════════════════════════════════════
 * TEST 1 — linear_no_overlap
 *
 * func () -> i16 {
 * bb0:
 *   %v0 = 1
 *   %v1 = %v0 + 1     ; %v0 dies here; only %v1 survives
 *   %v2 = %v1 + 1     ; %v1 dies here; only %v2 survives
 *   ret %v2
 * }
 *
 * Expected: no two vregs are simultaneously live -> zero edges.
 * ═══════════════════════════════════════════════════════════════════════════ */

static void test_linear_no_overlap(void)
{
    ir_function_t *f = ir_function_new("lnop", ir_type_i16());
    ir_block_t *bb0  = ir_block_new(f); ir_block_append(f, bb0);

    unsigned v0 = mk_const(f, bb0, 1)->dst.as.vreg;
    unsigned v1 = mk_binop_imm(f, bb0, IR_OP_ADD, v0, 1)->dst.as.vreg;
    unsigned v2 = mk_binop_imm(f, bb0, IR_OP_ADD, v1, 1)->dst.as.vreg;
    mk_ret(bb0, v2);

    ir_liveness_t *lv = ir_liveness_compute(f);
    ifg_t *g = ifg_build(f, lv);
    assert(g);

    printf("\n------- test_linear_no_overlap -------\n");
    printf("--- IR ---\n");
    ir_function_print(stdout, f);
    printf("--- Liveness ---\n");
    ir_liveness_print(stdout, f, lv);
    printf("--- Interference graph ---\n");
    ifg_print(stdout, f->name, g);

    CHECK(ifg_num_nodes(g) == 3, "3 nodes");
    CHECK(!ifg_interferes(g, v0, v1), "v0,v1 must not interfere");
    CHECK(!ifg_interferes(g, v1, v2), "v1,v2 must not interfere");
    CHECK(!ifg_interferes(g, v0, v2), "v0,v2 must not interfere");
    CHECK(ifg_degree(g, v0) == 0, "deg(v0)==0");
    CHECK(ifg_degree(g, v1) == 0, "deg(v1)==0");
    CHECK(ifg_degree(g, v2) == 0, "deg(v2)==0");
    CHECK(ifg_num_moves(g) == 0, "no moves");

    ifg_free(g);
    ir_liveness_free(lv);
    ir_function_free(f);
    PASS("linear_no_overlap");
}

/* ═══════════════════════════════════════════════════════════════════════════
 * TEST 2 — overlap_simple
 *
 * func () -> i16 {
 * bb0:
 *   %v0 = 1
 *   %v1 = 2            ; after this, {v0, v1} are both live
 *   %v2 = %v0 + %v1    ; def v2 while v0,v1 still live
 *   ret %v2
 * }
 *
 * Expected edges: (v0, v1)  — both live between their defs
 *
 * Backward pass in bb0:
 *   ret v2:    live_cur = {v2}
 *   add v0+v1: live_after={v2}, DEF v2 -> {}, USE v0,v1 -> {v0,v1}
 *   const v1:  live_after={v0,v1}, DEF v1 -> {v0}
 *   const v0:  live_after={v0},    DEF v0 -> {}
 *
 * For each DEF d, add edge(d, x) for x in live_after:
 *   const v0: live_after={v0}  -> nothing (only d itself)
 *   const v1: live_after={v0,v1} -> edge (v1, v0)
 *   add v2:   live_after={v2}  -> nothing
 *   ret:      no DEF
 * ═══════════════════════════════════════════════════════════════════════════ */

static void test_overlap_simple(void)
{
    ir_function_t *f = ir_function_new("ovl", ir_type_i16());
    ir_block_t *bb0  = ir_block_new(f); ir_block_append(f, bb0);

    unsigned v0 = mk_const(f, bb0, 1)->dst.as.vreg;
    unsigned v1 = mk_const(f, bb0, 2)->dst.as.vreg;
    unsigned v2 = mk_binop(f, bb0, IR_OP_ADD, v0, v1)->dst.as.vreg;
    mk_ret(bb0, v2);

    ir_liveness_t *lv = ir_liveness_compute(f);
    ifg_t *g = ifg_build(f, lv);
    assert(g);

    printf("\n------- test_overlap_simple -------\n");
    printf("--- IR ---\n");
    ir_function_print(stdout, f);
    printf("--- Liveness ---\n");
    ir_liveness_print(stdout, f, lv);
    printf("--- Interference graph ---\n");
    ifg_print(stdout, f->name, g);

    CHECK(ifg_num_nodes(g) == 3, "3 nodes");
    CHECK( ifg_interferes(g, v0, v1), "v0,v1 MUST interfere");
    CHECK(!ifg_interferes(g, v0, v2), "v0,v2 must not interfere");
    CHECK(!ifg_interferes(g, v1, v2), "v1,v2 must not interfere");

    CHECK(ifg_degree(g, v0) == 1, "deg(v0)==1");
    CHECK(ifg_degree(g, v1) == 1, "deg(v1)==1");
    CHECK(ifg_degree(g, v2) == 0, "deg(v2)==0");

    unsigned nb[4] = {0};
    unsigned n = ifg_neighbors(g, v0, nb, 4);
    CHECK(n == 1 && nb[0] == v1, "v0 neighbours = {v1}");
    n = ifg_neighbors(g, v1, nb, 4);
    CHECK(n == 1 && nb[0] == v0, "v1 neighbours = {v0}");

    CHECK(ifg_num_moves(g) == 0, "no moves");

    ifg_free(g);
    ir_liveness_free(lv);
    ir_function_free(f);
    PASS("overlap_simple");
}

/* ═══════════════════════════════════════════════════════════════════════════
 * TEST 3 — ifbranch_crossblock
 *
 * func () -> i16 {
 * bb0:
 *   %v0 = 1             ; cond
 *   %v1 = 10            ; must stay live into both branches
 *   if %v0 goto bb1 else bb2
 * bb1:
 *   %v2 = %v1 + 1
 *   ret %v2
 * bb2:
 *   %v3 = %v1 + 2
 *   ret %v3
 * }
 *
 * live_out[bb0] = {v1}
 * live_in[bb1]  = {v1}     live_in[bb2] = {v1}
 *
 * Interferences (from per-instruction backward pass in bb0):
 *   branch: live_after = {v1}, USE v0 -> cur = {v0,v1}
 *   const v1: live_after={v0,v1}, DEF v1 -> {v0}
 *     -> edge (v1, v0)
 *   const v0: live_after={v0}, DEF v0 -> {}
 *     -> no edge
 *
 * In bb1:
 *   ret v2: live_cur = {v2} (live_out[bb1]={})
 *   add:    live_after={v2}, DEF v2 -> {}, USE v1 -> {v1}
 *     -> edge (v2, ...) ?  live_after at add-site = {v2}. Only d=v2 -> no edge.
 *
 * Expected: only edge (v0, v1). v2, v3 are isolated.
 * ═══════════════════════════════════════════════════════════════════════════ */

static void test_ifbranch_crossblock(void)
{
    ir_function_t *f = ir_function_new("ifcb", ir_type_i16());
    ir_block_t *bb0 = ir_block_new(f); ir_block_append(f, bb0);
    ir_block_t *bb1 = ir_block_new(f); ir_block_append(f, bb1);
    ir_block_t *bb2 = ir_block_new(f); ir_block_append(f, bb2);

    unsigned v0 = mk_const(f, bb0, 1)->dst.as.vreg;
    unsigned v1 = mk_const(f, bb0, 10)->dst.as.vreg;
    mk_branch(bb0, v0, bb1->id, bb2->id);

    unsigned v2 = mk_binop_imm(f, bb1, IR_OP_ADD, v1, 1)->dst.as.vreg;
    mk_ret(bb1, v2);

    unsigned v3 = mk_binop_imm(f, bb2, IR_OP_ADD, v1, 2)->dst.as.vreg;
    mk_ret(bb2, v3);

    ir_liveness_t *lv = ir_liveness_compute(f);
    ifg_t *g = ifg_build(f, lv);
    assert(g);

    printf("\n------- test_ifbranch_crossblock -------\n");
    printf("--- IR ---\n");
    ir_function_print(stdout, f);
    printf("--- Liveness ---\n");
    ir_liveness_print(stdout, f, lv);
    printf("--- Interference graph ---\n");
    ifg_print(stdout, f->name, g);

    CHECK( ifg_interferes(g, v0, v1), "v0,v1 MUST interfere");
    CHECK(!ifg_interferes(g, v1, v2), "v1,v2 must not (v1 dies as v2 is defined)");
    CHECK(!ifg_interferes(g, v1, v3), "v1,v3 must not");
    CHECK(!ifg_interferes(g, v2, v3), "v2,v3 must not");

    CHECK(ifg_degree(g, v0) == 1, "deg(v0)==1");
    CHECK(ifg_degree(g, v1) == 1, "deg(v1)==1");
    CHECK(ifg_degree(g, v2) == 0, "deg(v2)==0");
    CHECK(ifg_degree(g, v3) == 0, "deg(v3)==0");

    CHECK(ifg_num_moves(g) == 0, "no moves");

    ifg_free(g);
    ir_liveness_free(lv);
    ir_function_free(f);
    PASS("ifbranch_crossblock");
}

/* ═══════════════════════════════════════════════════════════════════════════
 * TEST 4 — move_coalescing_setup
 *
 * func () -> i16 {
 * bb0:
 *   %v0 = 7
 *   %v1 = copy %v0       ; IR_OP_COPY — move-related; src exclusion
 *   %v2 = %v1 + 1
 *   ret %v2
 * }
 *
 * Backward:
 *   ret v2:    live_cur={v2}
 *   add v1+1:  live_after={v2}, DEF v2 -> {}, USE v1 -> {v1}
 *   copy v1<-v0: live_after={v1}, DEF v1, USE v0 -> {v0}
 *     (d=v1, move src=v0, live_after={v1}; after excluding d and src,
 *      no interference edge is added — exactly the point of the exception)
 *   const v0:  live_after={v0}, DEF v0 -> {}
 *     -> no edge (only d itself)
 *
 * Expected:
 *   zero interference edges; move list contains (v1, v0).
 * ═══════════════════════════════════════════════════════════════════════════ */

static void test_move_coalescing_setup(void)
{
    ir_function_t *f = ir_function_new("mvs", ir_type_i16());
    ir_block_t *bb0  = ir_block_new(f); ir_block_append(f, bb0);

    unsigned v0 = mk_const(f, bb0, 7)->dst.as.vreg;
    unsigned v1 = mk_copy(f, bb0, v0)->dst.as.vreg;
    unsigned v2 = mk_binop_imm(f, bb0, IR_OP_ADD, v1, 1)->dst.as.vreg;
    mk_ret(bb0, v2);

    ir_liveness_t *lv = ir_liveness_compute(f);
    ifg_t *g = ifg_build(f, lv);
    assert(g);

    printf("\n------- test_move_coalescing_setup -------\n");
    printf("--- IR ---\n");
    ir_function_print(stdout, f);
    printf("--- Liveness ---\n");
    ir_liveness_print(stdout, f, lv);
    printf("--- Interference graph ---\n");
    ifg_print(stdout, f->name, g);

    /* Critical property for coalescing: move dst and src do NOT interfere */
    CHECK(!ifg_interferes(g, v0, v1), "move (v1<-v0) must not create interference");
    CHECK(!ifg_interferes(g, v0, v2), "no edge v0,v2");
    CHECK(!ifg_interferes(g, v1, v2), "no edge v1,v2");

    CHECK(ifg_num_moves(g) == 1, "one move recorded");
    const ifg_move_t *mv = ifg_moves(g);
    CHECK(mv[0].dst == v1 && mv[0].src == v0, "move is (v1 <- v0)");

    ifg_free(g);
    ir_liveness_free(lv);
    ir_function_free(f);
    PASS("move_coalescing_setup");
}

/* ─── main ───────────────────────────────────────────────────────────────── */

int main(void)
{
    fprintf(stdout, "=== Etapa 2 — Interference Graph tests ===\n");
    test_linear_no_overlap();
    test_overlap_simple();
    test_ifbranch_crossblock();
    test_move_coalescing_setup();
    fprintf(stdout, "All tests passed.\n");
    return 0;
}
