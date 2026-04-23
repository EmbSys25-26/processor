#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "../IR/ir.h"
#include "liveness.h"
#include "interference.h"
#include "precolor.h"

/* ─── Helpers IR ────────────────────────────────────────── */
static ir_instr_t *mk_const(ir_function_t *f, ir_block_t *b, long val) {
    unsigned vr = ir_new_vreg(f); ir_instr_t *i = ir_instr_new(IR_OP_CONST);
    i->dst = ir_val_vreg(vr, ir_type_i16()); i->src[0] = ir_val_imm(val, ir_type_i16());
    ir_instr_push(b, i); return i;
}
static ir_instr_t *mk_binop_imm(ir_function_t *f, ir_block_t *b, ir_opcode_t op, unsigned va, long imm) {
    unsigned vr = ir_new_vreg(f); ir_instr_t *i = ir_instr_new(op);
    i->dst = ir_val_vreg(vr, ir_type_i16()); i->src[0] = ir_val_vreg(va, ir_type_i16()); i->src[1] = ir_val_imm(imm, ir_type_i16());
    ir_instr_push(b, i); return i;
}
static ir_instr_t *mk_binop(ir_function_t *f, ir_block_t *b, ir_opcode_t op, unsigned va, unsigned vb) {
    unsigned vr = ir_new_vreg(f); ir_instr_t *i = ir_instr_new(op);
    i->dst = ir_val_vreg(vr, ir_type_i16()); i->src[0] = ir_val_vreg(va, ir_type_i16()); i->src[1] = ir_val_vreg(vb, ir_type_i16());
    ir_instr_push(b, i); return i;
}
static void mk_ret_vreg(ir_block_t *b, unsigned vr) {
    ir_instr_t *i = ir_instr_new(IR_OP_RET); i->src[0] = ir_val_vreg(vr, ir_type_i16());
    ir_instr_push(b, i);
}
static unsigned add_param(ir_function_t *f, const char *name) {
    unsigned vr = ir_new_vreg(f); unsigned k = f->param_count;
    snprintf(f->param_names[k], sizeof(f->param_names[0]), "%s", name);
    f->param_types[k] = ir_type_i16(); f->param_count++; return vr;
}
static void mk_call(ir_function_t *f, ir_block_t *b, const char *callee, unsigned arg_vr, unsigned dst_vr) {
    ir_instr_t *i = ir_instr_new(IR_OP_CALL);
    snprintf(i->as.call.callee, sizeof(i->as.call.callee), "%s", callee);
    i->as.call.args[0] = ir_val_vreg(arg_vr, ir_type_i16()); i->as.call.arg_count = 1;
    i->dst = ir_val_vreg(dst_vr, ir_type_i16()); i->as.call.is_void_call = 0;
    ir_instr_push(b, i);
}

/* ─── Execute the 3 Stages ───────────────── */
static void run_tests(ir_function_t *f) {
    printf("\n████████████████████████████████████████████████████████████████████████\n");
    printf("█ TEST: @%s\n", f->name);
    printf("████████████████████████████████████████████████████████████████████████\n\n");

    printf("┌── [0] IR ─────────────────────────────────────────────\n");
    ir_function_print(stdout, f);

    printf("\n┌── [1] ETAPA 1: LIVENESS ANALYSIS ─────────────────────────────────────\n");
    ir_liveness_t *liv = ir_liveness_compute(f);
    assert(liv);
    ir_liveness_print(stdout, f, liv);

    printf("\n┌── [2] ETAPA 2: INTERFERENCE GRAPH ────────────────────────────────────\n");
    ifg_t *g = ifg_build(f, liv);
    assert(g);
    ifg_print(stdout, f->name, g);

    printf("\n┌── [3] ETAPA 3: PRE-COLORING ──────────────────────────────────────────\n");
    precolor_t *p = precolor_build(f);
    assert(p);
    precolor_print(stdout, f->name, p);
    printf("\n");

    /* Clear memory */
    precolor_free(p);
    ifg_free(g);
    ir_liveness_free(liv);
}

/* ─── TEST FUNCTIONS ───────────────────────────────────────────────────── */

static ir_function_t *build_linear(void) {
    ir_function_t *f = ir_function_new("linear", ir_type_i16());
    ir_block_t *bb0 = ir_block_new(f); ir_block_append(f, bb0);
    unsigned v0 = mk_const(f, bb0, 42)->dst.as.vreg;
    unsigned v1 = mk_binop_imm(f, bb0, IR_OP_ADD, v0, 1)->dst.as.vreg;
    mk_ret_vreg(bb0, v1);
    return f;
}

static ir_function_t *build_overlap_simple(void) {
    ir_function_t *f = ir_function_new("overlap_simple", ir_type_i16());
    ir_block_t *bb0  = ir_block_new(f); ir_block_append(f, bb0);
    unsigned v0 = mk_const(f, bb0, 1)->dst.as.vreg;
    unsigned v1 = mk_const(f, bb0, 2)->dst.as.vreg;
    unsigned v2 = mk_binop(f, bb0, IR_OP_ADD, v0, v1)->dst.as.vreg;
    mk_ret_vreg(bb0, v2);
    return f;
}

static ir_function_t *build_combined_precolor(void) {
    ir_function_t *f = ir_function_new("combined", ir_type_i16());
    ir_block_t *bb0 = ir_block_new(f); ir_block_append(f, bb0);
    unsigned v0 = add_param(f, "a"); unsigned v1 = add_param(f, "b");
    unsigned v2 = ir_new_vreg(f); mk_call(f, bb0, "transform", v0, v2);
    unsigned v3 = mk_binop(f, bb0, IR_OP_ADD, v2, v1)->dst.as.vreg;
    mk_ret_vreg(bb0, v3);
    return f;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Error- Missing arguments\n");
        return 1;
    }

    const char *target = argv[1];

    if (strcmp(target, "linear") == 0) {
        ir_function_t *f = build_linear();
        run_tests(f);
        ir_function_free(f);
    } 
    else if (strcmp(target, "overlap_simple") == 0) {
        ir_function_t *f = build_overlap_simple();
        run_tests(f);
        ir_function_free(f);
    } 
    else if (strcmp(target, "combined") == 0) {
        ir_function_t *f = build_combined_precolor();
        run_tests(f);
        ir_function_free(f);
    } 
    else {
        printf("Unknown test: %s\n", target);
    }

    return 0;
}
