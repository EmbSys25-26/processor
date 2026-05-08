#include <errno.h>
#include <stdlib.h>
#include <string.h>

#include "semantic_pass2.h"
#include "semantic_ast_helpers.h"
#include "../Util/NodeTypes.h"

/**
 * @brief Internal mutable state used while running semantic pass2.
 */
typedef struct {
  semantic_context_t *ctx;
  semantic_pass2_result_t result;
  const type_t *current_return_type;
  int in_function;
  size_t loop_depth;
  size_t switch_depth;
  TreeNode_t *root;
} pass2_state_t;

/** @brief Shared invalid type singleton for failed inference paths. */
static const type_t g_type_invalid = {
    .kind = TYPE_INVALID,
    .qualifiers = 0u};

/** @brief Shared builtin type singleton for `char`. */
static const type_t g_type_char = {
    .kind = TYPE_BUILTIN,
    .qualifiers = 0u,
    .as = {.builtin = BUILTIN_CHAR}};

/** @brief Shared builtin type singleton for `int`. */
static const type_t g_type_int = {
    .kind = TYPE_BUILTIN,
    .qualifiers = 0u,
    .as = {.builtin = BUILTIN_INT}};

/** @brief Shared builtin type singleton for `float`. */
static const type_t g_type_float = {
    .kind = TYPE_BUILTIN,
    .qualifiers = 0u,
    .as = {.builtin = BUILTIN_FLOAT}};

/** @brief Shared builtin type singleton for `double`. */
static const type_t g_type_double = {
    .kind = TYPE_BUILTIN,
    .qualifiers = 0u,
    .as = {.builtin = BUILTIN_DOUBLE}};

/*
 * Shared builtin type singleton for string literals (IR contract §3.6).
 * BUILTIN_STRING lowers to `ptr i8` with an implicit const pointee qualifier;
 * it is NOT flagged SEM_NODE_CODEGEN_BLOCKED — the backend handles it as a
 * read-only data pointer identical to `const char *`.
 */
static const type_t g_type_string = {
    .kind = TYPE_BUILTIN,
    .qualifiers = 0u,
    .as = {.builtin = BUILTIN_STRING}};

/** @brief Shared builtin type singleton for `void`. */
static const type_t g_type_void = {
    .kind = TYPE_BUILTIN,
    .qualifiers = 0u,
    .as = {.builtin = BUILTIN_VOID}};

static void pass2_emit(pass2_state_t *state,
                       const char *code,
                       size_t line,
                       const char *message);

static unsigned pass2_codegen_block_flags(const type_t *type, sem_value_kind_t vk);

static const sem_node_info_t *pass2_get_node_info(pass2_state_t *state, const TreeNode_t *node)
{
  return (state && state->ctx) ? semantic_get_node_info(state->ctx, node) : NULL;
}

static const type_t *pass2_cache_expr(pass2_state_t *state,
                                      TreeNode_t *node,
                                      const type_t *type,
                                      symbol_t *symbol,
                                      sem_value_kind_t value_kind,
                                      unsigned extra_flags)
{
  sem_node_info_t info;

  if (!state || !state->ctx || !node || !type || type->kind == TYPE_INVALID) {
    return type ? type : &g_type_invalid;
  }

  info.type = type;
  info.symbol = symbol;
  info.value_kind = value_kind;
  extra_flags |= pass2_codegen_block_flags(type, value_kind);
  info.flags = SEM_NODE_TYPED | extra_flags;
  if (semantic_set_node_info(state->ctx, node, &info) < 0) {
    pass2_emit(state, "SEM900", node->lineNumber, "failed to cache semantic node info");
  }

  return type;
}

static sem_value_kind_t pass2_decl_value_kind(symbol_kind_t kind)
{
  switch (kind) {
    case SYMBOL_FUNCTION:
      return SEM_VALUE_FUNCTION_DESIGNATOR;
    case SYMBOL_OBJECT:
    case SYMBOL_PARAMETER:
    case SYMBOL_FIELD:
      return SEM_VALUE_LVALUE;
    default:
      return SEM_VALUE_RVALUE;
  }
}

static int pass2_is_lvalue_kind(const sem_node_info_t *info)
{
  return info && info->value_kind == SEM_VALUE_LVALUE;
}

static int pass2_is_modifiable_lvalue(TreeNode_t *node,
                                      pass2_state_t *state,
                                      const type_t *type)
{
  const sem_node_info_t *info = pass2_get_node_info(state, node);

  if (!pass2_is_lvalue_kind(info)) {
    return 0;
  }

  if (!type) {
    return 0;
  }

  return (type->qualifiers & TYPE_QUAL_CONST) == 0u;
}

/**
 * @brief Emit one pass2 diagnostic into the shared diagnostics list.
 * @param state pass2 execution state.
 * @param code semantic code (SEM###).
 * @param line source line associated with the diagnostic.
 * @param message readable error message.
 */
static void pass2_emit(pass2_state_t *state,
                       const char *code,
                       size_t line,
                       const char *message)
{
  if (!state || !state->ctx) {
    return;
  }

  (void)diag_emit(&state->ctx->diagnostics, code, DIAG_ERROR, line, 0u, "%s", message);
}

/**
 * @brief Emit one pass2 diagnostic warning into the shared diagnostics list.
 * @param state pass2 execution state.
 * @param code semantic code (SEM###).
 * @param line source line associated with the diagnostic.
 * @param message readable error message.
 */
static void pass2_warning(pass2_state_t *state,
                       const char *code,
                       size_t line,
                       const char *message)
{
  if (!state || !state->ctx) {
    return;
  }

  (void)diag_emit(&state->ctx->diagnostics, code, DIAG_WARNING, line, 0u, "%s", message);
}

/**
 * @brief Check whether a builtin type is integral.
 * @param builtin builtin type enum.
 * @return non-zero if integral.
 */
static int is_integral_builtin(builtin_type_t builtin)
{
  return builtin == BUILTIN_CHAR ||
         builtin == BUILTIN_SHORT ||
         builtin == BUILTIN_INT ||
         builtin == BUILTIN_LONG;
}

/**
 * @brief Check whether a builtin type is floating.
 * @param builtin builtin type enum.
 * @return non-zero if floating.
 */
static int is_floating_builtin(builtin_type_t builtin)
{
  return builtin == BUILTIN_FLOAT ||
         builtin == BUILTIN_DOUBLE ||
         builtin == BUILTIN_LONG_DOUBLE;
}

/**
 * @brief Check whether a builtin type belongs to numeric family.
 * @param builtin builtin type enum.
 * @return non-zero if numeric.
 */
static int is_numeric_builtin(builtin_type_t builtin)
{
  return is_integral_builtin(builtin) ||
         is_floating_builtin(builtin);
}

/* Block codegen for types unsupported by the current backend */
static unsigned pass2_codegen_block_flags(const type_t *type, sem_value_kind_t vk)
{
  if (!type) return 0u;
  if (type->kind == TYPE_BUILTIN && is_floating_builtin(type->as.builtin))
    return SEM_NODE_CODEGEN_BLOCKED;
  if ((type->kind == TYPE_STRUCT_TAG || type->kind == TYPE_UNION_TAG)
      && vk == SEM_VALUE_RVALUE)
    return SEM_NODE_CODEGEN_BLOCKED;
  return 0u;
}

/**
 * @brief Return a widening rank for builtin numeric types.
 * @param builtin builtin type enum.
 * @return monotonically increasing rank, or zero when non-numeric.
 */
static int builtin_rank(builtin_type_t builtin)
{
  switch (builtin) {
    case BUILTIN_CHAR:
      return 1;
    case BUILTIN_SHORT:
      return 2;
    case BUILTIN_INT:
      return 3;
    case BUILTIN_LONG:
      return 4;
    case BUILTIN_FLOAT:
      return 5;
    case BUILTIN_DOUBLE:
      return 6;
    case BUILTIN_LONG_DOUBLE:
      return 7;
    default:
      return 0;
  }
}

/**
 * @brief Check whether a semantic type is numeric.
 * @param type semantic type pointer.
 * @return non-zero if numeric.
 */
static int type_is_numeric(const type_t *type)
{
  if (!type || type->kind != TYPE_BUILTIN) {
    return 0;
  }
  return is_numeric_builtin(type->as.builtin);
}
/**
 * @brief Check whether a semantic type is scalar.
 * @param type semantic type pointer.
 * @return non-zero if scalar.
 */
static int type_is_scalar(const type_t *type)
{
  if (!type) {
    return 0;
  }
  //Is scalar if it's numeric or pointer
  return type_is_numeric(type) || type->kind == TYPE_POINTER;
}

/**
 * @brief Check whether one semantic type is a builtin integral type.
 * @param type semantic type pointer.
 * @return non-zero if builtin integral.
 */
static int type_is_builtin_integral(const type_t *type)
{
  return type &&
         type->kind == TYPE_BUILTIN &&
         is_integral_builtin(type->as.builtin);
}

/**
 * @brief Check whether one semantic type is an unsigned builtin integral type.
 * @param type semantic type pointer.
 * @return non-zero if unsigned integral.
 */
static int type_is_unsigned_integral(const type_t *type)
{
  return type_is_builtin_integral(type) &&
         (type->qualifiers & TYPE_QUAL_UNSIGNED) != 0u;
}

/**
 * @brief Check whether one semantic type behaves as a signed builtin integral type.
 * @param type semantic type pointer.
 * @return non-zero if integral and not explicitly unsigned.
 */
static int type_is_signed_integral(const type_t *type)
{
  return type_is_builtin_integral(type) &&
         (type->qualifiers & TYPE_QUAL_UNSIGNED) == 0u;
}

/**
 * @brief Check whether one expression root is an explicit cast.
 * @param expr expression node.
 * @return non-zero if expression is an explicit cast root.
 */
static int expr_is_explicit_cast(const TreeNode_t *expr)
{
  return expr && expr->nodeType == NODE_TYPE_CAST;
}


/** 
 * @brief Check whether an AST node represents a constant zero expression.
 * @param node AST node pointer.
 * @return non-zero if the node is a constant zero expression; zero otherwise.
*/

static int is_constant_zero(const TreeNode_t *node)
{
  if (!node) {
    return 0;
  }

  if (node->nodeType == NODE_INTEGER && node->nodeData.dVal == 0) {
    return 1;
  }

  if (node->nodeType == NODE_CHAR && node->nodeData.dVal == 0) {
    return 1;
  }

  if (node->nodeType == NODE_FLOAT && node->nodeData.fVal == 0.0f) {
    return 1;
  }

  return 0;

}

