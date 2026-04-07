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
    // G1 TODO: allocate new vreg, emit IR_OP_LOAD instruction, return vreg
    return ir_val_none();
}

/* Emit a store */
static void emit_store(ir_lower_ctx_t *lctx, ir_value_t ptr_val,
                       ir_value_t val)
{
    // G1 TODO: emit IR_OP_STORE instruction
}

/* Emit addr_of a slot/global and return the pointer vreg */
static ir_value_t emit_addr_of(ir_lower_ctx_t *lctx, ir_value_t sym_val)
{
    // G1 TODO: allocate new vreg, emit IR_OP_ADDR_OF instruction, return vreg
    return ir_val_none();
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

    case NODE_ARRAY_ACCESS:
        // G4 TODO: lower base expression (get base pointer or array address)
        //       lower index expression
        //       determine element type and stride from semantic annotation
        //       if base is slot/global emit addr_of first
        //       emit IR_OP_GEP with stride
        //       return pointer vreg
        return ir_val_none();

    case NODE_MEMBER_ACCESS:
    case NODE_PTR_MEMBER_ACCESS:
        // G4 TODO: lower base expression
        //       for MEMBER_ACCESS: emit addr_of to get base pointer
        //       for PTR_MEMBER_ACCESS: base is already a pointer
        //       emit IR_OP_GEP with offset 0 placeholder
        //       embed field name in callee slot for backend reference
        //       return pointer vreg
        return ir_val_none();

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
        // G1: TODO: return an immediate ir_value_t with ir_val_imm()
        return ir_val_none();

    case NODE_CHAR:
        // G1: TODO: return an immediate ir_value_t with ir_val_imm()
        return ir_val_none();

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
        // G1: TODO: look up symbol from annotation table
        //       resolve to slot or global via resolve_symbol_ref
        //       emit addr_of + load
        return ir_val_none();
    }

    /* ── §8.2 rule 3: Assignment ────────────────────────── */
    case NODE_OPERATOR: {
        // G1: TODO: handle OP_ASSIGN
        //       handle OP_PLUS_ASSIGN, OP_MINUS_ASSIGN, etc.
        //       handle binary arithmetic ops (OP_PLUS, OP_MINUS, OP_MULTIPLY, OP_DIVIDE, OP_MODULE)
        //       handle bitwise ops (OP_BITWISE_AND, OP_BITWISE_OR, OP_BITWISE_XOR, OP_BITWISE_NOT)
        //       handle shift ops (OP_LEFT_SHIFT, OP_RIGHT_SHIFT)
        //       handle unary minus (OP_UNARY_MINUS, OP_NEGATIVE)
        return ir_val_none();   
    }

    /* ── §8.2 rule 4: Pre/post inc/dec ────────────────── */
    case NODE_PRE_INC:
    case NODE_PRE_DEC: {
        // G1: TODO: compute address, load old, add/sub 1, store new, return new
        return ir_val_none();
    }

    case NODE_POST_INC:
    case NODE_POST_DEC: {
        // G1: TODO: compute address, load old, add/sub 1, store new, return old
        return ir_val_none();
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

    /* ── Function call (§7.7) ── */
    case NODE_FUNCTION_CALL:
        // G3 TODO: find callee name from first child identifier
        //       iterate argument siblings, lower each with ir_lower_expr
        //       emit IR_OP_CALL instruction
        //       if return type is void: is_void_call=1, return ir_val_none()
        //       otherwise: allocate dst vreg, return it
        return ir_val_none();

    /* ── Array access (rvalue) ── */
    case NODE_ARRAY_ACCESS:
        // G4 TODO: call ir_lower_lvalue_addr to get element address
        //       emit load on that address
        //       return loaded value
        return ir_val_none();

    /* ── Member access (rvalue) ── */
    case NODE_MEMBER_ACCESS:
    case NODE_PTR_MEMBER_ACCESS:
        // G4 TODO: call ir_lower_lvalue_addr to get field address
        //       emit load on that address
        //       return loaded value
        return ir_val_none();

    /* ── Address-of ── */
    case NODE_REFERENCE:
        // G4 TODO: call ir_lower_lvalue_addr on operand
        //       return the address directly (no load)
        return ir_val_none();

    /* ── Dereference (rvalue) ── */
    case NODE_POINTER_CONTENT:
        // G4 TODO: lower operand with ir_lower_expr to get pointer value
        //       emit load using that pointer
        //       return loaded value
        return ir_val_none();

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