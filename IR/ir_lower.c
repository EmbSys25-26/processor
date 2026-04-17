/*
 * ir_lower.c — Section 4: Structure / top-level lowering glue
 *
 * Responsibilities (§8.1, §8.4, §6):
 *   • Walk the NODE_TRANSLATION_UNIT sibling chain.
 *   • Dispatch top-level declarations to ir_lower_decl.c.
 *   • Dispatch function definitions to ir_lower_function().
 *   • Provide the shared ir_lower_ctx_t helpers used by all sections.
 */

#include <assert.h>
#include <stdarg.h>
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

/* ***********************************************************
 * Diagnostics (§13)
 * ************************************************************/

void ir_diag(ir_lower_ctx_t *lctx, const char *code,
             size_t line, const char *fmt, ...)
{
    va_list ap;
    fprintf(stderr, "[%s] line %zu: ", code ? code : "IR???", line);
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fprintf(stderr, "\n");
    if (lctx) lctx->error_count++;
}

void ir_warn(ir_lower_ctx_t *lctx, const char *code,
             size_t line, const char *fmt, ...)
{
    va_list ap;
    fprintf(stderr, "[%s] line %zu: ", code ? code : "IRW??", line);
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fprintf(stderr, "\n");
    (void)lctx;
}

/* ***********************************************************
 * Semantic type → IR type  (§5)
 * ************************************************************/

ir_type_t ir_type_from_sem(const type_t *sem_type)
{
    if (!sem_type || sem_type->kind == TYPE_INVALID) {
        return ir_type_i16(); /* safe fallback */
    }

    switch (sem_type->kind) {
    case TYPE_BUILTIN:
        switch (sem_type->as.builtin) {
        case BUILTIN_VOID:        return ir_type_void();
        case BUILTIN_CHAR:        return ir_type_i8();
        case BUILTIN_SHORT:       return ir_type_i16();
        case BUILTIN_INT:         return ir_type_i16(); /* target is 16-bit */
        case BUILTIN_LONG:        return ir_type_i32();
        case BUILTIN_STRING:      return ir_type_ptr(); /* ptr to i8, §3.6 */
        case BUILTIN_FLOAT:
        case BUILTIN_DOUBLE:
        case BUILTIN_LONG_DOUBLE:
            /* Float is SEM_NODE_CODEGEN_BLOCKED; we return a placeholder.
             * The caller checks the flag before calling us. */
            return ir_type_i16();
        default:                  return ir_type_i16();
        }

    case TYPE_POINTER:
        return ir_type_ptr();

    case TYPE_ARRAY:
        if (sem_type->as.array.elem && sem_type->as.array.is_known_size) {
            ir_type_t elem = ir_type_from_sem(sem_type->as.array.elem);
            return ir_type_array(elem, sem_type->as.array.size);
        }
        return ir_type_ptr(); /* decay to pointer */

    case TYPE_STRUCT_TAG:
        return ir_type_struct(sem_type->as.aggregate.tag
                              ? sem_type->as.aggregate.tag : "?");

    case TYPE_UNION_TAG:
        return ir_type_union(sem_type->as.aggregate.tag
                             ? sem_type->as.aggregate.tag : "?");

    case TYPE_FUNCTION:
        return ir_type_ptr(); /* function pointer */

    default:
        return ir_type_i16();
    }
}

/* ***********************************************************
 * Control-frame helpers (§8.3 rule 6)
 * ************************************************************/

void ir_ctrl_push(ir_lower_ctx_t *lctx,
                  unsigned break_block,
                  unsigned continue_block,
                  int has_continue)
{
    if (lctx->ctrl_depth >= IR_CTRL_STACK_MAX) {
        ir_diag(lctx, "IR004", 0, "control-frame stack overflow");
        return;
    }
    ir_ctrl_frame_t *f = &lctx->ctrl_stack[lctx->ctrl_depth++];
    f->break_block    = break_block;
    f->continue_block = continue_block;
    f->has_continue   = has_continue;
}

void ir_ctrl_pop(ir_lower_ctx_t *lctx)
{
    if (lctx->ctrl_depth > 0) lctx->ctrl_depth--;
}

ir_ctrl_frame_t *ir_ctrl_top(ir_lower_ctx_t *lctx)
{
    if (lctx->ctrl_depth == 0) return NULL;
    return &lctx->ctrl_stack[lctx->ctrl_depth - 1];
}

/* ***********************************************************
 * Block helpers
 * ************************************************************/

