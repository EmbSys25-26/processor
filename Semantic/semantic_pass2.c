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
  type_t **temporary_types;
  size_t temporary_type_count;
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

/** @brief Shared builtin type singleton for string literals. */
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

/**
 * @brief Free all temporary inferred types retained during pass2.
 * @param state pass2 execution state.
 */
static void release_temporary_types(pass2_state_t *state)
{
  size_t i;

  if (!state || !state->temporary_types) {
    return;
  }

  for (i = 0u; i < state->temporary_type_count; ++i) {
    type_free(state->temporary_types[i]);
  }

  free(state->temporary_types);
  state->temporary_types = NULL;
  state->temporary_type_count = 0u;
}

/**
 * @brief Store an inferred heap-allocated type for later cleanup.
 * @param state pass2 execution state.
 * @param type newly allocated type to retain.
 * @return retained type pointer on success; invalid singleton on failure.
 */
static const type_t *remember_temporary_type(pass2_state_t *state, type_t *type)
{
  type_t **new_types;

  if (!state || !type) {
    return &g_type_invalid;
  }

  new_types = (type_t **)realloc(state->temporary_types,
                                 (state->temporary_type_count + 1u) * sizeof(*state->temporary_types));
  if (!new_types) {
    type_free(type);
    pass2_emit(state, "SEM900", 0u, "failed to retain inferred temporary type");
    return &g_type_invalid;
  }

  state->temporary_types = new_types;
  state->temporary_types[state->temporary_type_count++] = type;
  return type;
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
 * @brief Check whether a builtin type belongs to numeric family.
 * @param builtin builtin type enum.
 * @return non-zero if numeric.
 */
static int is_numeric_builtin(builtin_type_t builtin)
{
  return is_integral_builtin(builtin) ||
         builtin == BUILTIN_FLOAT ||
         builtin == BUILTIN_DOUBLE ||
         builtin == BUILTIN_LONG_DOUBLE;
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
    if (is_integral_builtin(lhs->as.builtin) && is_integral_builtin(rhs->as.builtin)) {
      return 1;
    }
    return 0;
  }

  return 0;
}

static const type_t *infer_expr_type(TreeNode_t *node, pass2_state_t *state);

/**
 * @brief Compose canonical symbol key for a struct/union/enum tag.
 * @param kind tag type kind.
 * @param tag_name source tag identifier.
 * @param buffer output buffer receiving prefixed key.
 * @param buffer_size size of output buffer.
 * @return 0 on success, negative errno-like value on error.
 */
static int build_tag_symbol_name(type_kind_t kind,
                                 const char *tag_name,
                                 char *buffer,
                                 size_t buffer_size)
{
  const char *prefix;

  if (!tag_name || !buffer || buffer_size == 0u) {
    return -EINVAL;
  }

  switch (kind) {
    case TYPE_STRUCT_TAG:
      prefix = "struct:";
      break;
    case TYPE_UNION_TAG:
      prefix = "union:";
      break;
    case TYPE_ENUM_TAG:
      prefix = "enum:";
      break;
    default:
      return -EINVAL;
  }

  if ((size_t)snprintf(buffer, buffer_size, "%s%s", prefix, tag_name) >= buffer_size) {
    return -ENAMETOOLONG;
  }

  return 0;
}

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
 * @brief Register one aggregate tag declaration in the current scope.
 * @param decl_node aggregate declaration node.
 * @param state pass2 execution state.
 */
