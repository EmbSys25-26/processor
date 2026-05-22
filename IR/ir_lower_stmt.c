/*
 * ir_lower_stmt.c — Section 3: Statement lowering
 *
 * Covers §8.3:
 *   1. if / if-else            → branch + merge blocks
 *   2. while                   → cond block + body + exit
 *   3. do-while                → body + cond + exit
 *   4. for                     → init + cond + body + update + exit
 *   5. switch / case / default → comparison chain + jumps
 *   6. break / continue        → resolve via ctrl_stack
 *   7. return                  → lower value + terminator
 *   8. Compound block (NODE_BLOCK)
 *   9. Expression statements
 *  10. Local declarations inside blocks
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../Parser/ASTree.h"
#include "../Semantic/semantic.h"
#include "ir.h"
#include "ir_lower.h"

/* ─── helpers ─────────────────────────────────────────────── */

/*
 * Coerce a value to i1 (boolean predicate) by comparing != 0.
 */
static ir_value_t coerce_to_pred(ir_lower_ctx_t *lctx, ir_value_t v)
{
    /* ── Predicate coercion: normalize to i1 for control-flow decisions ── */
    ir_instr_t *cmp;
    unsigned pred_reg;

    /* No value means the expression lowering failed earlier; propagate a
       structural diagnostic here so the branch builder does not consume
       an invalid predicate. */
    if (v.kind == IR_VAL_NONE) {
        ir_diag(lctx, "IR003", 0, "cannot coerce empty value to predicate");
        return ir_val_none();
    }

    /* If expression lowering already produced i1, keep it as-is to avoid
       creating redundant compare instructions. */
    if (v.type.kind == IR_TYPE_I1) {
        return v;
    }

    /* Canonical lowering for control predicates: (value != 0) -> i1. */
    pred_reg = ir_new_vreg(lctx->func);
    cmp = ir_instr_new(IR_OP_NEQ);
    cmp->dst = ir_val_vreg(pred_reg, ir_type_i1());
    cmp->src[0] = v;
    cmp->src[1] = ir_val_imm(0, v.type.kind == IR_TYPE_VOID ? ir_type_i16() : v.type);
    ir_instr_push(lctx->cur_block, cmp);

    return ir_val_vreg(pred_reg, ir_type_i1());
}

/************************************************************
 * Switch helper: emit a chain of compare-and-branch for case labels
 *************************************************************/

typedef struct switch_case_s switch_case_t;
struct switch_case_s {
    long          value;        /* case constant value     */
    ir_block_t   *block;        /* block for case body     */
    int           is_default;
    switch_case_t *next;
};

/* Remove an empty tail block that was created only to keep the
   traversal invariant after a terminator (e.g., break in switch).
   This avoids emitting dead empty bb artifacts for case clauses. */
static void prune_empty_tail_block(ir_lower_ctx_t *lctx)
{
    ir_block_t *tail;
    ir_block_t *prev;

    if (!lctx || !lctx->func) return;

    tail = lctx->func->block_tail;
    if (!tail || tail != lctx->cur_block) return;

    /* Only prune truly empty tail blocks. */
    if (tail->head || tail->tail) return;

    /* Keep function entry intact. */
    if (lctx->func->entry == tail) return;

    prev = lctx->func->entry;
    while (prev && prev->next != tail) {
        prev = prev->next;
    }
    if (!prev) return;

    prev->next = NULL;
    lctx->func->block_tail = prev;
    lctx->cur_block = prev;
    free(tail);
}

/* Walks the switch body's siblings and builds a linked list of case/default
 * descriptors, allocating a fresh block for each clause. */
