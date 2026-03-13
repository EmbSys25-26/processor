#include <stdio.h>
#include <stdlib.h>

#include "ASTree.h"
#include "semantic.h"

#define CHECK(cond, msg)                                                        \
  do {                                                                          \
    if (!(cond)) {                                                              \
      fprintf(stderr, "FAIL: %s\n", (msg));                                     \
      return 1;                                                                 \
    }                                                                           \
  } while (0)

static TreeNode_t *make_node(NodeType_t node_type, size_t line)
{
  TreeNode_t *node = (TreeNode_t *)calloc(1u, sizeof(*node));
  if (!node) {
    return NULL;
  }
  node->nodeType = node_type;
  node->lineNumber = line;
  return node;
}

static int append_child(TreeNode_t *parent, TreeNode_t *child)
{
  TreeNode_t *it;

  if (!parent || !child) {
    return -1;
  }

  if (!parent->p_firstChild) {
    parent->p_firstChild = child;
    parent->childNumber = 1u;
    return 0;
  }

  it = parent->p_firstChild;
  while (it->p_sibling) {
    it = it->p_sibling;
  }
  it->p_sibling = child;
  parent->childNumber++;
  return 0;
}

static void free_tree(TreeNode_t *node)
{
  if (!node) {
    return;
  }

  free_tree(node->p_firstChild);
  free_tree(node->p_sibling);
  free(node);
}

static int test_balanced_scope(void)
{
  TreeNode_t *root = make_node(NODE_NULL, 1u);
  TreeNode_t *block = make_node(NODE_BLOCK, 2u);
  semantic_result_t result;

  CHECK(root != NULL && block != NULL, "balanced tree allocation");
  CHECK(append_child(root, block) == 0, "attach block");

  result = semantic_run(root, "balanced.c");
  free_tree(root);

  CHECK(result.error_count == 0u, "balanced has no semantic errors");
  CHECK(result.warning_count == 0u, "balanced has no semantic warnings");
  CHECK(result.scope_count == 2u, "balanced scope count");
  return 0;
}

static int test_nested_block_scope(void)
{
  TreeNode_t *root = make_node(NODE_NULL, 1u);
  TreeNode_t *outer = make_node(NODE_BLOCK, 2u);
  TreeNode_t *inner = make_node(NODE_BLOCK, 3u);
  semantic_result_t result;

  CHECK(root != NULL && outer != NULL && inner != NULL, "nested-block tree allocation");
  CHECK(append_child(root, outer) == 0, "attach outer block");
  CHECK(append_child(outer, inner) == 0, "attach inner block");

  result = semantic_run(root, "nested_blocks.c");
  free_tree(root);

  CHECK(result.error_count == 0u, "nested blocks have no semantic errors");
  CHECK(result.scope_count == 3u, "nested block scope count");
  return 0;
}

static int test_for_scope(void)
{
  TreeNode_t *root = make_node(NODE_NULL, 1u);
  TreeNode_t *outer = make_node(NODE_BLOCK, 2u);
  TreeNode_t *loop = make_node(NODE_FOR, 3u);
  TreeNode_t *decl = make_node(NODE_VAR_DECLARATION, 3u);
  TreeNode_t *type = make_node(NODE_TYPE, 3u);
  TreeNode_t *cond = make_node(NODE_NULL, 3u);
  TreeNode_t *step = make_node(NODE_NULL, 3u);
  TreeNode_t *body = make_node(NODE_BLOCK, 4u);
  semantic_result_t result;

  CHECK(root != NULL && outer != NULL && loop != NULL &&
            decl != NULL && type != NULL && cond != NULL &&
            step != NULL && body != NULL,
        "for-scope tree allocation");

  decl->nodeData.sVal = "i";
  type->nodeData.dVal = TYPE_INT;

  CHECK(append_child(decl, type) == 0, "attach decl type");
  CHECK(append_child(loop, decl) == 0, "attach for init");
  CHECK(append_child(loop, cond) == 0, "attach for cond");
  CHECK(append_child(loop, step) == 0, "attach for step");
  CHECK(append_child(loop, body) == 0, "attach for body");
  CHECK(append_child(outer, loop) == 0, "attach for loop");
  CHECK(append_child(root, outer) == 0, "attach outer block");

  result = semantic_run(root, "for_scope.c");
  free_tree(root);

  CHECK(result.error_count == 0u, "for scope has no semantic errors");
  CHECK(result.scope_count == 4u, "for scope count");
  return 0;
}

int main(void)
{
  semantic_result_t null_result = semantic_run(NULL, "null_root.c");

  CHECK(null_result.error_count > 0u, "null root must produce semantic error");
  CHECK(test_balanced_scope() == 0, "balanced scope test");
  CHECK(test_nested_block_scope() == 0, "nested block scope test");
  CHECK(test_for_scope() == 0, "for scope test");

  printf("PASS test_semantic_api\n");
  return 0;
}
