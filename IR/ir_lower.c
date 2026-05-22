/*
 * ir_lower.c — Section 4: Structure / top-level lowering glue
 *
 * Responsibilities (§8.1, §8.4, §6):
 *   Walk the NODE_TRANSLATION_UNIT sibling chain.
 *   Dispatch top-level declarations to ir_lower_decl.c.
 *   Dispatch function definitions to ir_lower_function().
 *   Provide the shared ir_lower_ctx_t helpers used by all sections.
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

/* Emits a formatted error diagnostic and bumps the context's error counter. */
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

/* Emits a formatted warning diagnostic (does not count toward errors). */
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

/* Maps a semantic type_t to its corresponding IR type. */
ir_type_t ir_type_from_sem(const type_t *sem_type)
{
    if (!sem_type || sem_type->kind == TYPE_INVALID)
        return ir_type_i16(); /* safe fallback */

    switch (sem_type->kind) {
    case TYPE_BUILTIN:
        switch (sem_type->as.builtin) {
        case BUILTIN_VOID:        return ir_type_void();
        case BUILTIN_CHAR:        return ir_type_i8();
        case BUILTIN_SHORT:       return ir_type_i16();
        case BUILTIN_INT:         return ir_type_i16(); /* target is 16-bit */
        case BUILTIN_LONG:        return ir_type_i32();
        case BUILTIN_STRING:      return ir_type_ptr(); /* ptr to i8, §3.6 */
        default:                  return ir_type_i16();
        }
    case TYPE_POINTER:   return ir_type_ptr();
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
    case TYPE_FUNCTION:  return ir_type_ptr(); /* function pointer */
    default:             return ir_type_i16();
    }
}

/* ***********************************************************
 * Aggregate helpers — shared by ir_lower_decl.c and ir_lower_expr.c
 * (declared in ir_lower.h).
 * ************************************************************/

/* Searches the AST for a struct/union declaration node matching `tag`. */
const TreeNode_t *ir_find_aggregate_decl(const TreeNode_t *node,
                                          NodeType_t want_kind,
                                          const char *tag)
{
    if (!node || !tag) return NULL;
    if (node->nodeType == want_kind && node->nodeData.sVal &&
        strcmp(node->nodeData.sVal, tag) == 0)
        return node;
    for (const TreeNode_t *sib = node->p_sibling; sib; sib = sib->p_sibling) {
        const TreeNode_t *r = ir_find_aggregate_decl(sib, want_kind, tag);
        if (r) return r;
    }
    return ir_find_aggregate_decl(node->p_firstChild, want_kind, tag);
}

