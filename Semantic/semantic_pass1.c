#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "semantic_pass1.h"
#include "semantic_ast_helpers.h"
#include "../Util/NodeTypes.h"


/// @brief internal mutable pass 1 state struct, holding context and result
typedef struct {
  semantic_context_t *ctx;
  semantic_pass1_result_t result;
} pass1_state_t;

static int register_symbol(pass1_state_t *state,
                           const char *name,
                           symbol_kind_t kind,
                           const type_t *type,
                           size_t line,
                           int is_function_definition,
                           size_t arity);


/// @brief emit pass 1 diagnostic message into the diagnostics list 
/// @param state pass 1 execution stage 
/// @param line source line no. associated with the diagnostic 
/// @param col column no. associated with the diagnostic 
/// @param message error message 
static void pass1_emit(pass1_state_t *state,
                       const char *code,
                       size_t line, 
                       const char *message)
{
  if (!state || !state->ctx) {
    return;
  }

  (void)diag_emit(&state->ctx->diagnostics, code, DIAG_ERROR, line, 0u, "%s", message);
}

static void pass1_cache_decl_node(pass1_state_t *state,
                                  const TreeNode_t *node,
                                  symbol_t *symbol,
                                  sem_value_kind_t value_kind,
                                  unsigned extra_flags)
{
  sem_node_info_t info;

  if (!state || !state->ctx || !node || !symbol || !symbol->type) {
    return;
  }

  info.type = symbol->type;
  info.symbol = symbol;
  info.value_kind = value_kind;
  info.flags = SEM_NODE_TYPED | extra_flags;
  (void)semantic_set_node_info(state->ctx, node, &info);
}


/**
 * @brief Check whether one tag declaration node carries a body.
 * @param decl_node aggregate declaration node.
 * @return non-zero when the declaration defines members.
 */
static int tag_decl_has_body(const TreeNode_t *decl_node)
{
  return decl_node && decl_node->p_firstChild != NULL;
}

/**
 * @brief Check whether the current enum member name already appeared earlier in the same enum.
 * @param enum_decl enum declaration node.
 * @param member current enum member node.
 * @return non-zero if a previous sibling enum member uses the same identifier.
 */
static int enum_member_seen_earlier(const TreeNode_t *enum_decl, const TreeNode_t *member)
{
  const TreeNode_t *it;

  if (!enum_decl || !member || !member->nodeData.sVal) {
    return 0;
  }

  it = enum_decl->p_firstChild;
  while (it && it != member) {
    if (it->nodeType == NODE_ENUM_MEMBER &&
        it->nodeData.sVal &&
        strcmp(it->nodeData.sVal, member->nodeData.sVal) == 0) {
      return 1;
    }
    it = it->p_sibling;
  }

  return 0;
}

/**
 * @brief Register enum tag and enum members, checking duplicate members in the same enum.
 * @param decl_node enum declaration node.
 * @param state pass1 execution state.
 * @return 0 on success, negative errno-like value on failure.
 */
static int handle_enum_declaration(TreeNode_t *decl_node, pass1_state_t *state)
{
  const TreeNode_t *member;

  if (!decl_node || !state) {
    return -EINVAL;
  }

  if (decl_node->nodeData.sVal) {
    char key[256];
    const type_t *tag_type;
    int rc;

    rc = build_tag_symbol_name(TYPE_ENUM_TAG, decl_node->nodeData.sVal, key, sizeof(key));
    if (rc < 0) {
      pass1_emit(state, "SEM900", decl_node->lineNumber, "failed to build enum tag key");
      return rc;
    }

    tag_type = type_new_tagged(&state->ctx->type_context, TYPE_ENUM_TAG, decl_node->nodeData.sVal, 0u);
    if (!tag_type) {
      pass1_emit(state, "SEM900", decl_node->lineNumber, "failed to allocate enum tag type");
      return -ENOMEM;
    }
    type_set_aggregate_decl(tag_type, decl_node);

    rc = register_symbol(state,
                         key,
                         SYMBOL_TAG_ENUM,
                         tag_type,
                         decl_node->lineNumber,
                         0,
                         0u);
    if (rc < 0 && rc != -EEXIST) {
      return rc;
    }
  }

  member = decl_node->p_firstChild;
  while (member) {
    const type_t *member_type;
    int rc;

    if (member->nodeType != NODE_ENUM_MEMBER || !member->nodeData.sVal) {
      member = member->p_sibling;
      continue;
    }

    if (enum_member_seen_earlier(decl_node, member)) {
      pass1_emit(state, "SEM063", member->lineNumber, "duplicate enum member in same enum");
      member = member->p_sibling;
      continue;
    }

    member_type = type_new_builtin(&state->ctx->type_context, BUILTIN_INT, 0u);
    if (!member_type) {
      pass1_emit(state, "SEM900", member->lineNumber, "failed to allocate enum member type");
      return -ENOMEM;
    }

    rc = register_symbol(state,
                         member->nodeData.sVal,
                         SYMBOL_ENUM_CONST,
                         member_type,
                         member->lineNumber,
                         0,
                         0u);
    if (rc < 0 && rc != -EEXIST) {
      return rc;
    }

    member = member->p_sibling;
  }

  return 0;
}

