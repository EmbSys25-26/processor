/* 
 * The %code requires block is used to include headers that are needed
 * in the generated parser header (parser.tab.h). 
*/
%code requires{
#include "ASTree.h"
#include "../Util/NodeTypes.h"
}

//--------------------------------------------------------------------------------------------------
// Parser Prologue
//--------------------------------------------------------------------------------------------------
%{
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include "ASTree.h"
#include "../Util/NodeTypes.h"
#include "../Util/logger.h"
#include "ASTPrint.h"
#include "../Semantic/semantic.h"

int yylex(void);
void yyerror(const char *s);
extern FILE* yyin; 

static TreeNode_t* p_treeRoot = NULL;

static int build_tag_declaration_node(TreeNode_t **out_decl,
                                      NodeType_t decl_kind,
                                      const char *tag_name,
                                      TreeNode_t *members)
{
    int rc;
    TreeNode_t *decl = NULL;

    if (!out_decl || !tag_name) {
        return -EINVAL;
    }

    *out_decl = NULL;

    rc = NodeCreate(&decl, decl_kind);
    if (rc < 0) {
        return rc;
    }

    decl->nodeData.sVal = strdup(tag_name);
    if (!decl->nodeData.sVal) {
        NodeFree(decl);
        return -ENOMEM;
    }

    if (members) {
        rc = NodeAddChild(decl, members);
        if (rc < 0) {
            NodeFree(decl);
            return rc;
        }
    }

    *out_decl = decl;
    return 0;
}

static int build_tag_type_node(TreeNode_t **out_type,
                               VarType_t type_kind,
                               NodeType_t decl_kind,
                               char *tag_name,
                               TreeNode_t *members)
{
    int rc;
    TreeNode_t *type_node = NULL;
    TreeNode_t *tag_ident = NULL;
    TreeNode_t *decl_node = NULL;

    if (!out_type || !tag_name) {
        return -EINVAL;
    }

    *out_type = NULL;

    rc = NodeCreate(&type_node, NODE_TYPE);
    if (rc < 0) {
        return rc;
    }
    type_node->nodeData.dVal = type_kind;

    rc = NodeCreate(&tag_ident, NODE_IDENTIFIER);
    if (rc < 0) {
        NodeFree(type_node);
        return rc;
    }
    tag_ident->nodeData.sVal = tag_name;

    rc = NodeAddChild(type_node, tag_ident);
    if (rc < 0) {
        NodeFree(type_node);
        return rc;
    }

    if (members) {
        rc = build_tag_declaration_node(&decl_node, decl_kind, tag_name, members);
        if (rc < 0) {
            NodeFree(type_node);
            return rc;
        }

        rc = NodeAddChild(type_node, decl_node);
        if (rc < 0) {
            NodeFree(type_node);
            return rc;
        }
    }

    *out_type = type_node;
    return 0;
}

static int clone_or_synthesize_tag_declaration(const TreeNode_t *specs, TreeNode_t **out_decl)
{
    const TreeNode_t *it;

    if (!out_decl) {
        return -EINVAL;
    }

    *out_decl = NULL;

    for (it = specs; it != NULL; it = it->p_sibling) {
        const TreeNode_t *tag_ident;
        const TreeNode_t *child;
        NodeType_t decl_kind;

        if (it->nodeType != NODE_TYPE) {
            continue;
        }

        switch ((VarType_t)it->nodeData.dVal) {
            case TYPE_STRUCT:
                decl_kind = NODE_STRUCT_DECLARATION;
                break;
            case TYPE_UNION:
                decl_kind = NODE_UNION_DECLARATION;
                break;
            case TYPE_ENUM:
                decl_kind = NODE_ENUM_DECLARATION;
                break;
            default:
                continue;
        }

        tag_ident = it->p_firstChild;
        if (!tag_ident || tag_ident->nodeType != NODE_IDENTIFIER) {
            continue;
        }

        for (child = tag_ident->p_sibling; child != NULL; child = child->p_sibling) {
            if (child->nodeType == decl_kind) {
                return NodeCloneSubtree(child, out_decl);
            }
        }

        return build_tag_declaration_node(out_decl, decl_kind, tag_ident->nodeData.sVal, NULL);
    }

    return 0;
}

static int is_void_parameter_specifier(const TreeNode_t *specs)
{
    const TreeNode_t *it = specs;
    const TreeNode_t *type_node = NULL;
    size_t type_count = 0u;

    while (it) {
        if (it->nodeType == NODE_TYPE) {
            type_node = it;
            type_count++;
        } else if (it->nodeType == NODE_MODIFIER ||
                   it->nodeType == NODE_SIGN ||
                   it->nodeType == NODE_VISIBILITY) {
            return 0;
        }
        it = it->p_sibling;
    }

    return type_count == 1u &&
           type_node != NULL &&
           type_node->nodeData.dVal == TYPE_VOID &&
           type_node->p_firstChild == NULL;
}

static int build_member_access_node(TreeNode_t **out_node,
                                    NodeType_t access_kind,
                                    TreeNode_t *base_expr,
                                    char *field_name)
{
    int rc;
    TreeNode_t *member_node = NULL;
    TreeNode_t *field_ident = NULL;

    if (!out_node || !base_expr || !field_name) {
        return -EINVAL;
    }

    *out_node = NULL;

    rc = NodeCreate(&member_node, access_kind);
    if (rc < 0) {
        return rc;
    }

    rc = NodeCreate(&field_ident, NODE_IDENTIFIER);
    if (rc < 0) {
        NodeFree(member_node);
        return rc;
    }
    field_ident->nodeData.sVal = field_name;

    rc = NodeAddChild(member_node, base_expr);
    if (rc < 0) {
        NodeFree(member_node);
        return rc;
    }

    rc = NodeAddChild(member_node, field_ident);
    if (rc < 0) {
        NodeFree(member_node);
        return rc;
    }

    *out_node = member_node;
    return 0;
}

static int build_array_access_node(TreeNode_t **out_node,
                                   TreeNode_t *base_expr,
                                   TreeNode_t *index_expr)
{
    int rc;
    TreeNode_t *array_node = NULL;

    if (!out_node || !base_expr || !index_expr) {
        return -EINVAL;
    }

    *out_node = NULL;

    rc = NodeCreate(&array_node, NODE_ARRAY_ACCESS);
    if (rc < 0) {
        return rc;
    }

    rc = NodeAddChild(array_node, base_expr);
    if (rc < 0) {
        NodeFree(array_node);
        return rc;
    }

    rc = NodeAddChild(array_node, index_expr);
    if (rc < 0) {
        NodeFree(array_node);
        return rc;
    }

    *out_node = array_node;
    return 0;
}

static int build_function_call_node(TreeNode_t **out_node,
                                    TreeNode_t *callee_expr,
                                    TreeNode_t *arg_head)
{
    int rc;
    TreeNode_t *call_node = NULL;

    if (!out_node || !callee_expr) {
        return -EINVAL;
    }

    *out_node = NULL;

    rc = NodeCreate(&call_node, NODE_FUNCTION_CALL);
    if (rc < 0) {
        return rc;
    }

    rc = NodeAddChild(call_node, callee_expr);
    if (rc < 0) {
        NodeFree(call_node);
        return rc;
    }

    if (arg_head) {
        rc = NodeAddChild(call_node, arg_head);
        if (rc < 0) {
            NodeFree(call_node);
            return rc;
        }
    }

    *out_node = call_node;
    return 0;
}

static int build_operator_node(TreeNode_t **out_node,
                               long op_kind,
                               TreeNode_t *lhs,
                               TreeNode_t *rhs)
{
    int rc;
    TreeNode_t *op_node = NULL;

    if (!out_node || !lhs) {
        return -EINVAL;
    }

    *out_node = NULL;

    rc = NodeCreate(&op_node, NODE_OPERATOR);
    if (rc < 0) {
        return rc;
    }
    op_node->nodeData.dVal = op_kind;

    rc = NodeAddChild(op_node, lhs);
    if (rc < 0) {
        NodeFree(op_node);
        return rc;
    }

    if (rhs) {
        rc = NodeAddChild(op_node, rhs);
        if (rc < 0) {
            NodeFree(op_node);
            return rc;
        }
    }

    *out_node = op_node;
    return 0;
}
%}

