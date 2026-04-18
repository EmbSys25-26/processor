/*
 * ir_lower_expr.c — Section 2: Expression lowering
 *
 * Covers §8.2 and the expression-related subsets of §7.1–§7.5:
 *   • Literals        (INTEGER / CHAR / STRING / FLOAT)
 *   • Identifier read (load from slot or global)
 *   • Binary ops      (arithmetic, bitwise, comparison, logical, assignment)
 *   • Compound assign (+=, -= …)
 *   • Unary ops       (neg, not, sizeof, reference, dereference)
 *   • Pre/post inc/dec
 *   • Ternary (?: )
 *   • Function call
 *   • Array access
 *   • Member access (. and ->)
 *   • Type cast
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

/************************************************************
 * Helpers
 *************************************************************/

/* Emit a load from a pointer value */
static ir_value_t emit_load(ir_lower_ctx_t *lctx, ir_value_t ptr_val,
                             ir_type_t pointee_type)
{
    unsigned r = ir_new_vreg(lctx->func);
    ir_instr_t *i = ir_instr_new(IR_OP_LOAD);
    i->dst    = ir_val_vreg(r, pointee_type);
    i->src[0] = ptr_val;
    ir_instr_push(lctx->cur_block, i);
    return ir_val_vreg(r, pointee_type);
}

/* Emit a store */
static void emit_store(ir_lower_ctx_t *lctx, ir_value_t ptr_val,
                       ir_value_t val)
{
    ir_instr_t *i = ir_instr_new(IR_OP_STORE);
    i->src[0] = ptr_val;
    i->src[1] = val;
    ir_instr_push(lctx->cur_block, i);
}

/* Emit addr_of a slot/global and return the pointer vreg */
static ir_value_t emit_addr_of(ir_lower_ctx_t *lctx, ir_value_t sym_val)
{
    unsigned r = ir_new_vreg(lctx->func);
    ir_instr_t *i = ir_instr_new(IR_OP_ADDR_OF);
    i->dst    = ir_val_vreg(r, ir_type_ptr());
    i->src[0] = sym_val;
    ir_instr_push(lctx->cur_block, i);
    return ir_val_vreg(r, ir_type_ptr());
}

/* Look up a symbol by name and return the appropriate ir_value_t reference */
static ir_value_t resolve_symbol_ref(ir_lower_ctx_t *lctx,
                                      const symbol_t *sym,
                                      ir_type_t sym_type,
                                      size_t line)
{
    if (!sym) {
        ir_diag(lctx, "IR002", line, "missing symbol binding");
        return ir_val_none();
    }
    switch (sym->memory_class) {
    case MEMORY_CLASS_GLOBAL:
        return ir_val_global(sym->name, sym_type);
    case MEMORY_CLASS_STACK:
    case MEMORY_CLASS_PARAMETER: {
        unsigned slot = ir_find_slot(lctx->func, sym->name);
        if (slot == (unsigned)-1) {
            /* Parameter passed before body slots are built; create on demand */
            slot = ir_new_slot(lctx->func, sym->name, sym_type);
        }
        return ir_val_slot(slot, sym_type);
    }
    default:
        /* MEMORY_CLASS_NONE: enum constants, function names */
        return ir_val_global(sym->name, sym_type);
    }
}

/* Map OperatorType_t to signed/unsigned IR opcode for binary ops */
static ir_opcode_t binop_opcode(OperatorType_t op, int is_unsigned)
{
    switch (op) {
    case OP_PLUS:                 return IR_OP_ADD;
    case OP_MINUS:                return IR_OP_SUB;
    case OP_MULTIPLY:             return IR_OP_MUL;
    case OP_DIVIDE:               return is_unsigned ? IR_OP_DIVU : IR_OP_DIVS;
    case OP_MODULE:               return is_unsigned ? IR_OP_MODU : IR_OP_MODS;
    case OP_BITWISE_AND:          return IR_OP_AND;
    case OP_BITWISE_OR:           return IR_OP_OR;
    case OP_BITWISE_XOR:          return IR_OP_XOR;
    case OP_LEFT_SHIFT:           return IR_OP_SHL;
    case OP_RIGHT_SHIFT:          return is_unsigned ? IR_OP_SHRU : IR_OP_SHRS;
    case OP_EQUAL:                return IR_OP_EQ;
    case OP_NOT_EQUAL:            return IR_OP_NEQ;
    case OP_LESS_THAN:            return is_unsigned ? IR_OP_LTU : IR_OP_LTS;
    case OP_LESS_THAN_OR_EQUAL:   return is_unsigned ? IR_OP_LEU : IR_OP_LES;
    case OP_GREATER_THAN:         return is_unsigned ? IR_OP_GTU : IR_OP_GTS;
    case OP_GREATER_THAN_OR_EQUAL:return is_unsigned ? IR_OP_GEU : IR_OP_GES;
    default:                      return IR_OP_ADD; /* fallback */
    }
}

