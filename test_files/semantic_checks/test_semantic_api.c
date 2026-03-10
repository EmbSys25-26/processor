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
  TreeNode_t *start = make_node(NODE_START_SCOPE, 2u);
  TreeNode_t *end = make_node(NODE_END_SCOPE, 3u);
  semantic_result_t result;

  CHECK(root != NULL && start != NULL && end != NULL, "balanced tree allocation");
  CHECK(append_child(root, start) == 0, "attach start");
  CHECK(append_child(root, end) == 0, "attach end sibling");

  result = semantic_run(root, "balanced.c");
  free_tree(root);

  CHECK(result.error_count == 0u, "balanced has no semantic errors");
  CHECK(result.warning_count == 0u, "balanced has no semantic warnings");
  CHECK(result.scope_count == 2u, "balanced scope count");
  return 0;
}

static int test_unmatched_end_scope(void)
{
  TreeNode_t *root = make_node(NODE_NULL, 1u);
  TreeNode_t *end = make_node(NODE_END_SCOPE, 9u);
  semantic_result_t result;

  CHECK(root != NULL && end != NULL, "unmatched-end tree allocation");
  CHECK(append_child(root, end) == 0, "attach unmatched end");

  result = semantic_run(root, "unmatched_end.c");
  free_tree(root);

  CHECK(result.error_count > 0u, "unmatched end must error");
  return 0;
}

static int test_missing_end_scope(void)
{
  TreeNode_t *root = make_node(NODE_NULL, 1u);
  TreeNode_t *start = make_node(NODE_START_SCOPE, 2u);
  semantic_result_t result;

  CHECK(root != NULL && start != NULL, "missing-end tree allocation");
  CHECK(append_child(root, start) == 0, "attach unmatched start");

  result = semantic_run(root, "missing_end.c");
  free_tree(root);

  CHECK(result.error_count > 0u, "missing end must error");
  return 0;
}

int main(void)
{
  semantic_result_t null_result = semantic_run(NULL, "null_root.c");

  CHECK(null_result.error_count > 0u, "null root must produce semantic error");
  CHECK(test_balanced_scope() == 0, "balanced scope test");
  CHECK(test_unmatched_end_scope() == 0, "unmatched end scope test");
  CHECK(test_missing_end_scope() == 0, "missing end scope test");

  printf("PASS test_semantic_api\n");
  return 0;
}