static switch_case_t *collect_cases(const TreeNode_t *switch_body, ir_lower_ctx_t *lctx)
{
    switch_case_t *head = NULL, *tail = NULL;
    for (const TreeNode_t *stmt = switch_body; stmt; stmt = stmt->p_sibling) {
        if (stmt->nodeType == NODE_CASE || stmt->nodeType == NODE_DEFAULT) {
            switch_case_t *sc = (switch_case_t *)calloc(1, sizeof(*sc));
            if (!sc) continue;
            sc->is_default = (stmt->nodeType == NODE_DEFAULT);
            if (!sc->is_default) {
                /* label is first child: INTEGER or CHAR or IDENTIFIER */
                const TreeNode_t *lbl = stmt->p_firstChild;
                if (lbl) {
                    if (lbl->nodeType == NODE_INTEGER ||
                        lbl->nodeType == NODE_CHAR) {
                        sc->value = (long)lbl->nodeData.dVal;
                    }
                    /* IDENTIFIER (enum): semantic resolves; use 0 placeholder */
                }
            }
            /* Allocate a block for this case body */
            ir_block_t *cb = ir_new_block(lctx);
            sc->block = cb;
            if (!head) { head = sc; tail = sc; }
            else { tail->next = sc; tail = sc; }
        }
    }
    return head;
}

/************************************************************
 * Statement lowering dispatcher
 *************************************************************/

/* Forward declaration for mutual recursion */
static void ir_lower_single_stmt(ir_lower_ctx_t *lctx, const TreeNode_t *s);

/* Lowers a statement sibling chain, stopping early on the first error. */
void ir_lower_stmt(ir_lower_ctx_t *lctx, const TreeNode_t *stmt)
{
    if (!stmt) return;

    /* Process a sibling chain */
    for (const TreeNode_t *s = stmt; s; s = s->p_sibling) {
        if (lctx->error_count > 0) return;
        ir_lower_single_stmt(lctx, s);
    }
}

/* Dispatches a single statement node to the appropriate lowering rule
 * (blocks, control flow, declarations, returns, expression-statements). */