/* Return 1 if the semantic type is unsigned */
static int sem_type_is_unsigned(const type_t *t)
{
    if (!t || t->kind != TYPE_BUILTIN) return 0;
    return (t->qualifiers & TYPE_QUAL_UNSIGNED) != 0;
}

/* Widen a value to i16 if it is i1 or i8 (for arithmetic) */
static ir_value_t maybe_widen(ir_lower_ctx_t *lctx, ir_value_t v,
                               int is_unsigned)
{
    if (v.type.kind == IR_TYPE_I1 || v.type.kind == IR_TYPE_I8) {
        unsigned r = ir_new_vreg(lctx->func);
        ir_instr_t *i = ir_instr_new(is_unsigned ? IR_OP_ZEXT : IR_OP_SEXT);
        i->dst    = ir_val_vreg(r, ir_type_i16());
        i->src[0] = v;
        ir_instr_push(lctx->cur_block, i);
        return ir_val_vreg(r, ir_type_i16());
    }
    return v;
}

/* Cast a value to the target IR type when required. */
static ir_value_t cast_value(ir_lower_ctx_t *lctx,
                              ir_value_t v,
                              ir_type_t to_type,
                              int is_unsigned)
{
    if (ir_type_equal(v.type, to_type)) return v;

    if (!ir_type_is_integer(v.type) || !ir_type_is_integer(to_type)) {
        if (v.type.kind == IR_TYPE_PTR || to_type.kind == IR_TYPE_PTR) {
            unsigned r = ir_new_vreg(lctx->func);
            ir_instr_t *i = ir_instr_new(IR_OP_BITCAST);
            i->dst    = ir_val_vreg(r, to_type);
            i->src[0] = v;
            ir_instr_push(lctx->cur_block, i);
            return ir_val_vreg(r, to_type);
        }
        return v;
    }

    int src_sz = (v.type.kind == IR_TYPE_I1) ? 1 :
                 (v.type.kind == IR_TYPE_I8) ? 8 :
                 (v.type.kind == IR_TYPE_I16) ? 16 : 32;
    int dst_sz = (to_type.kind == IR_TYPE_I1) ? 1 :
                 (to_type.kind == IR_TYPE_I8) ? 8 :
                 (to_type.kind == IR_TYPE_I16) ? 16 : 32;

    ir_opcode_t op = IR_OP_BITCAST;
    if (dst_sz > src_sz) {
        op = is_unsigned ? IR_OP_ZEXT : IR_OP_SEXT;
    } else if (dst_sz < src_sz) {
        op = IR_OP_TRUNC;
    } else {
        return v;
    }

    unsigned r = ir_new_vreg(lctx->func);
    ir_instr_t *i = ir_instr_new(op);
    i->dst    = ir_val_vreg(r, to_type);
    i->src[0] = v;
    ir_instr_push(lctx->cur_block, i);
    return ir_val_vreg(r, to_type);
}
   
/************************************************************
 * lvalue address lowering  (§8.2 rules 3–4)
 *************************************************************/