%defines

// %define api.value.type is prefered over #define YYSTYPE
%define api.value.type {ParserObject_t}

//--------------------------------------------------------------------------------------------------
// Token Declarations From Lexer Contract
//--------------------------------------------------------------------------------------------------
%token TOKEN_NUM TOKEN_FNUM TOKEN_CNUM TOKEN_STR TOKEN_ID
%token TOKEN_INT TOKEN_CHAR TOKEN_FLOAT TOKEN_DOUBLE TOKEN_VOID
%token TOKEN_INLINE
%token TOKEN_SIGNED TOKEN_UNSIGNED TOKEN_LONG TOKEN_SHORT
%token TOKEN_STATIC TOKEN_EXTERN TOKEN_CONST TOKEN_VOLATILE
%token TOKEN_STRUCT TOKEN_UNION TOKEN_ENUM TOKEN_SIZEOF
%token TOKEN_IF TOKEN_ELSE TOKEN_SWITCH TOKEN_CASE TOKEN_DEFAULT
%token TOKEN_FOR TOKEN_WHILE TOKEN_DO TOKEN_BREAK TOKEN_CONTINUE TOKEN_RETURN
%token TOKEN_PLUS TOKEN_MINUS TOKEN_ASTERISK TOKEN_DIVIDE TOKEN_MOD
%token TOKEN_INCREMENT TOKEN_DECREMENT
%token TOKEN_ASSIGN
%token TOKEN_PLUS_ASSIGN TOKEN_MINUS_ASSIGN TOKEN_MULTIPLY_ASSIGN
%token TOKEN_DIVIDE_ASSIGN TOKEN_MODULUS_ASSIGN
%token TOKEN_AND_ASSIGN TOKEN_OR_ASSIGN TOKEN_XOR_ASSIGN
%token TOKEN_LEFT_SHIFT_ASSIGN TOKEN_RIGHT_SHIFT_ASSIGN
%token TOKEN_EQUAL TOKEN_NOT_EQUAL
%token TOKEN_LESS_THAN TOKEN_GREATER_THAN
%token TOKEN_LESS_THAN_OR_EQUAL TOKEN_GREATER_THAN_OR_EQUAL
%token TOKEN_LOGICAL_AND TOKEN_LOGICAL_OR TOKEN_LOGICAL_NOT
%token TOKEN_BITWISE_AND TOKEN_BITWISE_OR TOKEN_BITWISE_XOR TOKEN_BITWISE_NOT
%token TOKEN_LEFT_SHIFT TOKEN_RIGHT_SHIFT
%token TOKEN_ARROW TOKEN_ELLIPSIS TOKEN_DOT
%token TOKEN_SEMI TOKEN_COMMA TOKEN_COLON TOKEN_TERNARY
%token TOKEN_LEFT_PARENTHESES TOKEN_RIGHT_PARENTHESES
%token TOKEN_LEFT_BRACE TOKEN_RIGHT_BRACE
%token TOKEN_LEFT_BRACKET TOKEN_RIGHT_BRACKET
%token TOKEN_ERROR

//--------------------------------------------------------------------------------------------------
// Precedence And Associativity
//--------------------------------------------------------------------------------------------------
%nonassoc LOWER_THAN_ELSE //used for if statements without else
%nonassoc TOKEN_ELSE      //ensures closest if gets matched to else

//assignment operators are right associative
%right TOKEN_ASSIGN TOKEN_PLUS_ASSIGN TOKEN_MINUS_ASSIGN TOKEN_MULTIPLY_ASSIGN TOKEN_DIVIDE_ASSIGN TOKEN_MODULUS_ASSIGN TOKEN_AND_ASSIGN TOKEN_OR_ASSIGN TOKEN_XOR_ASSIGN TOKEN_LEFT_SHIFT_ASSIGN TOKEN_RIGHT_SHIFT_ASSIGN

/* Conditional operator */
%right TOKEN_TERNARY TOKEN_COLON

/* Logical operators */
%left TOKEN_LOGICAL_OR
%left TOKEN_LOGICAL_AND

/* Bitwise operators */
%left TOKEN_BITWISE_OR
%left TOKEN_BITWISE_XOR
%left TOKEN_BITWISE_AND

/* Equality */
%left TOKEN_EQUAL TOKEN_NOT_EQUAL

/* Relational */
%left TOKEN_LESS_THAN TOKEN_GREATER_THAN TOKEN_LESS_THAN_OR_EQUAL TOKEN_GREATER_THAN_OR_EQUAL

/* Shift */
%left TOKEN_LEFT_SHIFT TOKEN_RIGHT_SHIFT

/* Additive */
%left TOKEN_PLUS TOKEN_MINUS

/* Multiplicative */
%left TOKEN_ASTERISK TOKEN_DIVIDE TOKEN_MOD

/* Unary operators (use %prec UNARY in grammar rules) */
%right UNARY
%right TOKEN_LOGICAL_NOT TOKEN_BITWISE_NOT
%right TOKEN_SIZEOF

