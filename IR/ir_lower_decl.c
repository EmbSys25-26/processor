/*
 * ir_lower_decl.c — Section 1: Declaration lowering
 *
 * Covers:
 *   Global variable declarations - ir_module globals  (§6.1)
 *   Local variable declarations  - stack slots + optional initialiser
 *   Array declarations           - slot of array IR type
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

/* `ir_find_aggregate_decl` and `ir_compute_sem_type_words` previously lived
 * here (and a near-identical pair in ir_lower_expr.c).  Both have been
 * promoted to ir_lower.c and exposed via ir_lower.h so the two consumers
 * share one implementation. */

/* Evaluate a constant integer expression for global initialisers
 * Returns 1 on success and writes *out; 0 if the AST node is not a
 * supported constant expression. */
static int eval_const_int(const TreeNode_t *e, long *out) {
    if (!e) return 0; // null node

    switch(e->nodeType) {
        case NODE_INTEGER:
        case NODE_CHAR:
            *out = (long)e->nodeData.dVal;
            return 1;

        case NODE_TYPE_CAST: {
            /* (T)expr — TYPE_CAST has children:
             *   first  = NODE_TYPE  (target type, ignored at this layer)
             *   second = the actual expression to cast.
             * For 16-bit-or-narrower integer casts the value is
             * representation-preserving, so we forward the inner value. */
            const TreeNode_t *operand = e->p_firstChild
                                        ? e->p_firstChild->p_sibling
                                        : NULL;
            long v;
            if (operand && eval_const_int(operand, &v)) {
                *out = v;
                return 1;
            }
            return 0;
        }

        case NODE_OPERATOR: {
            const TreeNode_t *lhs = e->p_firstChild;
            const TreeNode_t *rhs = lhs ? lhs->p_sibling : NULL;
            long lv, rv;

            /* Unary forms: minus, plus, bitwise NOT, logical NOT. */
            if (lhs && !rhs) {
                if (!eval_const_int(lhs, &lv)) return 0;
                switch ((long)e->nodeData.dVal) {
                case OP_UNARY_MINUS: *out = -lv;  return 1;
                case OP_NEGATIVE:    *out = -lv;  return 1;
                case OP_BITWISE_NOT: *out = ~lv;  return 1;
                case OP_LOGICAL_NOT: *out = !lv;  return 1;
                default:             return 0;
                }
            }

            /* Binary forms: arithmetic, bitwise, shifts, comparisons. */
            if (lhs && rhs) {
                if (!eval_const_int(lhs, &lv)) return 0;
                if (!eval_const_int(rhs, &rv)) return 0;
                switch ((long)e->nodeData.dVal) {
                case OP_PLUS:        *out = lv +  rv;            return 1;
                case OP_MINUS:       *out = lv -  rv;            return 1;
                case OP_MULTIPLY:    *out = lv *  rv;            return 1;
                case OP_DIVIDE:      if (rv == 0) return 0;
                                     *out = lv /  rv;            return 1;
                case OP_MODULE:      if (rv == 0) return 0;
                                     *out = lv %  rv;            return 1;
                case OP_BITWISE_AND: *out = lv &  rv;            return 1;
                case OP_BITWISE_OR:  *out = lv |  rv;            return 1;
                case OP_BITWISE_XOR: *out = lv ^  rv;            return 1;
                case OP_LEFT_SHIFT:  *out = lv << rv;            return 1;
                case OP_RIGHT_SHIFT: *out = lv >> rv;            return 1;
                case OP_EQUAL:       *out = (lv == rv);          return 1;
                case OP_NOT_EQUAL:   *out = (lv != rv);          return 1;
                case OP_LESS_THAN:   *out = (lv <  rv);          return 1;
                case OP_LESS_THAN_OR_EQUAL:    *out = (lv <= rv); return 1;
                case OP_GREATER_THAN:          *out = (lv >  rv); return 1;
                case OP_GREATER_THAN_OR_EQUAL: *out = (lv >= rv); return 1;
                case OP_LOGICAL_AND: *out = (lv && rv);          return 1;
                case OP_LOGICAL_OR:  *out = (lv || rv);          return 1;
                default:             return 0;
                }
            }
            return 0;
        }

        default:
            return 0; // not a supported constant expression
    }
}


/* Lowers a top-level variable/array declaration into an ir_global with an
 * optional constant or string-literal initialiser. */