/**
 * @brief Register one struct/union tag and detect incompatible same-scope redefinition.
 * @param decl_node struct/union declaration node.
 * @param state pass1 execution state.
 * @return 0 on success, negative errno-like value on failure.
 */
static int handle_tag_declaration(TreeNode_t *decl_node, pass1_state_t *state)
{
  scope_t *scope;
  symbol_t *existing;
  type_kind_t kind;
  symbol_kind_t symbol_kind;
  char key[256];
  int rc;

  if (!decl_node || !state) {
    return -EINVAL;
  }

  switch (decl_node->nodeType) {
    case NODE_STRUCT_DECLARATION:
      kind = TYPE_STRUCT_TAG;
      symbol_kind = SYMBOL_TAG_STRUCT;
      break;
    case NODE_UNION_DECLARATION:
      kind = TYPE_UNION_TAG;
      symbol_kind = SYMBOL_TAG_UNION;
      break;
    default:
      return -EINVAL;
  }

  if (!decl_node->nodeData.sVal) {
    return 0;
  }

  rc = build_tag_symbol_name(kind, decl_node->nodeData.sVal, key, sizeof(key));
  if (rc < 0) {
    pass1_emit(state, "SEM900", decl_node->lineNumber, "failed to build tag symbol key");
    return rc;
  }

  scope = scope_current(&state->ctx->scope_stack);
  if (!scope) {
    pass1_emit(state, "SEM900", decl_node->lineNumber, "tag declaration without active scope");
    return -EINVAL;
  }

  existing = symbol_lookup_current(scope, key);
  if (existing) {
    const TreeNode_t *prev_decl = NULL;

    if (existing->kind != symbol_kind ||
        !existing->type ||
        existing->type->kind != kind) {
      pass1_emit(state, "SEM064", decl_node->lineNumber, "conflicting redefinition of struct/union tag");
      return -EEXIST;
    }

    prev_decl = (const TreeNode_t *)existing->type->as.aggregate.decl_node;
    if (tag_decl_has_body(decl_node) && tag_decl_has_body(prev_decl)) {
      pass1_emit(state, "SEM064", decl_node->lineNumber, "conflicting redefinition of struct/union tag");
      return -EEXIST;
    }

    if (tag_decl_has_body(decl_node) && !tag_decl_has_body(prev_decl)) {
      type_set_aggregate_decl(existing->type, decl_node);
    }

    return 0;
  }

  {
    const type_t *tag_type = type_new_tagged(&state->ctx->type_context, kind, decl_node->nodeData.sVal, 0u);
    if (!tag_type) {
      pass1_emit(state, "SEM900", decl_node->lineNumber, "failed to allocate tag type");
      return -ENOMEM;
    }

    type_set_aggregate_decl(tag_type, decl_node);
    rc = register_symbol(state,
                         key,
                         symbol_kind,
                         tag_type,
                         decl_node->lineNumber,
                         0,
                         0u);
    if (rc < 0) {
      return rc;
    }
  }

  return 0;
}