/* Postfix (highest precedence) */
%left TOKEN_DOT TOKEN_ARROW
%left TOKEN_INCREMENT TOKEN_DECREMENT


//Defines the start symbol of the grammar
%start translation_unit 

//--------------------------------------------------------------------------------------------------
// Grammar Rules
//--------------------------------------------------------------------------------------------------
%%

translation_unit
                :   external_declaration
                    {
                        NodeCreate(&$$.treeNode, NODE_TRANSLATION_UNIT);
                        NodeAddChild($$.treeNode, $1.treeNode);
                        p_treeRoot = $$.treeNode;
                    }
                |   translation_unit external_declaration
                    {
                        TreeNode_t* pRoot = $1.treeNode;
                        TreeNode_t* pHead = pRoot->p_firstChild;
                        if (NodeAppendSibling(&pHead, $2.treeNode)) { YYERROR; }
                        pRoot->p_firstChild = pHead;
                        pRoot->childNumber++;
                        $$.treeNode = pRoot;
                        p_treeRoot = $$.treeNode;
                    }
                ;


external_declaration
                :   function_definition { $$.treeNode = $1.treeNode; }
                |   declaration { $$.treeNode = $1.treeNode; }
                ;

//statements are siblings
statement_sequence : %empty          { $$.treeNode = NULL; }
                     | statement_sequence statement
                       {
                           TreeNode_t* pHead = $1.treeNode;
                           if ($2.treeNode != NULL) {
                               if (pHead == NULL) {
                                   pHead = $2.treeNode;
                               } else {
                                   if (NodeAppendSibling(&pHead, $2.treeNode)) { YYERROR; }
                               }
                           }
                           $$.treeNode = pHead;
                       }
                     ;

statement     :   selection_statement { $$.treeNode = $1.treeNode; }
                    |   iteration_statement { $$.treeNode = $1.treeNode; }
                    |   jump_statement { $$.treeNode = $1.treeNode; }
                    |   compound_statement { $$.treeNode = $1.treeNode; }  // everything that is in between { ... }
                    |   declaration { $$.treeNode = $1.treeNode; }
                    |   expression_statement { $$.treeNode = $1.treeNode; }
                    ;

expression_statement
                :   TOKEN_SEMI
                    {
                        $$.treeNode = NULL;
                    }
                |   expression TOKEN_SEMI
                    {
                        $$.treeNode = $1.treeNode;
                    }
                ;

//--------------------------------------------------------------------------------------------------------------------//
// Statements
//--------------------------------------------------------------------------------------------------------------------//

selection_statement : if_statement { $$.treeNode = $1.treeNode; }
                    | switch_statement { $$.treeNode = $1.treeNode; }
                    ;

jump_statement    :   break_statement { $$.treeNode = $1.treeNode; }
                  |   return_statement { $$.treeNode = $1.treeNode; }
                  |   continue_statement { $$.treeNode = $1.treeNode; }
                  ;

iteration_statement  :  do_while_loop { $$.treeNode = $1.treeNode; }
                     |  while_loop { $$.treeNode = $1.treeNode; }
                     |  for_loop { $$.treeNode = $1.treeNode; }
                     ;

compound_statement  :   TOKEN_LEFT_BRACE statement_sequence TOKEN_RIGHT_BRACE      
                        {
                            NodeCreate(&($$.treeNode), NODE_BLOCK);
                            if ($2.treeNode != NULL) {
                                NodeAddChild($$.treeNode, $2.treeNode);
                            }
                        }
                    ;

//RED, GREEN = 5, BLUE 
enum_member_list    :   enum_member { $$.treeNode = $1.treeNode; }
                    |   enum_member_list TOKEN_COMMA enum_member
                        {
                            TreeNode_t* pHead = $1.treeNode;
                            if (NodeAppendSibling(&pHead, $3.treeNode)) { YYERROR; }
                            $$.treeNode = pHead;
                        }
                    |   enum_member_list TOKEN_COMMA   // trailing comma: enum { A, B, }
                        { $$.treeNode = $1.treeNode; }
                    ;

enum_member         :   TOKEN_ID                            // RED
                        {
                            NodeCreate(&($$.treeNode), NODE_ENUM_MEMBER);
                            $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
                        }
                    |   TOKEN_ID TOKEN_ASSIGN TOKEN_NUM     // GREEN = 5, num is always integer
                        {
                            NodeCreate(&($$.treeNode), NODE_ENUM_MEMBER);
                            $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
                            TreeNode_t* pVal;
                            NodeCreate(&pVal, NODE_INTEGER);
                            pVal->nodeData.dVal = $3.nodeData.dVal;  // guarda o valor!
                            NodeAddChild($$.treeNode, pVal);
                        }
                    |   TOKEN_ID TOKEN_ASSIGN TOKEN_MINUS TOKEN_NUM  // BLUE = -1
                        {
                            NodeCreate(&($$.treeNode), NODE_ENUM_MEMBER);
                            $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
                            TreeNode_t* pVal;
                            NodeCreate(&pVal, NODE_INTEGER);
                            pVal->nodeData.dVal = -$4.nodeData.dVal;
                            NodeAddChild($$.treeNode, pVal);
                        }
                    ;

/* list of members inside struct/union --> its defined the same way
e.g: int x; int y;*/
struct_union_member_list  :   struct_member  { $$.treeNode = $1.treeNode; }
                          |   struct_union_member_list struct_member
                              {
                                  TreeNode_t* pHead = $1.treeNode;
                                  if (NodeAppendSibling(&pHead, $2.treeNode)) { YYERROR; }
                                  $$.treeNode = pHead;
                              }
                          ;

// each member: int x;  or  int arr[10];  or  struct Point* next;
struct_member       :   declaration_specifiers declarator TOKEN_SEMI
                        {
                            if (NodeAttachDeclSpecifiers($2.treeNode, $1.treeNode)) { YYERROR; }
                            if ($2.treeNode->nodeType == NODE_VAR_DECLARATION) {
                                $2.treeNode->nodeType = NODE_STRUCT_MEMBER;
                            }
                            NodeFree($1.treeNode);
                            $$.treeNode = $2.treeNode;
                        }
                    ;

//--------------------------------------------------------------------------------------------------------------------//
// Selection statements
//--------------------------------------------------------------------------------------------------------------------//

