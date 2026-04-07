/*
 * ir_lower_decl.c — Section 1: Declaration lowering
 *
 * Covers:
 *   • Global variable declarations  → ir_module globals  (§6.1)
 *   • Local variable declarations   → stack slots + optional initialiser
 *   • Array declarations            → slot of array IR type
 *
 * Contract references: §8.1, §8.4, §3 (memory_class).
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
 * Extract the symbol attached to a declaration node.
 * The semantic pass stores it in the annotation table.
 */
static const symbol_t *decl_symbol(ir_lower_ctx_t *lctx,
                                    const TreeNode_t *node)
{
    const sem_node_info_t *info =
        semantic_get_node_info(lctx->sem_ctx, node);
    if (!info || !info->symbol) {
        /* fall back: search identifier child */
        for (const TreeNode_t *ch = node->p_firstChild; ch; ch = ch->p_sibling) {
            if (ch->nodeType == NODE_IDENTIFIER) {
                const sem_node_info_t *ci =
                    semantic_get_node_info(lctx->sem_ctx, ch);
                if (ci && ci->symbol) return ci->symbol;
            }
        }
    }
    return info ? info->symbol : NULL;
}

/*
 * Find the initialiser child of a declaration node, if present.
 * In the AST, an initialiser is the rightmost child that is not
 * a type/sign/modifier/identifier/pointer node.
 */
static const TreeNode_t *decl_initialiser(const TreeNode_t *node)
{
    const TreeNode_t *last = NULL;
    for (const TreeNode_t *ch = node->p_firstChild; ch; ch = ch->p_sibling) {
        switch (ch->nodeType) {
        case NODE_TYPE:
        case NODE_SIGN:
        case NODE_MODIFIER:
        case NODE_VISIBILITY:
        case NODE_IDENTIFIER:
        case NODE_POINTER:
        case NODE_INTEGER:   /* array size in array decl */
            break;
        default:
            last = ch;
            break;
        }
    }
    return last;
}

/************************************************************
 * Global declaration  (MEMORY_CLASS_GLOBAL)
 *************************************************************/

void ir_lower_global_decl(ir_lower_ctx_t *lctx, const TreeNode_t *decl_node)
{
    if (!decl_node) return;

    /* §10: blocked? */
    const sem_node_info_t *info =
        semantic_get_node_info(lctx->sem_ctx, decl_node);
    if (info && (info->flags & SEM_NODE_CODEGEN_BLOCKED)) {
        ir_diag(lctx, "IR001", decl_node->lineNumber,
                "global declaration blocked for codegen");
        return;
    }

    const symbol_t *sym = decl_symbol(lctx, decl_node);
    if (!sym) {
        ir_diag(lctx, "IR002", decl_node->lineNumber,
                "global declaration has no symbol binding");
        return;
    }

    ir_type_t ir_t = ir_type_i16();
    if (info && info->type) {
        ir_t = ir_type_from_sem(info->type);
    } else if (sym->type) {
        ir_t = ir_type_from_sem(sym->type);
    }

    int is_extern = (sym->storage_class == STORAGE_EXTERN);
    ir_module_add_global(lctx->module, sym->name, ir_t, is_extern);

    /*
     * Global initialiser expressions are not emitted as instructions —
     * they are data-section values.  A future backend pass handles them.
     * We detect non-constant initialisers here and warn.
     */
    const TreeNode_t *init = decl_initialiser(decl_node);
    if (init) {
        const sem_node_info_t *iinfo =
            semantic_get_node_info(lctx->sem_ctx, init);
        if (iinfo && !(iinfo->flags & SEM_NODE_CONST_EXPR)) {
            ir_diag(lctx, "IR003", decl_node->lineNumber,
                    "global '%s' has a non-constant initialiser "
                    "(not yet supported in IR phase 1)", sym->name);
        }
        /* constant initialisers: recorded in the global node; backend emits. */
    }
}

/************************************************************
 * Local declaration  (MEMORY_CLASS_STACK / MEMORY_CLASS_PARAMETER)
 *************************************************************/

unsigned ir_lower_local_decl(ir_lower_ctx_t *lctx, const TreeNode_t *decl_node)
{
    if (!decl_node) return (unsigned)-1;

    const sem_node_info_t *info =
        semantic_get_node_info(lctx->sem_ctx, decl_node);
    if (info && (info->flags & SEM_NODE_CODEGEN_BLOCKED)) {
        ir_diag(lctx, "IR001", decl_node->lineNumber,
                "local declaration blocked for codegen");
        return (unsigned)-1;
    }

    const symbol_t *sym = decl_symbol(lctx, decl_node);
    if (!sym) {
        ir_diag(lctx, "IR002", decl_node->lineNumber,
                "local declaration has no symbol binding");
        return (unsigned)-1;
    }

    /* If a slot already exists (e.g. param pre-allocated in ir_lower_function)
     * re-use it rather than creating a duplicate. */
    unsigned existing = ir_find_slot(lctx->func, sym->name);
    if (existing != (unsigned)-1) return existing;

    ir_type_t ir_t = ir_type_i16();
    if (info && info->type) {
        ir_t = ir_type_from_sem(info->type);
    } else if (sym->type) {
        ir_t = ir_type_from_sem(sym->type);
    }

    unsigned slot = ir_new_slot(lctx->func, sym->name, ir_t);

    // G1 TODO: find the initialiser child node
    //       lower it with ir_lower_expr
    //       emit addr_of slot + store
    return slot;

}