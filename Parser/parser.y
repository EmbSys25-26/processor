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
static char* currentFunction = NULL;

//for define and undef directives
extern char pp_name[256];
extern char pp_value[512];

//for preprocessor #define/#undef directives
extern char pp_name[256];
extern char pp_value[512];
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
%token TOKEN_PP_DEFINE TOKEN_PP_UNDEF 
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
%token TOKEN_EOF TOKEN_ERROR

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
%start program 

//--------------------------------------------------------------------------------------------------
// Grammar Rules
//--------------------------------------------------------------------------------------------------
%%

program         :   program TOKEN_EOF
                    {
                        p_treeRoot = $1.treeNode;
                        LOG_DEBUG("Reached end of file!\n");
                        return 0;
                    }
                |   program global_statement
                    {
                        TreeNode_t* p_Head = $1.treeNode;
                        if ($2.treeNode != NULL) {
                            if (NodeAppendSibling(&p_Head, $2.treeNode)) { YYERROR; }
                        }
                        $$.treeNode = p_Head;
                    }
                |   global_statement
                    {
                        $$.treeNode = $1.treeNode;
                    }
                ;


global_statement    :   type_declaration { $$.treeNode = $1.treeNode; } 
		            |   var_declaration { $$.treeNode = $1.treeNode; }
                    |   function_prototype { $$.treeNode = $1.treeNode; }
                    |   function_definition { $$.treeNode = $1.treeNode; }
                    |   def_undef_definition { $$.treeNode = $1.treeNode; }
                    |   TOKEN_SEMI { $$.treeNode = NULL; }  //empty statement
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
                    |   var_declaration { $$.treeNode = $1.treeNode; }  //int x=5;
                    |   var_assignment { $$.treeNode = $1.treeNode; }  //x=5;
                    |   function_definition { $$.treeNode = $1.treeNode; }
                    |   exp TOKEN_SEMI { $$.treeNode = $1.treeNode; } //e.g. for sizeof
                    ;
                    
//--------------------------------------------------------------------------------------------------------------------//
// Pre-processor
//--------------------------------------------------------------------------------------------------------------------//
                    
def_undef_definition    : define    { $$.treeNode = $1.treeNode; }
                        | undef     { $$.treeNode = $1.treeNode; }
                        ;

define  :   TOKEN_PP_DEFINE  //#define MAX 10
            {
                NodeCreate(&($$.treeNode), NODE_PP_DEFINE);
                $$.treeNode->nodeData.sVal = strdup(pp_name);  //MAX

                if (pp_value[0] != '\0') {
                    TreeNode_t* pVal;
                    NodeCreate(&pVal, NODE_STRING);
                    pVal->nodeData.sVal = strdup(pp_value);  //10
                    NodeAddChild($$.treeNode, pVal);
                }
            }
        ;