if_statement    :   TOKEN_IF TOKEN_LEFT_PARENTHESES expression TOKEN_RIGHT_PARENTHESES statement %prec LOWER_THAN_ELSE
                    {
                        NodeCreate(&($$.treeNode), NODE_IF);
                        NodeAddChild($$.treeNode, $3.treeNode);    //condition
                        NodeAddChild($$.treeNode, $5.treeNode);    //if true
                    }
                |   TOKEN_IF TOKEN_LEFT_PARENTHESES expression TOKEN_RIGHT_PARENTHESES statement TOKEN_ELSE statement //if has else
                    {
                        NodeCreate(&($$.treeNode), NODE_IF);
                        NodeAddChild($$.treeNode, $3.treeNode);   //condition
                        NodeAddChild($$.treeNode, $5.treeNode);   //if true
                        NodeAddChild($$.treeNode, $7.treeNode);   //else
                    }
                ;

switch_statement    :   TOKEN_SWITCH TOKEN_LEFT_PARENTHESES expression TOKEN_RIGHT_PARENTHESES TOKEN_LEFT_BRACE switch_body TOKEN_RIGHT_BRACE
                        {
                            NodeCreate(&($$.treeNode), NODE_SWITCH);
                            NodeAddChild($$.treeNode, $3.treeNode);
                            NodeAddChild($$.treeNode, $6.treeNode);
                        }
                    ;

switch_body     :   case_list default_clause
                    {
                        TreeNode_t* pHead = $1.treeNode;
                        if (NodeAppendSibling(&pHead, $2.treeNode)) { YYERROR; }
                        $$.treeNode = pHead;
                    }
                |   case_list
                    {
                        $$.treeNode = $1.treeNode;
                    }
                |   default_clause
                    {
                        $$.treeNode = $1.treeNode;
                    }
                ;

case_list       :   case_clause
                    {
                        $$.treeNode = $1.treeNode;
                    }
                |   case_list case_clause  //multiple cases  case 0: ... case 1 : ...
                    {
                        TreeNode_t* pHead = $1.treeNode;
                        if (NodeAppendSibling(&pHead, $2.treeNode)) { YYERROR; }
                        $$.treeNode = pHead;
                    }
                ;

case_clause     :   TOKEN_CASE TOKEN_NUM TOKEN_COLON statement_sequence   //number
                    {
                          NodeCreate(&($$.treeNode), NODE_CASE);
                          $$.treeNode->nodeData.sVal = NULL;
                          $$.treeNode->nodeData.dVal = $2.nodeData.dVal;
                          NodeAddChild($$.treeNode, $4.treeNode);
                    }
                |   TOKEN_CASE TOKEN_CNUM TOKEN_COLON statement_sequence  //char
                    {
                          NodeCreate(&($$.treeNode), NODE_CASE);
                          $$.treeNode->nodeData.dVal = $2.nodeData.dVal;
                          NodeAddChild($$.treeNode, $4.treeNode);
                    }
                |   TOKEN_CASE TOKEN_ID TOKEN_COLON statement_sequence   // case RED --> enum used
                    {
                          NodeCreate(&($$.treeNode), NODE_CASE);
                          $$.treeNode->nodeData.sVal = $2.nodeData.sVal;  /* guarda o nome */
                          NodeAddChild($$.treeNode, $4.treeNode);
                    }
                ;

default_clause  :   TOKEN_DEFAULT TOKEN_COLON statement_sequence
                    {
                        NodeCreate(&($$.treeNode), NODE_DEFAULT);
                        NodeAddChild($$.treeNode, $3.treeNode);
                    }
                ;

//--------------------------------------------------------------------------------------------------------------------//
// Jump statements
//--------------------------------------------------------------------------------------------------------------------//

continue_statement  :   TOKEN_CONTINUE TOKEN_SEMI
                        { NodeCreate(&($$.treeNode), NODE_CONTINUE); }
                    ;

break_statement     :   TOKEN_BREAK TOKEN_SEMI
                        { NodeCreate(&($$.treeNode), NODE_BREAK); }
                    ;

return_statement    :   TOKEN_RETURN TOKEN_SEMI
                        {
                            NodeCreate(&($$.treeNode), NODE_RETURN);
                        }
                    |   TOKEN_RETURN expression TOKEN_SEMI
                        {
                            NodeCreate(&($$.treeNode), NODE_RETURN);
                            NodeAddChild($$.treeNode, $2.treeNode);
                        }
                    ;

//--------------------------------------------------------------------------------------------------------------------//
// Iteration statements
//--------------------------------------------------------------------------------------------------------------------//

while_loop      :   TOKEN_WHILE TOKEN_LEFT_PARENTHESES expression TOKEN_RIGHT_PARENTHESES statement // while(exp)
                    {
                        NodeCreate(&($$.treeNode), NODE_WHILE);
                        NodeAddChild($$.treeNode, $3.treeNode);    // Condition
                        NodeAddChild($$.treeNode, $5.treeNode);    // if true
                    }
                ;

// normally statement would be compound statement because of  {...}
do_while_loop   :   TOKEN_DO statement TOKEN_WHILE TOKEN_LEFT_PARENTHESES expression TOKEN_RIGHT_PARENTHESES TOKEN_SEMI
                    {
                        NodeCreate(&($$.treeNode), NODE_DO_WHILE);
                        NodeAddChild($$.treeNode, $2.treeNode);
                        NodeAddChild($$.treeNode, $5.treeNode);
                    }
                ;
//for(for_init_field, for_condition, for_assignment_field) statement (to allow compound)
for_loop        :   TOKEN_FOR TOKEN_LEFT_PARENTHESES for_init_field TOKEN_SEMI for_condition TOKEN_SEMI for_assignment_field TOKEN_RIGHT_PARENTHESES statement
                    {
                        TreeNode_t* pNull;

                        NodeCreate(&($$.treeNode), NODE_FOR);

                        if ($3.treeNode != NULL) {
                            NodeAddChild($$.treeNode, $3.treeNode);
                        } else {
                            NodeCreate(&pNull, NODE_NULL);
                            NodeAddChild($$.treeNode, pNull);
                        }

                        if ($5.treeNode != NULL) {
                            NodeAddChild($$.treeNode, $5.treeNode);
                        } else {
                            NodeCreate(&pNull, NODE_NULL);
                            NodeAddChild($$.treeNode, pNull);
                        }

                        if ($7.treeNode != NULL) {
                            NodeAddChild($$.treeNode, $7.treeNode);
                        } else {
                            NodeCreate(&pNull, NODE_NULL);
                            NodeAddChild($$.treeNode, pNull);
                        }

                        if ($9.treeNode != NULL) {
                            NodeAddChild($$.treeNode, $9.treeNode);
                        } else {
                            NodeCreate(&pNull, NODE_NULL);
                            NodeAddChild($$.treeNode, pNull);
                        }
                    }
                ;