/**
 * @brief Verifies whether two types are compatible for comparison operators.
 * @param lhs left-hand side type.
 * @param rhs right-hand side type.
 * @return non-zero (1) if they are compatible, 0 otherwise.
 */
static int is_comparison_compatible(const type_t *lhs, const type_t *rhs)
{
  if (!lhs || !rhs) {
    return 0;
  }

  if (type_equal(lhs, rhs)) {
    return 1;
  }

  if(type_is_numeric(lhs) && type_is_numeric(rhs)) {
    return 1;
  }

  if (lhs->kind == TYPE_POINTER && rhs->kind == TYPE_POINTER) {
    return 1;
  }
  
  return 0;
}



/**
 * @brief Check whether an AST node kind should be treated as an expression root.
 * @param node_type AST node type.
 * @return non-zero if the node kind represents an expression.
 */
static int is_expression_node_type(NodeType_t node_type)
{
  switch (node_type) {
    case NODE_INTEGER:
    case NODE_CHAR:
    case NODE_FLOAT:
    case NODE_STRING:
    case NODE_IDENTIFIER:
    case NODE_FUNCTION_CALL:
    case NODE_OPERATOR:
    case NODE_ARRAY_ACCESS:
    case NODE_POINTER_CONTENT:
    case NODE_POST_INC:
    case NODE_PRE_INC:
    case NODE_POST_DEC:
    case NODE_PRE_DEC:
    case NODE_MEMBER_ACCESS:
    case NODE_PTR_MEMBER_ACCESS:
    case NODE_TERNARY:
    case NODE_REFERENCE:
    case NODE_TYPE_CAST:
      return 1;
    default:
      return 0;
  }
}

/**
 * @brief Assignment compatibility predicate used by pass2 checks.
 * @param lhs left-hand side type.
 * @param rhs right-hand side type.
 * @return non-zero if assignment is accepted by current policy.
 */
static int assignment_compatible(const type_t *lhs, const type_t *rhs)
{
  if (!lhs || !rhs) {
    return 0;
  }
  
  if (type_equal(lhs, rhs)) {
    return 1;
  }

  if (lhs->kind == TYPE_BUILTIN && rhs->kind == TYPE_BUILTIN) {
    if (is_numeric_builtin(lhs->as.builtin) && is_numeric_builtin(rhs->as.builtin)) {
        return 1;
    }
    return 0;
  }

  if (lhs->kind == TYPE_ENUM_TAG && (rhs->kind == TYPE_BUILTIN) && is_integral_builtin(rhs->as.builtin)){
    return 1; 
  }
  return 0;
}

/**
 * @brief Check whether one implicit assignment narrows the numeric value family.
 * @param lhs left-hand side type.
 * @param rhs right-hand side type.
 * @param rhs_expr right-hand side AST node.
 * @return non-zero if the assignment should emit SEMW001.
 */
static int warns_on_narrowing_assignment(const type_t *lhs,
                                         const type_t *rhs,
                                         const TreeNode_t *rhs_expr)
{
  if (!lhs || !rhs || !rhs_expr || expr_is_explicit_cast(rhs_expr)) {
    return 0;
  }

  if (lhs->kind != TYPE_BUILTIN || rhs->kind != TYPE_BUILTIN) {
    return 0;
  }

  if (is_integral_builtin(lhs->as.builtin) && is_floating_builtin(rhs->as.builtin)) {
    return 1;
  }

  if (is_floating_builtin(lhs->as.builtin) &&
      is_floating_builtin(rhs->as.builtin) &&
      builtin_rank(lhs->as.builtin) < builtin_rank(rhs->as.builtin)) {
    return 1;
  }

  if (is_integral_builtin(lhs->as.builtin) &&
      is_integral_builtin(rhs->as.builtin) &&
      builtin_rank(lhs->as.builtin) < builtin_rank(rhs->as.builtin)) {
    return 1;
  }

  return 0;
}

/**
 * @brief Check whether one implicit assignment converts signed integral data to unsigned.
 * @param lhs left-hand side type.
 * @param rhs right-hand side type.
 * @param rhs_expr right-hand side AST node.
 * @return non-zero if the assignment should emit SEMW002.
 */
static int warns_on_signed_to_unsigned_assignment(const type_t *lhs,
                                                  const type_t *rhs,
                                                  const TreeNode_t *rhs_expr)
{
  if (!lhs || !rhs || !rhs_expr || expr_is_explicit_cast(rhs_expr)) {
    return 0;
  }

  if (!type_is_unsigned_integral(lhs) || !type_is_signed_integral(rhs)) {
    return 0;
  }

  /* Binary operator results carry their own SEMW002 mixed-sign diagnostic.
     Suppress the assignment-level warning to avoid doubling up; unary minus
     (negation of a literal) is the one operator that warrants an extra warning. */
  if (rhs_expr->nodeType == NODE_OPERATOR &&
      rhs_expr->nodeData.dVal != OP_UNARY_MINUS) {
    return 0;
  }

  return 1;
}

/**
 * @brief Check whether a binary operator mixes signed and unsigned integral operands.
 * @param lhs left operand type.
 * @param rhs right operand type.
 * @return non-zero if the operand pair should emit SEMW002.
 */
static int warns_on_mixed_signed_unsigned_operands(const type_t *lhs, const type_t *rhs)
{
  if (!type_is_builtin_integral(lhs) || !type_is_builtin_integral(rhs)) {
    return 0;
  }

  return type_is_unsigned_integral(lhs) != type_is_unsigned_integral(rhs);
}

/**
 * @brief Check whether a cast target removes const qualifiers anywhere in the pointee chain.
 * @param target cast target type.
 * @param source source expression type.
 * @return non-zero if const is dropped.
 */
static int cast_drops_const(const type_t *target, const type_t *source)
{
  if (!target || !source) {
    return 0;
  }

  if ((source->qualifiers & TYPE_QUAL_CONST) != 0u &&
      (target->qualifiers & TYPE_QUAL_CONST) == 0u) {
    return 1;
  }

  if (target->kind == TYPE_POINTER &&
      source->kind == TYPE_POINTER &&
      target->as.pointer.base &&
      source->as.pointer.base) {
    return cast_drops_const(target->as.pointer.base, source->as.pointer.base);
  }

  return 0;
}

/**
 * @brief Check whether one explicit pointer cast removes const from the pointee chain.
 * @param target cast target type.
 * @param source source expression type.
 * @return non-zero if SEMW003 should be emitted.
 */
static int warns_on_const_dropping_cast(const type_t *target, const type_t *source)
{
  if (!target || !source) {
    return 0;
  }

  if (target->kind != TYPE_POINTER || source->kind != TYPE_POINTER) {
    return 0;
  }

  return cast_drops_const(target->as.pointer.base, source->as.pointer.base);
}

/**
 * @brief Check whether one semantic type is a floating scalar type.
 * @param type semantic type pointer.
 * @return non-zero if the type is a builtin floating family.
 */
static int type_is_floating(const type_t *type)
{
  return type &&
         type->kind == TYPE_BUILTIN &&
         is_floating_builtin(type->as.builtin);
}

/**
 * @brief Check whether one semantic type is an incomplete struct/union object type.
 * @param type semantic type pointer.
 * @return non-zero if the type is a struct/union tag without a completed declaration body.
 */
static int type_is_incomplete_aggregate_object(const type_t *type)
{
  const TreeNode_t *decl_node;

  if (!type) {
    return 0;
  }

  if (type->kind != TYPE_STRUCT_TAG && type->kind != TYPE_UNION_TAG) {
    return 0;
  }

  decl_node = (const TreeNode_t *)type->as.aggregate.decl_node;
  return decl_node == NULL || decl_node->p_firstChild == NULL;
}

/**
 * @brief Check whether an explicit cast involves an incomplete struct/union object type.
 * @param target cast target type.
 * @param source source expression type.
 * @return non-zero if SEM015 should be emitted.
 */
static int cast_involves_incomplete_aggregate(const type_t *target, const type_t *source)
{
  return type_is_incomplete_aggregate_object(target) ||
         type_is_incomplete_aggregate_object(source);
}

/**
 * @brief Check whether an explicit cast converts between pointer and floating families.
 * @param target cast target type.
 * @param source source expression type.
 * @return non-zero if SEM016 should be emitted.
 */
static int cast_between_pointer_and_floating(const type_t *target, const type_t *source)
{
  if (!target || !source) {
    return 0;
  }

  return (target->kind == TYPE_POINTER && type_is_floating(source)) ||
         (source->kind == TYPE_POINTER && type_is_floating(target));
}

/**
 * @brief Check whether a semantic type is exactly `void`.
 * @param type semantic type pointer.
 * @return non-zero if type is builtin void.
 */
static int type_is_void(const type_t *type)
{
  return type &&
         type->kind == TYPE_BUILTIN &&
         type->as.builtin == BUILTIN_VOID;
}

/**
 * @brief Function argument compatibility predicate used by SEM042 checks.
 * @param param_type declared parameter type.
 * @param arg_type inferred argument type.
 * @return non-zero if the argument is accepted by current policy.
 */
static int argument_compatible(const type_t *param_type, const type_t *arg_type)
{
  if (!param_type || !arg_type) {
    return 0;
  }

  if (type_equal(param_type, arg_type)) {
    return 1;
  }

  /* Allow numeric implicit conversions, same policy as assignments. */
  if (param_type->kind == TYPE_BUILTIN && arg_type->kind == TYPE_BUILTIN) {
    if (is_numeric_builtin(param_type->as.builtin) &&
        is_numeric_builtin(arg_type->as.builtin)) {
      return 1;
    }
  }

  /* Allow array argument to match pointer parameter when element types match. */
  if (param_type->kind == TYPE_POINTER &&
      arg_type->kind == TYPE_ARRAY &&
      param_type->as.pointer.base &&
      arg_type->as.array.elem &&
      type_equal(param_type->as.pointer.base, arg_type->as.array.elem)) {
    return 1;
  }

  return 0;
}

typedef enum {
  CASE_LABEL_INVALID = 0,
  CASE_LABEL_VALUE,
  CASE_LABEL_ENUM_NAME
} case_label_kind_t;

/**
 * @brief Return the label child of one `case` node.
 * @param case_node case AST node.
 * @return first child when present, otherwise NULL.
 */
static const TreeNode_t *case_label_expr(const TreeNode_t *case_node)
{
  if (!case_node || case_node->nodeType != NODE_CASE) {
    return NULL;
  }

  return case_node->p_firstChild;
}

/**
 * @brief Return the statement/body child of one `case` node.
 * @param case_node case AST node.
 * @return second child when present, otherwise NULL.
 */
