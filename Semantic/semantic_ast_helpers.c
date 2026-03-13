#include <stdlib.h>

#include "semantic_ast_helpers.h"
#include "../Util/NodeTypes.h"

/**
 * @file semantic_ast_helpers.c
 * @brief Shared AST interpretation logic for semantic pass1 and pass2.
 */

/**
 * @brief Build one scalar semantic type from declaration-specifier siblings.
 * @param spec_chain First node in the declaration-specifier sibling chain.
 * @param qualifiers Bitmask of TYPE_QUAL_* flags to apply to the type.
 * @return Newly allocated scalar type, invalid type when the combination is
 *         syntactically inconsistent, or NULL on allocation failure.
 */
static type_t *semantic_ast_build_scalar_type_from_spec_chain(const TreeNode_t *spec_chain,
                                                              unsigned qualifiers)
{
  const TreeNode_t *it = spec_chain;
  const TreeNode_t *tag_name = NULL;
  const TreeNode_t *tag_decl = NULL;
  int tagged_kind = 0;
  int seen_char = 0;
  int seen_short = 0;
  int seen_int = 0;
  int seen_long = 0;
  int seen_float = 0;
  int seen_double = 0;
  int seen_void = 0;
  unsigned signedness = qualifiers & (TYPE_QUAL_SIGNED | TYPE_QUAL_UNSIGNED);

  while (it) {
    if (it->nodeType == NODE_TYPE) {
      VarType_t vtype = (VarType_t)it->nodeData.dVal;
      switch (vtype) {
        case TYPE_CHAR:
          seen_char++;
          break;
        case TYPE_SHORT:
          seen_short++;
          break;
        case TYPE_INT:
          seen_int++;
          break;
        case TYPE_LONG:
          seen_long++;
          break;
        case TYPE_FLOAT:
          seen_float++;
          break;
        case TYPE_DOUBLE:
          seen_double++;
          break;
        case TYPE_VOID:
          seen_void++;
          break;
        case TYPE_STRUCT:
          tagged_kind = TYPE_STRUCT_TAG;
          tag_name = it->p_firstChild;
          tag_decl = tag_name ? tag_name->p_sibling : NULL;
          break;
        case TYPE_UNION:
          tagged_kind = TYPE_UNION_TAG;
          tag_name = it->p_firstChild;
          tag_decl = tag_name ? tag_name->p_sibling : NULL;
          break;
        case TYPE_ENUM:
          tagged_kind = TYPE_ENUM_TAG;
          tag_name = it->p_firstChild;
          tag_decl = tag_name ? tag_name->p_sibling : NULL;
          break;
        default:
          break;
      }
    }
    it = it->p_sibling;
  }

  if (tagged_kind) {
    type_t *type;

    if (seen_char || seen_short || seen_int || seen_long || seen_float || seen_double || seen_void || signedness) {
      return type_new_invalid();
    }

    type = type_new_tagged((type_kind_t)tagged_kind,
                           (tag_name && tag_name->nodeType == NODE_IDENTIFIER) ? tag_name->nodeData.sVal : NULL,
                           qualifiers);
    type_set_aggregate_decl(type, tag_decl);
    return type;
  }

  if (seen_void) {
    if (seen_char || seen_short || seen_int || seen_long || seen_float || seen_double || signedness) {
      return type_new_invalid();
    }
    return type_new_builtin(BUILTIN_VOID, qualifiers);
  }

  if (seen_float) {
    if (seen_char || seen_short || seen_int || seen_long || seen_double || signedness) {
      return type_new_invalid();
    }
    return type_new_builtin(BUILTIN_FLOAT, qualifiers);
  }

  if (seen_double) {
    if (seen_char || seen_short || seen_void || seen_float || signedness || seen_long > 1) {
      return type_new_invalid();
    }
    if (seen_long == 1) {
      return type_new_builtin(BUILTIN_LONG_DOUBLE, qualifiers);
    }
    return type_new_builtin(BUILTIN_DOUBLE, qualifiers);
  }

  if (seen_char) {
    if (seen_short || seen_int || seen_long || seen_void || seen_float) {
      return type_new_invalid();
    }
    return type_new_builtin(BUILTIN_CHAR, qualifiers);
  }

  if (seen_short) {
    if (seen_char || seen_long || seen_void || seen_float || seen_double) {
      return type_new_invalid();
    }
    return type_new_builtin(BUILTIN_SHORT, qualifiers);
  }

  if (seen_long) {
    if (seen_char || seen_short || seen_void || seen_float) {
      return type_new_invalid();
    }
    return type_new_builtin(BUILTIN_LONG, qualifiers);
  }

  if (seen_int || signedness) {
    return type_new_builtin(BUILTIN_INT, qualifiers);
  }

  return type_new_invalid();
}

