#ifndef SEMANTIC_AST_HELPERS_H
#define SEMANTIC_AST_HELPERS_H

#include "../Parser/ASTree.h"
#include "type.h"

unsigned semantic_ast_collect_qualifiers_from_chain(const TreeNode_t *node);

const type_t *semantic_ast_build_type_from_type_node(type_context_t *tcx,
                                                     const TreeNode_t *type_node,
                                                     unsigned qualifiers);

const type_t *semantic_ast_build_type_from_declaration(type_context_t *tcx,
                                                       const TreeNode_t *decl_node);

int semantic_ast_is_param_node(const TreeNode_t *node);

void semantic_ast_split_function_children(const TreeNode_t *fn_node,
                                          const TreeNode_t **out_preamble,
                                          const TreeNode_t **out_param_head,
                                          const TreeNode_t **out_body);

int build_tag_symbol_name(type_kind_t kind,
                          const char *tag_name,
                          char *buffer,
                          size_t buffer_size);

#endif
