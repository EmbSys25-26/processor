/*
 * main.c — Main compiler driver (End-to-End)
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Include necessary headers from all compiler stages */
#include "Parser/ASTree.h"
#include "Parser/ASTPrint.h"
#include "Semantic/semantic.h"
#include "IR/ir.h"
#include "IR/ir_lower.h"
#include "CodeGen/RegAlloc/liveness.h"
#include "CodeGen/RegAlloc/interference.h"
#include "CodeGen/RegAlloc/precolor.h"
#include "CodeGen/RegAlloc/regalloc.h"
#include "CodeGen/RegAlloc/spill.h"
#include "CodeGen/codegen.h"

extern FILE *yyin;
extern int yyparse(void);

extern TreeNode_t *p_treeRoot;

/* ── print IR with physical registers substituted for virtual ones ────── */

static const char *phys_reg_str(phys_reg_t r)
{
    static const char *tbl[] = {
        "r0","r1","r2","r3","r4","r5","r6",
        "r7","r8","r9","r10","r11","r12"
    };
    if ((unsigned)r <= 12) return tbl[(unsigned)r];
    if (r == REGALLOC_SPILL) return "<spill>";
    return "<none>";
}

static void fprint_val_ra(FILE *out, const ir_value_t *v, const regalloc_t *ra)
{
    if (!v || v->kind == IR_VAL_NONE) { fprintf(out, "-"); return; }
    if (v->kind == IR_VAL_VREG && ra && v->as.vreg < ra->n_vregs) {
        phys_reg_t r = ra->color[v->as.vreg];
        if ((unsigned)r <= 12) { fprintf(out, "%s", phys_reg_str(r)); return; }
    }
    ir_value_print(out, v);
}

static const char *ir_op_str(ir_opcode_t op)
{
    switch (op) {
    case IR_OP_ADD:     return "add";     case IR_OP_SUB:     return "sub";
    case IR_OP_MUL:     return "mul";     case IR_OP_DIVS:    return "divs";
    case IR_OP_DIVU:    return "divu";    case IR_OP_MODS:    return "mods";
    case IR_OP_MODU:    return "modu";    case IR_OP_AND:     return "and";
    case IR_OP_OR:      return "or";      case IR_OP_XOR:     return "xor";
    case IR_OP_SHL:     return "shl";     case IR_OP_SHRU:    return "shru";
    case IR_OP_SHRS:    return "shrs";    case IR_OP_EQ:      return "eq";
    case IR_OP_NEQ:     return "neq";     case IR_OP_LTS:     return "lts";
    case IR_OP_LES:     return "les";     case IR_OP_GTS:     return "gts";
    case IR_OP_GES:     return "ges";     case IR_OP_LTU:     return "ltu";
    case IR_OP_LEU:     return "leu";     case IR_OP_GTU:     return "gtu";
    case IR_OP_GEU:     return "geu";     case IR_OP_ZEXT:    return "zext";
    case IR_OP_SEXT:    return "sext";    case IR_OP_TRUNC:   return "trunc";
    case IR_OP_BITCAST: return "bitcast";
    default:            return "?op";
    }
}