ir_value_t ir_lower_lvalue_addr(ir_lower_ctx_t *lctx,
                                 const TreeNode_t *expr,
                                 ir_type_t *out_pointee_type)
{
    if (!expr) {
        if (out_pointee_type) *out_pointee_type = ir_type_i16();
        return ir_val_none();
    }

    const sem_node_info_t *info =
        semantic_get_node_info(lctx->sem_ctx, expr);
    ir_type_t pt = info && info->type
                   ? ir_type_from_sem(info->type) : ir_type_i16();
    if (out_pointee_type) *out_pointee_type = pt;

    switch (expr->nodeType) {
    case NODE_IDENTIFIER: {
        if (!info || !info->symbol) {
            ir_diag(lctx, "IR002", expr->lineNumber,
                    "identifier '%s' has no symbol",
                    expr->nodeData.sVal ? expr->nodeData.sVal : "?");
            return ir_val_none();
        }
        ir_value_t ref = resolve_symbol_ref(lctx, info->symbol, pt,
                                             expr->lineNumber);
        return emit_addr_of(lctx, ref);
    }

    case NODE_POINTER_CONTENT: {
        /* *ptr — the address IS the pointer value */
        ir_type_t inner_type;
        ir_value_t ptr = ir_lower_expr(lctx, expr->p_firstChild, &inner_type);
        if (out_pointee_type) *out_pointee_type = inner_type;
        return ptr;
    }
    case NODE_ARRAY_ACCESS: {
        /* lower base expression (get base pointer or array address)
         *     lower index expression
         *     determine element type and stride from semantic annotation
         *     if base is slot/global emit addr_of first
         *     emit IR_OP_GEP with stride
         *     return pointer vreg
         */
        const TreeNode_t *base_node  = expr->p_firstChild;
        const TreeNode_t *index_node = base_node ? base_node->p_sibling : NULL;

        if (!base_node || !index_node) {
            ir_diag(lctx, "IR001", expr->lineNumber, "malformed array access");
            return ir_val_none();
        }

        /* Determine element type from semantic annotation on the array access node.
         * out_pointee_type should be the element type (what you get after indexing). */
        const sem_node_info_t *ainfo =
            semantic_get_node_info(lctx->sem_ctx, expr);
        ir_type_t elem_type = (ainfo && ainfo->type)
                              ? ir_type_from_sem(ainfo->type) : ir_type_i16();
        if (out_pointee_type) *out_pointee_type = elem_type;

        /* Compute stride = sizeof(element_type) in bytes */
        long stride = 2; /* default: i16 = 2 bytes */
        switch (elem_type.kind) {
        case IR_TYPE_I1:  stride = 1; break;
        case IR_TYPE_I8:  stride = 1; break;
        case IR_TYPE_I16: stride = 2; break;
        case IR_TYPE_I32: stride = 4; break;
        case IR_TYPE_PTR: stride = 2; break;
        default:          stride = 2; break;
        }

        /* Lower base: could be an identifier (slot/global) or any pointer expr */
        const sem_node_info_t *binfo =
            semantic_get_node_info(lctx->sem_ctx, base_node);
        ir_type_t base_sem_type = (binfo && binfo->type)
                                  ? ir_type_from_sem(binfo->type) : ir_type_ptr();

        ir_value_t base_ptr;
        if (base_sem_type.kind == IR_TYPE_ARRAY ||
            base_node->nodeType == NODE_IDENTIFIER) {
            /* Array variable: take its address first, then load the base pointer */
            ir_type_t dummy_pt;
            ir_value_t base_addr = ir_lower_lvalue_addr(lctx, base_node, &dummy_pt);
            base_ptr = emit_load(lctx, base_addr, ir_type_ptr());
        } else {
            /* Already a pointer expression */
            ir_type_t bt;
            base_ptr = ir_lower_expr(lctx, base_node, &bt);
        }

        /* Lower index */
        ir_type_t idx_type;
        ir_value_t idx_val = ir_lower_expr(lctx, index_node, &idx_type);
        idx_val = maybe_widen(lctx, idx_val, 0);

        /* Emit GEP: base_ptr + idx * stride */
        unsigned r = ir_new_vreg(lctx->func);
        ir_instr_t *gep = ir_instr_new(IR_OP_GEP);
        gep->dst      = ir_val_vreg(r, ir_type_ptr());
        gep->src[0]   = base_ptr;
        gep->src[1]   = idx_val;
        gep->as.gep.width = stride;
        ir_instr_push(lctx->cur_block, gep);
        return ir_val_vreg(r, ir_type_ptr());
    }

    case NODE_MEMBER_ACCESS:
    case NODE_PTR_MEMBER_ACCESS: {
        const TreeNode_t *base_node  = expr->p_firstChild;
        const TreeNode_t *field_node = base_node ? base_node->p_sibling : NULL;

        if (!base_node || !field_node) {
            ir_diag(lctx, "IR001", expr->lineNumber, "malformed member access");
            return ir_val_none();
        }

        /* Get field type from semantic annotation on the member access node */
        const sem_node_info_t *minfo =
            semantic_get_node_info(lctx->sem_ctx, expr);
        ir_type_t field_type = (minfo && minfo->type)
                               ? ir_type_from_sem(minfo->type) : ir_type_i16();
        if (out_pointee_type) *out_pointee_type = field_type;

        ir_value_t base_ptr;
        if (expr->nodeType == NODE_MEMBER_ACCESS) {
            /* '.' operator: base is a struct lvalue — take its address */
            ir_type_t dummy_pt;
            base_ptr = ir_lower_lvalue_addr(lctx, base_node, &dummy_pt);
        } else {
            /* '->' operator: base is already a pointer */
            ir_type_t bt;
            base_ptr = ir_lower_expr(lctx, base_node, &bt);
        }

        /* Field name embedded in callee slot for backend reference.
         * We use GEP with index 0 and stride 0 as a field-access placeholder.
         * The backend uses the field symbol name from the semantic annotation
         * to resolve the actual byte offset. */
        const char *field_name = (field_node->nodeData.sVal)
                                 ? field_node->nodeData.sVal : "?";
        unsigned r = ir_new_vreg(lctx->func);
        ir_instr_t *gep = ir_instr_new(IR_OP_GEP);
        gep->dst         = ir_val_vreg(r, ir_type_ptr());
        gep->src[0]      = base_ptr;
        gep->src[1]      = ir_val_imm(0, ir_type_i16());
        gep->as.gep.width = 0; /* backend resolves field offset by name */
        /* Store field name in callee string for backend reference */
        snprintf(gep->as.call.callee, sizeof(gep->as.call.callee), "%s", field_name);
        ir_instr_push(lctx->cur_block, gep);
        return ir_val_vreg(r, ir_type_ptr());
    }
    default:
        ir_diag(lctx, "IR001", expr->lineNumber,
                "expression is not a valid lvalue (node %d)", expr->nodeType);
        return ir_val_none();
    }
}

