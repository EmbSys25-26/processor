#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ASTree.h"
#include "diagnostics.h"
#include "semantic.h"
#include "semantic_pass1.h"
#include "semantic_pass2.h"

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

static int test_return_outside_function(void)
{
  TreeNode_t *root = make_node(NODE_NULL, 1u);
  TreeNode_t *ret = make_node(NODE_RETURN, 2u);
  semantic_context_t ctx;
  semantic_pass1_result_t pass1_result = {0u, 0u};
  semantic_pass2_result_t pass2_result = {0u, 0u};
  diagnostic_t *diag;

  CHECK(root != NULL && ret != NULL, "return-outside-function tree allocation");
  CHECK(append_child(root, ret) == 0, "attach stray return");
  CHECK(semantic_context_init(&ctx) == 0, "semantic context init");
  CHECK(semantic_pass1_run(root, &ctx, &pass1_result) == 0, "pass1 stray return");
  CHECK(semantic_pass2_run(root, &ctx, &pass2_result) == 0, "pass2 stray return");
  CHECK(diag_error_count(&ctx.diagnostics) == 1u, "stray return emits one semantic error");

  diag = ctx.diagnostics.head;
  CHECK(diag != NULL, "diagnostic list populated");
  CHECK(diag->severity == DIAG_ERROR, "stray return severity");
  CHECK(strcmp(diag->code, "SEM046") == 0, "stray return code");

  semantic_context_destroy(&ctx);
  free_tree(root);
  return 0;
}

static int test_multiple_default_labels(void)
{
  TreeNode_t *root = make_node(NODE_NULL, 1u);
  TreeNode_t *block = make_node(NODE_BLOCK, 2u);
  TreeNode_t *sw = make_node(NODE_SWITCH, 3u);
  TreeNode_t *expr = make_node(NODE_INTEGER, 3u);
  TreeNode_t *def1 = make_node(NODE_DEFAULT, 4u);
  TreeNode_t *def2 = make_node(NODE_DEFAULT, 5u);
  TreeNode_t *brk1 = make_node(NODE_BREAK, 4u);
  TreeNode_t *brk2 = make_node(NODE_BREAK, 5u);
  semantic_context_t ctx;
  semantic_pass1_result_t pass1_result = {0u, 0u};
  semantic_pass2_result_t pass2_result = {0u, 0u};
  diagnostic_t *diag;

  CHECK(root && block && sw && expr && def1 && def2 && brk1 && brk2,
        "multiple-default tree allocation");
  expr->nodeData.dVal = 0;
  CHECK(append_child(def1, brk1) == 0, "attach first default body");
  CHECK(append_child(def2, brk2) == 0, "attach second default body");
  CHECK(append_child(sw, expr) == 0, "attach switch expr");
  CHECK(append_child(sw, def1) == 0, "attach first default");
  CHECK(append_child(sw, def2) == 0, "attach second default");
  CHECK(append_child(block, sw) == 0, "attach switch block");
  CHECK(append_child(root, block) == 0, "attach root block");
  CHECK(semantic_context_init(&ctx) == 0, "semantic context init");
  CHECK(semantic_pass1_run(root, &ctx, &pass1_result) == 0, "pass1 multiple default");
  CHECK(semantic_pass2_run(root, &ctx, &pass2_result) == 0, "pass2 multiple default");
  CHECK(diag_error_count(&ctx.diagnostics) == 1u, "multiple defaults emit one semantic error");

  diag = ctx.diagnostics.head;
  CHECK(diag != NULL, "multiple default diagnostic list populated");
  CHECK(diag->severity == DIAG_ERROR, "multiple default severity");
  CHECK(strcmp(diag->code, "SEM056") == 0, "multiple default code");

  semantic_context_destroy(&ctx);
  free_tree(root);
  return 0;
}

int main(void)
{
  semantic_result_t null_result = semantic_run(NULL, "null_root.c");

  CHECK(null_result.error_count > 0u, "null root must produce semantic error");
  CHECK(test_balanced_scope() == 0, "balanced scope test");
  CHECK(test_nested_block_scope() == 0, "nested block scope test");
  CHECK(test_for_scope() == 0, "for scope test");
  CHECK(test_return_outside_function() == 0, "return outside function test");
  CHECK(test_multiple_default_labels() == 0, "multiple default labels test");

  printf("PASS test_semantic_api\n");
  return 0;
}