void ir_lower_global_decl(ir_lower_ctx_t *lctx,
                          const TreeNode_t *decl_node,
                          const TreeNode_t *init_expr)
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

    /* Allocate the global up-front; populate the init payload below. */
    ir_global_t *g = ir_module_add_global(lctx->module, sym->name,
                                           ir_t, is_extern);
    if (!g) return;

    /* Override storage size from the semantic type so structs / unions
     * (whose IR type drops layout info) get the right number of words. */
    if (info && info->type) {
        size_t sw = ir_compute_sem_type_words(lctx, info->type);
        if (sw) g->size_words = sw;
    } else if (sym->type) {
        size_t sw = ir_compute_sem_type_words(lctx, sym->type);
        if (sw) g->size_words = sw;
    }

    const TreeNode_t *init = init_expr
                            ? init_expr
                            : decl_initialiser(decl_node);

    if (init) {
        long init_value = 0;
        if (eval_const_int(init, &init_value)) {
            g->init_kind = IR_GINIT_INT;
            g->init_int  = init_value;
        } else if (init->nodeType == NODE_STRING && init->nodeData.sVal) {
            /* `char *p = "hello";` — emit the bytes into a fresh .strN
             * global and point this global at it via IR_GINIT_LABEL. */
            const char *raw = init->nodeData.sVal;
            size_t rlen = strlen(raw);
            size_t off  = (rlen >= 2 && raw[0] == '"' && raw[rlen - 1] == '"')
                          ? 1 : 0;
            size_t plen = rlen - 2 * off;

            static unsigned glb_str_id = 0;
            char strlabel[64];
            snprintf(strlabel, sizeof(strlabel), ".str%u", glb_str_id++);
            ir_global_t *sg = ir_module_add_global(lctx->module, strlabel,
                                                    ir_type_ptr(), 0);
            if (sg) {
                sg->init_kind = IR_GINIT_STRING;
                if (plen >= sizeof(sg->init_string))
                    plen = sizeof(sg->init_string) - 1;
                memcpy(sg->init_string, raw + off, plen);
                sg->init_string[plen] = '\0';
            }
            /* `g` is still the global we just added (we only append). */
            g->init_kind = IR_GINIT_LABEL;
            snprintf(g->init_label, sizeof(g->init_label), "%s", strlabel);
        } else {
            const sem_node_info_t *iinfo =
                semantic_get_node_info(lctx->sem_ctx, init);
            if (iinfo && !(iinfo->flags & SEM_NODE_CONST_EXPR)) {
                ir_diag(lctx, "IR003", decl_node->lineNumber,
                        "global '%s' has a non-constant initialiser "
                        "(not yet supported in IR phase 1)", sym->name);
            } else {
                ir_diag(lctx, "IR003", decl_node->lineNumber,
                        "global '%s' has an unsupported initialiser "
                        "(only constant integer expressions and string "
                        "literals supported in IR)",
                        sym->name);
            }
        }
    }
}

/************************************************************
 * Local declaration  (MEMORY_CLASS_STACK / MEMORY_CLASS_PARAMETER)
 *************************************************************/

/* Lowers a local variable/array declaration: allocates a stack slot and
 * stores its initialiser (if any), returning the slot id. */
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

    /* ir_new_slot reserves ir_type_size_words(ir_t) consecutive ids, but
     * IR types lose layout for structs/unions (they show up as 1 word).
     * Bump next_slot_id so an aggregate slot occupies the right number
     * of words on the stack. */
    {
        const type_t *sem_type = (info && info->type) ? info->type : sym->type;
        if (sem_type) {
            size_t correct  = ir_compute_sem_type_words(lctx, sem_type);
            size_t reserved = ir_type_size_words(ir_t);
            if (reserved == 0) reserved = 1;
            if (correct > reserved)
                lctx->func->next_slot_id += (unsigned)(correct - reserved);
        }
    }

    const TreeNode_t *init = decl_initialiser(decl_node);
    if (init) {
        ir_type_t rhs_type;
        ir_value_t rval = ir_lower_expr(lctx, init, &rhs_type);
        /* Cast if needed (same rules as expression lowering). */
        if (!ir_type_equal(rhs_type, ir_t) &&
            ir_type_is_integer(rhs_type) && ir_type_is_integer(ir_t)) {
            int src_sz = (rhs_type.kind == IR_TYPE_I1) ? 1 :
                         (rhs_type.kind == IR_TYPE_I8) ? 8 :
                         (rhs_type.kind == IR_TYPE_I16) ? 16 : 32;
            int dst_sz = (ir_t.kind == IR_TYPE_I1) ? 1 :
                         (ir_t.kind == IR_TYPE_I8) ? 8 :
                         (ir_t.kind == IR_TYPE_I16) ? 16 : 32;
            ir_opcode_t op = IR_OP_BITCAST;
            if (dst_sz > src_sz) {
                op = (sym->type && (sym->type->qualifiers & TYPE_QUAL_UNSIGNED))
                       ? IR_OP_ZEXT : IR_OP_SEXT;
            } else if (dst_sz < src_sz) {
                op = IR_OP_TRUNC;
            }
            if (op != IR_OP_BITCAST) {
                unsigned r = ir_new_vreg(lctx->func);
                ir_instr_t *cast = ir_instr_new(op);
                cast->dst    = ir_val_vreg(r, ir_t);
                cast->src[0] = rval;
                ir_instr_push(lctx->cur_block, cast);
                rval = ir_val_vreg(r, ir_t);
            }
        }
        ir_value_t addr = ir_val_slot(slot, ir_t);
        unsigned pr = ir_new_vreg(lctx->func);
        ir_instr_t *addr_i = ir_instr_new(IR_OP_ADDR_OF);
        addr_i->dst    = ir_val_vreg(pr, ir_type_ptr());
        addr_i->src[0] = addr;
        ir_instr_push(lctx->cur_block, addr_i);

        ir_instr_t *store_i = ir_instr_new(IR_OP_STORE);
        store_i->src[0] = ir_val_vreg(pr, ir_type_ptr());
        store_i->src[1] = rval;
        ir_instr_push(lctx->cur_block, store_i);
    }
    return slot;

}