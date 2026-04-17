#ifndef IR_LOWER_H
#define IR_LOWER_H

/*
 * ir_lower.h — AST-to-IR lowering interface
 *
 * Contract: §8 of IR_GENERATION_CONTRACT.md
 *
 * Entry point:
 *   ir_lower_translation_unit() consumes the typed AST and the live
 *   semantic_context_t produced by semantic_analyze() and returns a
 *   fully-populated ir_module_t.  Returns NULL on error; diagnostics
 *   are written to stderr using the IR### prefix.
 *
 * The four lowering sections are:
 *   1. Declarations  — §8.4 + §8.1  (ir_lower_decl.c)
 *   2. Expressions   — §8.2         (ir_lower_expr.c)
 *   3. Statements    — §8.3         (ir_lower_stmt.c)
 *   4. Structure     — §8.4 + §6    (ir_lower.c – top-level glue)
 */

#include "../Parser/ASTree.h"
#include "../Semantic/semantic.h"
#include "ir.h"

/* ────────────────────────────────────────────────────────────
 * Public entry point
 * ──────────────────────────────────────────────────────────── */

/*
 * Lower the whole translation unit.
 *
 * @param root        Root of the typed AST (NODE_TRANSLATION_UNIT).
 * @param sem_ctx     Live semantic context from semantic_analyze().
 * @param module_name Used as the module arch/name string in the IR header.
 * @return            Newly allocated ir_module_t (caller owns it), or NULL.
 */
ir_module_t *ir_lower_translation_unit(const TreeNode_t    *root,
                                        semantic_context_t  *sem_ctx,
                                        const char          *module_name);

/* ────────────────────────────────────────────────────────────
 * Internal shared state threaded through the lowering passes
 * (exposed here so all four .c files can share it)
 * ──────────────────────────────────────────────────────────── */

/*
 * Loop / switch control targets — a stack entry per enclosing
 * break/continue target (§8.3 rule 6).
 */
#define IR_CTRL_STACK_MAX 64 

typedef struct {
    unsigned break_block;     /* bb to jump to on break    */
    unsigned continue_block;  /* bb to jump to on continue */
    int      has_continue;    /* 0 for switch              */
} ir_ctrl_frame_t;

typedef struct ir_lower_ctx_s { 
    ir_module_t        *module;     // The IR module being built
    semantic_context_t *sem_ctx;    // Live semantic context for type info, diagnostics, etc.

    /* current function being lowered */
    ir_function_t      *func;       // The current function being lowered (NULL if not inside a function)

    /* current basic block (lowering appends here) */
    ir_block_t         *cur_block;  // The current basic block to which new instructions will be appended

    /* error counter — if > 0, lowering aborts */
    unsigned            error_count;    // Count of errors encountered during lowering; if > 0, the process should abort

    /* break/continue target stack */
    ir_ctrl_frame_t     ctrl_stack[IR_CTRL_STACK_MAX];  // Stack of control-flow contexts for break/continue resolution
    int                 ctrl_depth;   /* current depth of nested control contexts; 0 means we're not inside any loop/switch */
} ir_lower_ctx_t;

/* ────────────────────────────────────────────────────────────
 * Diagnostics helper (IR### codes, §13)
 * ──────────────────────────────────────────────────────────── */

void ir_diag(ir_lower_ctx_t *lctx, const char *code,
             size_t line, const char *fmt, ...);
void ir_warn(ir_lower_ctx_t *lctx, const char *code,
             size_t line, const char *fmt, ...);

/* ────────────────────────────────────────────────────────────
 * Type mapping: semantic type_t  →  ir_type_t
 * ──────────────────────────────────────────────────────────── */

ir_type_t ir_type_from_sem(const type_t *sem_type);

/* ────────────────────────────────────────────────────────────
 * Section 1 – Declarations  (ir_lower_decl.c)
 * ──────────────────────────────────────────────────────────── */

/*
 * Emit a global variable declaration into the module.
 * Called for top-level NODE_VAR_DECLARATION / NODE_ARRAY_DECLARATION
 * with MEMORY_CLASS_GLOBAL.
 */
void ir_lower_global_decl(ir_lower_ctx_t *lctx, const TreeNode_t *decl_node);

/*
 * Emit a stack slot for a local variable inside a function.
 * Called for local NODE_VAR_DECLARATION / NODE_ARRAY_DECLARATION.
 * Returns the slot id.
 */
unsigned ir_lower_local_decl(ir_lower_ctx_t *lctx, const TreeNode_t *decl_node);

/* ────────────────────────────────────────────────────────────
 * Section 2 – Expressions  (ir_lower_expr.c)
 * ──────────────────────────────────────────────────────────── */

/*
 * Lower an expression subtree.
 * Returns a value handle (%vN, immediate, …) and, via *out_type, the IR type.
 * On error returns ir_val_none() and increments lctx->error_count.
 */
ir_value_t ir_lower_expr(ir_lower_ctx_t *lctx,
                          const TreeNode_t *expr,
                          ir_type_t *out_type);

/*
 * Lower an expression as an lvalue: compute the address of the target.
 * Used by assignment and inc/dec lowering.
 */
ir_value_t ir_lower_lvalue_addr(ir_lower_ctx_t *lctx,
                                 const TreeNode_t *expr,
                                 ir_type_t *out_pointee_type);

/* ────────────────────────────────────────────────────────────
 * Section 3 – Statements  (ir_lower_stmt.c)
 * ──────────────────────────────────────────────────────────── */

/*
 * Lower a statement or statement list (sibling chain).
 * Updates lctx->cur_block on exit.
 */
void ir_lower_stmt(ir_lower_ctx_t *lctx, const TreeNode_t *stmt);

/* ────────────────────────────────────────────────────────────
 * Section 4 – Structure  (ir_lower.c)
 * ──────────────────────────────────────────────────────────── */

/*
 * Lower one function definition (NODE_FUNCTION with a body).
 */
void ir_lower_function(ir_lower_ctx_t *lctx, const TreeNode_t *func_node);

/* ────────────────────────────────────────────────────────────
 * Control-frame helpers used across stmt / expr lowering
 * ──────────────────────────────────────────────────────────── */

void ir_ctrl_push(ir_lower_ctx_t *lctx,
                  unsigned break_block,
                  unsigned continue_block,
                  int has_continue);
void ir_ctrl_pop(ir_lower_ctx_t *lctx);
ir_ctrl_frame_t *ir_ctrl_top(ir_lower_ctx_t *lctx);

/* ────────────────────────────────────────────────────────────
 * Block helpers
 * ──────────────────────────────────────────────────────────── */

/* Allocate + append a new basic block to the current function */
ir_block_t *ir_new_block(ir_lower_ctx_t *lctx);

/* Emit an unconditional branch to target_block from cur_block (if
 * cur_block has no terminator yet).  Does NOT change cur_block. */
void ir_seal_goto(ir_lower_ctx_t *lctx, unsigned target_id);

/* Emit a conditional branch from cur_block. */
void ir_seal_branch(ir_lower_ctx_t *lctx, ir_value_t pred,
                    unsigned true_id, unsigned false_id);

/* Emit a switch terminator from cur_block.
 * case_values[k] branches to case_blocks[k], otherwise default_id. */
void ir_seal_switch(ir_lower_ctx_t *lctx,
                    ir_value_t value,
                    unsigned default_id,
                    const long *case_values,
                    const unsigned *case_blocks,
                    unsigned case_count);

/* Return 1 if cur_block already has a terminator */
int ir_block_terminated(const ir_lower_ctx_t *lctx);

#endif /* IR_LOWER_H */