/**
 * @brief Check whether one object declaration carries a given visibility specifier.
 * @param decl_node Object declaration node.
 * @param visibility Visibility enum value to search for.
 * @return Non-zero when the specifier is present in the declaration chain.
 */
static int declaration_has_visibility(const TreeNode_t *decl_node, VisQualifier_t visibility)
{
  const TreeNode_t *child;

  if (!decl_node) {
    return 0;
  }

  child = decl_node->p_firstChild;
  while (child) {
    if (child->nodeType == NODE_VISIBILITY && child->nodeData.dVal == visibility) {
      return 1;
    }
    child = child->p_sibling;
  }

  return 0;
}

/**
 * @brief Enforce pass1 visibility restrictions on object declarations.
 * @param decl_node Object declaration node.
 * @param state pass1 execution state.
 * @return 0 on success, negative errno-like value on semantic violation.
 */
static int check_inline_on_object_declaration(TreeNode_t *decl_node, pass1_state_t *state)
{
  if (!decl_node || !state) {
    return -EINVAL;
  }

  if (declaration_has_visibility(decl_node, VIS_INLINE)) {
    pass1_emit(state, "SEM007", decl_node->lineNumber, "inline não é válido para declaração de variáveis");
    return -EINVAL;
  }

  return 0;
}

/**
 * @brief Check whether one AST node kind should be treated as an expression root.
 * @param node_type AST node kind.
 * @return Non-zero when the node belongs to the expression subset.
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

static int check_expression_identifier_uses(TreeNode_t *node,
                                            TreeNode_t *later_chain,
                                            pass1_state_t *state);

/**
 * @brief Check whether one later sibling chain contains a matching declaration.
 * @param node First sibling to inspect.
 * @param name Identifier name to search for.
 * @return Non-zero if a later declaration for the same name exists in the chain.
 */
static int declaration_exists_later_in_chain(TreeNode_t *node, const char *name)
{
  TreeNode_t *it = node;

  if (!name) {
    return 0;
  }

  while (it) {
    if ((it->nodeType == NODE_VAR_DECLARATION || it->nodeType == NODE_ARRAY_DECLARATION) &&
        it->nodeData.sVal &&
        strcmp(it->nodeData.sVal, name) == 0) {
      return 1;
    }
    it = it->p_sibling;
  }

  return 0;
}

/**
 * @brief Walk one sibling chain that belongs to a single expression subtree.
 * @param node First node in the chain.
 * @param state pass1 execution state.
 * @return 0 on success, negative errno-like value on semantic violation.
 */
static int check_expression_chain(TreeNode_t *node,
                                  TreeNode_t *later_chain,
                                  pass1_state_t *state)
{
  TreeNode_t *it = node;

  while (it) {
    int rc = check_expression_identifier_uses(it, later_chain, state);
    if (rc < 0) {
      return rc;
    }
    it = it->p_sibling;
  }

  return 0;
}

/**
 * @brief Check identifier uses inside expression trees for same-block use-before-declaration.
 * @param node Expression subtree root.
 * @param state pass1 execution state.
 * @return 0 on success, negative errno-like value when an identifier is not yet visible.
 */
static int check_expression_identifier_uses(TreeNode_t *node,
                                            TreeNode_t *later_chain,
                                            pass1_state_t *state)
{
  scope_t *scope;

  if (!node || !state) {
    return 0;
  }

  if (node->nodeType == NODE_IDENTIFIER) {
    scope = scope_current(&state->ctx->scope_stack);
    if (!scope || !symbol_lookup_visible(scope, node->nodeData.sVal)) {
      if (declaration_exists_later_in_chain(later_chain, node->nodeData.sVal)) {
        pass1_emit(state, "SEM006", node->lineNumber, "uso antes da declaração na ordem do mesmo bloco");
        return -EEXIST;
      }
      return 0;
    }
    return 0;
  }

  if (node->nodeType == NODE_MEMBER_ACCESS || node->nodeType == NODE_PTR_MEMBER_ACCESS) {
    return check_expression_identifier_uses(node->p_firstChild, later_chain, state);
  }

  if (node->nodeType == NODE_TYPE_CAST) {
    if (!node->p_firstChild) {
      return 0;
    }
    return check_expression_chain(node->p_firstChild->p_sibling, later_chain, state);
  }

  return check_expression_chain(node->p_firstChild, later_chain, state);
}