static const TreeNode_t *case_body_stmt(const TreeNode_t *case_node)
{
  const TreeNode_t *label = case_label_expr(case_node);
  return label ? label->p_sibling : NULL;
}

/**
 * @brief Classify one case label according to the currently supported subset.
 * @param label case label child node.
 * @param state pass2 execution state.
 * @param out_value numeric value for literal labels.
 * @param out_name enum constant name for identifier labels.
 * @return label classification used by switch-label validation.
 */
static case_label_kind_t evaluate_case_label(const TreeNode_t *label,
                                             pass2_state_t *state,
                                             long *out_value,
                                             const char **out_name)
{
  scope_t *scope;
  symbol_t *sym;

  if (out_value) {
    *out_value = 0;
  }
  if (out_name) {
    *out_name = NULL;
  }

  if (!label || !state) {
    return CASE_LABEL_INVALID;
  }

  switch (label->nodeType) {
    case NODE_INTEGER:
    case NODE_CHAR:
      if (out_value) {
        *out_value = (long)label->nodeData.dVal;
      }
      return CASE_LABEL_VALUE;
    case NODE_IDENTIFIER:
      if (!label->nodeData.sVal || label->nodeData.sVal[0] == '\0') {
        return CASE_LABEL_INVALID;
      }
      scope = scope_current(&state->ctx->scope_stack);
      sym = symbol_lookup_visible(scope, label->nodeData.sVal);
      if (!sym || sym->kind != SYMBOL_ENUM_CONST) {
        return CASE_LABEL_INVALID;
      }
      if (out_name) {
        *out_name = label->nodeData.sVal;
      }
      return CASE_LABEL_ENUM_NAME;
    default:
      return CASE_LABEL_INVALID;
  }
}

/**
 * @brief Scan one switch subtree for duplicate case labels and multiple defaults.
 * @param node subtree root belonging to the switch body.
 * @param state pass2 execution state.
 * @param case_values buffer of already seen case values.
 * @param case_count number of used entries in case_values.
 * @param case_capacity total capacity of case_values.
 * @param default_seen whether a default label was already seen.
 * @return 0 on success, negative errno-like value on fatal error.
 */
static int scan_switch_labels(const TreeNode_t *node,
                              pass2_state_t *state,
                              long *case_values,
                              size_t *case_count,
                              size_t case_capacity,
                              const char **case_names,
                              size_t *name_count,
                              int *default_seen)
{
  const TreeNode_t *it = node;

  while (it) {
    /* Nested switch starts a new label namespace: do not recurse into it. */
    if (it->nodeType == NODE_SWITCH) {
      it = it->p_sibling;
      continue;
    }

    if (it->nodeType == NODE_CASE) {
      const TreeNode_t *label = case_label_expr(it);
      const char *name = NULL;
      long value = 0;
      case_label_kind_t kind = evaluate_case_label(label, state, &value, &name);

      if (kind == CASE_LABEL_INVALID) {
        pass2_emit(state, "SEM054", it->lineNumber,
                   "case label must be an integral constant expression");
      } else if (kind == CASE_LABEL_ENUM_NAME) {
        size_t i;

        for (i = 0u; i < *name_count; ++i) {
          if (strcmp(case_names[i], name) == 0) {
            pass2_emit(state, "SEM055", it->lineNumber, "duplicate case label in same switch");
            break;
          }
        }

        if (*name_count < case_capacity) {
          case_names[*name_count] = name;
          (*name_count)++;
        } else {
          pass2_emit(state, "SEM900", it->lineNumber, "switch case tracking capacity exceeded");
          return -EINVAL;
        }
      } else {
        size_t i;

        for (i = 0u; i < *case_count; ++i) {
          if (case_values[i] == value) {
            pass2_emit(state, "SEM055", it->lineNumber, "duplicate case label in same switch");
            break;
          }
        }

        if (*case_count < case_capacity) {
          case_values[*case_count] = value;
          (*case_count)++;
        } else {
          pass2_emit(state, "SEM900", it->lineNumber, "switch case tracking capacity exceeded");
          return -EINVAL;
        }
      }
    } else if (it->nodeType == NODE_DEFAULT) {
      if (*default_seen) {
        pass2_emit(state, "SEM056", it->lineNumber, "multiple default labels in same switch");
      } else {
        *default_seen = 1;
      }
    }

    if (it->p_firstChild) {
      const TreeNode_t *child_root = it->p_firstChild;
      int rc;

      if (it->nodeType == NODE_CASE) {
        child_root = case_body_stmt(it);
      }

      if (!child_root) {
        it = it->p_sibling;
        continue;
      }

      rc = scan_switch_labels(child_root, state, case_values, case_count,
                              case_capacity, case_names, name_count, default_seen);
      if (rc < 0) {
        return rc;
      }
    }

    it = it->p_sibling;
  }

  return 0;
}

/**
 * @brief Validate uniqueness of case/default labels inside one switch statement.
 * @param switch_node switch AST node.
 * @param state pass2 execution state.
 * @return 0 on success, negative errno-like value on fatal error.
 */
static int check_switch_labels(TreeNode_t *switch_node, pass2_state_t *state)
{
  long case_values[256];
  const char *case_names[256];
  size_t case_count = 0u;
  size_t name_count = 0u;
  int default_seen = 0;
  TreeNode_t *switch_expr;
  TreeNode_t *switch_body;

  if (!switch_node || !state) {
    return 0;
  }

  switch_expr = switch_node->p_firstChild;
  switch_body = switch_expr ? switch_expr->p_sibling : NULL;

  if (!switch_body) {
    return 0;
  }

  return scan_switch_labels(switch_body, state, case_values, &case_count,
                            sizeof(case_values) / sizeof(case_values[0]),
                            case_names, &name_count, &default_seen);
}

static int statement_guarantees_return(const TreeNode_t *node);

/**
 * @brief Check whether a sibling-linked statement sequence guarantees return on any path.
 * @param node first statement in the sequence.
 * @return non-zero if execution cannot fall through past the sequence.
 */
static int statement_sequence_guarantees_return(const TreeNode_t *node)
{
  const TreeNode_t *it = node;

  while (it) {
    if (statement_guarantees_return(it)) {
      return 1;
    }
    it = it->p_sibling;
  }

  return 0;
}

/**
 * @brief Conservative return-path analysis used by SEM045.
 *        Returns non-zero only when ALL paths through the statement provably return.
 *        Deliberately under-approximates (no loop termination analysis).
 * @param node statement node to analyse.
 * @return non-zero if the statement guarantees a return on all paths.
 */
static int statement_guarantees_return(const TreeNode_t *node)
{
  const TreeNode_t *cond;
  const TreeNode_t *then_branch;
  const TreeNode_t *else_branch;

  if (!node) {
    return 0;
  }

  switch (node->nodeType) {
    case NODE_RETURN:
      return 1;
    case NODE_BLOCK:
      return statement_sequence_guarantees_return(node->p_firstChild);
    case NODE_IF:
      cond        = node->p_firstChild;
      then_branch = cond        ? cond->p_sibling        : NULL;
      else_branch = then_branch ? then_branch->p_sibling : NULL;
      /* Only guaranteed if BOTH branches return and an else branch exists. */
      return then_branch &&
             else_branch &&
             statement_guarantees_return(then_branch) &&
             statement_guarantees_return(else_branch);
    case NODE_DO_WHILE:
      return node->p_firstChild && statement_guarantees_return(node->p_firstChild);
    default:
      return 0;
  }
}

static const type_t *infer_expr_type(TreeNode_t *node, pass2_state_t *state);


/**
 * @brief Lookup currently visible tag symbol by kind and tag name.
 * @param state pass2 execution state.
 * @param kind tag kind to lookup.
 * @param tag_name source tag identifier.
 * @return visible symbol if found; NULL otherwise.
 */
static symbol_t *lookup_visible_tag_symbol(pass2_state_t *state,
                                           type_kind_t kind,
                                           const char *tag_name)
{
  char key[256];
  scope_t *scope;

  if (!state || !tag_name) {
    return NULL;
  }

  if (build_tag_symbol_name(kind, tag_name, key, sizeof(key)) < 0) {
    return NULL;
  }

  scope = scope_current(&state->ctx->scope_stack);
  if (!scope) {
    return NULL;
  }

  return symbol_lookup_visible(scope, key);
}


/**
 * @brief Recursively locate a visible aggregate tag declaration in the AST.
 * @param node subtree root to scan.
 * @param kind expected tag kind.
 * @param tag_name tag identifier.
 * @return matching declaration node or NULL when not found.
 */
static const TreeNode_t *find_tag_declaration(const TreeNode_t *node,
                                              type_kind_t kind,
                                              const char *tag_name)
{
  const TreeNode_t *it = node;
  NodeType_t decl_kind;

  if (!tag_name) {
    return NULL;
  }

  switch (kind) {
    case TYPE_STRUCT_TAG:
      decl_kind = NODE_STRUCT_DECLARATION;
      break;
    case TYPE_UNION_TAG:
      decl_kind = NODE_UNION_DECLARATION;
      break;
    default:
      return NULL;
  }

  while (it) {
    const TreeNode_t *found;

    if (it->nodeType == decl_kind &&
        it->nodeData.sVal &&
        strcmp(it->nodeData.sVal, tag_name) == 0) {
      return it;
    }

    found = find_tag_declaration(it->p_firstChild, kind, tag_name);
    if (found) {
      return found;
    }

    it = it->p_sibling;
  }

  return NULL;
}

static const TreeNode_t *resolve_member_decl(const TreeNode_t *aggregate_decl,
                                             const char *member_name)
{
  const TreeNode_t *member = aggregate_decl ? aggregate_decl->p_firstChild : NULL;

  while (member) {
    if ((member->nodeType == NODE_STRUCT_MEMBER || member->nodeType == NODE_ARRAY_DECLARATION) &&
        member->nodeData.sVal &&
        strcmp(member->nodeData.sVal, member_name) == 0) {
      return member;
    }
    member = member->p_sibling;
  }

  return NULL;
}

static const type_t *resolve_member_decl_type(const TreeNode_t *member_decl,
                                              pass2_state_t *state)
{
  const type_t *member_type;

  if (!member_decl || !state) {
    return &g_type_invalid;
  }

  member_type = semantic_ast_build_type_from_declaration(&state->ctx->type_context, member_decl);
  if (!member_type) {
    pass2_emit(state, "SEM900", member_decl->lineNumber, "failed to build member type");
    return &g_type_invalid;
  }

  return member_type;
}