/* Recursively computes the word size of a semantic type, expanding aggregates. */
size_t ir_compute_sem_type_words(ir_lower_ctx_t *lctx, const type_t *t)
{
    if (!t) return 1;
    switch (t->kind) {
    case TYPE_BUILTIN: {
        ir_type_t it = ir_type_from_sem(t);
        size_t s = ir_type_size_words(it);
        return s ? s : 1;
    }
    case TYPE_POINTER: return 1;
    case TYPE_ARRAY: {
        size_t elem = ir_compute_sem_type_words(lctx, t->as.array.elem);
        size_t cnt  = t->as.array.is_known_size ? t->as.array.size : 1;
        return elem * cnt;
    }
    case TYPE_STRUCT_TAG: {
        const TreeNode_t *decl =
            (const TreeNode_t *)t->as.aggregate.decl_node;
        if (!decl && t->as.aggregate.tag)
            decl = ir_find_aggregate_decl(lctx->root,
                                           NODE_STRUCT_DECLARATION,
                                           t->as.aggregate.tag);
        size_t total = 0;
        for (const TreeNode_t *m = decl ? decl->p_firstChild : NULL;
             m; m = m->p_sibling) {
            if (m->nodeType != NODE_STRUCT_MEMBER &&
                m->nodeType != NODE_ARRAY_DECLARATION) continue;
            const sem_node_info_t *mi =
                semantic_get_node_info(lctx->sem_ctx, m);
            size_t s = mi && mi->type
                ? ir_compute_sem_type_words(lctx, mi->type) : 1;
            total += s ? s : 1;
        }
        return total ? total : 1;
    }
    case TYPE_UNION_TAG: {
        const TreeNode_t *decl =
            (const TreeNode_t *)t->as.aggregate.decl_node;
        if (!decl && t->as.aggregate.tag)
            decl = ir_find_aggregate_decl(lctx->root,
                                           NODE_UNION_DECLARATION,
                                           t->as.aggregate.tag);
        size_t maxsz = 0;
        for (const TreeNode_t *m = decl ? decl->p_firstChild : NULL;
             m; m = m->p_sibling) {
            if (m->nodeType != NODE_STRUCT_MEMBER &&
                m->nodeType != NODE_ARRAY_DECLARATION) continue;
            const sem_node_info_t *mi =
                semantic_get_node_info(lctx->sem_ctx, m);
            size_t s = mi && mi->type
                ? ir_compute_sem_type_words(lctx, mi->type) : 1;
            if (s > maxsz) maxsz = s;
        }
        return maxsz ? maxsz : 1;
    }
    default:
        return 1;
    }
}

/* ***********************************************************
 * Control-frame helpers (§8.3 rule 6)
 * ************************************************************/

/* Pushes a break/continue target frame onto the control-flow stack. */
void ir_ctrl_push(ir_lower_ctx_t *lctx,
                  unsigned break_block, unsigned continue_block, int has_continue)
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

/* Pops the innermost control-flow frame. */
void ir_ctrl_pop(ir_lower_ctx_t *lctx)
{
    if (lctx->ctrl_depth > 0) lctx->ctrl_depth--;
}

/* Returns the innermost control-flow frame, or NULL if none. */
ir_ctrl_frame_t *ir_ctrl_top(ir_lower_ctx_t *lctx)
{
    if (lctx->ctrl_depth == 0) return NULL;
    return &lctx->ctrl_stack[lctx->ctrl_depth - 1];
}

/* ***********************************************************
 * Block helpers
 * ************************************************************/

/* Allocates and appends a fresh block to the current function. */
ir_block_t *ir_new_block(ir_lower_ctx_t *lctx)
{
    ir_block_t *b = ir_block_new(lctx->func);
    ir_block_append(lctx->func, b);
    return b;
}

/* Returns 1 if the current block already ends with a terminator. */
int ir_block_terminated(const ir_lower_ctx_t *lctx)
{
    if (!lctx->cur_block || !lctx->cur_block->tail) return 0;
    ir_opcode_t op = lctx->cur_block->tail->op;
    return (op == IR_OP_GOTO || op == IR_OP_BRANCH || op == IR_OP_RET);
}

/* Closes the current block with an unconditional goto to `target_id`. */
void ir_seal_goto(ir_lower_ctx_t *lctx, unsigned target_id)
{
    if (ir_block_terminated(lctx)) return;
    ir_instr_t *i = ir_instr_new(IR_OP_GOTO);
    IR_BRANCH_SET_TARGETS(i, target_id, target_id);
    ir_instr_push(lctx->cur_block, i);
}

/* Closes the current block with a conditional branch on `pred`. */
void ir_seal_branch(ir_lower_ctx_t *lctx, ir_value_t pred,
                    unsigned true_id, unsigned false_id)
{
    if (ir_block_terminated(lctx)) return;
    ir_instr_t *i = ir_instr_new(IR_OP_BRANCH);
    i->src[0] = pred;
    IR_BRANCH_SET_TARGETS(i, true_id, false_id);
    ir_instr_push(lctx->cur_block, i);
}