/**
 * @brief Push scope and account metrics for pass1.
 * @param state pass1 execution state.
 * @param line source line for diagnostics.
 * @return 0 on success, negative errno-like value on failure.
 */
static int push_scope(pass1_state_t *state, size_t line)
{
  int rc = scope_push(&state->ctx->scope_stack);
  if (rc < 0) {
    pass1_emit(state, "SEM900", line, "failed to enter lexical scope");
    return rc;
  }

  state->ctx->scope_enter_count++;
  state->result.scope_count++;
  return 0;
}

/**
 * @brief Pop scope and account metrics for pass1.
 * @param state pass1 execution state.
 * @param line source line for diagnostics.
 * @param code semantic diagnostic code on failure.
 * @param msg diagnostic text on failure.
 * @return 0 on success, negative errno-like value on failure.
 */
static int pop_scope(pass1_state_t *state, size_t line, const char *code, const char *msg)
{
  int rc = scope_pop(&state->ctx->scope_stack);
  if (rc < 0) {
    pass1_emit(state, code, line, msg);
    return rc;
  }
  state->ctx->scope_leave_count++;
  return 0;
}

/**
 * @brief Register one symbol in the current scope with semantic checks.
 * @param state pass1 execution state.
 * @param name symbol name.
 * @param kind symbol kind (object/function/parameter).
 * @param type owned type descriptor to move into symbol table on success.
 * @param line source line for diagnostics.
 * @param is_function_definition non-zero when registering a function definition.
 * @param arity function arity metadata (used for function symbols).
 * @return 0 on success, negative errno-like value on failure/duplicate.
 */
static int register_symbol(pass1_state_t *state,
                           const char *name,
                           symbol_kind_t kind,
                           const type_t *type,
                           size_t line,
                           int is_function_definition,
                           size_t arity)
{
  scope_t *scope;
  symbol_t *existing;
  symbol_t *symbol;
  int rc;

  if (!state || !state->ctx || !name || !type) {
    type_free(type);
    return -EINVAL;
  }

  scope = scope_current(&state->ctx->scope_stack);
  if (!scope) {
    pass1_emit(state, "SEM900", line, "symbol registration without active scope");
    type_free(type);
    return -EINVAL;
  }

  existing = symbol_lookup_current(scope, name);
  if (existing) {
    if (kind == SYMBOL_FUNCTION && existing->kind == SYMBOL_FUNCTION) {
      if (!type_equal(existing->type, type)) {
        pass1_emit(state, "SEM004", line, "function prototype/definition mismatch");
      } else if (is_function_definition && existing->is_defined) {
        pass1_emit(state, "SEM005", line, "duplicate function definition");
      } else if (is_function_definition) {
        existing->is_defined = 1;
      }
    } else {
      pass1_emit(state, "SEM002", line, "redeclaration in same scope");
    }
    type_free(type);
    return -EEXIST;
  }

  symbol = symbol_new(&state->ctx->persistent_arena, name, kind, type, line, 0u);
  if (!symbol) {
    type_free(type);
    pass1_emit(state, "SEM900", line, "failed to allocate symbol");
    return -ENOMEM;
  }

  if (kind == SYMBOL_FUNCTION) {
    symbol->arity = arity;
    symbol->is_defined = is_function_definition ? 1 : 0;
  }

  rc = symbol_insert(scope, symbol);
  if (rc < 0) {
    symbol_free(symbol);
    pass1_emit(state, "SEM900", line, "failed to insert symbol");
    return rc;
  }

  if (kind == SYMBOL_PARAMETER) {
    symbol->memory_class = MEMORY_CLASS_PARAMETER;
  } else if (kind == SYMBOL_FUNCTION || (kind == SYMBOL_OBJECT && scope_depth(scope) == 0u)) {
    symbol->memory_class = MEMORY_CLASS_GLOBAL;
  } else if (kind == SYMBOL_OBJECT) {
    symbol->memory_class = MEMORY_CLASS_STACK;
  }

  state->result.declaration_count++;
  return 0;
}

