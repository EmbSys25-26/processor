/*
 * main.c — Main compiler driver (End-to-End)
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Include necessary headers from all compiler stages */
#include "Parser/ASTree.h"
#include "Semantic/semantic.h"
#include "IR/ir.h"
#include "IR/ir_lower.h"
#include "RegAlloc/liveness.h"
#include "RegAlloc/interference.h"
#include "RegAlloc/precolor.h"

extern FILE *yyin;
extern int yyparse(void);

extern TreeNode_t *p_treeRoot; 

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
        fprintf(stderr, "Usage: %s <source_file.c>\n", argv[0]);
        return 1;
    }

    /* 1. Lexical & Syntax Analysis */
    yyin = open_source_file(argv[1]);
    if (!yyin) {
        fprintf(stderr, "Error: Could not open file '%s'\n", argv[1]);
        return 1;
    }
    
    if (yyparse() != 0 || !p_treeRoot) {
        fclose(yyin);
        return 1;
    }
    fclose(yyin);

    /* 2. Semantic Analysis */
    semantic_context_t *sem_ctx = NULL;
    semantic_result_t sem_res;
    
    int sem_status = semantic_analyze(p_treeRoot, argv[1], &sem_ctx, &sem_res);
    if (sem_status != 0 || !sem_ctx) {
        return 1;
    }

    /* 3. IR Lowering */
    ir_module_t *mod = ir_lower_translation_unit(p_treeRoot, sem_ctx, argv[1]);
    if (!mod) {
        return 1;
    }

    /* 4. Register Allocation (Only printing IR and Stages 1, 2, 3) */
    for (const ir_function_list_t *fl = mod->functions; fl; fl = fl->next) {
        ir_function_t *f = fl->func;

        printf("\n============================================================\n");
        printf(" FUNCTION: @%s\n", f->name);
        printf("============================================================\n\n");

        printf("┌── [0] IR ───────────────────────────────────\n");
        ir_function_print(stdout, f);

        printf("\n┌── [1] STAGE 1: LIVENESS ANALYSIS ─────────────────────────\n");
        ir_liveness_t *liv = ir_liveness_compute(f);
        if (liv) ir_liveness_print(stdout, f, liv);

        printf("\n┌── [2] STAGE 2: INTERFERENCE GRAPH ────────────────────────\n");
        ifg_t *g = ifg_build(f, liv);
        if (g) ifg_print(stdout, f->name, g);

        printf("\n┌── [3] STAGE 3: PRE-COLORING ──────────────────────────────\n");
        precolor_t *p = precolor_build(f, liv);
        if (p) precolor_print(stdout, f->name, p);
        printf("\n");

        /* Free local allocations */
        precolor_free(p);
        ifg_free(g);
        ir_liveness_free(liv);
    }

    /* Cleanup */
    ir_module_free(mod);
    return 0;
}