static void fprint_instr_ra(FILE *out, const ir_instr_t *ins, const regalloc_t *ra)
{
    if (!ins) return;
#define V(x) fprint_val_ra(out, (x), ra)
    switch (ins->op) {
    case IR_OP_GOTO:
        fprintf(out, "    goto bb%u\n", ins->as.branch.true_block);
        break;
    case IR_OP_BRANCH:
        fprintf(out, "    if "); V(&ins->src[0]);
        fprintf(out, " goto bb%u else bb%u\n",
                ins->as.branch.true_block, ins->as.branch.false_block);
        break;
    case IR_OP_SWITCH:
        fprintf(out, "    switch "); V(&ins->src[0]);
        fprintf(out, " default bb%u", ins->as.sw.default_block);
        for (unsigned k = 0; k < ins->as.sw.case_count; ++k)
            fprintf(out, " [%ld:bb%u]", ins->as.sw.case_values[k], ins->as.sw.case_blocks[k]);
        fprintf(out, "\n");
        break;
    case IR_OP_RET:
        if (ins->src[0].kind == IR_VAL_NONE) fprintf(out, "    ret void\n");
        else { fprintf(out, "    ret "); V(&ins->src[0]); fprintf(out, "\n"); }
        break;
    case IR_OP_STORE:
        fprintf(out, "    *"); V(&ins->src[0]);
        fprintf(out, " = "); V(&ins->src[1]); fprintf(out, "\n");
        break;
    case IR_OP_CALL:
        fprintf(out, "    ");
        if (!ins->as.call.is_void_call) { V(&ins->dst); fprintf(out, " = "); }
        fprintf(out, "@%s(", ins->as.call.callee);
        for (unsigned k = 0; k < ins->as.call.arg_count; ++k) {
            if (k) fprintf(out, ", ");
            V(&ins->as.call.args[k]);
        }
        fprintf(out, ")\n");
        break;
    case IR_OP_GEP:
        fprintf(out, "    "); V(&ins->dst);
        fprintf(out, " = gep "); V(&ins->src[0]);
        fprintf(out, " + "); V(&ins->src[1]);
        fprintf(out, " * %ld\n", ins->as.gep.width);
        break;
    case IR_OP_ZEXT: case IR_OP_SEXT: case IR_OP_TRUNC: case IR_OP_BITCAST:
        fprintf(out, "    "); V(&ins->dst);
        fprintf(out, " = (%s ", ir_op_str(ins->op));
        ir_type_print(out, &ins->dst.type);
        fprintf(out, ") "); V(&ins->src[0]); fprintf(out, "\n");
        break;
    case IR_OP_ADDR_OF:
        fprintf(out, "    "); V(&ins->dst);
        fprintf(out, " = addr_of "); V(&ins->src[0]); fprintf(out, "\n");
        break;
    case IR_OP_LOAD:
        fprintf(out, "    "); V(&ins->dst);
        fprintf(out, " = *"); V(&ins->src[0]); fprintf(out, "\n");
        break;
    case IR_OP_NEG: case IR_OP_NOT: case IR_OP_CONST: case IR_OP_COPY:
        fprintf(out, "    "); V(&ins->dst); fprintf(out, " = ");
        if (ins->op == IR_OP_NEG) fprintf(out, "-");
        if (ins->op == IR_OP_NOT) fprintf(out, "~");
        V(&ins->src[0]); fprintf(out, "\n");
        break;
    default:
        fprintf(out, "    "); V(&ins->dst); fprintf(out, " = ");
        V(&ins->src[0]);
        fprintf(out, " %s ", ir_op_str(ins->op));
        V(&ins->src[1]); fprintf(out, "\n");
        break;
    }
#undef V
}

static void print_ir_with_regs(FILE *out, const ir_function_t *f, const regalloc_t *ra)
{
    if (!f) return;
    fprintf(out, "func @%s(", f->name);
    for (unsigned k = 0; k < f->param_count; k++) {
        if (k) fprintf(out, ", ");
        ir_type_print(out, &f->param_types[k]);
        fprintf(out, " %%%s", f->param_names[k]);
    }
    fprintf(out, ") -> ");
    ir_type_print(out, &f->ret_type);
    fprintf(out, " {\n");

    for (const ir_slot_entry_t *e = f->slots; e; e = e->next) {
        fprintf(out, "  slot %%slot%u : ", e->slot_id);
        ir_type_print(out, &e->type);
        fprintf(out, "  ; %s\n", e->name);
    }
    if (f->slots) fprintf(out, "\n");

    for (const ir_block_t *b = f->entry; b; b = b->next) {
        fprintf(out, "bb%u:\n", b->id);
        for (const ir_instr_t *ins = b->head; ins; ins = ins->next)
            fprint_instr_ra(out, ins, ra);
        if (b->next) fprintf(out, "\n");
    }
    fprintf(out, "}\n");
}