/**
 * @brief Build semantic function type from function signature AST.
 * @param fn_node function node.
 * @param out_type output function type on success.
 * @param out_arity output number of fixed parameters.
 * @param out_variadic output variadic flag.
 * @return 0 on success, negative errno-like value on allocation failure.
 */
static int build_function_type(type_context_t *tcx,
                               const TreeNode_t *fn_node,
                               const type_t **out_type,
                               size_t *out_arity,
                               int *out_variadic)
{
  const TreeNode_t *preamble = NULL;
  const TreeNode_t *params = NULL;
  const TreeNode_t *body = NULL;
  const TreeNode_t *it;
  const type_t *ret_type = NULL;
  const type_t **param_types = NULL;
  size_t param_count = 0u;
  int is_variadic = 0;
  unsigned qualifiers;

  semantic_ast_split_function_children(fn_node, &preamble, &params, &body);
  (void)body;

  if (!preamble) {
    *out_type = type_new_invalid(tcx);
    *out_arity = 0u;
    *out_variadic = 0;
    return (*out_type != NULL) ? 0 : -ENOMEM;
  }

  qualifiers = semantic_ast_collect_qualifiers_from_chain(preamble);
  ret_type = semantic_ast_build_type_from_type_node(tcx, preamble, qualifiers);
  if (!ret_type) {
    return -ENOMEM;
  }

  it = params;
  while (it && semantic_ast_is_param_node(it)) {
    if (it->nodeType == NODE_PARAMETER && it->nodeData.sVal && strcmp(it->nodeData.sVal, "...") == 0) {
      is_variadic = 1;
    } else if (it->nodeType == NODE_VAR_DECLARATION || it->nodeType == NODE_ARRAY_DECLARATION) {
      const type_t *param_type = semantic_ast_build_type_from_declaration(tcx, it);
      const type_t **new_params;
      if (!param_type) {
        goto fail;
      }

      new_params = (const type_t **)realloc((void *)param_types, (param_count + 1u) * sizeof(*param_types));
      if (!new_params) {
        type_free(param_type);
        goto fail;
      }
      param_types = new_params;
      param_types[param_count++] = param_type;
    }
    it = it->p_sibling;
  }

  *out_type = type_new_function(tcx, ret_type, param_types, param_count, is_variadic, 0u);
  if (!*out_type) {
    goto fail;
  }

  *out_arity = param_count;
  *out_variadic = is_variadic;
  return 0;

fail:
  type_free(ret_type);
  if (param_types) {
    size_t i;
    for (i = 0u; i < param_count; ++i) {
      type_free(param_types[i]);
    }
    free(param_types);
  }
  *out_type = NULL;
  *out_arity = 0u;
  *out_variadic = 0;
  return -ENOMEM;
}

static int walk_pass1(TreeNode_t *node, pass1_state_t *state);

/**
 * @brief Process one function node in pass1 (signature + local scope + params).
 * @param fn_node function AST node.
 * @param state pass1 execution state.
 * @return 0 on success, negative errno-like value on traversal failure.
 */