for_init_field  :   %empty { $$.treeNode = NULL; }
                |   declaration_specifiers init_declarator_list
                    {
                        TreeNode_t *pNode = $2.treeNode;
                        do {
                            if (pNode->nodeType == NODE_VAR_DECLARATION ||
                                pNode->nodeType == NODE_ARRAY_DECLARATION) {
                                if (NodeAttachDeclSpecifiers(pNode, $1.treeNode)) { YYERROR; }
                            }
                            pNode = pNode->p_sibling;
                        } while (pNode != NULL);
                        NodeFree($1.treeNode);
                        $$.treeNode = $2.treeNode;
                    }
                |   expression
                    {
                        $$.treeNode = $1.treeNode;
                    }
                ;
for_condition     :   %empty { $$.treeNode = NULL; }
                  |   expression { $$.treeNode = $1.treeNode; }   //for (.., i < 0, ...)
                  ;

for_assignment_field    :   %empty { $$.treeNode = NULL; }
                        |   expression { $$.treeNode = $1.treeNode; }
                        ;

//--------------------------------------------------------------------------------------------------------------------//
// Functions
//--------------------------------------------------------------------------------------------------------------------//

function_definition :   declaration_specifiers declarator compound_statement
                        {
                            if ($2.treeNode->nodeType != NODE_FUNCTION) { YYERROR; }
                            if (NodeAttachDeclSpecifiers($2.treeNode, $1.treeNode)) { YYERROR; }
                            NodeFree($1.treeNode);
                            $$.treeNode = $2.treeNode;
                            NodeAddChild($$.treeNode, $3.treeNode);
                        }
                    ;

//parameter list for function declarators
parameter_list_opt
               :    %empty  { $$.treeNode = NULL; }

	           |    parameter_list_opt TOKEN_COMMA TOKEN_ELLIPSIS
                    {
                        TreeNode_t* pNode;
                        TreeNode_t* p_Head = $1.treeNode;
                        NodeCreate(&pNode, NODE_PARAMETER);
                        pNode->nodeData.sVal = strdup("...");
                        if (NodeAppendSibling(&p_Head, pNode)) { YYERROR; }
                        $$.treeNode = p_Head;
                    }
               |    parameter_list_opt TOKEN_COMMA param_declaration
                    {
                        TreeNode_t* p_Head = $1.treeNode;
                        if (NodeAppendSibling(&p_Head, $3.treeNode)) { YYERROR; }
                        $$.treeNode = p_Head;
                    }
               |    param_declaration  { $$.treeNode = $1.treeNode; }
               ;

// declaration of function parameters
param_declaration   :   declaration_specifiers declarator
                        {
                            if (NodeAttachDeclSpecifiers($2.treeNode, $1.treeNode)) { YYERROR; }
                            NodeFree($1.treeNode);
                            $$.treeNode = $2.treeNode;
                        }
                    |   declaration_specifiers  // void func(int) - unnamed parameter
                        {
                            if (is_void_parameter_specifier($1.treeNode)) {
                                $$.treeNode = NULL;
                            } else {
                                NodeCreate(&($$.treeNode), NODE_VAR_DECLARATION);
                                if (NodeAddChildCloneChain($$.treeNode, $1.treeNode)) { YYERROR; }
                            }
                            NodeFree($1.treeNode);
                        }
                   ;



//--------------------------------------------------------------------------------------------------------------------//
// Type Specifiers (variables and funtions)
//--------------------------------------------------------------------------------------------------------------------//

// (int)3.14 or (int*) ptr or (float) 5
type_name           :   all_type_specifiers
                        {
                            $$.treeNode = $1.treeNode;
                        }
                    ;

type_cast_specifier :   TOKEN_LEFT_PARENTHESES type_name TOKEN_RIGHT_PARENTHESES //(int)a
                        {
                            NodeCreate(&($$.treeNode), NODE_TYPE_CAST);
                            NodeAddChild($$.treeNode, $2.treeNode);
                        }
                    ;


all_type_specifiers  :   type_specifier { $$.treeNode = $1.treeNode; }
                     |   type_pointer { $$.treeNode = $1.treeNode; }
                     ;

type_pointer        :   type_specifier TOKEN_ASTERISK    //int*  or other type
                        {
                            NodeCreate(&($$.treeNode), NODE_POINTER);
                            NodeAddChild($$.treeNode, $1.treeNode);
                        }
                    |   type_pointer TOKEN_ASTERISK    //int**...
                        {
                            NodeCreate(&($$.treeNode), NODE_POINTER);
                            NodeAddChild($$.treeNode, $1.treeNode);
                        }
                    ;

enum_specifier  :   TOKEN_ENUM TOKEN_ID
                    {
                        if (build_tag_type_node(&$$.treeNode,
                                                TYPE_ENUM,
                                                NODE_ENUM_DECLARATION,
                                                $2.nodeData.sVal,
                                                NULL) < 0) { YYERROR; }
                    }
                |   TOKEN_ENUM TOKEN_ID TOKEN_LEFT_BRACE enum_member_list TOKEN_RIGHT_BRACE
                    {
                        if (build_tag_type_node(&$$.treeNode,
                                                TYPE_ENUM,
                                                NODE_ENUM_DECLARATION,
                                                $2.nodeData.sVal,
                                                $4.treeNode) < 0) { YYERROR; }
                    }
                ;

struct_specifier:   TOKEN_STRUCT TOKEN_ID
                    {
                        if (build_tag_type_node(&$$.treeNode,
                                                TYPE_STRUCT,
                                                NODE_STRUCT_DECLARATION,
                                                $2.nodeData.sVal,
                                                NULL) < 0) { YYERROR; }
                    }
                |   TOKEN_STRUCT TOKEN_ID TOKEN_LEFT_BRACE struct_union_member_list TOKEN_RIGHT_BRACE
                    {
                        if (build_tag_type_node(&$$.treeNode,
                                                TYPE_STRUCT,
                                                NODE_STRUCT_DECLARATION,
                                                $2.nodeData.sVal,
                                                $4.treeNode) < 0) { YYERROR; }
                    }
                ;

union_specifier :   TOKEN_UNION TOKEN_ID
                    {
                        if (build_tag_type_node(&$$.treeNode,
                                                TYPE_UNION,
                                                NODE_UNION_DECLARATION,
                                                $2.nodeData.sVal,
                                                NULL) < 0) { YYERROR; }
                    }
                |   TOKEN_UNION TOKEN_ID TOKEN_LEFT_BRACE struct_union_member_list TOKEN_RIGHT_BRACE
                    {
                        if (build_tag_type_node(&$$.treeNode,
                                                TYPE_UNION,
                                                NODE_UNION_DECLARATION,
                                                $2.nodeData.sVal,
                                                $4.treeNode) < 0) { YYERROR; }
                    }
                ;