static symbol_t *ensure_field_symbol(const TreeNode_t *member_decl,
                                     const type_t *member_type,
                                     pass2_state_t *state)
{
  const sem_node_info_t *cached;
  sem_node_info_t info;
  symbol_t *symbol;

  if (!member_decl || !member_type || !state || !state->ctx || !member_decl->nodeData.sVal) {
    return NULL;
  }

  cached = semantic_get_node_info(state->ctx, member_decl);
  if (cached && cached->symbol && cached->symbol->kind == SYMBOL_FIELD) {
    return cached->symbol;
  }

  symbol = symbol_new(&state->ctx->persistent_arena,
                      member_decl->nodeData.sVal,
                      SYMBOL_FIELD,
                      member_type,
                      member_decl->lineNumber,
                      0u);
  if (!symbol) {
    pass2_emit(state, "SEM900", member_decl->lineNumber, "failed to allocate field symbol");
    return NULL;
  }

  info.type = member_type;
  info.symbol = symbol;
  info.value_kind = SEM_VALUE_LVALUE;
  info.flags = SEM_NODE_TYPED;
  if (semantic_set_node_info(state->ctx, member_decl, &info) < 0) {
    pass2_emit(state, "SEM900", member_decl->lineNumber, "failed to cache field node info");
  }

  return symbol;
}

/**
 * @brief Infer member access expression type for '.' and '->'.
 * @param node member access AST node.
 * @param state pass2 execution state.
 * @param via_pointer non-zero for '->', zero for '.'.
 * @return inferred member type or invalid singleton on failure.
 */
//Extract base expression and the member name being accessed
static const type_t *infer_member_access_type(TreeNode_t *node,
                                              pass2_state_t *state,
                                              int via_pointer)
{
  TreeNode_t *base_expr;
  TreeNode_t *field_ident;
  const type_t *base_type;
  const type_t *aggregate_type;
  const TreeNode_t *aggregate_decl;
  const TreeNode_t *member_decl;
  symbol_t *tag_symbol;
  symbol_t *field_symbol = NULL;
  const type_t *member_type;
  const char *member_name;
  const char *semantic_code;
  const char *semantic_message;

  if (!node || !state) {
    return &g_type_invalid;
  }
  base_expr = node->p_firstChild;
  field_ident = base_expr ? base_expr->p_sibling : NULL;
  member_name = (field_ident && field_ident->nodeType == NODE_IDENTIFIER) ? field_ident->nodeData.sVal : NULL;

  if (!base_expr || !member_name) {
    return &g_type_invalid;
  }

  //Infer the type of the base expression
  base_type = infer_expr_type(base_expr, state);
  aggregate_type = base_type;
  semantic_code = via_pointer ? "SEM062" : "SEM061";
  semantic_message = via_pointer ? "operator '->' requires pointer to struct/union"
                                 : "operator '.' requires struct/union object";

  //If '->' is used, ensure LHS is a valid pointer and extract its base type
  if (via_pointer) {
    if (!base_type || base_type->kind != TYPE_POINTER || !base_type->as.pointer.base) {
      pass2_emit(state, semantic_code, node->lineNumber, semantic_message);
      return &g_type_invalid;
    }
    aggregate_type = base_type->as.pointer.base;
  }

  //Ensure the target is actually a struct or a union
  if (!aggregate_type ||
      (aggregate_type->kind != TYPE_STRUCT_TAG && aggregate_type->kind != TYPE_UNION_TAG)) {
    pass2_emit(state, semantic_code, node->lineNumber, semantic_message);
    return &g_type_invalid;
  }

  //Locate the struct/union definition (from type, symbol table, or AST)
  aggregate_decl = (const TreeNode_t *)aggregate_type->as.aggregate.decl_node;
  if (!aggregate_decl && aggregate_type->as.aggregate.tag) {
    tag_symbol = lookup_visible_tag_symbol(state,
                                           aggregate_type->kind,
                                           aggregate_type->as.aggregate.tag);
    if (tag_symbol && tag_symbol->type) {
      aggregate_decl = (const TreeNode_t *)tag_symbol->type->as.aggregate.decl_node;
    }
  }
  if (!aggregate_decl && aggregate_type->as.aggregate.tag) {
    aggregate_decl = find_tag_declaration(state->root,
                                          aggregate_type->kind,
                                          aggregate_type->as.aggregate.tag);
  }

  //SEM060: Fail if the struct is incomplete (declared but missing its body)
  if (!aggregate_decl) {
    pass2_emit(state, "SEM060", node->lineNumber, "aggregate member not found");
    return &g_type_invalid;
  }

  //SEM060: Fail if the requested member doesn't exist inside the struct
  member_decl = resolve_member_decl(aggregate_decl, member_name);
  if (!member_decl) {
    pass2_emit(state, "SEM060", node->lineNumber, "aggregate member not found");
    return &g_type_invalid;
  }

  member_type = resolve_member_decl_type(member_decl, state);
  if (member_type->kind == TYPE_INVALID) {
    return &g_type_invalid;
  }

  field_symbol = ensure_field_symbol(member_decl, member_type, state);
  return pass2_cache_expr(state, node, member_type, field_symbol, SEM_VALUE_LVALUE, 0u);
}
/**
 * @brief Lookup one identifier symbol through the currently visible scope chain.
 * @param name identifier name.
 * @param line source line for diagnostics.
 * @param state pass2 execution state.
 * @return symbol if found; NULL otherwise.
 */
static symbol_t *lookup_identifier_symbol(const char *name, size_t line, pass2_state_t *state)
{
  scope_t *scope;

  if (!state || !state->ctx || !name) {
    if (state) {
      pass2_emit(state, "SEM001", line, "unknown identifier");
    }
    return NULL;
  }

  scope = scope_current(&state->ctx->scope_stack);
  if (!scope) {
    pass2_emit(state, "SEM001", line, "unknown identifier");
    return NULL;
  }

  return symbol_lookup_visible(scope, name);
}

/**
 * @brief Count positional arguments in a function call node.
 * @param call_node function call AST node.
 * @return number of call arguments.
 */
static size_t count_call_arguments(TreeNode_t *call_node)
{
  size_t count = 0u;
  TreeNode_t *arg = call_node ? call_node->p_firstChild : NULL;

  if (arg) {
    arg = arg->p_sibling;
  }

  while (arg) {
    count++;
    arg = arg->p_sibling;
  }
  return count;
}

/**
 * @brief Infer function call type and check target/arity validity.
 * @param call_node function call AST node.
 * @param state pass2 execution state.
 * @return inferred return type on success; invalid singleton on failure.
 */
static const type_t *infer_call_type(TreeNode_t *call_node, pass2_state_t *state)
{
  TreeNode_t *callee_expr;
  const type_t *callee_type;
  size_t provided_arity;
  TreeNode_t *arg;
  size_t arg_index = 0u; 

  if (!call_node) {
    pass2_emit(state, "SEM040", call_node ? call_node->lineNumber : 0u, "call target must be a function");
    return &g_type_invalid;
  }

  callee_expr = call_node->p_firstChild;
  if (!callee_expr) {
    pass2_emit(state, "SEM040", call_node->lineNumber, "call target must be a function");
    return &g_type_invalid;
  }

  callee_type = infer_expr_type(callee_expr, state);
  if (!callee_type || callee_type->kind == TYPE_INVALID) {
    return &g_type_invalid;
  }

  if (callee_type->kind == TYPE_POINTER &&
      callee_type->as.pointer.base &&
      callee_type->as.pointer.base->kind == TYPE_FUNCTION) {
    callee_type = callee_type->as.pointer.base;
  }

  if (callee_type->kind != TYPE_FUNCTION) {
    pass2_emit(state, "SEM040", call_node->lineNumber, "call target must be a function");
    return &g_type_invalid;
  }

  
  provided_arity = count_call_arguments(call_node);
  if (!callee_type->as.function.is_variadic &&
    provided_arity != callee_type->as.function.param_count) {
      pass2_emit(state, "SEM041", call_node->lineNumber, "function call argument count mismatch");
    }
    
    
  arg = callee_expr->p_sibling;
  while (arg) {
    const type_t *arg_type = infer_expr_type(arg, state);
    
    if (arg_type->kind != TYPE_INVALID && 
        arg_index < callee_type->as.function.param_count)
    {
      const type_t *param_type = callee_type->as.function.params[arg_index]; 

      if (param_type &&
          param_type->kind != TYPE_INVALID &&
          !argument_compatible(param_type, arg_type)) {
        pass2_emit(state, "SEM042", arg->lineNumber, "function call argument type mismatch");
      }
    }

    arg_index++; 
    arg = arg->p_sibling; 
  }

  return callee_type->as.function.return_type 
          ? callee_type->as.function.return_type 
          : &g_type_void;
}

/**
 * @brief Infer operator expression type and apply selected operator checks.
 * @param op_node operator AST node.
 * @param state pass2 execution state.
 * @return inferred expression type.
 */