/* Closes the current block with a switch terminator over the case table. */
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
    if (!func_node) return;

    /* ── Retrieve semantic info for the function itself ── */
    const sem_node_info_t *finfo =
        semantic_get_node_info(lctx->sem_ctx, func_node);

    /* ── Build return type ── */
    ir_type_t ret_type = ir_type_i16();
    if (finfo && finfo->type && finfo->type->kind == TYPE_FUNCTION)
        ret_type = ir_type_from_sem(finfo->type->as.function.return_type);

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
    if (strcmp(fname, "unknown") == 0 && finfo && finfo->symbol && finfo->symbol->name)
        fname = finfo->symbol->name;

    /* Create the IR function object and its entry block. */
    ir_function_t *func = ir_function_new(fname, ret_type);
    if (!func) {
        ir_diag(lctx, "IR001", func_node->lineNumber,
                "out of memory creating function '%s'", fname);
        return;
    }

    lctx->func = func;

    ir_block_t *entry = ir_new_block(lctx);
    lctx->cur_block = entry;

    /* =====================================================================
    * G3: ir_lower_function
    *
    * Steps:
    *   1. Reserve the incoming parameter vregs (%v0, %v1, ...)
    *      before emitting any instruction, so later temporaries use
    *      higher register numbers.
    *   2. For each parameter, record its signature entry, allocate a
    *      local slot, and store the incoming vreg into that slot.
    *   3. Lower the function body with ir_lower_stmt().
    *   4. Insert an implicit "ret void" if the last block is still open.
    * ===================================================================== */

    /* ------------------------------------------------------------------
     * STEP 1: Reserve the incoming parameter vregs.
     *
     * Parameters are modelled as arriving in %v0, %v1, %v2, ...
     * Reserving them before any emitted instruction guarantees that
     * the addr_of temporaries created below use higher vreg ids.
     * ------------------------------------------------------------------ */

    /* Array to remember which vreg id was assigned to each parameter.
     * param_vregs[0] = id for the 1st param, param_vregs[1] for the 2nd, etc.
     * We need this later in step 2 when emitting the store instructions. */
    unsigned param_vregs[IR_MAX_PARAMS];

    /* Counter for how many parameters this function actually has. */
    unsigned n_params = 0;

    /* First pass: walk all children of the NODE_FUNCTION looking only for
     * parameter declarations (VAR_DECLARATION or ARRAY_DECLARATION).
     * For each one found, call ir_new_vreg to consume the next vreg id.
     * This "pre-allocates" %v0, %v1, ... so they are reserved for the
     * incoming argument values, before any addr_of instruction is emitted. */
    for (const TreeNode_t *ch = func_node->p_firstChild; ch; ch = ch->p_sibling) {

        /* Skip the function body block — we only want parameter nodes here. */
        if (ch->nodeType == NODE_BLOCK) continue;

        /* Only process actual variable/array parameter declarations. */
        if (ch->nodeType != NODE_VAR_DECLARATION &&
            ch->nodeType != NODE_ARRAY_DECLARATION) continue;

        /* Skip unnamed parameters (e.g. "void func(int)"). */
        if (!ch->nodeData.sVal) continue;

        /* Allocate the next vreg id and save it so step 2 can reference it.
         * After this loop: param_vregs[0]=0, param_vregs[1]=1, etc.
         * func->next_vreg is now equal to n_params, so any vreg allocated
         * after this point will have an id >= n_params. */
        if (n_params < IR_MAX_PARAMS)
            param_vregs[n_params++] = ir_new_vreg(func);
    }

    /* ------------------------------------------------------------------
     * STEP 2: Materialise parameters in local stack slots.
     *
     * For each parameter:
     *   %vA = addr_of %slotK          (A > n_params, slot for this param)
     *   *%vA = %vI                    (I = the reserved incoming vreg)
     * ------------------------------------------------------------------ */

    /* Will be set when we encounter the NODE_BLOCK child (function body). */
    const TreeNode_t *body_node = NULL;

    /* Index into param_vregs[]: tracks which reserved vreg we are
     * currently materialising into a slot. */
    unsigned param_idx = 0;

    /* Second pass: walk children again to actually emit the IR instructions
     * for each parameter, and to locate the function body block. */
    for (const TreeNode_t *ch = func_node->p_firstChild; ch; ch = ch->p_sibling) {

        /* When we find the body block, save it for step 3 and move on.
         * We do NOT process it here — body lowering comes after parameters. */
        if (ch->nodeType == NODE_BLOCK) {
            body_node = ch;
            continue;
        }

        /* Skip non-parameter children (type specifiers, modifiers, etc.). */
        if (ch->nodeType != NODE_VAR_DECLARATION &&
            ch->nodeType != NODE_ARRAY_DECLARATION) continue;

        const char *param_name = ch->nodeData.sVal;
        if (!param_name) continue;

        /* Look up the semantic annotation for this parameter node to get
         * its precise IR type (e.g. i16, ptr, i8 ...). */
        const sem_node_info_t *pinfo = semantic_get_node_info(lctx->sem_ctx, ch);
        ir_type_t param_ir_type = ir_type_i16(); /* safe default */
        if (pinfo && pinfo->type)
            param_ir_type = ir_type_from_sem(pinfo->type);
        else if (pinfo && pinfo->symbol && pinfo->symbol->type)
            param_ir_type = ir_type_from_sem(pinfo->symbol->type);

        /* Register this parameter in the function's printed signature.
         * This is what produces "func @soma(i16 %a, i16 %b)" in the IR dump. */
        if (func->param_count < IR_MAX_PARAMS) {
            func->param_types[func->param_count] = param_ir_type;
            snprintf(func->param_names[func->param_count],
                     sizeof(func->param_names[0]), "%s", param_name);
            func->param_count++;
        }

        /* Allocate a stack slot for this parameter.
         * Even though the value arrives in a vreg (or on the caller's stack
         * for params 4+), we immediately spill it to a named slot so that
         * the rest of the body can treat it like any other local variable
         * (load/store via addr_of). */
        unsigned slot = ir_new_slot(func, param_name, param_ir_type);

        /* Only emit IR to materialise REGISTER-PASSED params.  Stack-passed
         * params (index >= PHYS_ARG_REGS = 3) are loaded from the caller's
         * frame directly into their slot by the codegen prologue — going
         * through a vreg here would force every stack-param vreg to be
         * live-in simultaneously, but the IR has no construct for "live-in
         * from caller", so regalloc would coalesce them and the prologue
         * loads would clobber each other. */
        if (param_idx < 3 /* PHYS_ARG_REGS */) {
            /* Emit:  %vA = addr_of %slotK */
            unsigned addr_r = ir_new_vreg(func);
            ir_instr_t *addr_i = ir_instr_new(IR_OP_ADDR_OF);
            addr_i->dst    = ir_val_vreg(addr_r, ir_type_ptr());
            addr_i->src[0] = ir_val_slot(slot, param_ir_type);
            ir_instr_push(lctx->cur_block, addr_i);

            /* Emit:  *%vA = %vI  (the precolored argument register) */
            ir_instr_t *store_i = ir_instr_new(IR_OP_STORE);
            store_i->src[0] = ir_val_vreg(addr_r, ir_type_ptr());
            store_i->src[1] = ir_val_vreg(param_vregs[param_idx],
                                           param_ir_type);
            ir_instr_push(lctx->cur_block, store_i);
        }
        param_idx++;
    }

    /* ------------------------------------------------------------------
     * STEP 3: Lower the function body.
     *
     * ir_lower_stmt recursively walks the NODE_BLOCK and all statements
     * inside it, emitting IR instructions into lctx->cur_block.
     * It handles NODE_RETURN, expressions, declarations, control flow, etc.
     * ------------------------------------------------------------------ */
    if (body_node)
        ir_lower_stmt(lctx, body_node);

    /* ------------------------------------------------------------------
     * STEP 4: Add an implicit return.
     *
     * After lowering the body, the current block may still be "open"
     * (no terminator instruction). This happens when:
     *   - The function is void and has no explicit return at the end.
     *   - All paths inside already returned (dead block after last ret).
     * In both cases we emit "ret void" to ensure the IR is always valid.
     * ------------------------------------------------------------------ */
    if (!ir_block_terminated(lctx)) {
        ir_instr_t *ret_i = ir_instr_new(IR_OP_RET);
        ret_i->src[0] = ir_val_none(); /* void return: no value in src[0] */
        ir_instr_push(lctx->cur_block, ret_i);
    }

    /* Add the completed function to the module and reset context pointers
     * so the next function starts with a clean state. */
    ir_module_add_function(lctx->module, func);
    lctx->func      = NULL;
    lctx->cur_block = NULL;
}
/*-------------------------------------------------------------------------------*/