undef   :   TOKEN_PP_UNDEF    //#UNDEF MAX
            {
                NodeCreate(&($$.treeNode), NODE_PP_UNDEF);
                $$.treeNode->nodeData.sVal = strdup(pp_name);
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

type_declaration    :  enum_declaration { $$.treeNode = $1.treeNode; }
                    |  struct_declaration { $$.treeNode = $1.treeNode; }
                    |  union_declaration { $$.treeNode = $1.treeNode; }
                    ;
                                                                          
compound_statement  :   TOKEN_LEFT_BRACE statement_sequence TOKEN_RIGHT_BRACE      
                        {
                            if ($2.treeNode != NULL) {
                                TreeNode_t* pEnd;
                                TreeNode_t* pStart;
                                TreeNode_t* pHead;
                                NodeCreate(&pEnd,   NODE_END_SCOPE);
                                NodeCreate(&pStart, NODE_START_SCOPE);
                                pHead = $2.treeNode;
                                if (NodeAppendSibling(&pHead, pEnd))   { YYERROR; }
                                if (NodeAppendSibling(&pStart, pHead)) { YYERROR; }
                                $$.treeNode = pStart;
                            } else {
                                TreeNode_t* pNull;
                                NodeCreate(&pNull, NODE_NULL);
                                $$.treeNode = pNull;
                            }
                        }
                    ;

//--------------------------------------------------------------------------------------------------------------------//
// Type declarations
//--------------------------------------------------------------------------------------------------------------------//

// enum Color { enum_member_list};
enum_declaration    :   TOKEN_ENUM TOKEN_ID TOKEN_LEFT_BRACE enum_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI
                        {
                            NodeCreate(&($$.treeNode), NODE_ENUM_DECLARATION);
                            $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                            NodeAddChild($$.treeNode, $4.treeNode);
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

// struct Point { struct_union_member_list};
struct_declaration  :   TOKEN_STRUCT TOKEN_ID TOKEN_LEFT_BRACE struct_union_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI
                        {
                            NodeCreate(&($$.treeNode), NODE_STRUCT_DECLARATION);
                            $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                            NodeAddChild($$.treeNode, $4.treeNode);
                        }
                    ;

// union Data { int i; float f; };
union_declaration   :   TOKEN_UNION TOKEN_ID TOKEN_LEFT_BRACE struct_union_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI
                        {
                            NodeCreate(&($$.treeNode), NODE_UNION_DECLARATION);
                            $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                            NodeAddChild($$.treeNode, $4.treeNode);
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
struct_member       :   var_preamble TOKEN_ID TOKEN_SEMI
                        {
                            NodeCreate(&($$.treeNode), NODE_STRUCT_MEMBER);
                            $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                            NodeAddChild($$.treeNode, $1.treeNode);
                        }
                    |   var_preamble TOKEN_ID arr_size TOKEN_SEMI
                        {
                            NodeCreate(&($$.treeNode), NODE_ARRAY_DECLARATION);
                            $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                            NodeAddChild($$.treeNode, $1.treeNode);
                            NodeAddChild($$.treeNode, $3.treeNode);
                        }
                    ;

//--------------------------------------------------------------------------------------------------------------------//
// Selection statements
//--------------------------------------------------------------------------------------------------------------------//

if_statement    :   TOKEN_IF TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES statement %prec LOWER_THAN_ELSE
                    {
                        NodeCreate(&($$.treeNode), NODE_IF);
                        NodeAddChild($$.treeNode, $3.treeNode);    //condition
                        NodeAddChild($$.treeNode, $5.treeNode);    //if true
                    }
                |   TOKEN_IF TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES statement TOKEN_ELSE statement //if has else
                    {
                        NodeCreate(&($$.treeNode), NODE_IF);
                        NodeAddChild($$.treeNode, $3.treeNode);   //condition
                        NodeAddChild($$.treeNode, $5.treeNode);   //if true
                        NodeAddChild($$.treeNode, $7.treeNode);   //else
                    }
                ;

switch_statement    :   TOKEN_SWITCH TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES TOKEN_LEFT_BRACE switch_body TOKEN_RIGHT_BRACE
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
                            $$.treeNode->nodeData.sVal = currentFunction;
                        }
                    |   TOKEN_RETURN exp TOKEN_SEMI
                        {
                            NodeCreate(&($$.treeNode), NODE_RETURN);
                            NodeAddChild($$.treeNode, $2.treeNode);
                            $$.treeNode->nodeData.sVal = currentFunction;
                        }
                    ;

//--------------------------------------------------------------------------------------------------------------------//
// Iteration statements
//--------------------------------------------------------------------------------------------------------------------//

while_loop      :   TOKEN_WHILE TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES statement // while(exp)
                    {
                        NodeCreate(&($$.treeNode), NODE_WHILE);
                        NodeAddChild($$.treeNode, $3.treeNode);    // Condition
                        NodeAddChild($$.treeNode, $5.treeNode);    // if true
                    }
                ;

// normally statement would be compound statement because of  {...}
do_while_loop   :   TOKEN_DO statement TOKEN_WHILE TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES TOKEN_SEMI
                    {
                        NodeCreate(&($$.treeNode), NODE_DO_WHILE);
                        NodeAddChild($$.treeNode, $2.treeNode);
                        NodeAddChild($$.treeNode, $5.treeNode);
                    }
                ;
//for(for_init_field, for_condition, for_assignment_field) statement (to allow compound)
for_loop        :   TOKEN_FOR TOKEN_LEFT_PARENTHESES for_init_field TOKEN_SEMI for_condition TOKEN_SEMI for_assignment_field TOKEN_RIGHT_PARENTHESES statement
                    {
                        TreeNode_t* pNodeWhile;
                        TreeNode_t* pLoopBody = $9.treeNode;

                        /* só append do assignment se não for vazio */
                        if ($7.treeNode != NULL) {
                            if (NodeAppendSibling(&pLoopBody, $7.treeNode)) { YYERROR; }
                        }

                        NodeCreate(&pNodeWhile, NODE_WHILE);

                        /* só adiciona condição se não for vazia */
                        if ($5.treeNode != NULL) {
                            NodeAddChild(pNodeWhile, $5.treeNode);
                        }

                        NodeAddChild(pNodeWhile, pLoopBody);

                        /* só faz sequence se o init não for vazio */
                        if ($3.treeNode != NULL) {
                            TreeNode_t* pForSequence = $3.treeNode;
                            if (NodeAppendSibling(&pForSequence, pNodeWhile)) { YYERROR; }
                            $$.treeNode = pForSequence;
                        } else {
                            $$.treeNode = pNodeWhile;
                        }
                    }
                ;

for_init_field  :   %empty { $$.treeNode = NULL; }
                |   TOKEN_ID TOKEN_ASSIGN exp    //for (i = 0, ...)
                    {
                        TreeNode_t* pNode;
                        NodeCreate(&($$.treeNode), NODE_OPERATOR);
                        $$.treeNode->nodeData.dVal = OP_ASSIGN;
                        NodeAddNewChild($$.treeNode, &pNode, NODE_IDENTIFIER);
                        pNode->nodeData.sVal = $1.nodeData.sVal;
                        NodeAddChild($$.treeNode, $3.treeNode);
                    }
                |   var_preamble TOKEN_ID TOKEN_ASSIGN exp    //for (int i = 0, ...)
                    {
                        TreeNode_t* pNode;
                        NodeCreate(&($$.treeNode), NODE_VAR_DECLARATION);
                        $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                        NodeAddChild($$.treeNode, $1.treeNode);
                        TreeNode_t* pAssign;
                        NodeCreate(&pAssign, NODE_OPERATOR);
                        pAssign->nodeData.dVal = OP_ASSIGN;
                        NodeAddNewChild(pAssign, &pNode, NODE_IDENTIFIER);
                        pNode->nodeData.sVal = $2.nodeData.sVal;
                        NodeAddChild(pAssign, $4.treeNode);
                        if (NodeAppendSibling(&($$.treeNode), pAssign)) { YYERROR; }
                    }
                |   var_preamble TOKEN_ID   /* int i; without assignment */
                    {
                        NodeCreate(&($$.treeNode), NODE_VAR_DECLARATION);
                        $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                        NodeAddChild($$.treeNode, $1.treeNode);
                    }
                ;
for_condition     :   %empty { $$.treeNode = NULL; }
                  |   exp { $$.treeNode = $1.treeNode; }   //for (.., i < 0, ...)
                  ;

for_assignment_field    :   %empty { $$.treeNode = NULL; }
                        |   simple_var_assign   { $$.treeNode = $1.treeNode; }  // for (.., ..., i=1+2)
                        |   compound_var_assign { $$.treeNode = $1.treeNode; }  // for (.., ..., i+=2)
                        |   exp { $$.treeNode = $1.treeNode; }  //// for (.., ..., i++/++i..)
                        ;

simple_var_assign   :   TOKEN_ID TOKEN_ASSIGN exp
                        {
                            TreeNode_t* pNode;
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_ASSIGN;
                            NodeAddNewChild($$.treeNode, &pNode, NODE_IDENTIFIER);
                            pNode->nodeData.sVal = $1.nodeData.sVal;
                            NodeAddChild($$.treeNode, $3.treeNode);
                        }
                    ;

compound_var_assign :   TOKEN_ID compound_assign_operator exp
                        {
                            TreeNode_t* pNode;
                            NodeAddNewChild($2.treeNode, &pNode, NODE_IDENTIFIER);
                            pNode->nodeData.sVal = $1.nodeData.sVal;
                            NodeAddChild($2.treeNode, $3.treeNode);
                            $$.treeNode = $2.treeNode;
                        }
                    ;

//--------------------------------------------------------------------------------------------------------------------//
// Functions
//--------------------------------------------------------------------------------------------------------------------//

function_prototype  :   function_signature TOKEN_SEMI  //int sum(param, param, ...);
                        {
                            $$.treeNode = $1.treeNode;
                        }
                    ;

function_definition :   function_signature compound_statement  //int sum(int a, int b) {return a+b;}
                        {
                            $$.treeNode = $1.treeNode;
                            NodeAddChild($$.treeNode, $2.treeNode);
                        }
                    ;

// int sum(int a, int b)
function_signature  :   var_preamble TOKEN_ID TOKEN_LEFT_PARENTHESES arg_list TOKEN_RIGHT_PARENTHESES
                        {
                            NodeCreate(&$$.treeNode, NODE_FUNCTION);
                            $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                            currentFunction = $2.nodeData.sVal;
                            NodeAddChild($$.treeNode, $1.treeNode);
                            NodeAddChild($$.treeNode, $4.treeNode);
                        }
                    ;

//arguments list for function signature
arg_list       :    %empty  { $$.treeNode = NULL; }

	           |    arg_list TOKEN_COMMA TOKEN_ELLIPSIS     // int func(int x, ...)
                    {
                        TreeNode_t* pNode;
                        TreeNode_t* p_Head = $1.treeNode;
                        NodeCreate(&pNode, NODE_PARAMETER);
                        pNode->nodeData.sVal = "...";
                        if (NodeAppendSibling(&p_Head, pNode)) { YYERROR; }
                        $$.treeNode = p_Head;
                    }
               |    arg_list TOKEN_COMMA param_declaration    //void func(int x, int y)
                    {
                        TreeNode_t* p_Head = $1.treeNode;
                        if (NodeAppendSibling(&p_Head, $3.treeNode)) { YYERROR; }
                        $$.treeNode = p_Head;
                    }
               |    param_declaration  { $$.treeNode = $1.treeNode; }
               ;

// declaration of function parameters
param_declaration   :   var_preamble TOKEN_ID
                        {
                            NodeCreate(&($$.treeNode), NODE_VAR_DECLARATION);
                            $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                            NodeAddChildCopy($$.treeNode, $1.treeNode);
                            free($1.treeNode);
                        }
                    
                    |   var_preamble TOKEN_ID arr_size    /* int arr[] */
                        {
                            NodeCreate(&($$.treeNode), NODE_ARRAY_DECLARATION);
                            $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                            NodeAddChildCopy($$.treeNode, $1.treeNode);
                            free($1.treeNode);
                            NodeAddChild($$.treeNode, $3.treeNode);
                        }
                    |    var_preamble  // void func(int) - unnamed parameter
                        {
                            NodeCreate(&($$.treeNode), NODE_VAR_DECLARATION);
                            NodeAddChild($$.treeNode, $1.treeNode);
                        }
                   ;



func_call           :   TOKEN_ID TOKEN_LEFT_PARENTHESES exp_list TOKEN_RIGHT_PARENTHESES
                        {
                            NodeCreate(&($$.treeNode), NODE_FUNCTION_CALL);
                            $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
                            NodeAddChild($$.treeNode, $3.treeNode);
                        }
                    ;

//exp list for function calling
exp_list            :   %empty
                        {
                            $$.treeNode = NULL;
                        }
                    |   exp_list TOKEN_COMMA exp  //has multiple arguments separated by ','
                        {
                            TreeNode_t* pHead = $1.treeNode;
                            if (NodeAppendSibling(&pHead, $3.treeNode)) { YYERROR; }
                            $$.treeNode = pHead;
                        }
                    |   exp                     //has just one argument
                        {
                            $$.treeNode = $1.treeNode;
                        }
                    ;

//--------------------------------------------------------------------------------------------------------------------//
// Type Specifiers (variables and funtions)
//--------------------------------------------------------------------------------------------------------------------//

//(int)3.14 or (int*) ptr or (float) 5
//Be careful with cast in struct, union and enum - maybe not implement!
type_cast_specifier :   TOKEN_LEFT_PARENTHESES all_type_specifiers TOKEN_RIGHT_PARENTHESES //(int)a
                        {
                            NodeCreate(&($$.treeNode), NODE_TYPE_CAST);
                            NodeAddChild($$.treeNode, $2.treeNode);
                        }
                    ;


all_type_specifiers  :   data_type_specifier { $$.treeNode = $1.treeNode; }
                     |   type_pointer { $$.treeNode = $1.treeNode; }
                     ;

type_pointer        :   data_type_specifier TOKEN_ASTERISK    //int*  or other type
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

//can be a type or not a type by themselves --> long and short are not a type by themselves
data_type_specifier :   TOKEN_CHAR
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
                    |   TOKEN_LONG TOKEN_INT
                        {
                            NodeCreate(&($$.treeNode), NODE_TYPE);
                            $$.treeNode->nodeData.dVal = TYPE_LONG;
                        }
                    |   TOKEN_SHORT TOKEN_INT
                        {
                            NodeCreate(&($$.treeNode), NODE_TYPE);
                            $$.treeNode->nodeData.dVal = TYPE_SHORT;
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
                    |   TOKEN_LONG TOKEN_DOUBLE
                        {
                            NodeCreate(&($$.treeNode), NODE_TYPE);
                            $$.treeNode->nodeData.dVal = TYPE_LONG_DOUBLE;
                        }
                    |   TOKEN_VOID
                        {
                            NodeCreate(&($$.treeNode), NODE_TYPE);
                            $$.treeNode->nodeData.dVal = TYPE_VOID;
                        }
                    |   TOKEN_STRUCT TOKEN_ID  //struct Point
                        {
                            NodeCreate(&($$.treeNode), NODE_TYPE);
                            $$.treeNode->nodeData.dVal = TYPE_STRUCT;
                            TreeNode_t* pName;
                            NodeCreate(&pName, NODE_IDENTIFIER);
                            pName->nodeData.sVal = $2.nodeData.sVal;
                            NodeAddChild($$.treeNode, pName);
                        }
                    |   TOKEN_UNION TOKEN_ID    //union Data
                        {
                            NodeCreate(&($$.treeNode), NODE_TYPE);
                            $$.treeNode->nodeData.dVal = TYPE_UNION;
                            TreeNode_t* pName;
                            NodeCreate(&pName, NODE_IDENTIFIER);
                            pName->nodeData.sVal = $2.nodeData.sVal;
                            NodeAddChild($$.treeNode, pName);
                        }
                    |   TOKEN_ENUM TOKEN_ID   //enum Color
                        {
                            NodeCreate(&($$.treeNode), NODE_TYPE);
                            $$.treeNode->nodeData.dVal = TYPE_ENUM;
                            TreeNode_t* pName;
                            NodeCreate(&pName, NODE_IDENTIFIER);
                            pName->nodeData.sVal = $2.nodeData.sVal;
                            NodeAddChild($$.treeNode, pName);
                        }
                    ;

visibility_qualifier    :    TOKEN_STATIC
                             {
                                 NodeCreate(&($$.treeNode), NODE_VISIBILITY);
                                 $$.treeNode->nodeData.dVal = VIS_STATIC;
                             }
                         |   TOKEN_EXTERN
                             {
                                 NodeCreate(&($$.treeNode), NODE_VISIBILITY);
                                 $$.treeNode->nodeData.dVal = VIS_EXTERN;
                             }
                         |   TOKEN_INLINE
                             {
                                 NodeCreate(&($$.treeNode), NODE_VISIBILITY);
                                 $$.treeNode->nodeData.dVal = VIS_INLINE;
                             }
                         ;

mod_qualifier      :    TOKEN_CONST
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

sign_qualifier      :   TOKEN_SIGNED
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
// Variable Declarations and Assignments
//--------------------------------------------------------------------------------------------------------------------//

var_declaration :   var_preamble id_list TOKEN_SEMI
                    {
                        /* existing action — keep unchanged */
                        TreeNode_t* pNode = $2.treeNode;
                        do {
                            if (pNode->nodeType == NODE_VAR_DECLARATION ||
                                pNode->nodeType == NODE_ARRAY_DECLARATION) { 
                                NodeAddChildCopy(pNode, $1.treeNode);
                            }
                            pNode = pNode->p_sibling;
                        } while (pNode != NULL);
                        free($1.treeNode);
                        $$.treeNode = $2.treeNode;
                    }
                ;


arr_size    :   TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET   //[] inside can be num, func, expressions
                { $$.treeNode = $2.treeNode; }
            |   TOKEN_LEFT_BRACKET TOKEN_RIGHT_BRACKET
                { NodeCreate(&($$.treeNode), NODE_NULL); }
            |   arr_size TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET  //[][] to define matrix
                {
                    TreeNode_t* pHead = $1.treeNode;
                    if (NodeAppendSibling(&pHead, $3.treeNode)) { YYERROR; }
                    $$.treeNode = pHead;
                }
            ;

id_list  :    TOKEN_ID
              {
                  NodeCreate(&($$.treeNode), NODE_VAR_DECLARATION);
                  $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
              }
          |   TOKEN_ID TOKEN_ASSIGN exp         // int x=5;
              {
                  TreeNode_t* pNode;
                  NodeCreate(&($$.treeNode), NODE_VAR_DECLARATION);
                  $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
                  TreeNode_t* pAssign;
                  NodeCreate(&pAssign, NODE_OPERATOR);
                  pAssign->nodeData.dVal = OP_ASSIGN;
                  NodeAddNewChild(pAssign, &pNode, NODE_IDENTIFIER);
                  pNode->nodeData.sVal = $1.nodeData.sVal;
                  NodeAddChild(pAssign, $3.treeNode);
                  if (NodeAppendSibling(&($$.treeNode), pAssign)) { YYERROR; }
              }
          |   TOKEN_ID arr_size                        // int arr[10]
              {
                  NodeCreate(&($$.treeNode), NODE_ARRAY_DECLARATION);
                  $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
                  NodeAddChild($$.treeNode, $2.treeNode);
              }
          |   id_list TOKEN_COMMA TOKEN_ID
              {
                   TreeNode_t* pHead = $1.treeNode;
                   TreeNode_t* pNewNode;
                   NodeCreate(&pNewNode, NODE_VAR_DECLARATION);
                   pNewNode->nodeData.sVal = $3.nodeData.sVal;
                   if (NodeAppendSibling(&pHead, pNewNode)) { YYERROR; }
                   $$.treeNode = pHead;
              }
          |   id_list TOKEN_COMMA TOKEN_ID arr_size    // ← NEW: int x, arr[10]
              {
                    TreeNode_t* pHead = $1.treeNode;
                    TreeNode_t* pNewNode;
                    NodeCreate(&pNewNode, NODE_ARRAY_DECLARATION);
                    pNewNode->nodeData.sVal = $3.nodeData.sVal;
                    NodeAddChild(pNewNode, $4.treeNode);
                    if (NodeAppendSibling(&pHead, pNewNode)) { YYERROR; }
                    $$.treeNode = pHead;
              }

          |   id_list TOKEN_COMMA simple_var_assign   //int x, y = 5;
              {
                    TreeNode_t* pHead = $1.treeNode;
                    TreeNode_t* pNode = $3.treeNode->p_firstChild;
                    TreeNode_t* pNewNode;
                    NodeCreate(&pNewNode, NODE_VAR_DECLARATION);
                    pNewNode->nodeData.sVal = pNode->nodeData.sVal;
                    if (NodeAppendSibling(&pHead, pNewNode)) { YYERROR; }
                    if (NodeAppendSibling(&pHead, $3.treeNode)) { YYERROR; }
                    $$.treeNode = pHead;
              }
            ;

//e.g: unsigned long int, static float, const int....
/* helper macro-action shared by all var_preamble alternatives */
var_preamble    :   all_type_specifiers
                    {
                        $$.treeNode = $1.treeNode;
                    }
                |   visibility_qualifier all_type_specifiers
                    {
                        TreeNode_t* pHead = $2.treeNode;
                        if ($1.treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, $1.treeNode);
                        else
                            free($1.treeNode);
                        $$.treeNode = pHead;
                    }
                |   mod_qualifier all_type_specifiers
                    {
                        TreeNode_t* pHead = $2.treeNode;
                        if ($1.treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, $1.treeNode);
                        else
                            free($1.treeNode);
                        $$.treeNode = pHead;
                    }
                |   sign_qualifier all_type_specifiers
                    {
                        TreeNode_t* pHead = $2.treeNode;
                        if ($1.treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, $1.treeNode);
                        else
                            free($1.treeNode);
                        $$.treeNode = pHead;
                    }
                |   visibility_qualifier mod_qualifier all_type_specifiers
                    {
                        TreeNode_t* pHead = $3.treeNode;
                        if ($2.treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, $2.treeNode);
                        else
                            free($2.treeNode);
                        if ($1.treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, $1.treeNode);
                        else
                            free($1.treeNode);
                        $$.treeNode = pHead;
                    }
                |   visibility_qualifier sign_qualifier all_type_specifiers
                    {
                        TreeNode_t* pHead = $3.treeNode;
                        if ($2.treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, $2.treeNode);
                        else
                            free($2.treeNode);
                        if ($1.treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, $1.treeNode);
                        else
                            free($1.treeNode);
                        $$.treeNode = pHead;
                    }
                |   mod_qualifier sign_qualifier all_type_specifiers
                    {
                        TreeNode_t* pHead = $3.treeNode;
                        if ($2.treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, $2.treeNode);
                        else
                            free($2.treeNode);
                        if ($1.treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, $1.treeNode);
                        else
                            free($1.treeNode);
                        $$.treeNode = pHead;
                    }
                |   visibility_qualifier mod_qualifier sign_qualifier all_type_specifiers
                    {
                        TreeNode_t* pHead = $4.treeNode;
                        if ($3.treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, $3.treeNode);
                        else
                            free($3.treeNode);
                        if ($2.treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, $2.treeNode);
                        else
                            free($2.treeNode);
                        if ($1.treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, $1.treeNode);
                        else
                            free($1.treeNode);
                        $$.treeNode = pHead;
                    }
                ;


var_assignment  :   simple_var_assign TOKEN_SEMI  { $$.treeNode = $1.treeNode; }
                |   compound_var_assign TOKEN_SEMI  { $$.treeNode = $1.treeNode; }
                |   array_access TOKEN_ASSIGN exp TOKEN_SEMI
                    {
                        NodeCreate(&($$.treeNode), NODE_OPERATOR);
                        $$.treeNode->nodeData.dVal = OP_ASSIGN;
                        NodeAddChild($$.treeNode, $1.treeNode);
                        NodeAddChild($$.treeNode, $3.treeNode);
                    }
                |   pointer_content TOKEN_ASSIGN exp TOKEN_SEMI
                    {
                        NodeCreate(&($$.treeNode), NODE_OPERATOR);
                        $$.treeNode->nodeData.dVal = OP_ASSIGN;
                        NodeAddChild($$.treeNode, $1.treeNode);
                        NodeAddChild($$.treeNode, $3.treeNode);
                    }
                |   array_access compound_assign_operator exp TOKEN_SEMI  //arr[0] = 5;
                    {
                        NodeAddChild($2.treeNode, $1.treeNode);
                        NodeAddChild($2.treeNode, $3.treeNode);
                        $$.treeNode = $2.treeNode;
                    }
                |   factor TOKEN_DOT TOKEN_ID TOKEN_ASSIGN exp TOKEN_SEMI  //point.x = 10;
                    {
                        NodeCreate(&($$.treeNode), NODE_OPERATOR);
                        $$.treeNode->nodeData.dVal = OP_ASSIGN;
                        TreeNode_t* pMember;
                        NodeCreate(&pMember, NODE_IDENTIFIER);
                        pMember->nodeData.sVal = $3.nodeData.sVal;
                        NodeAddChild($$.treeNode, $1.treeNode);
                        NodeAddChild($$.treeNode, pMember);
                        NodeAddChild($$.treeNode, $5.treeNode);
                    }
                |   factor TOKEN_ARROW TOKEN_ID TOKEN_ASSIGN exp TOKEN_SEMI
                    {
                        NodeCreate(&($$.treeNode), NODE_OPERATOR);
                        $$.treeNode->nodeData.dVal = OP_ASSIGN;
                        TreeNode_t* pMember;
                        NodeCreate(&pMember, NODE_IDENTIFIER);
                        pMember->nodeData.sVal = $3.nodeData.sVal;
                        NodeAddChild($$.treeNode, $1.treeNode);
                        NodeAddChild($$.treeNode, pMember);
                        NodeAddChild($$.treeNode, $5.treeNode);
                    }
                |   pointer_content compound_assign_operator exp TOKEN_SEMI  //*ptr += 5;
                    {
                        NodeAddChild($2.treeNode, $1.treeNode);
                        NodeAddChild($2.treeNode, $3.treeNode);
                        $$.treeNode = $2.treeNode;
                    }
                |   factor TOKEN_DOT TOKEN_ID compound_assign_operator exp TOKEN_SEMI //point.x += 1;
                    {
                        TreeNode_t* pMember;
                        NodeCreate(&pMember, NODE_IDENTIFIER);
                        pMember->nodeData.sVal = $3.nodeData.sVal;
                        NodeAddChild($4.treeNode, $1.treeNode);
                        NodeAddChild($4.treeNode, pMember);
                        NodeAddChild($4.treeNode, $5.treeNode);
                        $$.treeNode = $4.treeNode;
                    }
                |   factor TOKEN_ARROW TOKEN_ID compound_assign_operator exp TOKEN_SEMI  //point.x += 1;
                    {
                        TreeNode_t* pMember;
                        NodeCreate(&pMember, NODE_IDENTIFIER);
                        pMember->nodeData.sVal = $3.nodeData.sVal;
                        NodeAddChild($4.treeNode, $1.treeNode);
                        NodeAddChild($4.treeNode, pMember);
                        NodeAddChild($4.treeNode, $5.treeNode);
                        $$.treeNode = $4.treeNode;
                    }
                ;

//--------------------------------------------------------------------------------------------------------------------//
// Expressions
//--------------------------------------------------------------------------------------------------------------------//

//lowest precedence --> arithmetic, comparison, logical, ternary, assignments
exp         :   exp arithmetic_operator term  //by leaving the base case eliminates ambiguity
                {
                    NodeAddChild($2.treeNode, $1.treeNode);
                    NodeAddChild($2.treeNode, $3.treeNode);
                    $$.treeNode = $2.treeNode; //sets the operator as the root
                }
            |   exp comparison_operator term
                {
                    NodeAddChild($2.treeNode, $1.treeNode);
                    NodeAddChild($2.treeNode, $3.treeNode);
                    $$.treeNode = $2.treeNode;
                }
            |   exp bitwise_operator term
                {
                    NodeAddChild($2.treeNode, $1.treeNode);
                    NodeAddChild($2.treeNode, $3.treeNode);
                    $$.treeNode = $2.treeNode;
                }
            |   exp logic_operator term
                {
                    NodeAddChild($2.treeNode, $1.treeNode);
                    NodeAddChild($2.treeNode, $3.treeNode);
                    $$.treeNode = $2.treeNode;
                }
            |   exp TOKEN_TERNARY exp TOKEN_COLON exp
                {
                    NodeCreate(&($$.treeNode), NODE_TERNARY);
                    NodeAddChild($$.treeNode, $1.treeNode);
                    NodeAddChild($$.treeNode, $3.treeNode);
                    NodeAddChild($$.treeNode, $5.treeNode);
                }
            |   term
                {
                    $$.treeNode = $1.treeNode;
                }
            ;

// term has higher precedence than exp
term        :   term priority_operator operand
                {
                    NodeAddChild($2.treeNode, $1.treeNode);
                    NodeAddChild($2.treeNode, $3.treeNode);
                    $$.treeNode = $2.treeNode;
                }
            |   operand  { $$.treeNode = $1.treeNode; }
            ;

//operand has higher precedence than term
operand     :   TOKEN_MINUS operand %prec UNARY
                {
                      NodeCreate(&($$.treeNode), NODE_OPERATOR);
                      $$.treeNode->nodeData.dVal = OP_UNARY_MINUS;
                      NodeAddChild($$.treeNode, $2.treeNode);
                }
            |   TOKEN_INCREMENT operand        // ++a  prefix has lower precedence so stays here
                {
                    NodeCreate(&($$.treeNode), NODE_PRE_INC);
                    NodeAddChild($$.treeNode, $2.treeNode);
                }
            |   TOKEN_DECREMENT operand        // --a
                {
                    NodeCreate(&($$.treeNode), NODE_PRE_DEC);
                    NodeAddChild($$.treeNode, $2.treeNode);
                }
            |   TOKEN_LOGICAL_NOT factor
                {
                    NodeCreate(&($$.treeNode), NODE_OPERATOR);
                    $$.treeNode->nodeData.dVal = OP_LOGICAL_NOT;
                    NodeAddChild($$.treeNode, $2.treeNode);
                }
            |   TOKEN_BITWISE_NOT term
                {
                    NodeCreate(&($$.treeNode), NODE_OPERATOR);
                    $$.treeNode->nodeData.dVal = OP_BITWISE_NOT;
                    NodeAddChild($$.treeNode, $2.treeNode);
                }
            |   type_cast_specifier factor
                {
                    NodeAddChild($1.treeNode, $2.treeNode);
                    $$.treeNode = $1.treeNode;
                }
            |   factor
                {
                    $$.treeNode = $1.treeNode;
                }
            ;

//Factor contains the atomic units within expressions, like numbers, IDs, etc.  // Examples:
factor      :   TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES
                {
                    $$.treeNode = $2.treeNode;
                }
            |   array_access
                {
                    $$.treeNode = $1.treeNode;
                }
            |   TOKEN_NUM
                {
                    NodeCreate(&($$.treeNode), NODE_INTEGER);
                    $$.treeNode->nodeData.dVal = $1.nodeData.dVal;
                }
            |   TOKEN_ID
                {
                    NodeCreate(&($$.treeNode), NODE_IDENTIFIER);
                    $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
                }
            |   pointer_content
                { $$.treeNode = $1.treeNode; }
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
            |   TOKEN_BITWISE_AND array_access
                {
                    NodeCreate(&($$.treeNode), NODE_REFERENCE);
                    NodeAddChild($$.treeNode, $2.treeNode);
                }
            |   TOKEN_BITWISE_AND TOKEN_ID
                {
                    NodeCreate(&($$.treeNode), NODE_REFERENCE);
                    $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                }
            |   TOKEN_SIZEOF TOKEN_LEFT_PARENTHESES sizeof_operand TOKEN_RIGHT_PARENTHESES  //sizeof(a)
                {
                    NodeCreate(&($$.treeNode), NODE_OPERATOR);
                    $$.treeNode->nodeData.dVal = OP_SIZEOF;
                    NodeAddChild($$.treeNode, $3.treeNode);
                }
            |   func_call  { $$.treeNode = $1.treeNode; }
            |   factor TOKEN_INCREMENT        // a++
                {
                    NodeCreate(&($$.treeNode), NODE_POST_INC);
                    NodeAddChild($$.treeNode, $1.treeNode);
                }
            |   factor TOKEN_DECREMENT        // a--
                {
                    NodeCreate(&($$.treeNode), NODE_POST_DEC);
                    NodeAddChild($$.treeNode, $1.treeNode);
                }
            |   factor TOKEN_DOT TOKEN_ID  //p.x
                {
                    NodeCreate(&($$.treeNode), NODE_IDENTIFIER);
                    $$.treeNode->nodeData.sVal = $3.nodeData.sVal;
                    NodeAddChild($$.treeNode, $1.treeNode);
                }
            |   factor TOKEN_ARROW TOKEN_ID   //p->x
                {
                    NodeCreate(&($$.treeNode), NODE_IDENTIFIER);
                    $$.treeNode->nodeData.sVal = $3.nodeData.sVal;
                    NodeAddChild($$.treeNode, $1.treeNode);
                }
             ;


sizeof_operand  :   all_type_specifiers             //sizeof(int) or sizeof(int*)
                    { $$.treeNode = $1.treeNode; }
                |   exp               //sizeof(a)  a is the sizeof_operand or sizeof (struct Point)
                    { $$.treeNode = $1.treeNode; }
                ;

//For now just simple rules. Could also be implemented: f()[i],...
array_access :   TOKEN_ID TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET   ////arr[i]
                {
                    NodeCreate(&($$.treeNode), NODE_ARRAY_ACCESS);
                    $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
                    NodeAddChild($$.treeNode, $3.treeNode);
                }
            |   array_access TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET   //arr[i][j]
                {
                    NodeAddChild($1.treeNode, $3.treeNode);
                    $$.treeNode = $1.treeNode;
                }
            ;
//for dereference  --> exp grammar
pointer_content :   TOKEN_ASTERISK pointer_content    //multiple level of dereference  e.g. **a
                    {
                        NodeCreate(&($$.treeNode), NODE_POINTER_CONTENT);
                        NodeAddChild($$.treeNode, $2.treeNode);
                    }
                |   TOKEN_ASTERISK TOKEN_ID    //*a
                    {
                        NodeCreate(&($$.treeNode), NODE_POINTER_CONTENT);
                        $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                    }
                |   TOKEN_ASTERISK array_access   //*arr[i]
                    {
                        NodeCreate(&($$.treeNode), NODE_POINTER_CONTENT);
                        NodeAddChild($$.treeNode, $2.treeNode);
                    }
                |   TOKEN_ASTERISK TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES   //*(a+1)
                    {
                        NodeCreate(&($$.treeNode), NODE_POINTER_CONTENT);
                        NodeAddChild($$.treeNode, $3.treeNode);
                    }
                ;

//--------------------------------------------------------------------------------------------------------------------//
// Binary Operators
//--------------------------------------------------------------------------------------------------------------------//

priority_operator   :   TOKEN_ASTERISK    //*
                        {
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_MULTIPLY;
                        }
                    |   TOKEN_DIVIDE      ///
                        {
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_DIVIDE;
                        }
                    |   TOKEN_MOD        //%
                        {
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_MODULE;
                        }
                    ;

arithmetic_operator :   TOKEN_PLUS      //+
                        {
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_PLUS;
                        }
                    |   TOKEN_MINUS     //-
                        {
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_MINUS;
                        }
                    |   TOKEN_RIGHT_SHIFT     //>>
                        {
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_RIGHT_SHIFT;
                        }
                    |   TOKEN_LEFT_SHIFT       //<<
                        {
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_LEFT_SHIFT;
                        }
                    ;

comparison_operator  :  TOKEN_EQUAL        //==
                        {
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_EQUAL;
                        }
                    |   TOKEN_NOT_EQUAL     //!=
                        {
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_NOT_EQUAL;
                        }
                    |   TOKEN_GREATER_THAN      //>
                        {
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_GREATER_THAN;
                        }
                    |   TOKEN_LESS_THAN_OR_EQUAL    //<=
                        {
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_LESS_THAN_OR_EQUAL;
                        }
                    |   TOKEN_GREATER_THAN_OR_EQUAL    //>=
                        {
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_GREATER_THAN_OR_EQUAL;
                        }
                    |   TOKEN_LESS_THAN              //<
                        {
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_LESS_THAN;
                        }
                    ;

bitwise_operator    :   TOKEN_BITWISE_AND   //&
                        {
                             NodeCreate(&($$.treeNode), NODE_OPERATOR);
                             $$.treeNode->nodeData.dVal = OP_BITWISE_AND;
                         }
                    |   TOKEN_BITWISE_OR    //|
                        {
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_BITWISE_OR;
                        }
                    |   TOKEN_BITWISE_XOR   //^
                        {
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_BITWISE_XOR;
                        }
                    ;

logic_operator      :   TOKEN_LOGICAL_AND   //&&
                        {
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_LOGICAL_AND;
                        }
                    |   TOKEN_LOGICAL_OR   //||
                        {
                            NodeCreate(&($$.treeNode), NODE_OPERATOR);
                            $$.treeNode->nodeData.dVal = OP_LOGICAL_OR;
                        }
                    ;

compound_assign_operator    :   TOKEN_PLUS_ASSIGN       //+=
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_PLUS_ASSIGN;
                            }
                        |   TOKEN_MINUS_ASSIGN      //-=
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_MINUS_ASSIGN;
                            }
                        |   TOKEN_MODULUS_ASSIGN    //%=
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_MODULUS_ASSIGN;
                            }
                        |   TOKEN_LEFT_SHIFT_ASSIGN    //<<=
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_LEFT_SHIFT_ASSIGN;
                            }
                        |   TOKEN_RIGHT_SHIFT_ASSIGN     //>>=
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_RIGHT_SHIFT_ASSIGN;
                            }
                        |   TOKEN_AND_ASSIGN        //&=
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_BITWISE_AND_ASSIGN;
                            }
                        |   TOKEN_OR_ASSIGN         //|=
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_BITWISE_OR_ASSIGN;
                            }
                        |   TOKEN_XOR_ASSIGN        //^=
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_BITWISE_XOR_ASSIGN;
                            }
                        |   TOKEN_MULTIPLY_ASSIGN   //*=
                            {
                                NodeCreate(&($$.treeNode), NODE_OPERATOR);
                                $$.treeNode->nodeData.dVal = OP_MULTIPLY_ASSIGN;
                            }
                        |   TOKEN_DIVIDE_ASSIGN     ///=
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