ir_block_t *ir_new_block(ir_lower_ctx_t *lctx)
{
    ir_block_t *b = ir_block_new(lctx->func);
    ir_block_append(lctx->func, b);
    return b;
}

int ir_block_terminated(const ir_lower_ctx_t *lctx)
{
    if (!lctx->cur_block || !lctx->cur_block->tail) return 0;
    ir_opcode_t op = lctx->cur_block->tail->op;
    return (op == IR_OP_GOTO || op == IR_OP_BRANCH || op == IR_OP_SWITCH || op == IR_OP_RET);
}

void ir_seal_goto(ir_lower_ctx_t *lctx, unsigned target_id)
{
    if (ir_block_terminated(lctx)) return; /* already has terminator */
    ir_instr_t *i = ir_instr_new(IR_OP_GOTO);
    i->as.branch.true_block  = target_id;
    i->as.branch.false_block = target_id;
    ir_instr_push(lctx->cur_block, i);
}

void ir_seal_branch(ir_lower_ctx_t *lctx, ir_value_t pred,
                    unsigned true_id, unsigned false_id)
{
    if (ir_block_terminated(lctx)) return;
    ir_instr_t *i = ir_instr_new(IR_OP_BRANCH);
    i->src[0]     = pred;
    i->as.branch.true_block  = true_id;
    i->as.branch.false_block = false_id;
    ir_instr_push(lctx->cur_block, i);
}

void ir_seal_switch(ir_lower_ctx_t *lctx,
                    ir_value_t value,
                    unsigned default_id,
                    const long *case_values,
                    const unsigned *case_blocks,
                    unsigned case_count)
{
    if (ir_block_terminated(lctx)) return;

    ir_instr_t *i = ir_instr_new(IR_OP_SWITCH);
    if (!i) {
        ir_diag(lctx, "IR001", 0, "out of memory creating switch terminator");
        return;
    }

    if (case_count > IR_MAX_SWITCH_CASES) {
        ir_diag(lctx, "IR001", 0, "switch has too many cases for IR_OP_SWITCH");
        free(i);
        return;
    }

    i->src[0] = value;
    i->as.sw.default_block = default_id;
    i->as.sw.case_count = case_count;
    for (unsigned k = 0; k < case_count; ++k) {
        i->as.sw.case_values[k] = case_values[k];
        i->as.sw.case_blocks[k] = case_blocks[k];
    }

    ir_instr_push(lctx->cur_block, i);
}

/* ***********************************************************
 * Section 4 — Function lowering (§8.4)
 * ************************************************************/

/*
 * Collect all NODE_PARAMETER children from a NODE_FUNCTION's parameter list,
 * allocate slots, bind them.
 *
 * AST layout (from parser.y):
 *   NODE_FUNCTION
 *     child[0]: return type specifiers (NODE_TYPE / NODE_SIGN / …)
 *     child[1]: identifier (function name)
 *     child[2]: parameter list — siblings of NODE_PARAMETER
 *     child[3]: body — NODE_BLOCK  (or NULL for prototype)
 *
 * We iterate sibling chains to find the body (NODE_BLOCK) and params.
 */
void ir_lower_function(ir_lower_ctx_t *lctx, const TreeNode_t *func_node)
{
    const TreeNode_t *body_node = NULL;

    if (!func_node) return;

    /* ── Retrieve semantic info for the function itself ── */
    const sem_node_info_t *finfo =
        semantic_get_node_info(lctx->sem_ctx, func_node);

    /* ── Build return type ── */
    ir_type_t ret_type = ir_type_i16(); /* safe default */
    if (finfo && finfo->type && finfo->type->kind == TYPE_FUNCTION) {
        ret_type = ir_type_from_sem(finfo->type->as.function.return_type);
    }

    /* ── Determine function name ── */
    const char *fname = "unknown";
    /* In the AST, NODE_FUNCTION has its name stored directly in nodeData.sVal
     * (set by the parser's helper). If not, walk children for NODE_IDENTIFIER. */
    if (func_node->nodeData.sVal && func_node->nodeData.sVal[0] != '\0') {
        fname = func_node->nodeData.sVal;
    } else {
        for (const TreeNode_t *ch = func_node->p_firstChild; ch; ch = ch->p_sibling) {
            if (ch->nodeType == NODE_IDENTIFIER && ch->nodeData.sVal) {
                fname = ch->nodeData.sVal;
                break;
            }
        }
    }
    /* Also try the symbol attached to this node */
    if (strcmp(fname, "unknown") == 0 && finfo && finfo->symbol && finfo->symbol->name) {
        fname = finfo->symbol->name;
    }

    /* ── Create the ir_function_t and entry block ── */
    ir_function_t *func = ir_function_new(fname, ret_type);
    if (!func) {
        ir_diag(lctx, "IR001", func_node->lineNumber,
                "out of memory creating function '%s'", fname);
        return;
    }

    lctx->func = func;

    ir_block_t *entry = ir_new_block(lctx);
    lctx->cur_block = entry;

    /* Find function body (compound statement) and lower it. */
    for (const TreeNode_t *ch = func_node->p_firstChild; ch; ch = ch->p_sibling) {
        if (ch->nodeType == NODE_BLOCK) {
            body_node = ch;
            break;
        }
    }

    if (body_node) {
        ir_lower_stmt(lctx, body_node);
    }

    /* Ensure every function has an explicit terminator in the active block.
       If control can fall through, inject a default return. */
    if (!ir_block_terminated(lctx)) {
        ir_instr_t *ret = ir_instr_new(IR_OP_RET);
        ret->src[0] = ir_val_none();
        ir_instr_push(lctx->cur_block, ret);
    }

    ir_module_add_function(lctx->module, func);
    lctx->func = NULL;
    lctx->cur_block = NULL;
}