static int handle_function_node(TreeNode_t *fn_node, pass1_state_t *state)
{
  const TreeNode_t *preamble = NULL;
  const TreeNode_t *param_head = NULL;
  const TreeNode_t *body = NULL;
  const TreeNode_t *it;
  const type_t *fn_type = NULL;
  size_t arity = 0u;
  int is_variadic = 0;
  int is_definition = 0;
  int rc;

  if (!fn_node || !state) {
    return -EINVAL;
  }

  semantic_ast_split_function_children(fn_node, &preamble, &param_head, &body);
  (void)preamble;
  is_definition = (body != NULL);

  if (fn_node->nodeData.sVal) {
    rc = build_function_type(&state->ctx->type_context, fn_node, &fn_type, &arity, &is_variadic);
    if (rc < 0 || !fn_type) {
      pass1_emit(state, "SEM900", fn_node->lineNumber, "failed to build function type");
      type_free(fn_type);
      return -ENOMEM;
    }
    (void)is_variadic;
    (void)register_symbol(state,
                          fn_node->nodeData.sVal,
                          SYMBOL_FUNCTION,
                          fn_type,
                          fn_node->lineNumber,
                          is_definition,
                          arity);
    pass1_cache_decl_node(state,
                          fn_node,
                          symbol_lookup_current(scope_current(&state->ctx->scope_stack), fn_node->nodeData.sVal),
                          SEM_VALUE_FUNCTION_DESIGNATOR,
                          0u);
  }

  if (push_scope(state, fn_node->lineNumber) < 0) {
    return -EINVAL;
  }

  it = param_head;
  while (it && semantic_ast_is_param_node(it)) {
    if ((it->nodeType == NODE_VAR_DECLARATION || it->nodeType == NODE_ARRAY_DECLARATION) &&
        it->nodeData.sVal) {
      const type_t *param_type = semantic_ast_build_type_from_declaration(&state->ctx->type_context, it);
      if (!param_type) {
        pass1_emit(state, "SEM900", it->lineNumber, "failed to build parameter type");
        return -ENOMEM;
      }
      (void)register_symbol(state,
                            it->nodeData.sVal,
                            SYMBOL_PARAMETER,
                            param_type,
                            it->lineNumber,
                            0,
                            0u);
      pass1_cache_decl_node(state,
                            it,
                            symbol_lookup_current(scope_current(&state->ctx->scope_stack), it->nodeData.sVal),
                            SEM_VALUE_LVALUE,
                            0u);
    }
    it = it->p_sibling;
  }

  if (body) {
    rc = walk_pass1((TreeNode_t *)body, state);
    if (rc < 0) {
      return rc;
    }
  }

  if (pop_scope(state, fn_node->lineNumber, "SEM901", "scope stack underflow while leaving function scope") < 0) {
    return -EINVAL;
  }

  return 0;
}

/**
 * @brief Register one object declaration symbol.
 * @param decl_node object declaration node.
 * @param state pass1 execution state.
 * @return 0 on success, negative errno-like value on allocation failure.
 */
static int handle_object_declaration(TreeNode_t *decl_node, pass1_state_t *state)
{
  const type_t *decl_type;

  if (!decl_node || !state) {
    return -EINVAL;
  }

  if (!decl_node->nodeData.sVal) {
    return 0;
  }

  decl_type = semantic_ast_build_type_from_declaration(&state->ctx->type_context, decl_node);
  if (!decl_type) {
    pass1_emit(state, "SEM900", decl_node->lineNumber, "failed to build declaration type");
    return -ENOMEM;
  }

  (void)register_symbol(state,
                        decl_node->nodeData.sVal,
                        SYMBOL_OBJECT,
                        decl_type,
                        decl_node->lineNumber,
                        0,
                        0u);
  pass1_cache_decl_node(state,
                        decl_node,
                        symbol_lookup_current(scope_current(&state->ctx->scope_stack), decl_node->nodeData.sVal),
                        SEM_VALUE_LVALUE,
                        0u);
  return 0;
}

/**
 * @brief Recursive pass1 traversal over AST siblings/children.
 * @param node first node in traversal chain.
 * @param state pass1 execution state.
 * @return 0 on success, negative errno-like value on fatal traversal error.
 */