static const type_t *infer_operator_type(TreeNode_t *op_node, pass2_state_t *state)
{
  TreeNode_t *lhs = NULL;
  TreeNode_t *rhs = NULL;
  const type_t *lhs_type = &g_type_invalid;
  const type_t *rhs_type = &g_type_invalid;
  long op_kind;

  if (!op_node) {
    return &g_type_invalid;
  }

  lhs = op_node->p_firstChild;
  rhs = lhs ? lhs->p_sibling : NULL;
  op_kind = op_node->nodeData.dVal;

  if (lhs) {
    lhs_type = infer_expr_type(lhs, state);
  }
  if (rhs) {
    rhs_type = infer_expr_type(rhs, state);
  }

  /* SEM022: Division or modulus by zero in constant expression */
  if(op_kind == OP_DIVIDE || op_kind == OP_MODULE || op_kind == OP_DIVIDE_ASSIGN || op_kind == OP_MODULUS_ASSIGN) {   //Check if the operator is division or modulus (including assignment variants)
    if(is_constant_zero(rhs)) {                                                                                       //Check if the right-hand side is a constant zero expression
      pass2_emit(state, "SEM022", op_node->lineNumber, "Division or module by zero in constant expression");
      return &g_type_invalid;
    }
  }
if (op_kind == OP_ASSIGN) {
    if (lhs_type->kind != TYPE_INVALID && rhs_type->kind != TYPE_INVALID) {
      /* SEM011: Assignment type mismatch - special handling for array initialization */
        if (lhs_type->kind == TYPE_ARRAY) {
          const type_t *elem_type = lhs_type->as.array.elem;
            /* For array initialization, we allow the RHS to be a NODE_NULL with children representing initializer elements.
               We need to validate each child against the array element type. */
            TreeNode_t *child = rhs; 
            int all_valid = 1;

            while (child) {
                const type_t *child_type = infer_expr_type(child, state);
                
                if (child_type->kind != TYPE_INVALID && !assignment_compatible(elem_type, child_type)) {
                    pass2_emit(state, "SEM011", child->lineNumber, "Type mismatch in aggregate initialization element");
                    all_valid = 0;
                }
                
                child = child->p_sibling;
            }            
            return all_valid ? lhs_type : &g_type_invalid;
        }
            


        if (!pass2_is_lvalue_kind(pass2_get_node_info(state, lhs))) {
            pass2_emit(state, "SEM027", op_node->lineNumber, "LHS of assignment must be a modifiable lvalue");
        } else if (!pass2_is_modifiable_lvalue(lhs, state, lhs_type)) {
            if (lhs->nodeType == NODE_IDENTIFIER && lhs->nodeData.sVal) {
                scope_t *scope = scope_current(&state->ctx->scope_stack);
                symbol_t *sym = symbol_lookup_visible(scope, lhs->nodeData.sVal);
                
                // If the symbol exists and the assignment is not on the declaration line, it's an error
                if (sym && sym->decl_line != op_node->lineNumber) {
                    // Trigger SEM008: Assignment to a constant object
                    pass2_emit(state, "SEM008", op_node->lineNumber, "Assignment to an object qualified as const");
                }
            } else {
                // For other lvalue types (like pointer dereferences) that are const
                pass2_emit(state, "SEM008", op_node->lineNumber, "Assignment to an object qualified as const");
            }
        }

        // These are checked independently of the errors above
        if (warns_on_narrowing_assignment(lhs_type, rhs_type, rhs)) {
            pass2_warning(state, "SEMW001", op_node->lineNumber, "implicit narrowing conversion");
        }
        if (warns_on_signed_to_unsigned_assignment(lhs_type, rhs_type, rhs)) {
            pass2_warning(state, "SEMW002", op_node->lineNumber, "implicit signed to unsigned conversion");
        }

        //TYPE COMPATIBILITY CHECKS

        // SEM010: Implicit removal of const in pointer assignment
        if (lhs_type->kind == TYPE_POINTER && rhs_type->kind == TYPE_POINTER &&
            !(lhs_type->as.pointer.base->qualifiers & TYPE_QUAL_CONST) &&
            (rhs_type->as.pointer.base->qualifiers & TYPE_QUAL_CONST)) {
            pass2_emit(state, "SEM010", op_node->lineNumber, "Implicit removal of the const qualifier in pointer assignment");
        }
        // SEM012: Pointer <-> Integer conversion
        else if ((lhs_type->kind == TYPE_POINTER && rhs_type->kind == TYPE_BUILTIN && is_integral_builtin(rhs_type->as.builtin)) ||
                 (lhs_type->kind == TYPE_BUILTIN && is_integral_builtin(lhs_type->as.builtin) && rhs_type->kind == TYPE_POINTER)) {
            pass2_emit(state, "SEM012", op_node->lineNumber, "Implicit conversion between pointer and integer not allowed");
        }
        // SEM013: Incompatible pointer types
        else if (lhs_type->kind == TYPE_POINTER && rhs_type->kind == TYPE_POINTER) {
            const type_t *l_base = lhs_type->as.pointer.base;
            const type_t *r_base = rhs_type->as.pointer.base;
            if (l_base->kind != r_base->kind || 
               (l_base->kind == TYPE_BUILTIN && l_base->as.builtin != r_base->as.builtin)) {
                pass2_emit(state, "SEM013", op_node->lineNumber, "Assignment between incompatible pointer types");
            }
        }
        // SEM014: Struct/Union identical type requirement
        else if ((lhs_type->kind == TYPE_STRUCT_TAG || lhs_type->kind == TYPE_UNION_TAG) &&
                 !type_equal(lhs_type, rhs_type)) {
            pass2_emit(state, "SEM014", op_node->lineNumber, "Assignment between struct/union requires identical types");
        }
        // SEM011: General type mismatch fallback
        else if (!assignment_compatible(lhs_type, rhs_type)) {
            pass2_emit(state, "SEM011", op_node->lineNumber, "Assignment type mismatch");
        }
    }
    return lhs_type;
}
/*SEM020: ARITHMETIC OPERATORS*/
  if (op_kind == OP_PLUS ||
      op_kind == OP_MINUS ||
      op_kind == OP_MULTIPLY ||
      op_kind == OP_DIVIDE ) {

    //1. Abort if any applicable type is already invalid
    if (!type_is_numeric(lhs_type) || !type_is_numeric(rhs_type)) {
      pass2_emit(state, "SEM020", op_node->lineNumber, "Arithmetic operators require arithmetic operands");
      return &g_type_invalid;
    }
    //2. If both sides are numeric, apply usual arithmetic conversions to determine the resulting type
    if (lhs_type->kind == TYPE_BUILTIN && rhs_type->kind == TYPE_BUILTIN) {
      if (warns_on_mixed_signed_unsigned_operands(lhs_type, rhs_type)) {
        pass2_warning(state, "SEMW002", op_node->lineNumber, "mixed signed and unsigned arithmetic");
      }
      if (lhs_type->as.builtin == BUILTIN_DOUBLE || rhs_type->as.builtin == BUILTIN_DOUBLE) {
        return &g_type_double;
      }
      // If either side is float (but not double), the result is float
      if (lhs_type->as.builtin == BUILTIN_FLOAT || rhs_type->as.builtin == BUILTIN_FLOAT) {
        return &g_type_float;
      }
    }
    return &g_type_int;
  }

   else if (op_kind == OP_MODULE) {
    if (lhs_type->kind == TYPE_INVALID || rhs_type->kind == TYPE_INVALID) {
      return &g_type_invalid;
    }

    /* SEM021: Module only allows integral types (int, char, etc.) */
    if (!type_is_integral(lhs_type) || !type_is_integral(rhs_type)) {
      pass2_emit(state, "SEM021", op_node->lineNumber, "Operator '%' only for integral operands");
      return &g_type_invalid;
    }
    return &g_type_int;
  }

  if (op_kind == OP_PLUS_ASSIGN ||
      op_kind == OP_MINUS_ASSIGN ||
      op_kind == OP_MULTIPLY_ASSIGN ||
      op_kind == OP_DIVIDE_ASSIGN ||
      op_kind == OP_MODULUS_ASSIGN ||
      op_kind == OP_LEFT_SHIFT_ASSIGN ||
      op_kind == OP_RIGHT_SHIFT_ASSIGN ||
      op_kind == OP_BITWISE_AND_ASSIGN ||
      op_kind == OP_BITWISE_OR_ASSIGN ||
      op_kind == OP_BITWISE_XOR_ASSIGN) {
    if (lhs_type->kind != TYPE_INVALID &&
        rhs_type->kind != TYPE_INVALID &&
        !assignment_compatible(lhs_type, rhs_type)) {
      pass2_emit(state, "SEM011", op_node->lineNumber, "assignment type mismatch"); // perhaps add a warning/error for float to integer implicit conversion? 
    }
    return lhs_type;
  }


// SEM023: BITWISE OPERATORS (<<, >>, &, |, ^, ~)
  if (op_kind == OP_LEFT_SHIFT || op_kind == OP_RIGHT_SHIFT ||
      op_kind == OP_BITWISE_AND || op_kind == OP_BITWISE_OR ||
      op_kind == OP_BITWISE_XOR || op_kind == OP_BITWISE_NOT) {
    
    // Check lhs, and ONLY check rhs if it's a binary operator
    if (!type_is_integral(lhs_type) || (op_kind != OP_BITWISE_NOT && !type_is_integral(rhs_type))) {
      pass2_emit(state, "SEM023", op_node->lineNumber, "Bitwise operators require integral operands");
      return &g_type_invalid;
    }
    if ((op_kind == OP_BITWISE_AND ||
         op_kind == OP_BITWISE_OR ||
         op_kind == OP_BITWISE_XOR) &&
        warns_on_mixed_signed_unsigned_operands(lhs_type, rhs_type)) {
      pass2_warning(state, "SEMW002", op_node->lineNumber, "mixed signed and unsigned integral operation");
    }
    return lhs_type;
  }

  /* SEM025: COMPARISON OPERATORS (==, !=, <, >, <=, >=) */
  if (op_kind == OP_EQUAL || op_kind == OP_NOT_EQUAL || 
    op_kind == OP_LESS_THAN || op_kind == OP_GREATER_THAN || 
    op_kind == OP_LESS_THAN_OR_EQUAL || op_kind == OP_GREATER_THAN_OR_EQUAL) {

    // Abort if types are already invalid
    if (lhs_type->kind == TYPE_INVALID || rhs_type->kind == TYPE_INVALID) {
        return &g_type_invalid;
    }

    // SEM025: Check if types are compatible for comparison (e.g., int vs int, ptr vs ptr)
    if (!is_comparison_compatible(lhs_type, rhs_type)) {  
        pass2_emit(state, "SEM025", op_node->lineNumber, "Incompatible types for comparison operator");
        return &g_type_invalid;
    }

    // SEMW002: Warning for mixed signed/unsigned comparison
    if (warns_on_mixed_signed_unsigned_operands(lhs_type, rhs_type)) {
        pass2_warning(state, "SEMW002", op_node->lineNumber, "mixed signed and unsigned comparison");
    }

    return &g_type_int;
  }
  // SEM024: LOGICAL OPERATORS (&&, ||, !)
  if (op_kind == OP_LOGICAL_AND || op_kind == OP_LOGICAL_OR || op_kind == OP_LOGICAL_NOT) {
    
    // 1. Abort if any applicable type is already invalid
    if (lhs_type->kind == TYPE_INVALID || (op_kind != OP_LOGICAL_NOT && rhs_type->kind == TYPE_INVALID)) {
      return &g_type_invalid;
    }
    
    // 2. SEM024: Both sides (if applicable) must be scalar
    if (!type_is_scalar(lhs_type) || (op_kind != OP_LOGICAL_NOT && !type_is_scalar(rhs_type))) {
      pass2_emit(state, "SEM024", op_node->lineNumber, "Logical operators require scalar operands");
      return &g_type_invalid;
    }
    
    return &g_type_int;
  }

  if (op_kind == OP_UNARY_MINUS) {
    if (!type_is_numeric(lhs_type)) {
      return &g_type_invalid;
    }
    return lhs_type;
  }

  if (op_kind == OP_SIZEOF) {
    return &g_type_int;
  }

  if (op_kind == OP_COMMA) {
    return rhs_type;
  }

  return lhs_type;
}

/**
 * @brief Infer expression type recursively for the subset C
 * @param node expression AST node.
 * @param state pass2 execution state.
 * @return inferred expression type or invalid singleton if unknown/illegal.
 */