unsigned semantic_ast_collect_qualifiers_from_chain(const TreeNode_t *node)
{
  unsigned qualifiers = 0u;
  const TreeNode_t *it = node;

  while (it) {
    if (it->nodeType == NODE_MODIFIER) {
      if (it->nodeData.dVal == MOD_CONST) {
        qualifiers |= TYPE_QUAL_CONST;
      } else if (it->nodeData.dVal == MOD_VOLATILE) {
        qualifiers |= TYPE_QUAL_VOLATILE;
      }
    } else if (it->nodeType == NODE_SIGN) {
      if (it->nodeData.dVal == SIGN_SIGNED) {
        qualifiers |= TYPE_QUAL_SIGNED;
      } else if (it->nodeData.dVal == SIGN_UNSIGNED) {
        qualifiers |= TYPE_QUAL_UNSIGNED;
      }
    }
    it = it->p_sibling;
  }

  return qualifiers;
}

type_t *semantic_ast_build_type_from_type_node(const TreeNode_t *type_node, unsigned qualifiers)
{
  type_t *base = NULL;

  if (!type_node) {
    return type_new_invalid();
  }

  if (type_node->nodeType == NODE_POINTER) {
    base = semantic_ast_build_type_from_type_node(type_node->p_firstChild, qualifiers);
    if (!base) {
      return NULL;
    }
    return type_new_pointer(base, 0u);
  }

  return semantic_ast_build_scalar_type_from_spec_chain(type_node, qualifiers);
}

type_t *semantic_ast_build_type_from_declaration(const TreeNode_t *decl_node)
{
  const TreeNode_t *it;
  const TreeNode_t *spec_chain = NULL;
  const TreeNode_t **dims = NULL;
  size_t dim_count = 0u;
  unsigned qualifiers;
  type_t *base;

  if (!decl_node) {
    return type_new_invalid();
  }

  it = decl_node->p_firstChild;
  while (it) {
    if (it->nodeType == NODE_TYPE ||
        it->nodeType == NODE_POINTER ||
        it->nodeType == NODE_VISIBILITY ||
        it->nodeType == NODE_MODIFIER ||
        it->nodeType == NODE_SIGN) {
      spec_chain = it;
      break;
    }

    if (decl_node->nodeType == NODE_ARRAY_DECLARATION) {
      const TreeNode_t **new_dims = (const TreeNode_t **)realloc(dims, (dim_count + 1u) * sizeof(*dims));
      if (!new_dims) {
        free(dims);
        return NULL;
      }
      dims = new_dims;
      dims[dim_count++] = it;
    }
    it = it->p_sibling;
  }

  qualifiers = semantic_ast_collect_qualifiers_from_chain(spec_chain);
  base = semantic_ast_build_type_from_type_node(spec_chain, qualifiers);
  if (!base) {
    free(dims);
    return NULL;
  }

  if (decl_node->nodeType == NODE_ARRAY_DECLARATION) {
    size_t idx = dim_count;

    while (idx > 0u) {
      size_t arr_size = 0u;
      int known_size = 0;
      type_t *array_type;
      const TreeNode_t *dim = dims[idx - 1u];

      if (dim->nodeType == NODE_INTEGER && dim->nodeData.dVal >= 0) {
        arr_size = (size_t)dim->nodeData.dVal;
        known_size = 1;
      }

      array_type = type_new_array(base, arr_size, known_size, 0u);
      if (!array_type) {
        type_free(base);
        free(dims);
        return NULL;
      }
      base = array_type;
      idx--;
    }
  }

  free(dims);
  return base;
}

int semantic_ast_is_param_node(const TreeNode_t *node)
{
  if (!node) {
    return 0;
  }

  return node->nodeType == NODE_VAR_DECLARATION ||
         node->nodeType == NODE_ARRAY_DECLARATION ||
         node->nodeType == NODE_PARAMETER;
}

void semantic_ast_split_function_children(const TreeNode_t *fn_node,
                                          const TreeNode_t **out_preamble,
                                          const TreeNode_t **out_param_head,
                                          const TreeNode_t **out_body)
{
  const TreeNode_t *preamble = NULL;
  const TreeNode_t *param_head = NULL;
  const TreeNode_t *body = NULL;
  const TreeNode_t *second;
  const TreeNode_t *scan;

  if (!out_preamble || !out_param_head || !out_body) {
    return;
  }

  if (!fn_node) {
    *out_preamble = NULL;
    *out_param_head = NULL;
    *out_body = NULL;
    return;
  }

  preamble = fn_node->p_firstChild;
  second = preamble ? preamble->p_sibling : NULL;

  if (semantic_ast_is_param_node(second)) {
    param_head = second;
    scan = second;
    while (scan && semantic_ast_is_param_node(scan)) {
      body = scan->p_sibling;
      scan = scan->p_sibling;
    }
  } else {
    body = second;
  }

  *out_preamble = preamble;
  *out_param_head = param_head;
  *out_body = body;
}