//can be a type or not a type by themselves --> long and short are not a type by themselves
type_specifier :   TOKEN_CHAR
                        {
                            NodeCreate(&($$.treeNode), NODE_TYPE);
                            $$.treeNode->nodeData.dVal = TYPE_CHAR;
                        }
                    |   TOKEN_SHORT
                        {
                            NodeCreate(&($$.treeNode), NODE_TYPE);
                            $$.treeNode->nodeData.dVal = TYPE_SHORT;
                        }
                    |   TOKEN_INT
                        {
                            NodeCreate(&($$.treeNode), NODE_TYPE);
                            $$.treeNode->nodeData.dVal = TYPE_INT;
                        }
                    |   TOKEN_LONG
                        {
                            NodeCreate(&($$.treeNode), NODE_TYPE);
                            $$.treeNode->nodeData.dVal = TYPE_LONG;
                        }
                    |   TOKEN_FLOAT
                            { NodeCreate(&($$.treeNode), NODE_TYPE);
                            $$.treeNode->nodeData.dVal = TYPE_FLOAT;
                        }
                    |   TOKEN_DOUBLE
                        {
                            NodeCreate(&($$.treeNode), NODE_TYPE);
                            $$.treeNode->nodeData.dVal = TYPE_DOUBLE;
                        }
                    |   TOKEN_VOID
                        {
                            NodeCreate(&($$.treeNode), NODE_TYPE);
                            $$.treeNode->nodeData.dVal = TYPE_VOID;
                        }
                    |   struct_specifier
                        {
                            $$.treeNode = $1.treeNode;
                        }
                    |   union_specifier
                        {
                            $$.treeNode = $1.treeNode;
                        }
                    |   enum_specifier
                        {
                            $$.treeNode = $1.treeNode;
                        }
                    ;

storage_class_specifier    :    TOKEN_STATIC
                             {
                                 NodeCreate(&($$.treeNode), NODE_VISIBILITY);
                                 $$.treeNode->nodeData.dVal = VIS_STATIC;
                             }
                         |   TOKEN_EXTERN
                             {
                                 NodeCreate(&($$.treeNode), NODE_VISIBILITY);
                                 $$.treeNode->nodeData.dVal = VIS_EXTERN;
                             }
                         ;

function_specifier         :    TOKEN_INLINE
                             {
                                 NodeCreate(&($$.treeNode), NODE_VISIBILITY);
                                 $$.treeNode->nodeData.dVal = VIS_INLINE;
                             }
                         ;

type_qualifier      :    TOKEN_CONST
                        {
                        NodeCreate(&($$.treeNode), NODE_MODIFIER);
                        $$.treeNode->nodeData.dVal = (long int) MOD_CONST;
                        }
                   |    TOKEN_VOLATILE
                        {
                        NodeCreate(&($$.treeNode), NODE_MODIFIER);
                        $$.treeNode->nodeData.dVal = (long int) MOD_VOLATILE;
                        }
                   ;

sign_specifier      :   TOKEN_SIGNED
                        {
                            NodeCreate(&($$.treeNode), NODE_SIGN);
                            $$.treeNode->nodeData.dVal = (long int) SIGN_SIGNED;
                        }
                    |   TOKEN_UNSIGNED
                        {
                            NodeCreate(&($$.treeNode), NODE_SIGN);
                            $$.treeNode->nodeData.dVal = (long int) SIGN_UNSIGNED;
                        }
                    ;


//--------------------------------------------------------------------------------------------------------------------//
// Declarations
//--------------------------------------------------------------------------------------------------------------------//

declaration_specifier  :   storage_class_specifier
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   type_specifier
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   type_qualifier
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   function_specifier
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   sign_specifier
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        ;

declaration_specifiers :   declaration_specifier
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   declaration_specifiers declaration_specifier
                            {
                                TreeNode_t *pHead = $1.treeNode;

                                if ($2.treeNode->nodeType == NODE_TYPE) {
                                    $2.treeNode->p_sibling = pHead;
                                    pHead = $2.treeNode;
                                } else {
                                    if (NodeAppendSibling(&pHead, $2.treeNode)) { YYERROR; }
                                }

                                $$.treeNode = pHead;
                            }
                        ;

pointer_prefix   :   TOKEN_ASTERISK
                    {
                        NodeCreate(&$$.treeNode, NODE_POINTER);
                    }
                |   TOKEN_ASTERISK pointer_prefix
                    {
                        NodeCreate(&$$.treeNode, NODE_POINTER);
                        NodeAddChild($$.treeNode, $2.treeNode);
                    }
                ;

declaration :   declaration_specifiers init_declarator_list_opt TOKEN_SEMI
                    {
                        TreeNode_t *result = NULL;

                        if ($2.treeNode != NULL) {
                            TreeNode_t *pNode = $2.treeNode;
                            while (pNode != NULL) {
                                if (pNode->nodeType == NODE_VAR_DECLARATION ||
                                    pNode->nodeType == NODE_ARRAY_DECLARATION ||
                                    pNode->nodeType == NODE_FUNCTION) {
                                    if (NodeAttachDeclSpecifiers(pNode, $1.treeNode)) { YYERROR; }
                                }
                                pNode = pNode->p_sibling;
                            }

                            result = $2.treeNode;
                        } else {
                            if (clone_or_synthesize_tag_declaration($1.treeNode, &result) < 0) { YYERROR; }
                        }

                        NodeFree($1.treeNode);
                        $$.treeNode = result;
                    }
                ;

init_declarator_list_opt
                        :   %empty
                            {
                                $$.treeNode = NULL;
                            }
                        |   init_declarator_list
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        ;

init_declarator_list    :   init_declarator
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   init_declarator_list TOKEN_COMMA init_declarator
                            {
                                TreeNode_t *pHead = $1.treeNode;
                                if (NodeAppendSibling(&pHead, $3.treeNode)) { YYERROR; }
                                $$.treeNode = pHead;
                            }
                        ;

init_declarator         :   declarator
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   declarator TOKEN_ASSIGN initializer
                            {
                                TreeNode_t *pAssign;
                                TreeNode_t *pId;
                                TreeNode_t *pHead = $1.treeNode;

                                NodeCreate(&pAssign, NODE_OPERATOR);
                                pAssign->nodeData.dVal = OP_ASSIGN;
                                NodeAddNewChild(pAssign, &pId, NODE_IDENTIFIER);
                                pId->nodeData.sVal = strdup($1.treeNode->nodeData.sVal);
                                if (!pId->nodeData.sVal) { YYERROR; }
                                NodeAddChild(pAssign, $3.treeNode);
                                if (NodeAppendSibling(&pHead, pAssign)) { YYERROR; }
                                $$.treeNode = pHead;
                            }
                        ;

