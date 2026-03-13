#ifndef SEMANTIC_AST_HELPERS_H
#define SEMANTIC_AST_HELPERS_H

#include "../Parser/ASTree.h"
#include "type.h"

/**
 * @file semantic_ast_helpers.h
 * @brief Shared AST-to-semantic-type helpers used by semantic passes.
 *
 * These helpers centralize the AST interpretation rules that both semantic
 * passes rely on: qualifier collection, declaration type reconstruction, and
 * function child splitting. Keeping them in one place prevents the two passes
 * from drifting when the parser's AST contract changes.
 */

/**
 * @brief Collect declaration qualifiers from one sibling chain.
 * @param node First node in a declaration-specifier sibling chain.
 * @return Bitmask composed from TYPE_QUAL_* flags.
 */
unsigned semantic_ast_collect_qualifiers_from_chain(const TreeNode_t *node);

/**
 * @brief Build one semantic type from an AST type node.
 * @param type_node AST node describing either a scalar type-specifier chain or
 *        a pointer node whose child recursively describes the pointee type.
 * @param qualifiers Top-level qualifier mask to apply to the reconstructed
 *        type.
 * @return Newly allocated type owned by the caller. Returns an invalid type on
 *         malformed AST shapes, or NULL on allocation failure.
 */
type_t *semantic_ast_build_type_from_type_node(const TreeNode_t *type_node,
                                               unsigned qualifiers);

/**
 * @brief Build the declared type for one object or array declaration node.
 * @param decl_node AST declaration node (`NODE_VAR_DECLARATION` or
 *        `NODE_ARRAY_DECLARATION`).
 * @return Newly allocated type owned by the caller. Returns an invalid type on
 *         malformed AST shapes, or NULL on allocation failure.
 */
type_t *semantic_ast_build_type_from_declaration(const TreeNode_t *decl_node);

/**
 * @brief Check whether an AST node belongs to a function parameter list.
 * @param node Candidate AST node.
 * @return Non-zero when the node is a parameter-like declaration.
 */
int semantic_ast_is_param_node(const TreeNode_t *node);

/**
 * @brief Split a function node into preamble, parameter chain, and body.
 * @param fn_node Function AST node.
 * @param out_preamble Receives the declaration-specifier/preamble child.
 * @param out_param_head Receives the first parameter node, or NULL if none.
 * @param out_body Receives the function body subtree, or NULL for prototypes.
 */
void semantic_ast_split_function_children(const TreeNode_t *fn_node,
                                          const TreeNode_t **out_preamble,
                                          const TreeNode_t **out_param_head,
                                          const TreeNode_t **out_body);

#endif
