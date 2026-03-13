#include <errno.h>
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
                           type_t *type,
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

  symbol = symbol_new(name, kind, type, line, 0u);
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
static int build_function_type(const TreeNode_t *fn_node,
                               type_t **out_type,
                               size_t *out_arity,
                               int *out_variadic)
{
  const TreeNode_t *preamble = NULL;
  const TreeNode_t *params = NULL;
  const TreeNode_t *body = NULL;
  const TreeNode_t *it;
  type_t *ret_type = NULL;
  type_t **param_types = NULL;
  size_t param_count = 0u;
  int is_variadic = 0;
  unsigned qualifiers;

  semantic_ast_split_function_children(fn_node, &preamble, &params, &body);
  (void)body;

  if (!preamble) {
    *out_type = type_new_invalid();
    *out_arity = 0u;
    *out_variadic = 0;
    return (*out_type != NULL) ? 0 : -ENOMEM;
  }

  qualifiers = semantic_ast_collect_qualifiers_from_chain(preamble);
  ret_type = semantic_ast_build_type_from_type_node(preamble, qualifiers);
  if (!ret_type) {
    return -ENOMEM;
  }

  it = params;
  while (it && semantic_ast_is_param_node(it)) {
    if (it->nodeType == NODE_PARAMETER && it->nodeData.sVal && strcmp(it->nodeData.sVal, "...") == 0) {
      is_variadic = 1;
    } else if (it->nodeType == NODE_VAR_DECLARATION || it->nodeType == NODE_ARRAY_DECLARATION) {
      type_t *param_type = semantic_ast_build_type_from_declaration(it);
      type_t **new_params;
      if (!param_type) {
        goto fail;
      }

      new_params = (type_t **)realloc(param_types, (param_count + 1u) * sizeof(*param_types));
      if (!new_params) {
        type_free(param_type);
        goto fail;
      }
      param_types = new_params;
      param_types[param_count++] = param_type;
    }
    it = it->p_sibling;
  }

  *out_type = type_new_function(ret_type, param_types, param_count, is_variadic, 0u);
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
  type_t *fn_type = NULL;
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
    rc = build_function_type(fn_node, &fn_type, &arity, &is_variadic);
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
  }

  if (push_scope(state, fn_node->lineNumber) < 0) {
    return -EINVAL;
  }

  it = param_head;
  while (it && semantic_ast_is_param_node(it)) {
    if ((it->nodeType == NODE_VAR_DECLARATION || it->nodeType == NODE_ARRAY_DECLARATION) &&
        it->nodeData.sVal) {
      type_t *param_type = semantic_ast_build_type_from_declaration(it);
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
  type_t *decl_type;

  if (!decl_node || !state) {
    return -EINVAL;
  }

  if (!decl_node->nodeData.sVal) {
    return 0;
  }

  decl_type = semantic_ast_build_type_from_declaration(decl_node);
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
    } else if (it->nodeType == NODE_VAR_DECLARATION || it->nodeType == NODE_ARRAY_DECLARATION) {
      if (handle_object_declaration(it, state) < 0) {
        return -ENOMEM;
      }
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

  scope_stack_init(&ctx->scope_stack);
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
 * [ ] SEM001 Identificador desconhecido deve resolver para simbolo visivel (feito no fluxo de lookup do pass2)
 * [x] SEM002 Redeclaracao no mesmo scope e rejeitada
 * [x] SEM003 Shadowing em scope aninhado e permitido
 * [x] SEM004 Compatibilidade entre prototipo e definicao de funcao
 * [x] SEM005 Definicao duplicada de funcao e rejeitada
 * [ ] SEM006 Uso antes da declaracao na ordem do mesmo bloco
 * [ ] SEM007 'inline' invalido para declaracao de variaveis
 * [ ] SEM063 Redeclaracao de membro em enum
 * [ ] SEM064 Redefinicao incompativel de tag struct/union
 *
 * Checks prioritarios ainda em falta no pass1:
 * [ ] SEM006
 * [ ] SEM007
 * [ ] SEM063
 * [ ] SEM064
 *
 */