initializer             :   assignment_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        ;

declarator              :   direct_declarator
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   pointer_prefix direct_declarator
                            {
                                if ($2.treeNode->nodeType == NODE_FUNCTION) {
                                    $1.treeNode->p_sibling = $2.treeNode->p_firstChild;
                                    $2.treeNode->p_firstChild = $1.treeNode;
                                    $2.treeNode->childNumber++;
                                } else {
                                    NodeAddChild($2.treeNode, $1.treeNode);
                                }
                                $$.treeNode = $2.treeNode;
                            }
                        ;

direct_declarator       :   TOKEN_ID
                            {
                                NodeCreate(&$$.treeNode, NODE_VAR_DECLARATION);
                                $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
                            }
                        |   TOKEN_ID arr_size
                            {
                                NodeCreate(&$$.treeNode, NODE_ARRAY_DECLARATION);
                                $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
                                NodeAddChild($$.treeNode, $2.treeNode);
                            }
                        |   TOKEN_ID TOKEN_LEFT_PARENTHESES parameter_list_opt TOKEN_RIGHT_PARENTHESES
                            {
                                NodeCreate(&$$.treeNode, NODE_FUNCTION);
                                $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
                                if ($3.treeNode != NULL) {
                                    NodeAddChild($$.treeNode, $3.treeNode);
                                }
                            }
                        ;

arr_size    :   TOKEN_LEFT_BRACKET expression TOKEN_RIGHT_BRACKET   //[] inside can be num, func, expressions
                { $$.treeNode = $2.treeNode; }
            |   TOKEN_LEFT_BRACKET TOKEN_RIGHT_BRACKET
                { NodeCreate(&($$.treeNode), NODE_NULL); }
            |   arr_size TOKEN_LEFT_BRACKET expression TOKEN_RIGHT_BRACKET  //[][] to define matrix
                {
                    TreeNode_t* pHead = $1.treeNode;
                    if (NodeAppendSibling(&pHead, $3.treeNode)) { YYERROR; }
                    $$.treeNode = pHead;
                }
            ;



//--------------------------------------------------------------------------------------------------------------------//
// Expressions (C11 N1570 6.5)
//--------------------------------------------------------------------------------------------------------------------//

expression              :   assignment_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   expression TOKEN_COMMA assignment_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_COMMA, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        ;

assignment_expression   :   conditional_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   unary_expression assignment_operator assignment_expression
                            {
                                if ($2.treeNode->nodeType != NODE_OPERATOR) { YYERROR; }
                                if (NodeAddChild($2.treeNode, $1.treeNode) < 0) { YYERROR; }
                                if (NodeAddChild($2.treeNode, $3.treeNode) < 0) { YYERROR; }
                                $$.treeNode = $2.treeNode;
                            }
                        ;

conditional_expression  :   logical_or_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   logical_or_expression TOKEN_TERNARY expression TOKEN_COLON conditional_expression
                            {
                                NodeCreate(&($$.treeNode), NODE_TERNARY);
                                NodeAddChild($$.treeNode, $1.treeNode);
                                NodeAddChild($$.treeNode, $3.treeNode);
                                NodeAddChild($$.treeNode, $5.treeNode);
                            }
                        ;

logical_or_expression   :   logical_and_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   logical_or_expression TOKEN_LOGICAL_OR logical_and_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_LOGICAL_OR, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        ;

logical_and_expression  :   inclusive_or_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   logical_and_expression TOKEN_LOGICAL_AND inclusive_or_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_LOGICAL_AND, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        ;

inclusive_or_expression :   exclusive_or_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   inclusive_or_expression TOKEN_BITWISE_OR exclusive_or_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_BITWISE_OR, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        ;

exclusive_or_expression :   and_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   exclusive_or_expression TOKEN_BITWISE_XOR and_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_BITWISE_XOR, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        ;

and_expression          :   equality_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   and_expression TOKEN_BITWISE_AND equality_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_BITWISE_AND, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        ;

equality_expression     :   relational_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   equality_expression TOKEN_EQUAL relational_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_EQUAL, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        |   equality_expression TOKEN_NOT_EQUAL relational_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_NOT_EQUAL, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        ;

relational_expression   :   shift_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   relational_expression TOKEN_LESS_THAN shift_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_LESS_THAN, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        |   relational_expression TOKEN_GREATER_THAN shift_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_GREATER_THAN, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        |   relational_expression TOKEN_LESS_THAN_OR_EQUAL shift_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_LESS_THAN_OR_EQUAL, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        |   relational_expression TOKEN_GREATER_THAN_OR_EQUAL shift_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_GREATER_THAN_OR_EQUAL, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        ;

shift_expression        :   additive_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   shift_expression TOKEN_LEFT_SHIFT additive_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_LEFT_SHIFT, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        |   shift_expression TOKEN_RIGHT_SHIFT additive_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_RIGHT_SHIFT, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        ;

additive_expression     :   multiplicative_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   additive_expression TOKEN_PLUS multiplicative_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_PLUS, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        |   additive_expression TOKEN_MINUS multiplicative_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_MINUS, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        ;

multiplicative_expression
                        :   cast_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   multiplicative_expression TOKEN_ASTERISK cast_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_MULTIPLY, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        |   multiplicative_expression TOKEN_DIVIDE cast_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_DIVIDE, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        |   multiplicative_expression TOKEN_MOD cast_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_MODULE, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        ;

cast_expression         :   unary_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   type_cast_specifier cast_expression
                            {
                                if (NodeAddChild($1.treeNode, $2.treeNode) < 0) { YYERROR; }
                                $$.treeNode = $1.treeNode;
                            }
                        ;