static int walk_pass1(TreeNode_t *node, pass1_state_t *state)
{
  TreeNode_t *it = node;

  while (it) {
    if (it->nodeType == NODE_BLOCK) {
      int rc;

      if (push_scope(state, it->lineNumber) < 0) {
        return -EINVAL;
      }

      if (it->p_firstChild) {
        rc = walk_pass1(it->p_firstChild, state);
        if (rc < 0) {
          return rc;
        }
      }

      if (pop_scope(state, it->lineNumber, "SEM901", "scope stack underflow while leaving block scope") < 0) {
        return -EINVAL;
      }

      it = it->p_sibling;
      continue;
    } else if (it->nodeType == NODE_FOR) {
      int rc;

      if (push_scope(state, it->lineNumber) < 0) {
        return -EINVAL;
      }

      if (it->p_firstChild) {
        rc = walk_pass1(it->p_firstChild, state);
        if (rc < 0) {
          return rc;
        }
      }

      if (pop_scope(state, it->lineNumber, "SEM901", "scope stack underflow while leaving for scope") < 0) {
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
    } else if (it->nodeType == NODE_ENUM_DECLARATION) {
      int rc = handle_enum_declaration(it, state);
      if (rc < 0) {
        return rc;
      }
      it = it->p_sibling;
      continue;
    } else if (it->nodeType == NODE_STRUCT_DECLARATION ||
               it->nodeType == NODE_UNION_DECLARATION) {
      int rc = handle_tag_declaration(it, state);
      if (rc < 0) {
        return rc;
      }
      it = it->p_sibling;
      continue;
    } else if (it->nodeType == NODE_VAR_DECLARATION || it->nodeType == NODE_ARRAY_DECLARATION) {
      if (handle_object_declaration(it, state) < 0) {
        return -ENOMEM;
      }
      if (check_inline_on_object_declaration(it, state) < 0) {
        return -EINVAL;
      }
    } else if (is_expression_node_type(it->nodeType)) {
      int rc = check_expression_identifier_uses(it, it->p_sibling, state);
      if (rc < 0) {
        return rc;
      }
      it = it->p_sibling;
      continue;
    }

    if (it->p_firstChild) {
      int rc = walk_pass1(it->p_firstChild, state);
      if (rc < 0) {
        return rc;
      }
    }

    it = it->p_sibling;
  }

  return 0;
}

/**
 * @brief Run semantic pass1 (scope construction and symbol binding foundations).
 * @param root AST root.
 * @param ctx shared semantic context.
 * @param out_result pass1 metrics output.
 * @return 0 on success, negative errno-like value on fatal setup/traversal error.
 */
int semantic_pass1_run(TreeNode_t *root, semantic_context_t *ctx, semantic_pass1_result_t *out_result)
{
  pass1_state_t state;
  int rc;

  if (!ctx || !out_result) {
    return -EINVAL;
  }

  memset(&state, 0, sizeof(state));
  state.ctx = ctx;

  ctx->scope_enter_count = 0u;
  ctx->scope_leave_count = 0u;

  rc = push_scope(&state, 0u);
  if (rc < 0) {
    *out_result = state.result;
    return rc;
  }

  if (root) {
    rc = walk_pass1(root, &state);
    if (rc < 0) {
      *out_result = state.result;
      return rc;
    }
  }

  while (scope_current(&ctx->scope_stack) && scope_current(&ctx->scope_stack)->parent) {
    pass1_emit(&state, "SEM902", 0u, "unbalanced lexical scopes after traversal");
    (void)pop_scope(&state, 0u, "SEM901", "scope stack underflow while leaving scope");
  }

  *out_result = state.result;
  return 0;
}

/*
 * Registo de checks semanticos - passe 1
 * NOTA:
 * MANTER A LISTA SINCRONIZADA COM
 * 1) docs da drive
 * 2) se virem que falta algum importante, avisar! e colocar aqui e no docs da drive!
 *
 * PASSE 1 - Declaracoes, scopes, simbolos
 * [ X ] SEM001 Identificador desconhecido deve resolver para simbolo visivel (feito no fluxo de lookup do pass2)
 * [ X ] SEM002 Redeclaracao no mesmo scope e rejeitada
 * [ X ] SEM003 Shadowing em scope aninhado e permitido
 * [ X ] SEM004 Compatibilidade entre prototipo e definicao de funcao
 * [ X ] SEM005 Definicao duplicada de funcao e rejeitada
 * [ X ] SEM006 Uso antes da declaracao na ordem do mesmo bloco
 * [ X ] SEM007 'inline' invalido para declaracao de variaveis
 * [ X ] SEM063 Redeclaracao de membro em enum
 * [ X ] SEM064 Redefinicao incompativel de tag struct/union
 *
 * Checks prioritarios ainda em falta no pass1:
 * [   ] SEM080 Expressao inicializadora nao e verificada contra o tipo declarado  <-- missing
 * [   ] SEM081 Struct/union incompleta (forward decl sem corpo) usada como tipo valor (nao ponteiro)  <-- missing
 * [   ] SEM082 Constante de enum deve ser tipada como int, nao como TYPE_ENUM_TAG  <-- missing
 * [   ] SEM083 Dimensao de array deve ser expressao constante integral (ICE) em contexto nao-VLA  <-- missing
 */
