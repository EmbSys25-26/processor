#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ASTree.h"
#include "diagnostics.h"
#include "semantic.h"
#include "semantic_pass1.h"
#include "semantic_pass2.h"
#include "Util/NodeTypes.h"

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

static TreeNode_t *make_builtin_type(size_t line, VarType_t vtype)
{
  TreeNode_t *type = make_node(NODE_TYPE, line);
  if (type) {
    type->nodeData.dVal = vtype;
  }
  return type;
}

static TreeNode_t *make_identifier(size_t line, const char *name)
{
  TreeNode_t *id = make_node(NODE_IDENTIFIER, line);
  if (id) {
    id->nodeData.sVal = (char *)name;
  }
  return id;
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
  TreeNode_t *type = make_builtin_type(3u, TYPE_INT);
  TreeNode_t *cond = make_node(NODE_NULL, 3u);
  TreeNode_t *step = make_node(NODE_NULL, 3u);
  TreeNode_t *body = make_node(NODE_BLOCK, 4u);
  semantic_result_t result;

  CHECK(root != NULL && outer != NULL && loop != NULL &&
            decl != NULL && type != NULL && cond != NULL &&
            step != NULL && body != NULL,
        "for-scope tree allocation");

  decl->nodeData.sVal = "i";

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

static int test_semantic_analyze_persistent_context(void)
{
  TreeNode_t *root = make_node(NODE_NULL, 1u);
  TreeNode_t *block = make_node(NODE_BLOCK, 2u);
  TreeNode_t *decl = make_node(NODE_VAR_DECLARATION, 3u);
  TreeNode_t *decl_type = make_builtin_type(3u, TYPE_INT);
  TreeNode_t *assign = make_node(NODE_OPERATOR, 4u);
  TreeNode_t *lhs_id = make_identifier(4u, "x");
  TreeNode_t *rhs_lit = make_node(NODE_INTEGER, 4u);
  semantic_context_t *ctx = NULL;
  semantic_result_t result = {0u, 0u, 0u};
  const sem_node_info_t *decl_info;
  const sem_node_info_t *lhs_info;
  const sem_node_info_t *assign_info;
  int rc;

  CHECK(root && block && decl && decl_type && assign && lhs_id && rhs_lit, "persistent-context tree allocation");

  decl->nodeData.sVal = "x";
  assign->nodeData.dVal = OP_ASSIGN;
  rhs_lit->nodeData.dVal = 1;

  CHECK(append_child(decl, decl_type) == 0, "attach decl type");
  CHECK(append_child(assign, lhs_id) == 0, "attach lhs id");
  CHECK(append_child(assign, rhs_lit) == 0, "attach rhs literal");
  CHECK(append_child(block, decl) == 0, "attach decl");
  CHECK(append_child(block, assign) == 0, "attach assign");
  CHECK(append_child(root, block) == 0, "attach root block");

  rc = semantic_analyze(root, "persistent_context.c", &ctx, &result);
  CHECK(rc == 0, "semantic_analyze rc");
  CHECK(ctx != NULL, "semantic_analyze returns live context");
  CHECK(result.error_count == 0u, "persistent-context has no semantic errors");

  decl_info = semantic_get_node_info(ctx, decl);
  lhs_info = semantic_get_node_info(ctx, lhs_id);
  assign_info = semantic_get_node_info(ctx, assign);

  CHECK(decl_info != NULL, "decl node info exists");
  CHECK(decl_info->type != NULL, "decl type cached");
  CHECK(decl_info->symbol != NULL, "decl symbol cached");
  CHECK(decl_info->symbol->decl_scope != NULL, "decl scope survives analysis");
  CHECK(lhs_info != NULL, "identifier node info exists");
  CHECK(lhs_info->symbol == decl_info->symbol, "identifier resolves to declaration symbol");
  CHECK(lhs_info->value_kind == SEM_VALUE_LVALUE, "identifier value kind");
  CHECK(assign_info != NULL, "assignment node info exists");
  CHECK(assign_info->type != NULL && assign_info->type->kind == TYPE_BUILTIN, "assignment type cached");

  semantic_context_destroy(ctx);
  free(ctx);
  free_tree(root);
  return 0;
}

static int test_function_member_array_annotations(void)
{
  TreeNode_t *root = make_node(NODE_NULL, 1u);
  TreeNode_t *fn = make_node(NODE_FUNCTION, 1u);
  TreeNode_t *fn_ret = make_builtin_type(1u, TYPE_VOID);
  TreeNode_t *block = make_node(NODE_BLOCK, 2u);
  TreeNode_t *struct_decl = make_node(NODE_STRUCT_DECLARATION, 3u);
  TreeNode_t *member_decl = make_node(NODE_STRUCT_MEMBER, 3u);
  TreeNode_t *member_type = make_builtin_type(3u, TYPE_INT);
  TreeNode_t *obj_decl = make_node(NODE_VAR_DECLARATION, 4u);
  TreeNode_t *obj_type = make_builtin_type(4u, TYPE_STRUCT);
  TreeNode_t *tag_id = make_identifier(4u, "P");
  TreeNode_t *arr_decl = make_node(NODE_ARRAY_DECLARATION, 5u);
  TreeNode_t *arr_dim = make_node(NODE_INTEGER, 5u);
  TreeNode_t *arr_type = make_builtin_type(5u, TYPE_INT);
  TreeNode_t *member_expr = make_node(NODE_MEMBER_ACCESS, 6u);
  TreeNode_t *member_base = make_identifier(6u, "p");
  TreeNode_t *member_name = make_identifier(6u, "x");
  TreeNode_t *call = make_node(NODE_FUNCTION_CALL, 7u);
  TreeNode_t *callee = make_identifier(7u, "foo");
  TreeNode_t *array_expr = make_node(NODE_ARRAY_ACCESS, 8u);
  TreeNode_t *array_base = make_identifier(8u, "a");
  TreeNode_t *array_idx = make_node(NODE_INTEGER, 8u);
  semantic_context_t *ctx = NULL;
  semantic_result_t result = {0u, 0u, 0u};
  const sem_node_info_t *callee_info;
  const sem_node_info_t *member_info;
  const sem_node_info_t *array_info;
  int rc;

  CHECK(root && fn && fn_ret && block && struct_decl && member_decl && member_type &&
            obj_decl && obj_type && tag_id && arr_decl && arr_dim && arr_type &&
            member_expr && member_base && member_name && call && callee &&
            array_expr && array_base && array_idx,
        "function/member/array tree allocation");

  fn->nodeData.sVal = "foo";
  struct_decl->nodeData.sVal = "P";
  member_decl->nodeData.sVal = "x";
  obj_decl->nodeData.sVal = "p";
  arr_decl->nodeData.sVal = "a";
  arr_dim->nodeData.dVal = 4;
  array_idx->nodeData.dVal = 1;

  CHECK(append_child(member_decl, member_type) == 0, "attach struct member type");
  CHECK(append_child(struct_decl, member_decl) == 0, "attach struct member");
  CHECK(append_child(obj_type, tag_id) == 0, "attach struct tag identifier");
  CHECK(append_child(obj_decl, obj_type) == 0, "attach object struct type");
  CHECK(append_child(arr_decl, arr_dim) == 0, "attach array dimension");
  CHECK(append_child(arr_decl, arr_type) == 0, "attach array type");
  CHECK(append_child(member_expr, member_base) == 0, "attach member base");
  CHECK(append_child(member_expr, member_name) == 0, "attach member name");
  CHECK(append_child(call, callee) == 0, "attach call callee");
  CHECK(append_child(array_expr, array_base) == 0, "attach array base");
  CHECK(append_child(array_expr, array_idx) == 0, "attach array index");
  CHECK(append_child(fn, fn_ret) == 0, "attach function return type");
  CHECK(append_child(fn, block) == 0, "attach function body");
  CHECK(append_child(block, struct_decl) == 0, "attach struct declaration");
  CHECK(append_child(block, obj_decl) == 0, "attach object declaration");
  CHECK(append_child(block, arr_decl) == 0, "attach array declaration");
  CHECK(append_child(block, member_expr) == 0, "attach member expression");
  CHECK(append_child(block, call) == 0, "attach call expression");
  CHECK(append_child(block, array_expr) == 0, "attach array expression");
  CHECK(append_child(root, fn) == 0, "attach function");

  rc = semantic_analyze(root, "ir_contract.c", &ctx, &result);
  CHECK(rc == 0, "semantic_analyze rc");
  CHECK(ctx != NULL, "context returned");
  CHECK(result.error_count == 0u, "ir-contract sample has no semantic errors");

  callee_info = semantic_get_node_info(ctx, callee);
  member_info = semantic_get_node_info(ctx, member_expr);
  array_info = semantic_get_node_info(ctx, array_expr);

  CHECK(callee_info != NULL, "callee node info exists");
  CHECK(callee_info->symbol != NULL && callee_info->symbol->kind == SYMBOL_FUNCTION, "callee symbol binding");
  CHECK(callee_info->value_kind == SEM_VALUE_FUNCTION_DESIGNATOR, "callee function designator kind");
  CHECK(member_info != NULL, "member access node info exists");
  CHECK(member_info->type != NULL && member_info->type->kind == TYPE_BUILTIN, "member access type cached");
  CHECK(member_info->symbol != NULL && member_info->symbol->kind == SYMBOL_FIELD, "member access field symbol");
  CHECK(member_info->value_kind == SEM_VALUE_LVALUE, "member access lvalue kind");
  CHECK(array_info != NULL, "array access node info exists");
  CHECK(array_info->type != NULL && array_info->type->kind == TYPE_BUILTIN, "array access type cached");
  CHECK(array_info->value_kind == SEM_VALUE_LVALUE, "array access lvalue kind");

  semantic_context_destroy(ctx);
  free(ctx);
  free_tree(root);
  return 0;
}

static int test_memory_class_assignment(void)
{
  /*
   * Tree:
   *   root
   *     var_decl "g"          <- global (depth 0) -> MEMORY_CLASS_GLOBAL
   *       type INT
   *     function "myfn"       <- MEMORY_CLASS_GLOBAL
   *       type VOID  (return)
   *       param "p"           <- MEMORY_CLASS_PARAMETER
   *         type INT
   *       block
   *         var_decl "local"  <- MEMORY_CLASS_STACK
   *           type INT
   */
  TreeNode_t *root   = make_node(NODE_NULL, 1u);
  TreeNode_t *g_decl = make_node(NODE_VAR_DECLARATION, 2u);
  TreeNode_t *g_type = make_builtin_type(2u, TYPE_INT);
  TreeNode_t *fn     = make_node(NODE_FUNCTION, 3u);
  TreeNode_t *fn_ret = make_builtin_type(3u, TYPE_VOID);
  /* Parameters in the AST are NODE_VAR_DECLARATION nodes placed between the
     return-type child and the body child; pass1 identifies them via their
     position and assigns SYMBOL_PARAMETER + MEMORY_CLASS_PARAMETER. */
  TreeNode_t *param  = make_node(NODE_VAR_DECLARATION, 3u);
  TreeNode_t *p_type = make_builtin_type(3u, TYPE_INT);
  TreeNode_t *block  = make_node(NODE_BLOCK, 4u);
  TreeNode_t *l_decl = make_node(NODE_VAR_DECLARATION, 5u);
  TreeNode_t *l_type = make_builtin_type(5u, TYPE_INT);
  semantic_context_t *ctx = NULL;
  semantic_result_t result = {0u, 0u, 0u};
  const sem_node_info_t *g_info;
  const sem_node_info_t *fn_info;
  const sem_node_info_t *p_info;
  const sem_node_info_t *l_info;
  int rc;

  CHECK(root && g_decl && g_type && fn && fn_ret && param && p_type &&
            block && l_decl && l_type,
        "memory_class tree allocation");

  g_decl->nodeData.sVal = "g";
  fn->nodeData.sVal     = "myfn";
  param->nodeData.sVal  = "p";
  l_decl->nodeData.sVal = "local";

  CHECK(append_child(g_decl, g_type) == 0, "attach global type");
  CHECK(append_child(param, p_type)  == 0, "attach param type");
  CHECK(append_child(l_decl, l_type) == 0, "attach local type");
  CHECK(append_child(fn, fn_ret)     == 0, "attach function return type");
  CHECK(append_child(fn, param)      == 0, "attach function param");
  CHECK(append_child(block, l_decl)  == 0, "attach local decl");
  CHECK(append_child(fn, block)      == 0, "attach function body");
  CHECK(append_child(root, g_decl)   == 0, "attach global decl");
  CHECK(append_child(root, fn)       == 0, "attach function");

  rc = semantic_analyze(root, "memory_class.c", &ctx, &result);
  CHECK(rc == 0, "semantic_analyze rc");
  CHECK(ctx != NULL, "context returned");
  CHECK(result.error_count == 0u, "memory_class test has no semantic errors");

  g_info  = semantic_get_node_info(ctx, g_decl);
  fn_info = semantic_get_node_info(ctx, fn);
  p_info  = semantic_get_node_info(ctx, param);
  l_info  = semantic_get_node_info(ctx, l_decl);

  CHECK(g_info  != NULL && g_info->symbol  != NULL, "global symbol bound");
  CHECK(fn_info != NULL && fn_info->symbol != NULL, "function symbol bound");
  CHECK(p_info  != NULL && p_info->symbol  != NULL, "parameter symbol bound");
  CHECK(l_info  != NULL && l_info->symbol  != NULL, "local symbol bound");

  CHECK(g_info->symbol->memory_class  == MEMORY_CLASS_GLOBAL,
        "global var -> MEMORY_CLASS_GLOBAL");
  CHECK(fn_info->symbol->memory_class == MEMORY_CLASS_GLOBAL,
        "function -> MEMORY_CLASS_GLOBAL");
  CHECK(p_info->symbol->memory_class  == MEMORY_CLASS_PARAMETER,
        "parameter -> MEMORY_CLASS_PARAMETER");
  CHECK(l_info->symbol->memory_class  == MEMORY_CLASS_STACK,
        "local var -> MEMORY_CLASS_STACK");

  semantic_context_destroy(ctx);
  free(ctx);
  free_tree(root);
  return 0;
}

static int test_codegen_blocked_flags(void)
{
  /*
   * A float literal inside a function body must carry SEM_NODE_CODEGEN_BLOCKED
   * because the backend has no floating-point support (IR contract §10).
   */
  TreeNode_t *root   = make_node(NODE_NULL, 1u);
  TreeNode_t *fn     = make_node(NODE_FUNCTION, 1u);
  TreeNode_t *fn_ret = make_builtin_type(1u, TYPE_VOID);
  TreeNode_t *block  = make_node(NODE_BLOCK, 2u);
  TreeNode_t *flit   = make_node(NODE_FLOAT, 3u);
  semantic_context_t *ctx = NULL;
  semantic_result_t result = {0u, 0u, 0u};
  const sem_node_info_t *flit_info;
  int rc;

  CHECK(root && fn && fn_ret && block && flit, "codegen-blocked tree allocation");

  fn->nodeData.sVal  = "bar";
  flit->nodeData.fVal = 3.14;

  CHECK(append_child(fn, fn_ret)  == 0, "attach function return type");
  CHECK(append_child(block, flit) == 0, "attach float literal");
  CHECK(append_child(fn, block)   == 0, "attach function body");
  CHECK(append_child(root, fn)    == 0, "attach function");

  rc = semantic_analyze(root, "codegen_blocked.c", &ctx, &result);
  CHECK(rc == 0, "semantic_analyze rc");
  CHECK(ctx != NULL, "context returned");

  flit_info = semantic_get_node_info(ctx, flit);
  CHECK(flit_info != NULL, "float literal node info exists");
  CHECK((flit_info->flags & SEM_NODE_CODEGEN_BLOCKED) != 0u,
        "float literal has SEM_NODE_CODEGEN_BLOCKED set");
  CHECK(flit_info->type != NULL, "float literal type cached");

  semantic_context_destroy(ctx);
  free(ctx);
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
  CHECK(test_semantic_analyze_persistent_context() == 0, "persistent context test");
  CHECK(test_function_member_array_annotations() == 0, "function/member/array annotations test");
  CHECK(test_memory_class_assignment() == 0, "memory_class assignment test");
  CHECK(test_codegen_blocked_flags() == 0, "codegen blocked flags test");

  printf("PASS test_semantic_api\n");
  return 0;
}