unary_expression        :   postfix_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   TOKEN_INCREMENT unary_expression
                            {
                                NodeCreate(&($$.treeNode), NODE_PRE_INC);
                                NodeAddChild($$.treeNode, $2.treeNode);
                            }
                        |   TOKEN_DECREMENT unary_expression
                            {
                                NodeCreate(&($$.treeNode), NODE_PRE_DEC);
                                NodeAddChild($$.treeNode, $2.treeNode);
                            }
                        |   TOKEN_BITWISE_AND cast_expression
                            {
                                NodeCreate(&($$.treeNode), NODE_REFERENCE);
                                NodeAddChild($$.treeNode, $2.treeNode);
                            }
                        |   TOKEN_ASTERISK cast_expression
                            {
                                NodeCreate(&($$.treeNode), NODE_POINTER_CONTENT);
                                NodeAddChild($$.treeNode, $2.treeNode);
                            }
                        |   TOKEN_PLUS cast_expression
                            {
                                $$.treeNode = $2.treeNode;
                            }
                        |   TOKEN_MINUS cast_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_UNARY_MINUS, $2.treeNode, NULL) < 0) { YYERROR; }
                            }
                        |   TOKEN_LOGICAL_NOT cast_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_LOGICAL_NOT, $2.treeNode, NULL) < 0) { YYERROR; }
                            }
                        |   TOKEN_BITWISE_NOT cast_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_BITWISE_NOT, $2.treeNode, NULL) < 0) { YYERROR; }
                            }
                        |   TOKEN_SIZEOF unary_expression
                            {
                                if (build_operator_node(&$$.treeNode, OP_SIZEOF, $2.treeNode, NULL) < 0) { YYERROR; }
                            }
                        |   TOKEN_SIZEOF TOKEN_LEFT_PARENTHESES type_name TOKEN_RIGHT_PARENTHESES
                            {
                                if (build_operator_node(&$$.treeNode, OP_SIZEOF, $3.treeNode, NULL) < 0) { YYERROR; }
                            }
                        ;

postfix_expression      :   primary_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   postfix_expression TOKEN_LEFT_BRACKET expression TOKEN_RIGHT_BRACKET
                            {
                                if (build_array_access_node(&$$.treeNode, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        |   postfix_expression TOKEN_LEFT_PARENTHESES argument_expression_list_opt TOKEN_RIGHT_PARENTHESES
                            {
                                if (build_function_call_node(&$$.treeNode, $1.treeNode, $3.treeNode) < 0) { YYERROR; }
                            }
                        |   postfix_expression TOKEN_DOT TOKEN_ID
                            {
                                if (build_member_access_node(&$$.treeNode, NODE_MEMBER_ACCESS, $1.treeNode, $3.nodeData.sVal) < 0) { YYERROR; }
                            }
                        |   postfix_expression TOKEN_ARROW TOKEN_ID
                            {
                                if (build_member_access_node(&$$.treeNode, NODE_PTR_MEMBER_ACCESS, $1.treeNode, $3.nodeData.sVal) < 0) { YYERROR; }
                            }
                        |   postfix_expression TOKEN_INCREMENT
                            {
                                NodeCreate(&($$.treeNode), NODE_POST_INC);
                                NodeAddChild($$.treeNode, $1.treeNode);
                            }
                        |   postfix_expression TOKEN_DECREMENT
                            {
                                NodeCreate(&($$.treeNode), NODE_POST_DEC);
                                NodeAddChild($$.treeNode, $1.treeNode);
                            }
                        ;

primary_expression      :   TOKEN_ID
                            {
                                NodeCreate(&($$.treeNode), NODE_IDENTIFIER);
                                $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
                            }
                        |   TOKEN_NUM
                            {
                                NodeCreate(&($$.treeNode), NODE_INTEGER);
                                $$.treeNode->nodeData.dVal = $1.nodeData.dVal;
                            }
                        |   TOKEN_FNUM
                            {
                                NodeCreate(&($$.treeNode), NODE_FLOAT);
                                $$.treeNode->nodeData.fVal = $1.nodeData.fVal;
                            }
                        |   TOKEN_CNUM
                            {
                                NodeCreate(&($$.treeNode), NODE_CHAR);
                                $$.treeNode->nodeData.dVal = $1.nodeData.dVal;
                            }
                        |   TOKEN_STR
                            {
                                NodeCreate(&($$.treeNode), NODE_STRING);
                                $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
                            }
                        |   TOKEN_LEFT_PARENTHESES expression TOKEN_RIGHT_PARENTHESES
                            {
                                $$.treeNode = $2.treeNode;
                            }
                        ;

argument_expression_list_opt
                        :   %empty
                            {
                                $$.treeNode = NULL;
                            }
                        |   argument_expression_list
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        ;

argument_expression_list
                        :   assignment_expression
                            {
                                $$.treeNode = $1.treeNode;
                            }
                        |   argument_expression_list TOKEN_COMMA assignment_expression
                            {
                                TreeNode_t *pHead = $1.treeNode;
                                if (NodeAppendSibling(&pHead, $3.treeNode)) { YYERROR; }
                                $$.treeNode = pHead;
                            }
                        ;

assignment_operator    :   TOKEN_ASSIGN
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_ASSIGN;
                            }
                        |   TOKEN_PLUS_ASSIGN
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_PLUS_ASSIGN;
                            }
                        |   TOKEN_MINUS_ASSIGN
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_MINUS_ASSIGN;
                            }
                        |   TOKEN_MODULUS_ASSIGN
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_MODULUS_ASSIGN;
                            }
                        |   TOKEN_LEFT_SHIFT_ASSIGN
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_LEFT_SHIFT_ASSIGN;
                            }
                        |   TOKEN_RIGHT_SHIFT_ASSIGN
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_RIGHT_SHIFT_ASSIGN;
                            }
                        |   TOKEN_AND_ASSIGN
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_BITWISE_AND_ASSIGN;
                            }
                        |   TOKEN_OR_ASSIGN
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_BITWISE_OR_ASSIGN;
                            }
                        |   TOKEN_XOR_ASSIGN
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_BITWISE_XOR_ASSIGN;
                            }
                        |   TOKEN_MULTIPLY_ASSIGN
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_MULTIPLY_ASSIGN;
                            }
                        |   TOKEN_DIVIDE_ASSIGN
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_DIVIDE_ASSIGN;
                            }
                        ;

//--------------------------------------------------------------------------------------------------
// Parser Support Code
//--------------------------------------------------------------------------------------------------
%%

void yyerror(const char *s)
{
    extern int yylineno;
    extern char* yytext;
    fprintf(stderr, "Parse error: %s at line %d, near token '%s'\n", 
            s, yylineno, yytext);
}

int main(int argc, char* argv[])
{
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <file.c>\n", argv[0]);
        return 1;
    }

    FILE* f = fopen(argv[1], "r");
    if (!f) {
        fprintf(stderr, "Error: cannot open file '%s'\n", argv[1]);
        return 1;
    }

    yyin = f;  // diz ao flex para ler deste ficheiro em vez de stdin

    int result = yyparse();
    fclose(f);

    if (result == 0) {
        printf("Parse succeeded. AST:\n");
        ASTPrint(p_treeRoot);

        semantic_result_t sem_result = semantic_run(p_treeRoot, argv[1]);
        fprintf(stderr,
                "Semantic summary: errors=%zu warnings=%zu scopes=%zu\n",
                sem_result.error_count,
                sem_result.warning_count,
                sem_result.scope_count);

        if (sem_result.error_count > 0u) {
            return 2;
        }
    }
    return result;
}