static void ir_lower_single_stmt(ir_lower_ctx_t *lctx, const TreeNode_t *s)
{
    if (!s) return;

    /* §10: blocked */
    const sem_node_info_t *sinfo =
        semantic_get_node_info(lctx->sem_ctx, s);
    if (sinfo && (sinfo->flags & SEM_NODE_CODEGEN_BLOCKED)) {
        ir_diag(lctx, "IR001", s->lineNumber,
                "statement blocked for codegen");
        return;
    }

    switch (s->nodeType) {

    /* ── Compound block ─────────────────────────────────── */
    case NODE_BLOCK:
        for (const TreeNode_t *ch = s->p_firstChild; ch; ch = ch->p_sibling) {
            if (lctx->error_count) return;
            ir_lower_single_stmt(lctx, ch);
        }
        break;

    /* ── Variable/array declarations ────────────────────── */
    case NODE_VAR_DECLARATION:
    case NODE_ARRAY_DECLARATION:
        ir_lower_local_decl(lctx, s);
        break;

    /* Struct/union/enum declarations inside a function are type-only */
    case NODE_STRUCT_DECLARATION:
    case NODE_UNION_DECLARATION:
    case NODE_ENUM_DECLARATION:
        break;

    /* ── Expression statement ───────────────────────────── */
    case NODE_OPERATOR:
    case NODE_FUNCTION_CALL:
    case NODE_POST_INC:
    case NODE_POST_DEC:
    case NODE_PRE_INC:
    case NODE_PRE_DEC:
    case NODE_TERNARY:
    case NODE_REFERENCE:
    case NODE_POINTER_CONTENT:
    case NODE_ARRAY_ACCESS:
    case NODE_MEMBER_ACCESS:
    case NODE_PTR_MEMBER_ACCESS:
    case NODE_TYPE_CAST:
    case NODE_IDENTIFIER:
    case NODE_INTEGER:
    case NODE_CHAR:
    case NODE_STRING:
    case NODE_FLOAT: {
        ir_type_t t;
        ir_lower_expr(lctx, s, &t); /* discard result */
        break;
    }

    /* ── §8.3 rule 7: return ────────────────────────────── */
    case NODE_RETURN:
    {
        /* ── Return statement: emit value + terminator + fresh block ── */

        // s is the current return statement node. Its first child (if present) is the return expression.
        const TreeNode_t *ret_expr = s->p_firstChild;

        // create a new IR instruction for the return operation
        ir_instr_t *ret = ir_instr_new(IR_OP_RET);

        /* return <expr>; lower expression and place it in src[0].
           return; uses IR_VAL_NONE to encode void return. */
        if (ret_expr) {
            ir_type_t ret_type;
            // Just uses the first source operand to hold the return value

            /*Lowering context, AST node for the return expression and
              a pointer to the IR storage type for the return value */
            ret->src[0] = ir_lower_expr(lctx, ret_expr, &ret_type);

        } else {
            /*If the first child of the return node is NULL, it means we have a void return,
             so we set the source operand to IR_VAL_NONE. */         
            ret->src[0] = ir_val_none();    

        }

        // Push the created IR instruction to the current basic block with the current block lowering context.
        ir_instr_push(lctx->cur_block, ret);

        /* Keep the statement walker invariant: after a terminator, point to a 
            fresh block so subsequent sibling nodes never append after RET. */
        lctx->cur_block = ir_new_block(lctx);
        break;
    }

    /* ── §8.3 rule 6: break ─────────────────────────────── */
    case NODE_BREAK:
    {
        /* ── Break statement: resolve frame and jump to exit block ── */

        /*  Get the current control frame from the lowering context.
         *  The control frame is a structure that holds information about the current control flow constructs
         *  (like loops and switches) that we're inside. It includes the target basic blocks for 
         *  break and continue statements.
         *  The control frame stack is managed by loop/switch lowering to keep track of valid
         *  break/continue targets at each nesting level.
         */
        ir_ctrl_frame_t *frame = ir_ctrl_top(lctx);

        /* break must resolve inside nearest loop/switch frame. */
        if (!frame) {
            /*  If there is no valid control frame, it means the break statement is used outside of any loop
             *  or switch context, which is illegal in C. We emit a diagnostic message to indicate this error.
             *  IR004 is the error code for "break outside loop/switch".
             *  We also include the line number of the offending break statement. 
             */

            ir_diag(lctx, "IR004", s->lineNumber, "break outside loop/switch");
            break;
        }

        /*  Emit jump to the frame exit block, then move lowering to a dead/open
         *  block to preserve the single-terminator discipline. 
         *  This function updates the current blocks terminator to jump to the break target block 
         *  specified in the control frame.
         *  We create a new instruction for an unconditional jump (IR_OP_GOTO) to the break target 
         *  block and push it to the current block.
         *  After emitting the jump instruction, we move the current block to a new block. 
         *  This is necessary to maintain the invariant that a basic block can only have one 
         *  terminator instruction.
         */
        ir_seal_goto(lctx, frame->break_block);
        lctx->cur_block = ir_new_block(lctx);
        break;
    }

    /* ── §8.3 rule 6: continue ──────────────────────────── */
    case NODE_CONTINUE:
    {
        /* ── Continue statement: resolve loop frame and jump to cond/update ── */

        /*  Get the current control frame from the lowering context.
         *  The control frame is a structure that holds information about the current control flow constructs
         *  (like loops and switches) that we're inside. It includes the target basic blocks for break and continue statements.
         *  The control frame stack is managed by loop/switch lowering to keep track of valid
         *  break/continue targets at each nesting level.
         */
        ir_ctrl_frame_t *frame = ir_ctrl_top(lctx);

        /* continue is legal only for loop frames that expose a continue target. */
        if (!frame || !frame->has_continue) {
            /*  If there is no valid control frame, it means the continue statement is used outside of any loop
             *  context, which is illegal in C. We emit a diagnostic message to indicate this error.
             *  IR004 is the error code for "break outside loop/switch".
             *  We also include the line number of the offending break statement. 
             */
            ir_diag(lctx, "IR004", s->lineNumber, "continue outside loop");
            break;  // We break out of the case for NODE_CONTINUE since we cannot proceed with an invalid continue statement
        }

        /*  Jump to loop continue target (cond/update depending on loop shape),
         *  then advance to a dead/open block for subsequent sibling traversal.
         *  This function updates the current blocks terminator to jump to the continue target 
         *  block specified in the control frame.
         *  We create a new instruction for an unconditional jump (IR_OP_GOTO) to the continue 
         *  target block and push it to the current block.
         *  After emitting the jump instruction, we move the current block to a new block. 
         *  This is necessary to maintain the invariant that a basic block can only have one terminator instruction.
         */
        ir_seal_goto(lctx, frame->continue_block);
        lctx->cur_block = ir_new_block(lctx);
        break;
    }

    /* ── §8.3 rule 1: if / if-else ──────────────────────── */
    case NODE_IF:
    {
        /* ── If/else CFG: decision block branching to then/else/merge ── */

        // condition is always the first child of the if statement node
        const TreeNode_t *cond_node = s->p_firstChild;          
        // if the condition node is present, then the "then" block is the next sibling; otherwise, it's NULL (malformed if)
        const TreeNode_t *then_node = cond_node ? cond_node->p_sibling : NULL;  
        // the "else" block is the sibling after the "then" block, but only if the "then" block is present; otherwise, it's NULL (no else)
        const TreeNode_t *else_node = then_node ? then_node->p_sibling : NULL;

        ir_type_t cond_type;            // Type of the condition expression(what type of value it returns), to be filled by ir_lower_expr
        ir_value_t cond_val;            // IR value resulting from lowering the condition expression, to be filled by ir_lower_expr
        ir_value_t pred;                // Used for branching -> result of coercing(boolean) cond_val to i1 if necessary
        ir_block_t *then_block;         // Declare the basic block for the "then" branch; 
        ir_block_t *else_block = NULL;  // Declare the basic block for the "else" branch; its NULL by default
        ir_block_t *merge_block;        // Declare the basic block for the merge point after the if statement;

        // if either the condition node or the then node are missing, it means the if statement is malformed
        if (!cond_node || !then_node) {
            /*  IR001 is the error code for "malformed if statement". 
             *  We emit a diagnostic message with this code, including the  
             *  line number of the offending if statement. */
            ir_diag(lctx, "IR001", s->lineNumber, "malformed if statement");
            break;  // Exit the case for NODE_IF since we cannot proceed with a malformed if statement
        }

        /* Evaluate condition in current block and normalize it to i1. */
        cond_val = ir_lower_expr(lctx, cond_node, &cond_type);  // Lower the condition expression and get its type
        pred = coerce_to_pred(lctx, cond_val);  // coerce the condition value to a predicate (i1) boolean value 

        /* Pre-allocate structural blocks for both arms and merge point.
           No-else if statements branch false directly into merge. */
        then_block = ir_new_block(lctx);        // Create a new basic block for the "then" branch of the if statement
        merge_block = ir_new_block(lctx);       // Create a new basic block for the merge point after the if statement
        if (else_node) {
            else_block = ir_new_block(lctx);    // Only create a new basic block for the "else" branch if there is an else node present
        }

        /*  Defines the structure of the current block as a branch based on the predicate value. 
         *  Emit conditional branch to then/else or then/merge depending on presence of else. 
         *  This function updates the current block's terminator to be a conditional branch based on the predicate value.
         *  If there is an else block, the true target is the then_block and the false target is the else_block; 
         *  otherwise, the false target is the merge_block.
         */
        ir_seal_branch(lctx, pred,then_block->id, else_block ? else_block->id : merge_block->id);
                       
        /* Lower then arm and ensure it reconnects to merge if not already terminated by return/break/etc. */
        lctx->cur_block = then_block;           
        ir_lower_single_stmt(lctx, then_node);      // Lower the "then" block by recursively calling ir_lower_single_stmt 
        ir_seal_goto(lctx, merge_block->id);        // Merge it to the merge block if it did not already terminate

        /* Lower else arm when present and seal it to merge as well. */
        if (else_block) {
            lctx->cur_block = else_block;
            ir_lower_single_stmt(lctx, else_node);  // Lower the "else" block by recursively calling ir_lower_single_stmt 
            ir_seal_goto(lctx, merge_block->id);    // Merge it to the merge block if it did not already terminate
        }

        lctx->cur_block = merge_block;
        break;
    }

    /* ── §8.3 rule 2: while ─────────────────────────────── */
    case NODE_WHILE:
    {
        /* ── While loop CFG: condition-checked bounded iteration ── */
        const TreeNode_t *cond_node = s->p_firstChild;
        const TreeNode_t *body_node = cond_node ? cond_node->p_sibling : NULL;  
        ir_type_t cond_type;
        ir_value_t cond_val;
        ir_value_t pred;
        ir_block_t *cond_block;
        ir_block_t *body_block;
        ir_block_t *exit_block;

        if (!cond_node || !body_node) {
            ir_diag(lctx, "IR001", s->lineNumber, "malformed while statement");
            break;
        }

        /* Canonical while CFG:
           preheader -> cond, cond -> body/exit, body -> cond. */
        // Create new basic block for each of the structural components of the while loop
        cond_block = ir_new_block(lctx);
        body_block = ir_new_block(lctx);
        exit_block = ir_new_block(lctx);

        ir_seal_goto(lctx, cond_block->id);

        /*  Move to the condition block to lower the loop condition expression, 
            coerce it to a predicate, and emit the conditional branch to the body and exit blocks. */
        lctx->cur_block = cond_block;                           // Move to the condition block
        cond_val = ir_lower_expr(lctx, cond_node, &cond_type);  // Lower the condition expression and get its ttype
        pred = coerce_to_pred(lctx, cond_val);                  // Coerce the condition value to a predicate (i1) boolean value
        ir_seal_branch(lctx, pred, body_block->id, exit_block->id); // Emit the conditional branch 

        /* Inside body, expose break->exit and continue->cond targets. */
        lctx->cur_block = body_block;                           // Move to the body block
        ir_ctrl_push(lctx, exit_block->id, cond_block->id, 1);  // Move to a new control frame for the loop body (PUSH)
        ir_lower_single_stmt(lctx, body_node);                  // Recursively lower the loop body
        ir_ctrl_pop(lctx);                                      // Exit the control for the loop body (POP)
        ir_seal_goto(lctx, cond_block->id);                     // Emit an unconditional jump back to the condition block to complete the loop

        lctx->cur_block = exit_block;
        break;
    }

    /* ── §8.3 rule 3: do-while ──────────────────────────── */
    case NODE_DO_WHILE:
    {
        /* ── Do-while loop CFG: body-first then condition-checked iteration ── */

        /*  'Do-while' IR generation is similar to 'while', 
            with only the sequence of blocks changed to reflect the do-while semantics,
            in this case, the body block is processed before the condition block
        */
        
        const TreeNode_t *body_node = s->p_firstChild;
        const TreeNode_t *cond_node = body_node ? body_node->p_sibling : NULL;
        ir_type_t cond_type;
        ir_value_t cond_val;
        ir_value_t pred;
        ir_block_t *body_block;
        ir_block_t *cond_block;
        ir_block_t *exit_block;

        if (!body_node || !cond_node) {
            ir_diag(lctx, "IR001", s->lineNumber, "malformed do-while statement");
            break;
        }

        /* Canonical do-while CFG:
           preheader -> body, body -> cond, cond -> body/exit. */
        // Create new basic block for each of the structural components of the do-while loop
        body_block = ir_new_block(lctx);
        cond_block = ir_new_block(lctx);
        exit_block = ir_new_block(lctx);
    
        /*  As opposed to while loops, do-while loops execute the body
            at least once before checking the condition, which is reflected here
            by having the preheader jump directly to the body block (goto) before any condition evaluation. 
        */
        ir_seal_goto(lctx, body_block->id);

        // Move to the body block to lower the loop body
        lctx->cur_block = body_block;
        /* continue in do-while jumps to condition block, not body. */
        ir_ctrl_push(lctx, exit_block->id, cond_block->id, 1);  // Move to a new control frame for the loop body (PUSH) 
        ir_lower_single_stmt(lctx, body_node);                  // Recursively lower the loop body
        ir_ctrl_pop(lctx);                                      // Exit the control for the loop body (POP)
        ir_seal_goto(lctx, cond_block->id);                     // Emit an unconditional jump to the condition block to complete the loop


        // Only after lowering the body do we move to the condition block to lower the loop condition expression
        lctx->cur_block = cond_block;                           // Move to the condition block
        cond_val = ir_lower_expr(lctx, cond_node, &cond_type);  // Lower the condition expression and get its type
        pred = coerce_to_pred(lctx, cond_val);                  // Coerce the condition value to a predicate (i1) boolean value
        ir_seal_branch(lctx, pred, body_block->id, exit_block->id); // Emit the conditional branch

        lctx->cur_block = exit_block;
        break;
    }

    /* ── §8.3 rule 4: for ───────────────────────────────── */
    case NODE_FOR:
    {
        /* ── For loop CFG: init + cond + body + update + exit structure ── */

        /*
         * A for-loop is represented in the AST as four siblings:
         * init ; cond ; update ; body
         * This extraction keeps the lowering logic explicit and robust.
         */
        /*
         * A multi-declarator init like `for (int *p, *q; ...)` arrives as
         * a sibling chain of declaration nodes that all belong to the init
         * slot, so cond/update/body live past the run of declarations.
         */
        const TreeNode_t *init_node = s->p_firstChild;
        const TreeNode_t *init_end = init_node;
        if (init_node &&
            (init_node->nodeType == NODE_VAR_DECLARATION ||
             init_node->nodeType == NODE_ARRAY_DECLARATION)) {
            while (init_end->p_sibling &&
                   (init_end->p_sibling->nodeType == NODE_VAR_DECLARATION ||
                    init_end->p_sibling->nodeType == NODE_ARRAY_DECLARATION)) {
                init_end = init_end->p_sibling;
            }
        }
        const TreeNode_t *cond_node = init_end ? init_end->p_sibling : NULL;
        const TreeNode_t *update_node = cond_node ? cond_node->p_sibling : NULL;
        const TreeNode_t *body_node = update_node ? update_node->p_sibling : NULL;
        ir_type_t cond_type;
        ir_value_t cond_val;
        ir_value_t pred;
        ir_block_t *cond_block;
        ir_block_t *body_block;
        ir_block_t *update_block;
        ir_block_t *exit_block;

        if (!init_node || !cond_node || !update_node || !body_node) {
            ir_diag(lctx, "IR001", s->lineNumber, "malformed for statement");
            break;
        }

        /*
         * Lower the initializer(s) in the current preheader block before
         * entering loop control flow.
         * If init is a declaration (e.g., for (int i = 0; ...)), create its
         * local slot here; otherwise lower it as a normal expression.
         */
        if (init_node->nodeType != NODE_NULL) {
            if (init_node->nodeType == NODE_VAR_DECLARATION ||
                init_node->nodeType == NODE_ARRAY_DECLARATION) {
                for (const TreeNode_t *d = init_node; d != cond_node;
                     d = d->p_sibling) {
                    ir_lower_local_decl(lctx, d);
                }
            } else {
                ir_type_t t;
                (void)ir_lower_expr(lctx, init_node, &t);
            }
        }

        /*
         * Build canonical for-loop CFG blocks:
         * preheader -> cond
         * cond -> body | exit
         * body -> update
         * update -> cond
         */
        cond_block = ir_new_block(lctx);
        body_block = ir_new_block(lctx);
        update_block = ir_new_block(lctx);
        exit_block = ir_new_block(lctx);

        ir_seal_goto(lctx, cond_block->id);

        lctx->cur_block = cond_block;
        /*
         * No condition means an implicit true loop condition.
         * In that case we jump directly to body and rely on break/return to exit.
         */
        if (cond_node->nodeType == NODE_NULL) {
            ir_seal_goto(lctx, body_block->id);
        } else {
            cond_val = ir_lower_expr(lctx, cond_node, &cond_type);
            pred = coerce_to_pred(lctx, cond_val);
            ir_seal_branch(lctx, pred, body_block->id, exit_block->id);
        }

        /*
         * While lowering the body, publish loop targets so nested
         * break/continue statements resolve correctly:
         * break -> exit, continue -> update.
         */
        lctx->cur_block = body_block;
        ir_ctrl_push(lctx, exit_block->id, update_block->id, 1);
        ir_lower_single_stmt(lctx, body_node);
        ir_ctrl_pop(lctx);
        ir_seal_goto(lctx, update_block->id);

        lctx->cur_block = update_block;
        /*
         * Lower optional update expression after body execution, then reconnect
         * control back to the condition block.
         */
        if (update_node->nodeType != NODE_NULL) {
            ir_type_t t;
            (void)ir_lower_expr(lctx, update_node, &t);
        }
        ir_seal_goto(lctx, cond_block->id);

        lctx->cur_block = exit_block;
        break;
    }

    /* ── §8.3 rule 5: switch ────────────────────────────── */
    case NODE_SWITCH: {
        /* ── Switch CFG: jump table + comparison chain + case blocks + exits ── */

        /*
         * Parser shape: NODE_SWITCH has two direct children:
         * child[0] = expression
         * child[1] = case/default sibling chain
         */
        const TreeNode_t *expr_node = s->p_firstChild;
        const TreeNode_t *body_node = expr_node ? expr_node->p_sibling : NULL;
        const TreeNode_t *clause;   // Contains all the cases logic as siblings

        /* Dedicated switch exit target used by break statements.
         * The default block will point to the exit_block by default, and will be kept there
         * if no default node is found among the cases, otherwise it will be updated to point 
         * to the found default block 
         */
        ir_block_t *exit_block = ir_new_block(lctx);

        if (!expr_node || !body_node) {
            ir_diag(lctx, "IR001", s->lineNumber, "malformed switch statement");
            break;
        }

        if (body_node->nodeType != NODE_CASE && body_node->nodeType != NODE_DEFAULT) {
            ir_diag(lctx, "IR001", s->lineNumber, "malformed switch body");
            break;
        }

        /* Evaluate the controlling switch expression once. */
        ir_type_t et;
        ir_value_t eval = ir_lower_expr(lctx, expr_node, &et);

        /*
         *  Collect cases/default logic and pre-allocate one block per clause. 
         *  These are actually each of the case logic, meaning the basic blocks the
         *  comparisons will jump to when the comparison for that case is true,
         *  and not the comparison blocks themselves, which will be created in the comparison chain below.
         */
        switch_case_t *cases = collect_cases(body_node, lctx);


        /*  The exit block is the default target for when none of the cases match and 
         *  for break statements inside the switch body.
         *  If there is an explicit default case, we use its block as the default target
         *  for the comparison chain instead of the exit block.
         */
        //  Assuming there is no default case, the target for the default block is the exit block
        ir_block_t *default_block = exit_block;     
        // Search the cases for the default block, and if there is one, set the default block to its own block instead
        for (switch_case_t *sc = cases; sc; sc = sc->next) {
            if (sc->is_default) { default_block = sc->block; break; }
        }

        /*
         * Preferred dispatch: a single switch terminator carrying all case
         * value -> target mappings. This keeps lowering modular and allows
         * backends to choose jump tables without changing statement lowering.
         * Fallback to linear chain when case count exceeds opcode capacity (old behavior).
         */
        {
            long case_values[IR_MAX_SWITCH_CASES];
            unsigned case_blocks[IR_MAX_SWITCH_CASES];
            unsigned case_count = 0;

            for (switch_case_t *sc = cases; sc; sc = sc->next) {
                if (sc->is_default) continue;
                if (case_count >= IR_MAX_SWITCH_CASES) {
                    case_count = IR_MAX_SWITCH_CASES + 1u;
                    break;
                }
                case_values[case_count] = sc->value;
                case_blocks[case_count] = sc->block->id;
                case_count++;
            }

            if (case_count <= IR_MAX_SWITCH_CASES) {
                // No found cases, just jump to default (which may be the exit block if no default is found)
                if (case_count == 0u) {
                    ir_seal_goto(lctx, default_block->id);
                } else {
                    ir_seal_switch(lctx, eval, default_block->id,
                                   case_values, 
                                   case_blocks, 
                                   case_count);
                }
            } else {
                /*  Fallback path: preserve old behavior for oversized switches. 
                 *  Old behavior: emit a chain of comparisons for each case value,
                 *  branching to corresponding case block when true, and to the default
                 *  when all standard cases comparisons are false. 
                 */
                // ------------------------------------------------------------------------------------------
                // --------------- Legacy compare-chain lowering for large switch statements ----------------
                // ------------------------------------------------------------------------------------------
                ir_warn(lctx, "IRW001", s->lineNumber,
                        "switch case count exceeded IR_OP_SWITCH capacity; using legacy compare-chain lowering");
                ir_block_t *chain_tail = lctx->cur_block;

                for (switch_case_t *sc = cases; sc; sc = sc->next) {
                    if (sc->is_default) continue;

                    unsigned cmp_r = ir_new_vreg(lctx->func);
                    ir_instr_t *cmp = ir_instr_new(IR_OP_EQ);

                    cmp->dst    = ir_val_vreg(cmp_r, ir_type_i1());
                    cmp->src[0] = eval;                         // The resolved value of the switch expression
                    cmp->src[1] = ir_val_imm(sc->value, et);    // The immediate value of the current case label
                    ir_instr_push(chain_tail, cmp);             // Push instruction comparing the two

                    ir_block_t *next_chain = ir_new_block(lctx);
                    ir_seal_branch(lctx, ir_val_vreg(cmp_r, ir_type_i1()),
                                   sc->block->id, next_chain->id);

                    chain_tail = next_chain;
                    lctx->cur_block = next_chain;
                }
                ir_seal_goto(lctx, default_block->id);
                // ------------------------------------------------------------------------------------------
                // --------------------------- End of legacy compare-chain lowering -------------------------
                // ------------------------------------------------------------------------------------------
            }
        }


        /*
         * Lower clause bodies in AST order, using their pre-allocated blocks.
         * switch frame rules:
         * break is valid and targets exit_block; continue is disabled here.
         */
        ir_ctrl_push(lctx, exit_block->id, 0, /*has_continue=*/0);

        if (body_node) {
            switch_case_t *sc = cases;  // Pointer to the head of the linked list of collected switch cases

            // Where there are new clauses (case/default) in the switch body, loop through them
            for (clause = body_node; clause && sc; clause = clause->p_sibling) {
                const TreeNode_t *clause_body;

                // If it isnt a standard case or a default, then it is not a valid clause
                if (clause->nodeType != NODE_CASE && clause->nodeType != NODE_DEFAULT) {
                    continue;   // Proceed to the next sibling without modifying the switch case list
                }

                /* Move lowering cursor to this clause's dedicated block. */
                lctx->cur_block = sc->block;

                /* CASE body starts after label expression; DEFAULT starts at first child. */
                clause_body = (clause->nodeType == NODE_DEFAULT)
                    ? clause->p_firstChild
                    : (clause->p_firstChild ? clause->p_firstChild->p_sibling : NULL);

                if (clause_body) {
                    /* Lower the full statement chain for this clause so
                       trailing statements like break are not skipped. */
                    ir_lower_stmt(lctx, clause_body);
                    prune_empty_tail_block(lctx);
                }

                sc = sc->next;
            }
        }

        ir_ctrl_pop(lctx);

        /* If the last visited clause block is open, close it to switch exit. */
        ir_seal_goto(lctx, exit_block->id);
        
        /* Free temporary case metadata list used only during lowering. */
        for (switch_case_t *sc = cases; sc; ) {
            switch_case_t *next = sc->next;
            free(sc);
            sc = next;
        }
        
        lctx->cur_block = exit_block;
        break;
    }

    /* ── NULL node ──────────────────────────────────────── */
    case NODE_NULL:
        break;

    /* ── Ignore preprocessor / type-only nodes ──────────── */
    case NODE_PP_DEFINE:
    case NODE_PP_UNDEF:
        break;

    /* ── Function definitions nested in a block (not standard C,
          but the parser may produce them) ── */
    case NODE_FUNCTION:
        /* Nested function: ignore in phase 1 */
        break;

    default:
        /* Unknown statement node — emit as expression if possible */
        {
            ir_type_t t;
            ir_lower_expr(lctx, s, &t);
        }
        break;
    }
}