/************************************************************
 * PUBLIC IR ENTRY POINT
 *************************************************************/

/* Top-level entry: walks the translation unit and lowers each
 * function and global into the returned ir_module_t. */
ir_module_t *ir_lower_translation_unit(const TreeNode_t   *root,
                                        semantic_context_t *sem_ctx,
                                        const char         *module_name)
{
    if (!root || !sem_ctx) return NULL;

    ir_module_t *mod = ir_module_new(module_name ? module_name : "ATL83");
    if (!mod) return NULL;

    ir_lower_ctx_t lctx;
    memset(&lctx, 0, sizeof(lctx));
    lctx.module  = mod;
    lctx.sem_ctx = sem_ctx;
    lctx.root    = root;

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
        case NODE_FUNCTION: /* Prototype (no body) — skip for now; backend would solve via externs - not applicable for us */
          {
            int has_body = 0;
            for (const TreeNode_t *ch = child->p_firstChild; ch; ch = ch->p_sibling) {
                if (ch->nodeType == NODE_BLOCK) { has_body = 1; break; }
            }
            if (has_body) {
                ir_lower_function(&lctx, child);
            } else {
                /* emit extern declaration — NODE_FUNCTION stores the name
                 * directly on the node (same convention as NODE_VAR_DECLARATION),
                 * not as a NODE_IDENTIFIER child. */
                const char *fname = (child->nodeData.sVal && child->nodeData.sVal[0])
                                    ? child->nodeData.sVal
                                    : "unknown";
                ir_type_t ft = ir_type_ptr();
                ir_module_add_global(mod, fname, ft, /*is_extern=*/1);
            }
            break;
        }

        case NODE_VAR_DECLARATION:
        case NODE_ARRAY_DECLARATION: {
            /* Detect a sibling `=` initialiser of the form 
            *       VAR_DECL(x)
            *       OPERATOR(=)
            *           IDENTIFIER(x)
            *           <expr>
            * and feed the RHS to ir_lower_global-decl as the initialiser */
            const TreeNode_t *init_expr = NULL;
            const TreeNode_t *next = child->p_sibling;

            /* Find this declaration's identifier name (if any). */
            const char *decl_name = child->nodeData.sVal;

            if (decl_name && next &&
                next->nodeType == NODE_OPERATOR &&
                (long)next->nodeData.dVal == OP_ASSIGN &&
                next->p_firstChild && next->p_firstChild->nodeType == NODE_IDENTIFIER &&
                next->p_firstChild->nodeData.sVal &&
                strcmp(next->p_firstChild->nodeData.sVal, decl_name) == 0) {
                    init_expr = next->p_firstChild->p_sibling; /* RHS */
            }

            ir_lower_global_decl(&lctx, child, init_expr);
            
            if (init_expr) {
                /* Skip the OPERATOR(=) node since we already processed the initialiser. */
                child = next; 
            }

            break;
        }

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