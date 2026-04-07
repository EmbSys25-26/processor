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
#include "../Semantic/symbol.h"
#include "../Semantic/type.h"
#include "../Util/NodeTypes.h"
#include "ir.h"
#include "ir_lower.h"

/* ─── helpers ─────────────────────────────────────────────── */

/*
 * Coerce a value to i1 (boolean predicate) by comparing != 0.
 */
static ir_value_t coerce_to_pred(ir_lower_ctx_t *lctx, ir_value_t v)
{
    // G2 TODO: if already i1 return as-is
    //       otherwise emit IR_OP_NEQ against immediate 0
    //       return the i1 result vreg
    return ir_val_none();
}

/************************************************************
 * Switch helper: emit a chain of compare-and-branch for case labels
 *************************************************************/

typedef struct switch_case_s switch_case_t;
struct switch_case_s {
    long          value;        /* case constant value     */
    unsigned      target_block; /* bb id for case body     */
    int           is_default;
    switch_case_t *next;
};

static switch_case_t *collect_cases(const TreeNode_t *switch_node,
                                     ir_lower_ctx_t *lctx)
{
    /* switch body is the last child (NODE_BLOCK) */
    const TreeNode_t *body = NULL;
    for (const TreeNode_t *ch = switch_node->p_firstChild; ch; ch = ch->p_sibling) {
        if (ch->nodeType == NODE_BLOCK) body = ch;
    }
    if (!body) return NULL;

    switch_case_t *head = NULL, *tail = NULL;
    for (const TreeNode_t *stmt = body->p_firstChild; stmt; stmt = stmt->p_sibling) {
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
            sc->target_block = cb->id;
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

void ir_lower_stmt(ir_lower_ctx_t *lctx, const TreeNode_t *stmt)
{
    if (!stmt) return;

    /* Process a sibling chain */
    for (const TreeNode_t *s = stmt; s; s = s->p_sibling) {
        if (lctx->error_count > 0) return;
        ir_lower_single_stmt(lctx, s);
    }
}

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
        // G2 TODO: lower return value expression if present
        //       emit IR_OP_RET
        //       create dead block and set as cur_block
        break;

    /* ── §8.3 rule 6: break ─────────────────────────────── */
    case NODE_BREAK:
        // G2 TODO: get top ctrl frame
        //       seal goto frame->break_block
        //       create dead block
        break;

    /* ── §8.3 rule 6: continue ──────────────────────────── */
    case NODE_CONTINUE:
        // G2 TODO: get top ctrl frame
        //       seal goto frame->continue_block
        //       create dead block
        break;

    /* ── §8.3 rule 1: if / if-else ──────────────────────── */
    case NODE_IF:     
        // G2 TODO: lower condition with ir_lower_expr
        //       coerce to predicate (compare != 0)
        //       create then_block, else_block (if present), merge_block
        //       emit ir_seal_branch
        //       lower then body, seal goto merge
        //       lower else body if present, seal goto merge
        //       set cur_block to merge
        break;

    /* ── §8.3 rule 2: while ─────────────────────────────── */
    case NODE_WHILE: 
        // G2 TODO: create cond_block, body_block, exit_block
        //       seal goto cond_block
        //       lower condition, emit branch
        //       push ctrl frame (break=exit, continue=cond)
        //       lower body, seal goto cond
        //       pop ctrl frame
        //       set cur_block to exit
        break;

    /* ── §8.3 rule 3: do-while ──────────────────────────── */
    case NODE_DO_WHILE: 
        // G2 TODO: create body_block, cond_block, exit_block
        //       seal goto body
        //       push ctrl frame
        //       lower body, seal goto cond
        //       pop ctrl frame
        //       lower condition, emit branch back to body or exit
        break;

    /* ── §8.3 rule 4: for ───────────────────────────────── */
    case NODE_FOR: 
        // G2 TODO: lower init (expr or decl)
        //       create cond_block, body_block, update_block, exit_block
        //       lower condition, emit branch
        //       push ctrl frame (break=exit, continue=update)
        //       lower body, seal goto update
        //       pop ctrl frame
        //       lower update, seal goto cond
        break;

    /* ── §8.3 rule 5: switch ────────────────────────────── */
    case NODE_SWITCH: {
        /*
         * AST: NODE_SWITCH → expr, NODE_BLOCK(cases)
         *
         * Strategy (phase 1): comparison chain.
         *   1. Evaluate the switch expression.
         *   2. Collect case labels and pre-allocate their blocks.
         *   3. Emit a chain of eq-comparisons with jumps.
         *   4. Lower each case body in order.
         */
        const TreeNode_t *expr_node = s->p_firstChild;
        const TreeNode_t *body_node = NULL;
        for (const TreeNode_t *ch = s->p_firstChild; ch; ch = ch->p_sibling) {
            if (ch->nodeType == NODE_BLOCK) { body_node = ch; break; }
        }

        ir_block_t *exit_block = ir_new_block(lctx);

        /* Evaluate switch expression */
        ir_type_t et;
        ir_value_t eval = ir_lower_expr(lctx, expr_node, &et);

        /* Collect cases (pre-allocates blocks) */
        switch_case_t *cases = collect_cases(s, lctx);
        unsigned default_block_id = exit_block->id;
        for (switch_case_t *sc = cases; sc; sc = sc->next) {
            if (sc->is_default) { default_block_id = sc->target_block; break; }
        }

        /* Emit comparison chain */
        ir_block_t *chain_tail = lctx->cur_block; /* starts from cur */
        for (switch_case_t *sc = cases; sc; sc = sc->next) {
            if (sc->is_default) continue; /* handled at end */

            unsigned cmp_r = ir_new_vreg(lctx->func);
            ir_instr_t *cmp = ir_instr_new(IR_OP_EQ);
            cmp->dst    = ir_val_vreg(cmp_r, ir_type_i1());
            cmp->src[0] = eval;
            cmp->src[1] = ir_val_imm(sc->value, et);
            ir_instr_push(chain_tail, cmp);

            /* Next chain block (fallthrough when no match) */
            ir_block_t *next_chain = ir_new_block(lctx);
            ir_seal_branch(lctx, ir_val_vreg(cmp_r, ir_type_i1()),
                            sc->target_block, next_chain->id);
            chain_tail = next_chain;
            lctx->cur_block = next_chain;
        }
        /* End of chain: goto default or exit */
        ir_seal_goto(lctx, default_block_id);

        /* Lower case bodies */
        ir_ctrl_push(lctx, exit_block->id, 0, /*has_continue=*/0);

        if (body_node) {
            switch_case_t *sc = cases;
            for (const TreeNode_t *stmt2 = body_node->p_firstChild;
                 stmt2; stmt2 = stmt2->p_sibling)
            {
                if (stmt2->nodeType == NODE_CASE ||
                    stmt2->nodeType == NODE_DEFAULT) {
                    /* Switch to the pre-allocated block for this case */
                    if (sc) {
                        lctx->cur_block = lctx->func->entry;
                        /* Walk to the block with the right id */
                        for (ir_block_t *b = lctx->func->entry; b; b = b->next) {
                            if (b->id == sc->target_block) {
                                lctx->cur_block = b;
                                break;
                            }
                        }
                        sc = sc->next;
                    }
                    /* Lower the statements following this label */
                    const TreeNode_t *label_stmts =
                        stmt2->p_firstChild
                        ? stmt2->p_firstChild->p_sibling /* skip label value */
                        : NULL;
                    if (label_stmts)
                        ir_lower_single_stmt(lctx, label_stmts);
                } else {
                    ir_lower_single_stmt(lctx, stmt2);
                }
            }
        }
        ir_ctrl_pop(lctx);

        /* Seal into exit if not already terminated */
        ir_seal_goto(lctx, exit_block->id);

        /* Free case list */
        switch_case_t *sc = cases;
        while (sc) { switch_case_t *next = sc->next; free(sc); sc = next; }

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