/************************************************************
 * Main expression lowering  (§8.2)
 ************************************************************ */

ir_value_t ir_lower_expr(ir_lower_ctx_t *lctx,
                          const TreeNode_t *expr,
                          ir_type_t *out_type)
{
    ir_type_t dummy;
    if (!out_type) out_type = &dummy;
    *out_type = ir_type_i16();

    if (!expr) return ir_val_none();

    /* §10: blocked nodes */
    const sem_node_info_t *info =
        semantic_get_node_info(lctx->sem_ctx, expr);
    if (info && (info->flags & SEM_NODE_CODEGEN_BLOCKED)) {
        ir_diag(lctx, "IR001", expr->lineNumber,
                "expression blocked for codegen (unsupported feature)");
        return ir_val_none();
    }

    /* Determine IR type from semantic annotation */
    ir_type_t expr_type = (info && info->type)
                          ? ir_type_from_sem(info->type) : ir_type_i16();
    *out_type = expr_type;

    switch (expr->nodeType) {

    /* ── §8.2 rule 1: Literals ─────────────────────────── */
    case NODE_INTEGER:
        return ir_val_imm((long)expr->nodeData.dVal, expr_type);

    case NODE_CHAR:
        return ir_val_imm((long)expr->nodeData.dVal, expr_type);

    case NODE_STRING: {
        /* BUILTIN_STRING → ptr to read-only i8; name is emitted as global */
        *out_type = ir_type_ptr();
        const char *s = expr->nodeData.sVal ? expr->nodeData.sVal : "";
        /* We emit a synthetic global label for string literals.
           The backend is responsible for placing them in .rodata. */
        static unsigned str_id = 0;
        char label[64];
        snprintf(label, sizeof(label), ".str%u", str_id++);
        ir_module_add_global(lctx->module, label, ir_type_ptr(), 0);
        /* Mark global with the string value via a comment embedded in name */
        (void)s; /* content used by backend data emitter, not IR instructions */
        return ir_val_global(label, ir_type_ptr());
    }

    case NODE_FLOAT:
        /* Floating-point: should be blocked by semantic; emit diagnostic */
        ir_diag(lctx, "IR001", expr->lineNumber,
                "floating-point literal not supported by current backend");
        return ir_val_none();

    /* ── §8.2 rule 2: Identifier read ─────────────────── */
    case NODE_IDENTIFIER: {
        if (!info || !info->symbol) {
            ir_diag(lctx, "IR002", expr->lineNumber,
                    "identifier '%s' has no symbol",
                    expr->nodeData.sVal ? expr->nodeData.sVal : "?");
            return ir_val_none();
        }
        ir_value_t ref = resolve_symbol_ref(lctx, info->symbol, expr_type,
                                             expr->lineNumber);
        ir_value_t addr = emit_addr_of(lctx, ref);
        return emit_load(lctx, addr, expr_type);
    }

    /* ── §8.2 rule 3: Assignment ────────────────────────── */
    case NODE_OPERATOR: {
        OperatorType_t op = (OperatorType_t)expr->nodeData.dVal;
        const TreeNode_t *lhs_node = expr->p_firstChild;
        const TreeNode_t *rhs_node = lhs_node ? lhs_node->p_sibling : NULL;

        if (op == OP_ASSIGN) {
            ir_type_t lhs_type;
            ir_value_t addr = ir_lower_lvalue_addr(lctx, lhs_node, &lhs_type);
            ir_type_t rhs_type;
            ir_value_t rval = ir_lower_expr(lctx, rhs_node, &rhs_type);
            int is_unsigned = sem_type_is_unsigned(info ? info->type : NULL);
            rval = cast_value(lctx, rval, lhs_type, is_unsigned);
            emit_store(lctx, addr, rval);
            *out_type = lhs_type;
            return rval;
        }

        if (op == OP_PLUS_ASSIGN || op == OP_MINUS_ASSIGN ||
            op == OP_MULTIPLY_ASSIGN || op == OP_DIVIDE_ASSIGN ||
            op == OP_MODULUS_ASSIGN || op == OP_LEFT_SHIFT_ASSIGN ||
            op == OP_RIGHT_SHIFT_ASSIGN || op == OP_BITWISE_AND_ASSIGN ||
            op == OP_BITWISE_OR_ASSIGN || op == OP_BITWISE_XOR_ASSIGN) {
            ir_type_t lhs_type;
            ir_value_t addr = ir_lower_lvalue_addr(lctx, lhs_node, &lhs_type);
            ir_value_t old = emit_load(lctx, addr, lhs_type);
            ir_type_t rhs_type;
            ir_value_t rval = ir_lower_expr(lctx, rhs_node, &rhs_type);
            int is_unsigned = sem_type_is_unsigned(info ? info->type : NULL);
            rval = cast_value(lctx, rval, lhs_type, is_unsigned);

            OperatorType_t base = OP_PLUS;
            switch (op) {
            case OP_PLUS_ASSIGN:        base = OP_PLUS; break;
            case OP_MINUS_ASSIGN:       base = OP_MINUS; break;
            case OP_MULTIPLY_ASSIGN:    base = OP_MULTIPLY; break;
            case OP_DIVIDE_ASSIGN:      base = OP_DIVIDE; break;
            case OP_MODULUS_ASSIGN:     base = OP_MODULE; break;
            case OP_LEFT_SHIFT_ASSIGN:  base = OP_LEFT_SHIFT; break;
            case OP_RIGHT_SHIFT_ASSIGN: base = OP_RIGHT_SHIFT; break;
            case OP_BITWISE_AND_ASSIGN: base = OP_BITWISE_AND; break;
            case OP_BITWISE_OR_ASSIGN:  base = OP_BITWISE_OR; break;
            case OP_BITWISE_XOR_ASSIGN: base = OP_BITWISE_XOR; break;
            default: break;
            }

            unsigned r = ir_new_vreg(lctx->func);
            ir_instr_t *i = ir_instr_new(binop_opcode(base, is_unsigned));
            i->dst    = ir_val_vreg(r, lhs_type);
            i->src[0] = old;
            i->src[1] = rval;
            ir_instr_push(lctx->cur_block, i);
            ir_value_t res = ir_val_vreg(r, lhs_type);
            emit_store(lctx, addr, res);
            *out_type = lhs_type;
            return res;
        }

        if (op == OP_LOGICAL_NOT) {
            ir_type_t lt;
            ir_value_t v = ir_lower_expr(lctx, lhs_node, &lt);
            v = maybe_widen(lctx, v, 0);
            unsigned r = ir_new_vreg(lctx->func);
            ir_instr_t *i = ir_instr_new(IR_OP_EQ);
            i->dst    = ir_val_vreg(r, ir_type_i1());
            i->src[0] = v;
            i->src[1] = ir_val_imm(0, v.type);
            ir_instr_push(lctx->cur_block, i);
            *out_type = ir_type_i1();
            return ir_val_vreg(r, ir_type_i1());
        }

        /* ── Sizeof ── */
        if (op == OP_SIZEOF) {
            /* Resolved to a constant at IR time based on IR type size */
            long sz = 2; /* default */
            if (lhs_node) {
                const sem_node_info_t *si =
                    semantic_get_node_info(lctx->sem_ctx, lhs_node);
                if (si && si->type) {
                    ir_type_t it = ir_type_from_sem(si->type);
                    switch (it.kind) {
                    case IR_TYPE_I1:  sz = 1; break;
                    case IR_TYPE_I8:  sz = 1; break;
                    case IR_TYPE_I16: sz = 2; break;
                    case IR_TYPE_I32: sz = 4; break;
                    case IR_TYPE_PTR: sz = 2; break;
                    default:          sz = 2; break;
                    }
                }
            }
            *out_type = ir_type_i16();
            return ir_val_imm(sz, ir_type_i16());
        }

        if (op == OP_UNARY_MINUS || op == OP_NEGATIVE || op == OP_BITWISE_NOT) {
            ir_type_t lt;
            ir_value_t v = ir_lower_expr(lctx, lhs_node, &lt);
            unsigned r = ir_new_vreg(lctx->func);
            ir_instr_t *i = ir_instr_new(op == OP_BITWISE_NOT ? IR_OP_NOT : IR_OP_NEG);
            i->dst    = ir_val_vreg(r, lt);
            i->src[0] = v;
            ir_instr_push(lctx->cur_block, i);
            *out_type = lt;
            return ir_val_vreg(r, lt);
        }

        if (op == OP_LOGICAL_AND || op == OP_LOGICAL_OR) {
            ir_diag(lctx, "IR001", expr->lineNumber,
                    "logical operators require control-flow lowering");
            return ir_val_none();
        }

        if (!lhs_node || !rhs_node) {
            ir_diag(lctx, "IR001", expr->lineNumber,
                    "malformed operator node");
            return ir_val_none();
        }

        /* Binary ops (arithmetic, bitwise, shifts, comparisons) */
        ir_type_t lt, rt;
        ir_value_t lv = ir_lower_expr(lctx, lhs_node, &lt);
        ir_value_t rv = ir_lower_expr(lctx, rhs_node, &rt);

        int is_unsigned = sem_type_is_unsigned(info ? info->type : NULL);
        lv = maybe_widen(lctx, lv, is_unsigned);
        rv = maybe_widen(lctx, rv, is_unsigned);

        ir_opcode_t ir_op = binop_opcode(op, is_unsigned);
        ir_type_t dst_type = expr_type;
        if (ir_op == IR_OP_EQ || ir_op == IR_OP_NEQ ||
            ir_op == IR_OP_LTS || ir_op == IR_OP_LES ||
            ir_op == IR_OP_GTS || ir_op == IR_OP_GES ||
            ir_op == IR_OP_LTU || ir_op == IR_OP_LEU ||
            ir_op == IR_OP_GTU || ir_op == IR_OP_GEU) {
            dst_type = ir_type_i1();
            *out_type = dst_type;
        }

        unsigned r = ir_new_vreg(lctx->func);
        ir_instr_t *i = ir_instr_new(ir_op);
        i->dst    = ir_val_vreg(r, dst_type);
        i->src[0] = lv;
        i->src[1] = rv;
        ir_instr_push(lctx->cur_block, i);
        return ir_val_vreg(r, dst_type);
    }

    /* ── §8.2 rule 4: Pre/post inc/dec ────────────────── */
    case NODE_PRE_INC:
    case NODE_PRE_DEC: {
        ir_type_t pt;
        ir_value_t addr = ir_lower_lvalue_addr(lctx, expr->p_firstChild, &pt);
        ir_value_t oldv = emit_load(lctx, addr, pt);
        ir_value_t one = ir_val_imm(1, pt);
        unsigned r = ir_new_vreg(lctx->func);
        ir_instr_t *i = ir_instr_new((expr->nodeType == NODE_PRE_INC) ? IR_OP_ADD : IR_OP_SUB);
        i->dst    = ir_val_vreg(r, pt);
        i->src[0] = oldv;
        i->src[1] = one;
        ir_instr_push(lctx->cur_block, i);
        ir_value_t newv = ir_val_vreg(r, pt);
        emit_store(lctx, addr, newv);
        *out_type = pt;
        return newv;
    }

    case NODE_POST_INC:
    case NODE_POST_DEC: {
        ir_type_t pt;
        ir_value_t addr = ir_lower_lvalue_addr(lctx, expr->p_firstChild, &pt);
        ir_value_t oldv = emit_load(lctx, addr, pt);
        ir_value_t one = ir_val_imm(1, pt);
        unsigned r = ir_new_vreg(lctx->func);
        ir_instr_t *i = ir_instr_new((expr->nodeType == NODE_POST_INC) ? IR_OP_ADD : IR_OP_SUB);
        i->dst    = ir_val_vreg(r, pt);
        i->src[0] = oldv;
        i->src[1] = one;
        ir_instr_push(lctx->cur_block, i);
        ir_value_t newv = ir_val_vreg(r, pt);
        emit_store(lctx, addr, newv);
        *out_type = pt;
        return oldv;
    }

    /* ── §8.2 rule 5: Ternary ── */
    case NODE_TERNARY: {
        const TreeNode_t *cond_node  = expr->p_firstChild;
        const TreeNode_t *true_node  = cond_node ? cond_node->p_sibling : NULL;
        const TreeNode_t *false_node = true_node ? true_node->p_sibling : NULL;
        if (!cond_node || !true_node || !false_node) {
            ir_diag(lctx, "IR001", expr->lineNumber, "malformed ternary");
            return ir_val_none();
        }

        unsigned res_slot = ir_new_slot(lctx->func, ".tern", expr_type);
        ir_type_t cond_type;
        ir_value_t cond = ir_lower_expr(lctx, cond_node, &cond_type);
        cond = maybe_widen(lctx, cond, 0);

        /* cond != 0 */
        unsigned pred_r = ir_new_vreg(lctx->func);
        ir_instr_t *cmp = ir_instr_new(IR_OP_NEQ);
        cmp->dst    = ir_val_vreg(pred_r, ir_type_i1());
        cmp->src[0] = cond;
        cmp->src[1] = ir_val_imm(0, cond.type);
        ir_instr_push(lctx->cur_block, cmp);

        ir_block_t *true_block  = ir_new_block(lctx);
        ir_block_t *false_block = ir_new_block(lctx);
        ir_block_t *merge_block = ir_new_block(lctx);
        ir_seal_branch(lctx, ir_val_vreg(pred_r, ir_type_i1()),
                        true_block->id, false_block->id);

        lctx->cur_block = true_block;
        ir_type_t tt;
        ir_value_t tv = ir_lower_expr(lctx, true_node, &tt);
        ir_value_t ta = emit_addr_of(lctx, ir_val_slot(res_slot, expr_type));
        emit_store(lctx, ta, tv);
        ir_seal_goto(lctx, merge_block->id);

        lctx->cur_block = false_block;
        ir_type_t ft;
        ir_value_t fv = ir_lower_expr(lctx, false_node, &ft);
        ir_value_t fa = emit_addr_of(lctx, ir_val_slot(res_slot, expr_type));
        emit_store(lctx, fa, fv);
        ir_seal_goto(lctx, merge_block->id);

        lctx->cur_block = merge_block;
        ir_value_t res_addr = emit_addr_of(lctx, ir_val_slot(res_slot, expr_type));
        *out_type = expr_type;
        return emit_load(lctx, res_addr, expr_type);
    }

    /* ── G3: NODE_FUNCTION_CALL ──────────────────────────────────────
     *
     * AST layout (built by build_function_call_node in parser.y):
     *   NODE_FUNCTION_CALL
     *     p_firstChild          -> NODE_IDENTIFIER with the callee name
     *     p_firstChild->sibling -> arg0, arg1, arg2, ... (sibling chain)
     *
     * IR generated for: y = sum(10, 20)
     *   %v2 = addr_of @sum       (resolve callee)
     *   %v3 = *%v2               (load)
     *   ...evaluate arguments...
     *   %vN = @sum(%v_arg0, %v_arg1)
     *
     * Simplified phase-1 form (direct call by name):
     *   %v0 = 10
     *   %v1 = 20
     *   %v2 = @sum(%v0, %v1)
     */
    case NODE_FUNCTION_CALL: {

        /* The first child of NODE_FUNCTION_CALL is always the callee.
         * Without it there is nothing to call — emit a diagnostic and bail. */
        const TreeNode_t *callee_node = expr->p_firstChild;
        if (!callee_node) {
            ir_diag(lctx, "IR001", expr->lineNumber, "function call missing callee");
            return ir_val_none();
        }

        /* Phase 1 only supports direct calls (e.g. "foo(...)").
         * We extract the function name from the NODE_IDENTIFIER child.
         * Indirect calls through a pointer (e.g. "(*fp)(...)") are not yet
         * supported and are rejected with a diagnostic. */
        const char *callee_name = NULL;
        if (callee_node->nodeType == NODE_IDENTIFIER && callee_node->nodeData.sVal) {
            /* Direct call: callee_name now points to e.g. "soma", "printf". */
            callee_name = callee_node->nodeData.sVal;
        } else {
            ir_diag(lctx, "IR001", expr->lineNumber,
                    "indirect function call not supported in phase 1");
            return ir_val_none();
        }

        /* Walk the sibling chain after the callee node — those are the arguments.
         * Each argument expression is lowered recursively with ir_lower_expr,
         * which may emit several intermediate instructions and returns the
         * final value (a vreg, immediate, or global reference).
         * Results are stored left-to-right in a local array for later use. */
        ir_value_t args[IR_MAX_ARGS];
        unsigned actual_args = 0;

        for (const TreeNode_t *a = callee_node->p_sibling;
             a && actual_args < IR_MAX_ARGS; a = a->p_sibling) {
            ir_type_t arg_type;
            /* Lower the argument expression and save its resulting IR value. */
            args[actual_args++] = ir_lower_expr(lctx, a, &arg_type);
        }

        /* Determine whether this call returns a value or is void.
         * This controls whether we allocate a destination vreg for the result.
         * We check in two ways because the annotation may be on the call node
         * or on the callee symbol, depending on how the semantic pass stored it. */
        int is_void = 0;

        /* Check 1: look at the type annotated directly on the call expression.
         * If the semantic pass typed it as BUILTIN_VOID, the call is void. */
        if (info && info->type &&
            info->type->kind == TYPE_BUILTIN &&
            info->type->as.builtin == BUILTIN_VOID) {
            is_void = 1;
        }

        /* Check 2: if check 1 was inconclusive, look up the callee symbol and
         * inspect its function type's return type directly.
         * This handles cases where the call node itself was not annotated
         * with a void type but the function declaration clearly returns void. */
        if (!is_void) {
            const sem_node_info_t *ci =
                semantic_get_node_info(lctx->sem_ctx, callee_node);
            if (ci && ci->symbol && ci->symbol->type &&
                ci->symbol->type->kind == TYPE_FUNCTION &&
                ci->symbol->type->as.function.return_type) {
                const type_t *ret = ci->symbol->type->as.function.return_type;
                if (ret->kind == TYPE_BUILTIN && ret->as.builtin == BUILTIN_VOID) {
                    is_void = 1;
                }
            }
        }

        /* Build the IR_OP_CALL instruction.
         * Copy the callee name into the fixed-size callee field,
         * set the argument count, the void flag, and copy each argument value. */
        ir_instr_t *call_i = ir_instr_new(IR_OP_CALL);

        /* Store the function name (e.g. "soma") in the instruction. */
        snprintf(call_i->as.call.callee, sizeof(call_i->as.call.callee),
                 "%s", callee_name);

        /* Record how many arguments were evaluated. */
        call_i->as.call.arg_count    = actual_args;

        /* Mark whether the call is void — the printer uses this to decide
         * whether to emit "%vN = @f(...)" or just "@f(...)". */
        call_i->as.call.is_void_call = is_void;

        /* Copy the evaluated argument values into the instruction's arg array. */
        for (unsigned k = 0; k < actual_args; k++) {
            call_i->as.call.args[k] = args[k];
        }

        if (is_void) {
            /* Void call: no destination register is needed.
             * IR_VAL_NONE in dst tells the printer to omit the "%vN = " prefix.
             * We return ir_val_none() because the expression has no value. */
            call_i->dst = ir_val_none();
            ir_instr_push(lctx->cur_block, call_i);
            *out_type = ir_type_void();
            return ir_val_none();
        } else {
            /* Non-void call: allocate a fresh vreg to hold the return value.
             * The instruction becomes:  %vN = @soma(%v0, %v1)
             * We return this vreg so the parent expression can use the result
             * (e.g. in an assignment like "resultado = soma(10, 20)"). */
            unsigned r = ir_new_vreg(lctx->func);
            call_i->dst = ir_val_vreg(r, expr_type); /* destination: %vN */
            ir_instr_push(lctx->cur_block, call_i);
            *out_type = expr_type;
            return ir_val_vreg(r, expr_type); /* return the vreg to the caller */
        }
    }
    /* ── Array access (rvalue) ── */
    case NODE_ARRAY_ACCESS: {
        /*  call ir_lower_lvalue_addr to get element address
         *     emit load on that address
         *     return loaded value
         */
        ir_type_t elem_type;
        ir_value_t elem_addr = ir_lower_lvalue_addr(lctx, expr, &elem_type);
        if (elem_addr.kind == IR_VAL_NONE) return ir_val_none();
        *out_type = elem_type;
        return emit_load(lctx, elem_addr, elem_type);
    }

    /* ── Member access (rvalue) ── */
    case NODE_MEMBER_ACCESS:
    case NODE_PTR_MEMBER_ACCESS: {
        /* call ir_lower_lvalue_addr to get field address
         *     emit load on that address
         *     return loaded value
         */
        ir_type_t field_type;
        ir_value_t field_addr = ir_lower_lvalue_addr(lctx, expr, &field_type);
        if (field_addr.kind == IR_VAL_NONE) return ir_val_none();
        *out_type = field_type;
        return emit_load(lctx, field_addr, field_type);
    }

    /* ── Address-of ── */
    case NODE_REFERENCE: {

        /*  call ir_lower_lvalue_addr on operand
         *  return the address directly (no load)
         */
        if (!expr->p_firstChild) {
            ir_diag(lctx, "IR001", expr->lineNumber, "address-of has no operand");
            return ir_val_none();
        }
        ir_type_t pointee_type;
        ir_value_t addr = ir_lower_lvalue_addr(lctx, expr->p_firstChild, &pointee_type);
        *out_type = ir_type_ptr();
        return addr;
    }

    /* ── Dereference (rvalue) ── */
    case NODE_POINTER_CONTENT: {

        /* lower operand with ir_lower_expr to get pointer value
         *     emit load using that pointer
         *     return loaded value
         */
        if (!expr->p_firstChild) {
            ir_diag(lctx, "IR001", expr->lineNumber, "dereference has no operand");
            return ir_val_none();
        }
        ir_type_t ptr_type;
        ir_value_t ptr_val = ir_lower_expr(lctx, expr->p_firstChild, &ptr_type);

        /* The pointee type comes from the semantic annotation on this node */
        ir_type_t pointee_type = (info && info->type)
                                 ? ir_type_from_sem(info->type) : ir_type_i16();
        *out_type = pointee_type;
        return emit_load(lctx, ptr_val, pointee_type);

    /* ── Type cast (§7.5) ── */
    case NODE_TYPE_CAST: {
        const TreeNode_t *operand = expr->p_firstChild;
        /* The cast-to type is annotated on the NODE_TYPE_CAST itself */
        ir_type_t to_type = expr_type;

        if (!operand) return ir_val_none();
        ir_type_t src_type;
        ir_value_t src = ir_lower_expr(lctx, operand, &src_type);

        if (ir_type_equal(src_type, to_type)) {
            *out_type = to_type;
            return src;
        }

        /* Select the right cast opcode */
        ir_opcode_t cast_op = IR_OP_BITCAST;
        if (ir_type_is_integer(src_type) && ir_type_is_integer(to_type)) {
            /* widening vs narrowing */
            int src_sz = (src_type.kind == IR_TYPE_I8)  ? 8  :
                         (src_type.kind == IR_TYPE_I16)  ? 16 : 32;
            int dst_sz = (to_type.kind  == IR_TYPE_I8)  ? 8  :
                         (to_type.kind  == IR_TYPE_I16)  ? 16 : 32;
            if (dst_sz > src_sz) {
                cast_op = sem_type_is_unsigned(info ? info->type : NULL)
                           ? IR_OP_ZEXT : IR_OP_SEXT;
            } else {
                cast_op = IR_OP_TRUNC;
            }
        } else if (to_type.kind == IR_TYPE_PTR || src_type.kind == IR_TYPE_PTR) {
            cast_op = IR_OP_BITCAST;
        }

        unsigned r = ir_new_vreg(lctx->func);
        ir_instr_t *cast = ir_instr_new(cast_op);
        cast->dst    = ir_val_vreg(r, to_type);
        cast->src[0] = src;
        ir_instr_push(lctx->cur_block, cast);
        *out_type = to_type;
        return ir_val_vreg(r, to_type);
    }

    default:
        ir_diag(lctx, "IR001", expr->lineNumber,
                "unhandled expression node type %d", (int)expr->nodeType);
        return ir_val_none();
    }
}
}