/* Resolves the file path if it's in the test_files folder */
FILE* open_source_file(const char *filename) {
    FILE *f = fopen(filename, "r");
    if (f) return f;

    char path[512];
    snprintf(path, sizeof(path), "test_files/RegisterAllocation/%s", filename);
    f = fopen(path, "r");
    if (f) return f;

    return NULL;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr,
            "Usage: %s [--ast] <source_file.c>\n"
            "  --ast   parse only and print the AST tree, then exit\n",
            argv[0]);
        return 1;
    }

    int print_ast = 0;
    const char *src_path = NULL;
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--ast") == 0)      print_ast = 1;
        else if (!src_path)                     src_path = argv[i];
    }
    if (!src_path) {
        fprintf(stderr, "Usage: %s [--ast] <source_file.c>\n", argv[0]);
        return 1;
    }

    FILE *asm_out = NULL;
    if (!print_ast) {
        asm_out = fopen("output.asm", "w");
        if (!asm_out) {
            fprintf(stderr, "Error: cannot open output.asm\n");
            return 1;
        }
    }

    /* 1. Lexical & Syntax Analysis */
    yyin = open_source_file(src_path);
    if (!yyin) {
        fprintf(stderr, "Error: Could not open file '%s'\n", src_path);
        return 1;
    }

    if (yyparse() != 0 || !p_treeRoot) {
        fclose(yyin);
        return 1;
    }
    fclose(yyin);

    /* --ast: print the parse tree and exit before semantic analysis */
    if (print_ast) {
        ASTPrint(p_treeRoot);
        return 0;
    }

    /* 2. Semantic Analysis */
    semantic_context_t *sem_ctx = NULL;
    semantic_result_t sem_res;

    int sem_status = semantic_analyze(p_treeRoot, src_path, &sem_ctx, &sem_res);
    if (sem_status != 0 || !sem_ctx) {
        return 1;
    }
    if (sem_res.error_count > 0) {
        if (asm_out) fclose(asm_out);
        return 2;
    }

    /* 3. IR Lowering */
    ir_module_t *mod = ir_lower_translation_unit(p_treeRoot, sem_ctx, src_path);
    if (!mod) {
        return 1;
    }

    /* 4 + 5. Register Allocation — iterative spill loop.
     *
     * Each iteration runs the full backend pipeline on the current IR:
     *   liveness → interference graph → precolour → regalloc
     *
     * If the allocator cannot colour every vreg (n_spills > 0), Stage 5
     * rewrites the IR to replace spilled vregs with stack-slot accesses,
     * shrinking their live ranges to one instruction.  The pipeline then
     * restarts on the modified IR.  The loop terminates when n_spills == 0.
     */

    /* Count functions so we can build the allocs[] array for codegen_emit_module. */
    unsigned n_funcs = 0;
    for (const ir_function_list_t *fl = mod->functions; fl; fl = fl->next)
        n_funcs++;

    regalloc_t **allocs = calloc(n_funcs, sizeof(regalloc_t *));
    if (!allocs) {
        fprintf(stderr, "Error: out of memory allocating allocs[]\n");
        ir_module_free(mod);
        fclose(asm_out);
        return 1;
    }

    unsigned func_idx = 0;
    for (const ir_function_list_t *fl = mod->functions; fl; fl = fl->next, func_idx++) {
        ir_function_t *f = fl->func;

        printf("\n============================================================\n");
        printf(" FUNCTION: @%s\n", f->name);
        printf("============================================================\n\n");

        /* Print the original IR once, before any spill rewrites. */
        printf("┌── [0] IR ───────────────────────────────────────────────────\n");
        ir_function_print(stdout, f);

        unsigned spill_iter = 0;

        while (1) {
            ir_liveness_t *liv = ir_liveness_compute(f);
            ifg_t         *g   = ifg_build(f, liv);
            precolor_t    *p   = precolor_build(f, liv);
            regalloc_t    *ra  = regalloc_build(f, g, p);

            if (!ra || ra->n_spills == 0) {
                /* All vregs were coloured — print the final pipeline state. */
                if (spill_iter > 0)
                    printf("\n┌── [SPILL DONE] IR after %u rewrite(s) ─────────────────\n",
                           spill_iter);

                printf("\n┌── [1] STAGE 1: LIVENESS ANALYSIS ──────────────────────\n");
                if (liv) ir_liveness_print(stdout, f, liv);

                printf("\n┌── [2] STAGE 2: INTERFERENCE GRAPH ─────────────────────\n");
                if (g) ifg_print(stdout, f->name, g);

                printf("\n┌── [3] STAGE 3: PRE-COLORING ───────────────────────────\n");
                if (p) precolor_print(stdout, f->name, p);

                printf("\n┌── [4] STAGE 4: REGISTER ALLOCATION ────────────────────\n");
                if (ra) regalloc_print(stdout, f->name, ra, p);

                printf("\n┌── [5] FINAL IR (physical registers) ───────────────────\n");
                if (ra) print_ir_with_regs(stdout, f, ra);
                printf("\n");
                /* Store the final regalloc result; codegen runs after all
                 * functions have been allocated (codegen_emit_module needs
                 * the full module + the complete allocs[] array). */
                allocs[func_idx] = ra;   /* ownership transferred; freed below */
                precolor_free(p);
                ifg_free(g);
                ir_liveness_free(liv);
                break;
            }

            /* Spills detected: rewrite the IR and run the pipeline again. */
            printf("\n┌── [5] STAGE 5: SPILL REWRITE (iter %u) ─────────────────────\n",
                   spill_iter);
            spill_result_t *sr = spill_rewrite(f, ra, g);
            if (sr) {
                spill_print(stdout, f->name, sr);
                spill_result_free(sr);
            }

            printf("\n  IR after spill rewrite:\n");
            ir_function_print(stdout, f);

            regalloc_free(ra);
            precolor_free(p);
            ifg_free(g);
            ir_liveness_free(liv);
            spill_iter++;
        }
    }

    /* 6. Code generation — emit the full module now that every function has
     *    a completed register allocation. */
    codegen_emit_module(asm_out, mod, (const regalloc_t **)allocs);
    printf("Assembly written to output.asm\n");

    /* Cleanup */
    for (unsigned i = 0; i < n_funcs; i++)
        regalloc_free(allocs[i]);
    free(allocs);
    ir_module_free(mod);
    fclose(asm_out);
    return 0;
}