static const type_t *infer_expr_type(TreeNode_t *node, pass2_state_t *state)
{
  const sem_node_info_t *cached;

  if (!node || !state) {
    return &g_type_invalid;
  }

  cached = pass2_get_node_info(state, node);
  if (cached && (cached->flags & SEM_NODE_TYPED) != 0u && cached->type) {
    return cached->type;
  }

  switch (node->nodeType) {
    case NODE_CHAR:
      return pass2_cache_expr(state, node, &g_type_char, NULL, SEM_VALUE_RVALUE, SEM_NODE_CONST_EXPR);
    case NODE_INTEGER:
      return pass2_cache_expr(state, node, &g_type_int, NULL, SEM_VALUE_RVALUE, SEM_NODE_CONST_EXPR);
    case NODE_FLOAT:
      return pass2_cache_expr(state, node, &g_type_double, NULL, SEM_VALUE_RVALUE, SEM_NODE_CONST_EXPR);
    case NODE_STRING:
      return pass2_cache_expr(state, node, &g_type_string, NULL, SEM_VALUE_ADDRESS, SEM_NODE_CONST_EXPR | SEM_NODE_ADDR_TAKEN);
    case NODE_IDENTIFIER:
      if (node->p_firstChild) {
        return infer_expr_type(node->p_firstChild, state);
      }
      if (node->nodeData.sVal) {
        symbol_t *symbol = lookup_identifier_symbol(node->nodeData.sVal, node->lineNumber, state);
        if (!symbol || !symbol->type) {
          pass2_emit(state, "SEM001", node->lineNumber, "unknown identifier");
          return &g_type_invalid;
        }
        return pass2_cache_expr(state,
                                node,
                                symbol->type,
                                symbol,
                                pass2_decl_value_kind(symbol->kind),
                                symbol->kind == SYMBOL_ENUM_CONST ? SEM_NODE_CONST_EXPR : 0u);
      }
      return &g_type_invalid;
    case NODE_FUNCTION_CALL:
      state->result.expression_count++;
      {
        const type_t *call_type = infer_call_type(node, state);
        symbol_t *callee_symbol = NULL;
        unsigned call_extra = 0u;
        TreeNode_t *callee_expr = node->p_firstChild;
        const sem_node_info_t *callee_info = callee_expr
            ? pass2_get_node_info(state, callee_expr) : NULL;
        if (callee_info) {
          callee_symbol = callee_info->symbol;
          if (callee_symbol && callee_symbol->type &&
              callee_symbol->type->kind == TYPE_FUNCTION &&
              callee_symbol->type->as.function.is_variadic) {
            call_extra |= SEM_NODE_CODEGEN_BLOCKED;
          }
        }
        return pass2_cache_expr(state, node, call_type, callee_symbol,
                                SEM_VALUE_RVALUE, call_extra);
      }
    case NODE_OPERATOR:
      state->result.expression_count++;
      return pass2_cache_expr(state, node, infer_operator_type(node, state), NULL, SEM_VALUE_RVALUE, 0u);
    case NODE_ARRAY_ACCESS:
      if (node->p_firstChild) {
        const type_t *base = infer_expr_type(node->p_firstChild, state);
        const TreeNode_t *index_expr = node->p_firstChild->p_sibling;
        
        if (index_expr) {
          /* 1. Save the returned type */
          const type_t *index_type = infer_expr_type((TreeNode_t *)index_expr, state);
          
          /* 2. SEM031: Error if the index is not an integer */
          if (index_type->kind != TYPE_INVALID && !type_is_integral(index_type)) {
            pass2_emit(state, "SEM031", node->lineNumber, "Array index must be integral");
          }
          }

          /* 3. SEM032: Check if the base is actually an array or a pointer */
        if (base->kind != TYPE_INVALID && base->kind != TYPE_ARRAY && base->kind != TYPE_POINTER) {
          pass2_emit(state, "SEM032", node->lineNumber, "Base of [] access must be an array or pointer");
        }

        /* 4. Return the underlying type if it's valid */
        if (base->kind == TYPE_ARRAY && base->as.array.elem) {
          return pass2_cache_expr(state, node, base->as.array.elem, NULL, SEM_VALUE_LVALUE, 0u);
        }
        if (base->kind == TYPE_POINTER && base->as.pointer.base) {
          return pass2_cache_expr(state, node, base->as.pointer.base, NULL, SEM_VALUE_LVALUE, 0u);
        }
      }
      return &g_type_invalid;
    case NODE_REFERENCE:
      if (node->p_firstChild) {
        const type_t *base_type = infer_expr_type(node->p_firstChild, state);
        const type_t *ref_type;

        if (base_type->kind == TYPE_INVALID) {
          return &g_type_invalid;
        }
        /* SEM029: The operand of the address-of operator must be a modifiable lvalue (identifier, array access, pointer content, or member access) */
        if (!( node->p_firstChild->nodeType == NODE_IDENTIFIER ||
              node->p_firstChild->nodeType == NODE_ARRAY_ACCESS ||
              node->p_firstChild->nodeType == NODE_POINTER_CONTENT ||
              node->p_firstChild->nodeType == NODE_MEMBER_ACCESS ||
              node->p_firstChild->nodeType == NODE_PTR_MEMBER_ACCESS ))   //Check if the operand is an identifier, array access, pointer content, or member access
              {
            pass2_emit(state, "SEM029", node->lineNumber, "Address-of operator requires lvalue operand"); //Operator '&'
            return &g_type_invalid;
          }

        ref_type = type_new_pointer(&state->ctx->type_context, base_type, 0u);
        if (!ref_type) {
          pass2_emit(state, "SEM900", node->lineNumber, "failed to build reference type");
          return &g_type_invalid;
        }

        return pass2_cache_expr(state, node, ref_type, NULL, SEM_VALUE_ADDRESS, SEM_NODE_ADDR_TAKEN);
      }
      return &g_type_invalid;
    case NODE_POINTER_CONTENT:
      if (node->p_firstChild) {
        const type_t *ptr_type = infer_expr_type(node->p_firstChild, state);
        if (ptr_type->kind == TYPE_INVALID) {
            return &g_type_invalid;
        }
        if (ptr_type->kind == TYPE_POINTER && ptr_type->as.pointer.base) {
          return pass2_cache_expr(state, node, ptr_type->as.pointer.base, NULL, SEM_VALUE_LVALUE, 0u);
        }
        else if(ptr_type->kind != TYPE_POINTER){
          pass2_emit(state, "SEM030", node->lineNumber, "The operator * requires an operand of type pointer.");
        }
      }
      return &g_type_invalid;
    case NODE_TYPE_CAST:
      if (node->p_firstChild) {
        unsigned qualifiers = semantic_ast_collect_qualifiers_from_chain(node->p_firstChild);
        const type_t *cast_type = semantic_ast_build_type_from_type_node(&state->ctx->type_context, node->p_firstChild, qualifiers);
        const type_t *source_type = &g_type_invalid;
        if (node->p_firstChild->p_sibling) {
          source_type = infer_expr_type(node->p_firstChild->p_sibling, state);
        }
        if (!cast_type) {
          pass2_emit(state, "SEM900", node->lineNumber, "failed to build cast target type");
          return &g_type_invalid;
        }
        if (source_type->kind != TYPE_INVALID &&
            cast_involves_incomplete_aggregate(cast_type, source_type)) {
          pass2_emit(state, "SEM015", node->lineNumber,
                     "cast involving incomplete struct/union type");
        }
        if (source_type->kind != TYPE_INVALID &&
            cast_between_pointer_and_floating(cast_type, source_type)) {
          pass2_emit(state, "SEM016", node->lineNumber,
                     "pointer to floating cast is forbidden in strict mode");
        }
        if (source_type->kind != TYPE_INVALID &&
            warns_on_const_dropping_cast(cast_type, source_type)) {
          pass2_warning(state, "SEMW003", node->lineNumber, "explicit cast removes const qualifier");
        }
        return pass2_cache_expr(state, node, cast_type, NULL, SEM_VALUE_RVALUE, 0u);
      }
      return &g_type_invalid;
    case NODE_POST_INC:
    case NODE_PRE_INC:
    case NODE_POST_DEC:
    case NODE_PRE_DEC:
      if (node->p_firstChild) {
        const type_t *operand_type = infer_expr_type(node->p_firstChild, state);
        if (operand_type->kind != TYPE_INVALID) {
          if (!pass2_is_lvalue_kind(pass2_get_node_info(state, node->p_firstChild))) {
            pass2_emit(state, "SEM028", node->lineNumber, "Increment/decrement requires modifiable lvalue");
          } else if ((operand_type->qualifiers & TYPE_QUAL_CONST) != 0u) {
            pass2_emit(state, "SEM009", node->lineNumber, "Increment/decrement of a const object");
          }
          return pass2_cache_expr(state, node, operand_type, NULL, SEM_VALUE_RVALUE, 0u);
        }
        return &g_type_invalid;
      }
      return &g_type_invalid;
        
    /*SEM026: TERNARY OPERATOR compatibility check*/
    case NODE_TERNARY:
      if (node->p_firstChild) {
        const type_t *cond_type;
        const type_t *true_type;
        const type_t *false_type;

        cond_type = infer_expr_type(node->p_firstChild, state);
        true_type = infer_expr_type(node->p_firstChild->p_sibling, state);
        false_type = infer_expr_type(node->p_firstChild->p_sibling ?
                                     node->p_firstChild->p_sibling->p_sibling : NULL,
                                     state);

        // 1. SEM026: If any type is invalid, return invalid without emitting to avoid cascading errors
        if (cond_type->kind == TYPE_INVALID || true_type->kind == TYPE_INVALID || false_type->kind == TYPE_INVALID) {
          return &g_type_invalid;
        }
        //If the true and false types are compatible, return the more general type (e.g., int for char vs int)
        if (assignment_compatible(true_type, false_type)) {
          return pass2_cache_expr(state, node, true_type, NULL, SEM_VALUE_RVALUE, 0u);
        }
        if (assignment_compatible(false_type, true_type)) {
          return pass2_cache_expr(state, node, false_type, NULL, SEM_VALUE_RVALUE, 0u);
        }
        // 2. SEM026: If neither is compatible with the other, emit error and return invalid
        pass2_emit(state, "SEM026", node->lineNumber, "Incompatible types in ternary operator");
      }
      return &g_type_invalid;
    case NODE_MEMBER_ACCESS:
      state->result.expression_count++;
      return infer_member_access_type(node, state, 0);
    case NODE_PTR_MEMBER_ACCESS:
      state->result.expression_count++;
      return infer_member_access_type(node, state, 1);
    default:
      if (node->p_firstChild) {
        return infer_expr_type(node->p_firstChild, state);
      }
      return &g_type_invalid;
  }
}