/************************************************************
 * PUBLIC IR ENTRY POINT 
 *************************************************************/

ir_module_t *ir_lower_translation_unit(const TreeNode_t   *root,
                                        semantic_context_t *sem_ctx,
                                        const char         *module_name)
{
    if (!root || !sem_ctx) return NULL;

    ir_module_t *mod = ir_module_new(module_name ? module_name : "ATL83"); // depois muda-se o nome, ou não kkk
    if (!mod) return NULL;

    ir_lower_ctx_t lctx;
    memset(&lctx, 0, sizeof(lctx));
    lctx.module   = mod;
    lctx.sem_ctx  = sem_ctx;

    /*
     * Walk the direct children of NODE_TRANSLATION_UNIT.
     * Each child is a top-level declaration or function definition.
     * IMPORTANT: top-down pre-order traversal, with post-order emission on expression
     */
    const TreeNode_t *child = root->p_firstChild;
    while (child) {
        /* §10 / §3.8: check codegen-blocked before descending */
        const sem_node_info_t *info =
            semantic_get_node_info(sem_ctx, child);
        if (info && (info->flags & SEM_NODE_CODEGEN_BLOCKED)) {
            ir_diag(&lctx, "IR001", child->lineNumber,
                    "node blocked for codegen (unsupported feature)");
            child = child->p_sibling;
            continue;
        }

        switch (child->nodeType) {
        case NODE_FUNCTION:
            /* Prototype (no body) — skip for now; backend would solve via externs - not applicable for us */
            {
                int has_body = 0;
                for (const TreeNode_t *ch = child->p_firstChild; ch; ch = ch->p_sibling) {
                    if (ch->nodeType == NODE_BLOCK) { has_body = 1; break; }
                }
                if (has_body) {
                    ir_lower_function(&lctx, child);
                } else {
                    /* emit extern declaration */
                    const char *fname = "unknown";
                    for (const TreeNode_t *ch = child->p_firstChild; ch; ch = ch->p_sibling) {
                        if (ch->nodeType == NODE_IDENTIFIER && ch->nodeData.sVal) {
                            fname = ch->nodeData.sVal;
                            break;
                        }
                    }
                    ir_type_t ft = ir_type_ptr();
                    ir_module_add_global(mod, fname, ft, /*is_extern=*/1);
                }
            }
            break;

        case NODE_VAR_DECLARATION:
        case NODE_ARRAY_DECLARATION:
            ir_lower_global_decl(&lctx, child);
            break;

        case NODE_STRUCT_DECLARATION:
        case NODE_UNION_DECLARATION:
        case NODE_ENUM_DECLARATION:
            /* Aggregate type definitions are metadata only at IR level;
             * no instructions emitted for the declaration itself. */
            break;

        case NODE_PP_DEFINE:
        case NODE_PP_UNDEF:
            /* Preprocessor nodes are handled before semantic; ignore. */
            break;

        default:
            /* other top-level nodes (e.g. NODE_NULL) — ignore silently */
            break;
        }

        if (lctx.error_count > 0) {
            /* abort on first function-level error to avoid cascade */
            break;
        }

        child = child->p_sibling;
    }

    if (lctx.error_count > 0) {
        ir_module_free(mod);
        return NULL;
    }
    return mod;
}