static void register_tag_declaration(TreeNode_t *decl_node, pass2_state_t *state)
{
  symbol_kind_t symbol_kind;
  type_kind_t type_kind;
  type_t *tag_type;
  symbol_t *symbol;
  scope_t *scope;
  char key[256];

  if (!decl_node || !decl_node->nodeData.sVal || !state) {
    return;
  }

  switch (decl_node->nodeType) {
    case NODE_STRUCT_DECLARATION:
      symbol_kind = SYMBOL_TAG_STRUCT;
      type_kind = TYPE_STRUCT_TAG;
      break;
    case NODE_UNION_DECLARATION:
      symbol_kind = SYMBOL_TAG_UNION;
      type_kind = TYPE_UNION_TAG;
      break;
    case NODE_ENUM_DECLARATION:
      symbol_kind = SYMBOL_TAG_ENUM;
      type_kind = TYPE_ENUM_TAG;
      break;
    default:
      return;
  }

  if (build_tag_symbol_name(type_kind, decl_node->nodeData.sVal, key, sizeof(key)) < 0) {
    pass2_emit(state, "SEM900", decl_node->lineNumber, "failed to build tag symbol key");
    return;
  }

  scope = scope_current(&state->ctx->scope_stack);
  if (!scope || symbol_lookup_current(scope, key)) {
    return;
  }

  tag_type = type_new_tagged(type_kind, decl_node->nodeData.sVal, 0u);
  if (!tag_type) {
    pass2_emit(state, "SEM900", decl_node->lineNumber, "failed to build tag type");
    return;
  }
  type_set_aggregate_decl(tag_type, decl_node);

  symbol = symbol_new(key, symbol_kind, tag_type, decl_node->lineNumber, 0u);
  if (!symbol) {
    type_free(tag_type);
    pass2_emit(state, "SEM900", decl_node->lineNumber, "failed to allocate tag symbol");
    return;
  }

  if (symbol_insert(scope, symbol) < 0) {
    symbol_free(symbol);
  }
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

/**
 * @brief Resolve member declaration type inside an aggregate declaration.
 * @param aggregate_decl struct/union declaration node.
 * @param member_name requested member name.
 * @param state pass2 execution state.
 * @return member type, NULL when member missing, or invalid singleton on fatal error.
 */
static const type_t *resolve_member_decl_type(const TreeNode_t *aggregate_decl,
                                              const char *member_name,
                                              pass2_state_t *state)
{
  const TreeNode_t *member;

  if (!aggregate_decl || !member_name || !state) {
    return &g_type_invalid;
  }

  member = aggregate_decl->p_firstChild;
  while (member) {
    if ((member->nodeType == NODE_STRUCT_MEMBER || member->nodeType == NODE_ARRAY_DECLARATION) &&
        member->nodeData.sVal &&
        strcmp(member->nodeData.sVal, member_name) == 0) {
      type_t *member_type = semantic_ast_build_type_from_declaration(member);
      if (!member_type) {
        pass2_emit(state, "SEM900", member->lineNumber, "failed to build member type");
        return &g_type_invalid;
      }
      return remember_temporary_type(state, member_type);
    }
    member = member->p_sibling;
  }

  return NULL;
}

/**
 * @brief Infer member access expression type for '.' and '->'.
 * @param node member access AST node.
 * @param state pass2 execution state.
 * @param via_pointer non-zero for '->', zero for '.'.
 * @return inferred member type or invalid singleton on failure.
 */
static const type_t *infer_member_access_type(TreeNode_t *node,
                                              pass2_state_t *state,
                                              int via_pointer)
{
  TreeNode_t *base_expr;
  TreeNode_t *field_ident;
  const type_t *base_type;
  const type_t *aggregate_type;
  const TreeNode_t *aggregate_decl;
  symbol_t *tag_symbol;
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

  base_type = infer_expr_type(base_expr, state);
  aggregate_type = base_type;
  semantic_code = via_pointer ? "SEM062" : "SEM061";
  semantic_message = via_pointer ? "operator '->' requires pointer to struct/union"
                                 : "operator '.' requires struct/union object";

  if (via_pointer) {
    if (!base_type || base_type->kind != TYPE_POINTER || !base_type->as.pointer.base) {
      pass2_emit(state, semantic_code, node->lineNumber, semantic_message);
      return &g_type_invalid;
    }
    aggregate_type = base_type->as.pointer.base;
  }

  if (!aggregate_type ||
      (aggregate_type->kind != TYPE_STRUCT_TAG && aggregate_type->kind != TYPE_UNION_TAG)) {
    pass2_emit(state, semantic_code, node->lineNumber, semantic_message);
    return &g_type_invalid;
  }

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
  if (!aggregate_decl) {
    pass2_emit(state, "SEM060", node->lineNumber, "aggregate member not found");
    return &g_type_invalid;
  }

  member_type = resolve_member_decl_type(aggregate_decl, member_name, state);
  if (!member_type) {
    pass2_emit(state, "SEM060", node->lineNumber, "aggregate member not found");
    return &g_type_invalid;
  }

  return member_type;
}

/**
 * @brief lookup identifier type through the currently visible scope chain.
 * @param name identifier name.
 * @param line source line for diagnostics.
 * @param state pass2 execution state.
 * @return type if found; invalid type singleton otherwise.
 */
static const type_t *lookup_identifier_type(const char *name, size_t line, pass2_state_t *state)
{
  scope_t *scope = scope_current(&state->ctx->scope_stack);
  symbol_t *symbol;

  if (!scope || !name) {
    pass2_emit(state, "SEM001", line, "unknown identifier");
    return &g_type_invalid;
  }

  symbol = symbol_lookup_visible(scope, name);
  if (!symbol) {
    pass2_emit(state, "SEM001", line, "unknown identifier");
    return &g_type_invalid;
  }

  if (!symbol->type) {
    return &g_type_invalid;
  }

  return symbol->type;
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

  arg = callee_expr->p_sibling;
  while (arg) {
    (void)infer_expr_type(arg, state);
    arg = arg->p_sibling;
  }

  provided_arity = count_call_arguments(call_node);
  if (!callee_type->as.function.is_variadic &&
      provided_arity != callee_type->as.function.param_count) {
    pass2_emit(state, "SEM041", call_node->lineNumber, "function call argument count mismatch");
  }

  return callee_type->as.function.return_type ? callee_type->as.function.return_type : &g_type_void;
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

  if (op_kind == OP_ASSIGN) {
    if (lhs_type->kind != TYPE_INVALID &&
        rhs_type->kind != TYPE_INVALID &&
        !assignment_compatible(lhs_type, rhs_type)) {
      pass2_emit(state, "SEM011", op_node->lineNumber, "assignment type mismatch");
    }
    return lhs_type;
  }

  if (op_kind == OP_PLUS ||
      op_kind == OP_MINUS ||
      op_kind == OP_MULTIPLY ||
      op_kind == OP_DIVIDE ||
      op_kind == OP_MODULE) {
    if (!type_is_numeric(lhs_type) || !type_is_numeric(rhs_type)) {
      return &g_type_invalid;
    }
    if (lhs_type->kind == TYPE_BUILTIN && rhs_type->kind == TYPE_BUILTIN) {
      if (lhs_type->as.builtin == BUILTIN_DOUBLE || rhs_type->as.builtin == BUILTIN_DOUBLE) {
        return &g_type_double;
      }
      if (lhs_type->as.builtin == BUILTIN_FLOAT || rhs_type->as.builtin == BUILTIN_FLOAT) {
        return &g_type_float;
      }
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
      pass2_emit(state, "SEM011", op_node->lineNumber, "assignment type mismatch");
    }
    return lhs_type;
  }

  if (op_kind == OP_LEFT_SHIFT ||
      op_kind == OP_RIGHT_SHIFT ||
      op_kind == OP_BITWISE_AND ||
      op_kind == OP_BITWISE_OR ||
      op_kind == OP_BITWISE_XOR) {
    if (!type_is_integral(lhs_type) || !type_is_integral(rhs_type)) {
      return &g_type_invalid;
    }
    return lhs_type;
  }

  if (op_kind == OP_EQUAL ||
      op_kind == OP_NOT_EQUAL ||
      op_kind == OP_LESS_THAN ||
      op_kind == OP_GREATER_THAN ||
      op_kind == OP_LESS_THAN_OR_EQUAL ||
      op_kind == OP_GREATER_THAN_OR_EQUAL ||
      op_kind == OP_LOGICAL_AND ||
      op_kind == OP_LOGICAL_OR) {
    if (lhs_type->kind == TYPE_INVALID || rhs_type->kind == TYPE_INVALID) {
      return &g_type_invalid;
    }
    return &g_type_int;
  }

  if (op_kind == OP_LOGICAL_NOT) {
    if (lhs_type->kind == TYPE_INVALID) {
      return &g_type_invalid;
    }
    return &g_type_int;
  }

  if (op_kind == OP_BITWISE_NOT) {
    if (!type_is_integral(lhs_type)) {
      return &g_type_invalid;
    }
    return lhs_type;
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
  if (!node || !state) {
    return &g_type_invalid;
  }

  switch (node->nodeType) {
    case NODE_INTEGER:
      return &g_type_int;
    case NODE_CHAR:
      return &g_type_char;
    case NODE_FLOAT:
      return &g_type_double;
    case NODE_STRING:
      return &g_type_string;
    case NODE_IDENTIFIER:
      if (node->p_firstChild) {
        return infer_expr_type(node->p_firstChild, state);
      }
      return lookup_identifier_type(node->nodeData.sVal, node->lineNumber, state);
    case NODE_FUNCTION_CALL:
      state->result.expression_count++;
      return infer_call_type(node, state);
    case NODE_OPERATOR:
      state->result.expression_count++;
      return infer_operator_type(node, state);
    case NODE_ARRAY_ACCESS:
      if (node->p_firstChild) {
        const type_t *base = infer_expr_type(node->p_firstChild, state);
        const TreeNode_t *index_expr = node->p_firstChild->p_sibling;
        if (index_expr) {
          (void)infer_expr_type((TreeNode_t *)index_expr, state);
        }
        if (base->kind == TYPE_ARRAY && base->as.array.elem) {
          return base->as.array.elem;
        }
        if (base->kind == TYPE_POINTER && base->as.pointer.base) {
          return base->as.pointer.base;
        }
      }
      return &g_type_invalid;
    case NODE_REFERENCE:
      if (node->p_firstChild) {
        const type_t *base_type = infer_expr_type(node->p_firstChild, state);
        type_t *base_copy;
        type_t *ref_type;

        if (base_type->kind == TYPE_INVALID) {
          return &g_type_invalid;
        }

        base_copy = type_clone(base_type);
        if (!base_copy) {
          pass2_emit(state, "SEM900", node->lineNumber, "failed to clone reference operand type");
          return &g_type_invalid;
        }

        ref_type = type_new_pointer(base_copy, 0u);
        if (!ref_type) {
          type_free(base_copy);
          pass2_emit(state, "SEM900", node->lineNumber, "failed to build reference type");
          return &g_type_invalid;
        }

        return remember_temporary_type(state, ref_type);
      }
      return &g_type_invalid;
    case NODE_POINTER_CONTENT:
      if (node->p_firstChild) {
        const type_t *ptr_type = infer_expr_type(node->p_firstChild, state);
        if (ptr_type->kind == TYPE_POINTER && ptr_type->as.pointer.base) {
          return ptr_type->as.pointer.base;
        }
      }
      return &g_type_invalid;
    case NODE_TYPE_CAST:
      if (node->p_firstChild) {
        unsigned qualifiers = semantic_ast_collect_qualifiers_from_chain(node->p_firstChild);
        type_t *cast_type = semantic_ast_build_type_from_type_node(node->p_firstChild, qualifiers);
        if (node->p_firstChild->p_sibling) {
          (void)infer_expr_type(node->p_firstChild->p_sibling, state);
        }
        if (!cast_type) {
          pass2_emit(state, "SEM900", node->lineNumber, "failed to build cast target type");
          return &g_type_invalid;
        }
        return remember_temporary_type(state, cast_type);
      }
      return &g_type_invalid;
    case NODE_POST_INC:
    case NODE_PRE_INC:
    case NODE_POST_DEC:
    case NODE_PRE_DEC:
      if (node->p_firstChild) {
        return infer_expr_type(node->p_firstChild, state);
      }
      return &g_type_invalid;
    case NODE_TERNARY:
      if (node->p_firstChild) {
        const type_t *true_type;
        const type_t *false_type;
        (void)infer_expr_type(node->p_firstChild, state);
        true_type = infer_expr_type(node->p_firstChild->p_sibling, state);
        false_type = infer_expr_type(node->p_firstChild->p_sibling ?
                                     node->p_firstChild->p_sibling->p_sibling : NULL,
                                     state);
        if (true_type->kind == TYPE_INVALID || false_type->kind == TYPE_INVALID) {
          return &g_type_invalid;
        }
        if (assignment_compatible(true_type, false_type)) {
          return true_type;
        }
        if (assignment_compatible(false_type, true_type)) {
          return false_type;
        }
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
  type_t *decl_type;
  symbol_t *symbol;

  if (!decl_node || !decl_node->nodeData.sVal || !state) {
    return;
  }

  scope = scope_current(&state->ctx->scope_stack);
  if (!scope || scope->depth == 0u) {
    return;
  }

  if (symbol_lookup_current(scope, decl_node->nodeData.sVal)) {
    return;
  }

  decl_type = semantic_ast_build_type_from_declaration(decl_node);
  if (!decl_type) {
    pass2_emit(state, "SEM900", decl_node->lineNumber, "failed to build declaration type");
    return;
  }

  symbol = symbol_new(decl_node->nodeData.sVal, kind, decl_type, decl_node->lineNumber, 0u);
  if (!symbol) {
    type_free(decl_type);
    pass2_emit(state, "SEM900", decl_node->lineNumber, "failed to allocate symbol");
    return;
  }

  if (symbol_insert(scope, symbol) < 0) {
    symbol_free(symbol);
  }
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

  if (scope_pop(&state->ctx->scope_stack) < 0) {
    pass2_emit(state, "SEM901", fn_node->lineNumber, "scope stack underflow while leaving function scope");
    return -EINVAL;
  }

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

      if (scope_push(&state->ctx->scope_stack) < 0) {
        pass2_emit(state, "SEM900", it->lineNumber, "failed to enter for-loop scope");
        return -EINVAL;
      }

      state->loop_depth++;

      if (it->p_firstChild) {
        rc = walk_pass2(it->p_firstChild, state);
        if (rc < 0) {
          state->loop_depth--;
          return rc;
        }
      }

      state->loop_depth--;

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
      register_tag_declaration(it, state);
    } else if (it->nodeType == NODE_WHILE || it->nodeType == NODE_DO_WHILE) {
      int rc;

      state->loop_depth++;
      rc = it->p_firstChild ? walk_pass2(it->p_firstChild, state) : 0;
      state->loop_depth--;
      if (rc < 0) {
        return rc;
      }
      it = it->p_sibling;
      continue;
    } else if (it->nodeType == NODE_SWITCH) {
      int rc;

      state->switch_depth++;
      rc = it->p_firstChild ? walk_pass2(it->p_firstChild, state) : 0;
      state->switch_depth--;
      if (rc < 0) {
        return rc;
      }
      it = it->p_sibling;
      continue;
    } else if (it->nodeType == NODE_VAR_DECLARATION || it->nodeType == NODE_ARRAY_DECLARATION) {
      register_local_decl(it, state, SYMBOL_OBJECT);
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
      if (it->p_firstChild) {
        ret_type = infer_expr_type(it->p_firstChild, state);
      }
      if (state->in_function && state->current_return_type &&
          state->current_return_type->kind != TYPE_INVALID &&
          ret_type->kind != TYPE_INVALID &&
          !assignment_compatible(state->current_return_type, ret_type)) {
        pass2_emit(state, "SEM043", it->lineNumber, "return type mismatch");
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
      release_temporary_types(&state);
      *out_result = state.result;
      return rc;
    }
  }

  while (scope_current(&ctx->scope_stack) && scope_current(&ctx->scope_stack)->parent) {
    (void)scope_pop(&ctx->scope_stack);
  }

  release_temporary_types(&state);
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
 * [x] SEM001 Identificador desconhecido deve resolver para simbolo visivel (implementado no fluxo de lookup do pass2)
 * [ ] SEM008 Atribuicao a objeto qualificado como const
 * [ ] SEM009 inc/dec em objeto qualificado como const
 * [ ] SEM010 Remocao implicita de qualificador const em atribuicao de ponteiros
 * [x] SEM011 Compatibilidade de tipos em atribuicoes
 * [ ] SEM012 Conversao implicita ponteiro <-> inteiro nao permitida
 * [ ] SEM013 Atribuicao entre ponteiros de tipos incompativeis
 * [ ] SEM014 Atribuicao entre struct/union exige tipos identicos
 * [ ] SEM015 Cast envolvendo struct/union incompleta
 * [ ] SEM016 Cast ponteiro <-> float proibido (modo estrito)
 * [ ] SEM020 Operadores aritmeticos requerem operandos aritmeticos
 * [ ] SEM021 '%' apenas para operandos integrais
 * [ ] SEM022 Divisao/modulo por zero constante
 * [ ] SEM023 Operadores bitwise requerem operandos integrais
 * [ ] SEM024 Operadores logicos requerem operandos escalares
 * [ ] SEM025 Compatibilidade de operandos em comparacoes
 * [ ] SEM026 Compatibilidade dos ramos do operador ternario
 * [ ] SEM027 LHS da atribuicao deve ser lvalue modificavel
 * [ ] SEM028 inc/dec requer lvalue modificavel
 * [ ] SEM029 '&' requer operando lvalue
 * [ ] SEM030 '*' requer operando do tipo ponteiro
 * [ ] SEM031 Indice de array deve ser integral
 * [ ] SEM032 Base de [] deve ser array ou ponteiro
 * [x] SEM040 Alvo de chamada deve ser uma funcao
 * [x] SEM041 Numero de argumentos deve coincidir com a assinatura
 * [ ] SEM042 Compatibilidade de tipos dos argumentos da chamada
 * [x] SEM043 Tipo da expressao return compativel com tipo da funcao
 * [ ] SEM044 return com valor dentro de funcao void
 * [ ] SEM045 Funcao nao-void sem return obrigatorio
 * [ ] SEM046 return fora do contexto de funcao
 * [x] SEM050 break apenas valido dentro de loop ou switch
 * [x] SEM051 continue apenas valido dentro de loop
 * [ ] SEM052 Condicao de controlo (if/while/for) deve ser escalar
 * [ ] SEM053 Expressao de switch deve ser integral ou enum
 * [ ] SEM054 Label case deve ser expressao constante integral
 * [ ] SEM055 Label case duplicado no mesmo switch
 * [ ] SEM056 Multiplos default no mesmo switch
 * [x] SEM060 Acesso a membro inexistente em struct/union
 * [x] SEM061 Operador '.' requer objeto struct/union
 * [x] SEM062 Operador '->' requer ponteiro para struct/union
 * [ ] SEM070 Limitacao backend: aritmetica com float nao suportada
 * [ ] SEM071 Limitacao backend: retorno de struct nao suportado
 * [ ] SEM072 Limitacao backend: chamadas variadicas nao suportadas
 * [ ] SEMW001 Aviso: cast truncado (ex.: float -> int)
 * [ ] SEMW002 Aviso: conversao suspeita signed/unsigned
 * [ ] SEMW003 Aviso: cast explicito que remove const
 *
 * Checks prioritarios ainda em falta:
 * atualizar aqui dps com os checks 
 */