/**
 * @brief Register local declaration into current non-global scope for pass2 lookups.
 * @param decl_node declaration node.
 * @param state pass2 execution state.
 * @param kind symbol kind to register.
 */
static void register_local_decl(TreeNode_t *decl_node, pass2_state_t *state, symbol_kind_t kind)
{
  scope_t *scope;
  const type_t *decl_type;
  symbol_t *symbol;
  sem_node_info_t info;

  if (!decl_node || !decl_node->nodeData.sVal || !state) {
    return;
  }

  scope = scope_current(&state->ctx->scope_stack);
  if (!scope || scope->depth == 0u) {
    return;
  }

  symbol = symbol_lookup_current(scope, decl_node->nodeData.sVal);
  if (symbol) {
    info.type = symbol->type;
    info.symbol = symbol;
    info.value_kind = pass2_decl_value_kind(kind);
    info.flags = symbol->type ? SEM_NODE_TYPED : 0u;
    (void)semantic_set_node_info(state->ctx, decl_node, &info);
    return;
  }

  decl_type = semantic_ast_build_type_from_declaration(&state->ctx->type_context, decl_node);
  if (!decl_type) {
    pass2_emit(state, "SEM900", decl_node->lineNumber, "failed to build declaration type");
    return;
  }

  symbol = symbol_new(&state->ctx->persistent_arena, decl_node->nodeData.sVal, kind, decl_type, decl_node->lineNumber, 0u);
  if (!symbol) {
    type_free(decl_type);
    pass2_emit(state, "SEM900", decl_node->lineNumber, "failed to allocate symbol");
    return;
  }

  if (symbol_insert(scope, symbol) < 0) {
    symbol_free(symbol);
    return;
  }

  /* Mirror pass1 register_symbol: set IR locality hint on the new symbol.
     register_local_decl is only called inside functions (scope->depth > 0). */
  if (kind == SYMBOL_PARAMETER) {
    symbol->memory_class = MEMORY_CLASS_PARAMETER;
  } else if (kind == SYMBOL_OBJECT) {
    symbol->memory_class = MEMORY_CLASS_STACK;
  }

  info.type = symbol->type;
  info.symbol = symbol;
  info.value_kind = pass2_decl_value_kind(kind);
  info.flags = symbol->type ? SEM_NODE_TYPED : 0u;
  (void)semantic_set_node_info(state->ctx, decl_node, &info);
}

static int walk_pass2(TreeNode_t *node, pass2_state_t *state);

/**
 * @brief Process one function node during pass2 with return-type context tracking.
 * @param fn_node function AST node.
 * @param state pass2 execution state.
 * @return 0 on success, negative errno-like value on fatal traversal error.
 */
static int handle_function_node(TreeNode_t *fn_node, pass2_state_t *state)
{
  const TreeNode_t *preamble = NULL;
  const TreeNode_t *param_head = NULL;
  const TreeNode_t *body = NULL;
  const TreeNode_t *it;
  scope_t *current_scope;
  symbol_t *fn_symbol = NULL;
  const type_t *prev_return_type;
  int prev_in_function;

  semantic_ast_split_function_children(fn_node, &preamble, &param_head, &body);
  (void)preamble;

  current_scope = scope_current(&state->ctx->scope_stack);
  if (current_scope && fn_node->nodeData.sVal) {
    fn_symbol = symbol_lookup_visible(current_scope, fn_node->nodeData.sVal);
  }

  prev_return_type = state->current_return_type;
  prev_in_function = state->in_function;
  state->in_function = 1;
  state->current_return_type =
      (fn_symbol && fn_symbol->type && fn_symbol->type->kind == TYPE_FUNCTION)
          ? fn_symbol->type->as.function.return_type
          : &g_type_invalid;

  if (scope_push(&state->ctx->scope_stack) < 0) {
    pass2_emit(state, "SEM900", fn_node->lineNumber, "failed to enter function scope");
    state->current_return_type = prev_return_type;
    state->in_function = prev_in_function;
    return -EINVAL;
  }

  it = param_head;
  while (it && semantic_ast_is_param_node(it)) {
    if ((it->nodeType == NODE_VAR_DECLARATION || it->nodeType == NODE_ARRAY_DECLARATION) &&
        it->nodeData.sVal) {
      register_local_decl((TreeNode_t *)it, state, SYMBOL_PARAMETER);
    }
    it = it->p_sibling;
  }

  if (body) {
    int rc = walk_pass2((TreeNode_t *)body, state);
    if (rc < 0) {
      return rc;
    }
  }

  if (body &&
      state->current_return_type &&
      state->current_return_type->kind != TYPE_INVALID &&
      !type_is_void(state->current_return_type) &&
      !statement_guarantees_return(body)) {
    pass2_emit(state, "SEM045", fn_node->lineNumber,
               "non-void function may reach end without returning a value");
  }

  if (scope_pop(&state->ctx->scope_stack) < 0) 
  {
    pass2_emit(state, "SEM901", fn_node->lineNumber, "scope stack underflow while leaving function scope");
    return -EINVAL;
  }

  sem_arena_reset(&state->ctx->scratch_arena);
  state->current_return_type = prev_return_type;
  state->in_function = prev_in_function;
  return 0;
}

/**
 * @brief Recursive pass2 traversal over AST siblings/children.
 * @param node first node in traversal chain.
 * @param state pass2 execution state.
 * @return 0 on success, negative errno-like value on fatal traversal error.
 */
static int walk_pass2(TreeNode_t *node, pass2_state_t *state)
{
  TreeNode_t *it = node;

  while (it) {
    if (it->nodeType == NODE_BLOCK) {
      int rc;

      if (scope_push(&state->ctx->scope_stack) < 0) {
        pass2_emit(state, "SEM900", it->lineNumber, "failed to enter lexical block scope");
        return -EINVAL;
      }

      if (it->p_firstChild) {
        rc = walk_pass2(it->p_firstChild, state);
        if (rc < 0) {
          return rc;
        }
      }

      if (scope_pop(&state->ctx->scope_stack) < 0) {
        pass2_emit(state, "SEM901", it->lineNumber, "scope stack underflow while leaving block scope");
        return -EINVAL;
      }

      it = it->p_sibling;
      continue;
    } else if (it->nodeType == NODE_FOR) {
      int rc;
      TreeNode_t *for_init;
      TreeNode_t *for_cond;
      TreeNode_t *for_step;
      TreeNode_t *for_body;

      if (scope_push(&state->ctx->scope_stack) < 0) {
        pass2_emit(state, "SEM900", it->lineNumber, "failed to enter for-loop scope");
        return -EINVAL;
      }

      for_init = it->p_firstChild;
      for_cond = for_init ? for_init->p_sibling : NULL;
      for_step = for_cond ? for_cond->p_sibling : NULL;
      for_body = for_step ? for_step->p_sibling : NULL;

      /* init: register declaration or evaluate expression. */
      if (for_init) {
        if (for_init->nodeType == NODE_VAR_DECLARATION ||
            for_init->nodeType == NODE_ARRAY_DECLARATION) {
          register_local_decl(for_init, state, SYMBOL_OBJECT);
          if (for_init->p_firstChild) {
            rc = walk_pass2(for_init->p_firstChild, state);
            if (rc < 0) {
              (void)scope_pop(&state->ctx->scope_stack);
              return rc;
            }
          }
        } else if (is_expression_node_type(for_init->nodeType)) {
          (void)infer_expr_type(for_init, state);
        } else if (for_init->p_firstChild) {
          rc = walk_pass2(for_init->p_firstChild, state);
          if (rc < 0) {
            (void)scope_pop(&state->ctx->scope_stack);
            return rc;
          }
        }
      }

      /* SEM052: for condition must be scalar. */
      if (for_cond) {
        const type_t *cond_type = infer_expr_type(for_cond, state);
        if (cond_type && cond_type->kind != TYPE_INVALID && !type_is_scalar(cond_type)) {
          pass2_emit(state, "SEM052", it->lineNumber, "control condition must be scalar");
        }
      }

      /* step: evaluate expression (runs after body, but type-checked here). */
      if (for_step) {
        if (is_expression_node_type(for_step->nodeType)) {
          (void)infer_expr_type(for_step, state);
        } else if (for_step->p_firstChild) {
          rc = walk_pass2(for_step->p_firstChild, state);
          if (rc < 0) {
            (void)scope_pop(&state->ctx->scope_stack);
            return rc;
          }
        }
      }

      /* body */
      state->loop_depth++;
      rc = for_body ? walk_pass2(for_body, state) : 0;
      state->loop_depth--;
      if (rc < 0) {
        (void)scope_pop(&state->ctx->scope_stack);
        return rc;
      }

      if (scope_pop(&state->ctx->scope_stack) < 0) {
        pass2_emit(state, "SEM901", it->lineNumber, "scope stack underflow while leaving for-loop scope");
        return -EINVAL;
      }

      it = it->p_sibling;
      continue;
    } else if (it->nodeType == NODE_FUNCTION) {
      int rc = handle_function_node(it, state);
      if (rc < 0) {
        return rc;
      }
      it = it->p_sibling;
      continue;
    } else if (it->nodeType == NODE_STRUCT_DECLARATION ||
               it->nodeType == NODE_UNION_DECLARATION ||
               it->nodeType == NODE_ENUM_DECLARATION) {
      /* Tags were fully registered in pass1; skip type-specifier children
         to avoid walking IDENTIFIER nodes inside member declarations. */
      it = it->p_sibling;
      continue;
    } else if (it->nodeType == NODE_WHILE) {
      int rc;
      TreeNode_t *w_cond = it->p_firstChild;
      TreeNode_t *w_body = w_cond ? w_cond->p_sibling : NULL;

      /* SEM052: while condition must be scalar; check before walking to avoid double-eval. */
      if (w_cond) {
        const type_t *cond_type = infer_expr_type(w_cond, state);
        if (cond_type && cond_type->kind != TYPE_INVALID && !type_is_scalar(cond_type)) {
          pass2_emit(state, "SEM052", it->lineNumber, "control condition must be scalar");
        }
      }

      state->loop_depth++;
      rc = w_body ? walk_pass2(w_body, state) : 0;
      state->loop_depth--;
      if (rc < 0) {
        return rc;
      }
      it = it->p_sibling;
      continue;
    } else if (it->nodeType == NODE_DO_WHILE) {
      int rc;
      TreeNode_t *dw_body = it->p_firstChild;
      TreeNode_t *dw_cond = dw_body ? dw_body->p_sibling : NULL;

      state->loop_depth++;
      rc = dw_body ? walk_pass2(dw_body, state) : 0;
      state->loop_depth--;
      if (rc < 0) {
        return rc;
      }

      /* SEM052: do-while condition must be scalar; checked after body walk. */
      if (dw_cond) {
        const type_t *cond_type = infer_expr_type(dw_cond, state);
        if (cond_type && cond_type->kind != TYPE_INVALID && !type_is_scalar(cond_type)) {
          pass2_emit(state, "SEM052", it->lineNumber, "control condition must be scalar");
        }
      }

      it = it->p_sibling;
      continue;
    } else if (it->nodeType == NODE_SWITCH) {
      int rc;
      TreeNode_t *sw_expr = it->p_firstChild;

      /* SEM053: switch expression must be integral or enum. */
      if (sw_expr) {
        const type_t *sw_type = infer_expr_type(sw_expr, state);
        if (sw_type && sw_type->kind != TYPE_INVALID &&
            !type_is_integral(sw_type) && sw_type->kind != TYPE_ENUM_TAG) {
          pass2_emit(state, "SEM053", it->lineNumber, "switch expression must be integral or enum");
        }
      }

      /* SEM055/SEM056: scan for duplicate case labels and multiple defaults. */
      rc = check_switch_labels(it, state);
      if (rc < 0) {
        return rc;
      }

      state->switch_depth++;
      rc = it->p_firstChild ? walk_pass2(it->p_firstChild, state) : 0;
      state->switch_depth--;
      if (rc < 0) {
        return rc;
      }
      it = it->p_sibling;
      continue;
    } else if (it->nodeType == NODE_IF) {
      int rc;
      TreeNode_t *if_cond    = it->p_firstChild;
      TreeNode_t *then_branch = if_cond    ? if_cond->p_sibling    : NULL;
      TreeNode_t *else_branch = then_branch ? then_branch->p_sibling : NULL;

      /* SEM052: if condition must be scalar. */
      if (if_cond) {
        const type_t *cond_type = infer_expr_type(if_cond, state);
        if (cond_type && cond_type->kind != TYPE_INVALID && !type_is_scalar(cond_type)) {
          pass2_emit(state, "SEM052", it->lineNumber, "control condition must be scalar");
        }
      }

      if (then_branch) {
        rc = walk_pass2(then_branch, state);
        if (rc < 0) {
          return rc;
        }
      }
      if (else_branch) {
        rc = walk_pass2(else_branch, state);
        if (rc < 0) {
          return rc;
        }
      }

      it = it->p_sibling;
      continue;
    } else if (it->nodeType == NODE_CASE || it->nodeType == NODE_DEFAULT) {
      /* Label values validated by check_switch_labels; just recurse into body. */
      TreeNode_t *body = (it->nodeType == NODE_CASE)
                             ? (TreeNode_t *)case_body_stmt(it)
                             : it->p_firstChild;
      if (body) {
        int rc = walk_pass2(body, state);
        if (rc < 0) {
          return rc;
        }
      }
      it = it->p_sibling;
      continue;
    } else if (it->nodeType == NODE_VAR_DECLARATION || it->nodeType == NODE_ARRAY_DECLARATION) {
      register_local_decl(it, state, SYMBOL_OBJECT);
      it = it->p_sibling;
      continue;
    } else if (it->nodeType == NODE_BREAK) {
      state->result.statement_count++;
      if (state->loop_depth == 0u && state->switch_depth == 0u) {
        pass2_emit(state, "SEM050", it->lineNumber, "break only valid inside loop or switch");
      }
      it = it->p_sibling;
      continue;
    } else if (it->nodeType == NODE_CONTINUE) {
      state->result.statement_count++;
      if (state->loop_depth == 0u) {
        pass2_emit(state, "SEM051", it->lineNumber, "continue only valid inside loop");
      }
      it = it->p_sibling;
      continue;
    } else if (it->nodeType == NODE_RETURN) {
      const type_t *ret_type = &g_type_void;
      state->result.statement_count++;

      /* SEM046: return statement must be inside a function body. */
      if (!state->in_function) {
        pass2_emit(state, "SEM046", it->lineNumber, "return statement outside of function");
        it = it->p_sibling;
        continue;
      }

      if (it->p_firstChild) {
        ret_type = infer_expr_type(it->p_firstChild, state);
      }

      if (state->in_function && state->current_return_type) {
        int is_void_func = type_is_void(state->current_return_type);

        /* SEM044: void function must not return a value. */
        if (is_void_func && it->p_firstChild) {
          pass2_emit(state, "SEM044", it->lineNumber, "return with value in void function");
        }
        /* SEM043: non-void return expression must be type-compatible. */
        else if (!is_void_func &&
                 state->current_return_type->kind != TYPE_INVALID &&
                 ret_type->kind != TYPE_INVALID &&
                 !assignment_compatible(state->current_return_type, ret_type)) {
          pass2_emit(state, "SEM043", it->lineNumber, "return type mismatch");
        }
      }

      it = it->p_sibling;
      continue;
    } else if (is_expression_node_type(it->nodeType)) {
      (void)infer_expr_type(it, state);
      it = it->p_sibling;
      continue;
    }

    if (it->p_firstChild) {
      int rc = walk_pass2(it->p_firstChild, state);
      if (rc < 0) {
        return rc;
      }
    }

    it = it->p_sibling;
  }

  return 0;
}

/**
 * @brief Run semantic pass2 (type/usage validation over pass1 bindings).
 * @param root AST root.
 * @param ctx shared semantic context.
 * @param out_result pass2 metrics output.
 * @return 0 on success, negative errno-like value on fatal setup/traversal error.
 */
int semantic_pass2_run(TreeNode_t *root, semantic_context_t *ctx, semantic_pass2_result_t *out_result)
{
  pass2_state_t state;
  int rc = 0;

  if (!ctx || !out_result) {
    return -EINVAL;
  }

  memset(&state, 0, sizeof(state));
  state.ctx = ctx;
  state.root = root;

  if (!scope_current(&ctx->scope_stack)) {
    if (scope_push(&ctx->scope_stack) < 0) {
      pass2_emit(&state, "SEM900", 0u, "failed to create global scope for pass2");
      *out_result = state.result;
      return -EINVAL;
    }
  }

  if (root) {
    rc = walk_pass2(root, &state);
    if (rc < 0) {
      *out_result = state.result;
      return rc;
    }
  }

  while (scope_current(&ctx->scope_stack) && scope_current(&ctx->scope_stack)->parent) {
    (void)scope_pop(&ctx->scope_stack);
  }

  sem_arena_reset(&ctx->scratch_arena);
  *out_result = state.result;
  return 0;
}

/*
 * Registo de checks semanticos - passe 2
 * NOTA:
 * MANTER A LISTA SINCRONIZADA COM
 * 1) docs da drive
 * 2) se virem que falta algum importante, avisar! e colocar aqui e no docs da drive!
 *
 * PASSE 2 - Tipos, expressoes, chamadas e controlo de fluxo
 * [ X ] SEM001 Identificador desconhecido deve resolver para simbolo visivel (implementado no fluxo de lookup do pass2)
 * [ X ] SEM008 Atribuicao a objeto qualificado como const
 * [ X ] SEM009 inc/dec em objeto qualificado como const
 * [ X ] SEM010 Remocao implicita de qualificador const em atribuicao de ponteiros
 * [ X ] SEM011 Compatibilidade de tipos em atribuicoes
 * [ X ] SEM012 Conversao implicita ponteiro <-> inteiro nao permitida
 * [ X ] SEM013 Atribuicao entre ponteiros de tipos incompativeis
 * [ X ] SEM014 Atribuicao entre struct/union exige tipos identicos
 * [ X ] SEM015 Cast envolvendo struct/union incompleta
 * [ X ] SEM016 Cast ponteiro <-> float proibido (modo estrito)
 * [ X ] SEM020 Operadores aritmeticos requerem operandos aritmeticos
 * [ X ] SEM021 '%' apenas para operandos integrais
 * [ X ] SEM022 Divisao/modulo por zero constante
 * [ X ] SEM023 Operadores bitwise requerem operandos integrais
 * [ X ] SEM024 Operadores logicos requerem operandos escalares
 * [ X ] SEM025 Compatibilidade de operandos em comparacoes
 * [ X ] SEM026 Compatibilidade dos ramos do operador ternario
 * [ X ] SEM027 LHS da atribuicao deve ser lvalue modificavel
 * [ X ] SEM028 inc/dec requer lvalue modificavel
 * [ X ] SEM029 '&' requer operando lvalue
 * [ X ] SEM030 '*' requer operando do tipo ponteiro
 * [ X ] SEM031 Indice de array deve ser integral
 * [ X ] SEM032 Base de [] deve ser array ou ponteiro
 * [ X ] SEM040 Alvo de chamada deve ser uma funcao
 * [ X ] SEM041 Numero de argumentos deve coincidir com a assinatura
 * [ X ] SEM042 Compatibilidade de tipos dos argumentos da chamada
 * [ X ] SEM043 Tipo da expressao return compativel com tipo da funcao
 * [ X ] SEM044 return com valor dentro de funcao void
 * [ X ] SEM045 Funcao nao-void sem return obrigatorio (analise conservadora de CFG)
 * [ X ] SEM046 return fora do contexto de funcao
 * [ X ] SEM050 break apenas valido dentro de loop ou switch
 * [ X ] SEM051 continue apenas valido dentro de loop
 * [ X ] SEM052 Condicao de controlo (if/while/for/do-while) deve ser escalar
 * [ X ] SEM053 Expressao de switch deve ser integral ou enum
 * [ X ] SEM054 Label case deve ser expressao constante integral
 * [ X ] SEM055 Label case duplicado no mesmo switch
 * [ X ] SEM056 Multiplos default no mesmo switch
 * [ X ] SEM060 Acesso a membro inexistente em struct/union
 * [ X ] SEM061 Operador '.' requer objeto struct/union
 * [ X ] SEM062 Operador '->' requer ponteiro para struct/union
 * [   ] SEM070 Limitacao backend: aritmetica com float nao suportada  <-- missing
 * [   ] SEM071 Limitacao backend: retorno de struct nao suportado  <-- missing
 * [   ] SEM072 Limitacao backend: chamadas variadicas nao suportadas  <-- missing
 * [ X ] SEMW001 Aviso: cast truncado / narrowing implicito
 * [ X ] SEMW002 Aviso: conversao suspeita signed/unsigned
 * [ X ] SEMW003 Aviso: cast explicito que remove const

 POSTPONED TO IR: 
  SEM070/71/72: estão relacionados com as capacidades do processador, para já tratamos apenas
  das regras semánticas da linguagem ISO C11 
 */
