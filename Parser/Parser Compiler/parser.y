//--------------------------------------------------------------------------------------------------
// Shared Types For Generated Header
//--------------------------------------------------------------------------------------------------
%code requires {
#include "ASTree.h"
#include "logger.h"
}

//--------------------------------------------------------------------------------------------------
// Parser Prologue
//--------------------------------------------------------------------------------------------------
%{
#include <stdio.h>
#include <string.h>
#include "ASTree.h"
#include "logger.h"
#include "ASTPrint.h"

int yylex(void);
void yyerror(const char *s);

static TreeNode_t* p_treeRoot = NULL;
static char* currentFunction = NULL;
%}

//--------------------------------------------------------------------------------------------------
// Bison Parser Configuration
//--------------------------------------------------------------------------------------------------
%defines
%define api.value.type {ParserObject_t}
%start program

//--------------------------------------------------------------------------------------------------
// Token Declarations From Lexer Contract
//--------------------------------------------------------------------------------------------------
%token TOKEN_NUM TOKEN_FNUM TOKEN_CNUM TOKEN_STR TOKEN_ID
%token TOKEN_INT TOKEN_CHAR TOKEN_FLOAT TOKEN_DOUBLE TOKEN_VOID
%token TOKEN_BOOL TOKEN_INLINE
%token TOKEN_SIGNED TOKEN_UNSIGNED TOKEN_LONG TOKEN_SHORT
%token TOKEN_STATIC TOKEN_EXTERN TOKEN_CONST TOKEN_VOLATILE
%token TOKEN_STRUCT TOKEN_UNION TOKEN_ENUM TOKEN_TYPEDEF TOKEN_SIZEOF
%token TOKEN_IF TOKEN_ELSE TOKEN_SWITCH TOKEN_CASE TOKEN_DEFAULT
%token TOKEN_FOR TOKEN_WHILE TOKEN_DO TOKEN_BREAK TOKEN_RETURN TOKEN_CONTINUE
%token TOKEN_PP_DEFINE TOKEN_PP_UNDEF TOKEN_PP_INCLUDE_SYS TOKEN_PP_INCLUDE_USR
%token TOKEN_PLUS TOKEN_MINUS TOKEN_ASTERISK TOKEN_OVER TOKEN_PERCENT
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
%token TOKEN_ARROW TOKEN_DOT
%token TOKEN_SEMI TOKEN_COMMA TOKEN_COLON TOKEN_TERNARY
%token TOKEN_LEFT_PARENTHESES TOKEN_RIGHT_PARENTHESES
%token TOKEN_LEFT_BRACE TOKEN_RIGHT_BRACE
%token TOKEN_LEFT_BRACKET TOKEN_RIGHT_BRACKET
%token TOKEN_EOF TOKEN_ERROR

//--------------------------------------------------------------------------------------------------
// Precedence And Associativity
//--------------------------------------------------------------------------------------------------
%nonassoc LOWER_THAN_ELSE
%nonassoc TOKEN_ELSE

%right TOKEN_ASSIGN TOKEN_PLUS_ASSIGN TOKEN_MINUS_ASSIGN TOKEN_MULTIPLY_ASSIGN TOKEN_DIVIDE_ASSIGN TOKEN_MODULUS_ASSIGN TOKEN_AND_ASSIGN TOKEN_OR_ASSIGN TOKEN_XOR_ASSIGN TOKEN_LEFT_SHIFT_ASSIGN TOKEN_RIGHT_SHIFT_ASSIGN
%right TOKEN_TERNARY TOKEN_COLON
%left TOKEN_LOGICAL_OR
%left TOKEN_LOGICAL_AND
%left TOKEN_BITWISE_OR
%left TOKEN_BITWISE_XOR
%left TOKEN_BITWISE_AND
%left TOKEN_EQUAL TOKEN_NOT_EQUAL
%left TOKEN_LESS_THAN TOKEN_GREATER_THAN TOKEN_LESS_THAN_OR_EQUAL TOKEN_GREATER_THAN_OR_EQUAL
%left TOKEN_LEFT_SHIFT TOKEN_RIGHT_SHIFT
%left TOKEN_PLUS TOKEN_MINUS
%left TOKEN_ASTERISK TOKEN_OVER TOKEN_PERCENT
%right TOKEN_LOGICAL_NOT TOKEN_BITWISE_NOT

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
                        if (NodeAppendSibling(&p_Head, $2.treeNode)) { YYERROR; }
                        $$.treeNode = p_Head;
                    }

                |   global_statement
                    {
                        $$.treeNode = $1.treeNode;
                    }
                ;


global_statement    :   declaration
                        { $$.treeNode = $1.treeNode; }
                    |   function_prototype
                        { $$.treeNode = $1.treeNode; }
                    |   function_definition
                        { $$.treeNode = $1.treeNode; }
                    |   struct_declaration  
                        { $$.treeNode = $1.treeNode; }
                    | enum_declaration
                   { $$.treeNode = $1.treeNode; }
                 | union_declaration
                   { $$.treeNode = $1.treeNode; }
                    |   TOKEN_TYPEDEF declaration_specifiers TOKEN_ID TOKEN_SEMI
                        {
                        NodeCreate(&($$.treeNode), NODE_VAR_DECLARATION);
                        $$.treeNode->nodeData.sVal = $3.nodeData.sVal;
                        NodeAddChild($$.treeNode, $2.treeNode);
                        }
                    | TOKEN_SEMI { $$.treeNode = NULL; }  
                                    ;


//--------------------------------------------------------------------------------------------------------------------//
// Functions
//--------------------------------------------------------------------------------------------------------------------//

function_prototype  :   function_signature TOKEN_SEMI
                        { $$.treeNode = $1.treeNode; }
                    ;

function_definition :   function_signature compound_statement
                        {
                            $$.treeNode = $1.treeNode;
                            NodeAddChild($$.treeNode, $2.treeNode);
                        }
                    ;

function_signature  :   declaration_specifiers TOKEN_ID TOKEN_LEFT_PARENTHESES parameter_list TOKEN_RIGHT_PARENTHESES
                        {
                            NodeCreate(&$$.treeNode, NODE_FUNCTION);
                            $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                            currentFunction = $2.nodeData.sVal;
                            NodeAddChild($$.treeNode, $1.treeNode);
                            NodeAddChild($$.treeNode, $4.treeNode);
                        }
                    ;

parameter_list      :   %empty
                        { NodeCreate(&($$.treeNode), NODE_NULL); }
                    |   parameter_declaration
                        { $$.treeNode = $1.treeNode; }
                    |   parameter_list TOKEN_COMMA parameter_declaration
                        {
                            TreeNode_t* p_Head = $1.treeNode;
                            if (NodeAppendSibling(&p_Head, $3.treeNode)) { YYERROR; }
                            $$.treeNode = p_Head;
                        }
                    ;

parameter_declaration   :   declaration_qualifiers type_all_specifier TOKEN_ID
                            {
                                NodeCreate(&($$.treeNode), NODE_PARAMETER);
                                $$.treeNode->nodeData.sVal = $3.nodeData.sVal;
                                NodeAddChild($$.treeNode, $1.treeNode);
                                NodeAddChild($$.treeNode, $2.treeNode);
                            }
                            |   declaration_qualifiers type_all_specifier TOKEN_ID arr_size
                             {
                                NodeCreate(&($$.treeNode), NODE_PARAMETER);
                                $$.treeNode->nodeData.sVal = $3.nodeData.sVal;
                                NodeAddChild($$.treeNode, $1.treeNode);
                                NodeAddChild($$.treeNode, $2.treeNode);
                                NodeAddChild($$.treeNode, $4.treeNode);
                            }
                        ;

func_call           :   TOKEN_ID TOKEN_LEFT_PARENTHESES exp_list TOKEN_RIGHT_PARENTHESES
                        {
                            NodeCreate(&($$.treeNode), NODE_FUNCTION_CALL);
                            $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
                            NodeAddChild($$.treeNode, $3.treeNode);
                        }
                    ;

exp_list            :   %empty
                        { $$.treeNode = NULL; }
                    |   exp
                        { $$.treeNode = $1.treeNode; }
                    |   exp_list TOKEN_COMMA exp
                        {
                            TreeNode_t* pHead = $1.treeNode;
                            if (NodeAppendSibling(&pHead, $3.treeNode)) { YYERROR; }
                            $$.treeNode = pHead;
                        }
                    ;


//--------------------------------------------------------------------------------------------------------------------//
// Declarations
//--------------------------------------------------------------------------------------------------------------------//

/*declaration         :   declaration_specifiers init_declarator_list_opt TOKEN_SEMI
                        {
                            NodeCreate(&($$.treeNode), NODE_VAR_DECLARATION);
                            NodeAddChild($$.treeNode, $1.treeNode);
                            NodeAddChild($$.treeNode, $2.treeNode);
                        }
                    ;
*/
declaration : declaration_specifiers init_declarator_list_opt TOKEN_SEMI
              {
                  NodeCreate(&($$.treeNode), NODE_VAR_DECLARATION);
                  NodeAddChild($$.treeNode, $1.treeNode);
                  NodeAddChild($$.treeNode, $2.treeNode);
              }
            | declaration_specifiers TOKEN_ID arr_size TOKEN_SEMI
              {
                  NodeCreate(&($$.treeNode), NODE_ARRAY_DECLARATION);
                  $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                  NodeAddChild($$.treeNode, $1.treeNode);
                  NodeAddChild($$.treeNode, $3.treeNode);
              }
            ;
declaration_specifiers  :   declaration_qualifiers type_all_specifier
                            {
                                TreeNode_t* pHead = $1.treeNode;
                                if (NodeAppendSibling(&pHead, $2.treeNode)) { YYERROR; }
                                $$.treeNode = pHead;
                            }
                        ;

declaration_qualifiers  :   %empty
                            { NodeCreate(&($$.treeNode), NODE_NULL); }
                        |   declaration_qualifiers declaration_qualifier
                            {
                                TreeNode_t* p_Head = $1.treeNode;
                                if (NodeAppendSibling(&p_Head, $2.treeNode)) { YYERROR; }
                                $$.treeNode = p_Head;
                            }
                        ;

declaration_qualifier   :   storage_class_specifier
                            { $$.treeNode = $1.treeNode; }
                        |   type_qualifier
                            { $$.treeNode = $1.treeNode; }
                        |   sign_qualifier
                            { $$.treeNode = $1.treeNode; }
                        ;

init_declarator_list_opt    :   %empty
                                { NodeCreate(&($$.treeNode), NODE_NULL); }
                            |   id_list
                                { $$.treeNode = $1.treeNode; }
                            ;


//--------------------------------------------------------------------------------------------------------------------//
// Type Specifiers and Qualifiers
//--------------------------------------------------------------------------------------------------------------------//

type_cast_specifier :   TOKEN_LEFT_PARENTHESES type_all_specifier TOKEN_RIGHT_PARENTHESES
                        {
                            NodeCreate(&($$.treeNode), NODE_TYPE_CAST);
                            NodeAddChild($$.treeNode, $2.treeNode);
                        }
                    ;

type_all_specifier  :   data_type_specifier
                        { $$.treeNode = $1.treeNode; }
                    |   type_pointer
                        { $$.treeNode = $1.treeNode; }
                    ;

type_pointer        :   data_type_specifier TOKEN_ASTERISK
                        {
                            NodeCreate(&($$.treeNode), NODE_POINTER);
                            NodeAddChild($$.treeNode, $1.treeNode);
                        }
                        |   type_pointer TOKEN_ASTERISK
                    {
                        NodeCreate(&($$.treeNode), NODE_POINTER);
                        NodeAddChild($$.treeNode, $1.treeNode);
                    }
                    ;

data_type_specifier :   TOKEN_CHAR
                        { NodeCreate(&($$.treeNode), NODE_TYPE); $$.treeNode->nodeData.dVal = TYPE_CHAR; }
                    |   TOKEN_SHORT
                        { NodeCreate(&($$.treeNode), NODE_TYPE); $$.treeNode->nodeData.dVal = TYPE_SHORT; }
                    |   TOKEN_INT
                        { NodeCreate(&($$.treeNode), NODE_TYPE); $$.treeNode->nodeData.dVal = TYPE_INT; }
                    |   TOKEN_LONG
                        { NodeCreate(&($$.treeNode), NODE_TYPE); $$.treeNode->nodeData.dVal = TYPE_LONG; }
                    |   TOKEN_LONG TOKEN_LONG
                        { NodeCreate(&($$.treeNode), NODE_TYPE); $$.treeNode->nodeData.dVal = TYPE_LONG; }
                    |   TOKEN_FLOAT
                        { NodeCreate(&($$.treeNode), NODE_TYPE); $$.treeNode->nodeData.dVal = TYPE_FLOAT; }
                    |   TOKEN_DOUBLE
                        { NodeCreate(&($$.treeNode), NODE_TYPE); $$.treeNode->nodeData.dVal = TYPE_DOUBLE; }
                    |   TOKEN_LONG TOKEN_DOUBLE
                        { NodeCreate(&($$.treeNode), NODE_TYPE); $$.treeNode->nodeData.dVal = TYPE_LONG_DOUBLE; }
                    |   TOKEN_VOID
                        { NodeCreate(&($$.treeNode), NODE_TYPE); $$.treeNode->nodeData.dVal = TYPE_VOID; }
                    ;

storage_class_specifier :   TOKEN_STATIC
                            { NodeCreate(&($$.treeNode), NODE_VISIBILITY); $$.treeNode->nodeData.dVal = (long int) VIS_STATIC; }
                        |   TOKEN_EXTERN
                            { NodeCreate(&($$.treeNode), NODE_VISIBILITY); $$.treeNode->nodeData.dVal = (long int) VIS_EXTERN; }
                        |   TOKEN_INLINE
                            { NodeCreate(&($$.treeNode), NODE_VISIBILITY); $$.treeNode->nodeData.dVal = (long int) VIS_STATIC; }
                        ;

type_qualifier      :   TOKEN_CONST
                        { NodeCreate(&($$.treeNode), NODE_MODIFIER); $$.treeNode->nodeData.dVal = (long int) MOD_CONST; }
                    |   TOKEN_VOLATILE
                        { NodeCreate(&($$.treeNode), NODE_MODIFIER); $$.treeNode->nodeData.dVal = (long int) MOD_VOLATILE; }
                    ;

sign_qualifier      :   TOKEN_SIGNED
                        { NodeCreate(&($$.treeNode), NODE_SIGN); $$.treeNode->nodeData.dVal = (long int) SIGN_SIGNED; }
                    |   TOKEN_UNSIGNED
                        { NodeCreate(&($$.treeNode), NODE_SIGN); $$.treeNode->nodeData.dVal = (long int) SIGN_UNSIGNED; }
                    ;


//--------------------------------------------------------------------------------------------------------------------//
// Statements
//--------------------------------------------------------------------------------------------------------------------//

local_statement_list    :   %empty
                            { $$.treeNode = NULL; }
                        |   local_statement_list local_statement
                            {
                                TreeNode_t* pHead = $1.treeNode;
                                if (NodeAppendSibling(&pHead, $2.treeNode)) { YYERROR; }
                                $$.treeNode = pHead;
                            }
                        |   local_statement
                            { $$.treeNode = $1.treeNode; }
                        ;

local_statement     :   if_statement        { $$.treeNode = $1.treeNode; }
                    |   switch_statement    { $$.treeNode = $1.treeNode; }
                    |   break_statement     { $$.treeNode = $1.treeNode; }
                    |   continue_statement  { $$.treeNode = $1.treeNode; }
                    |   do_while_loop       { $$.treeNode = $1.treeNode; }
                    |   while_loop          { $$.treeNode = $1.treeNode; }
                    |   for_loop            { $$.treeNode = $1.treeNode; }
                    |   compound_statement  { $$.treeNode = $1.treeNode; }
                    |   return_statement    { $$.treeNode = $1.treeNode; }
                    |   var_declaration     { $$.treeNode = $1.treeNode; }
                    |   var_assignment      { $$.treeNode = $1.treeNode; }
                    |   func_call TOKEN_SEMI { $$.treeNode = $1.treeNode; }
                    |   inc_dec TOKEN_SEMI   { $$.treeNode = $1.treeNode; }
                
                    ;

compound_statement  :   TOKEN_LEFT_BRACE local_statement_list TOKEN_RIGHT_BRACE
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
                    |   TOKEN_LEFT_BRACE TOKEN_RIGHT_BRACE
                        { $$.treeNode = NULL; }
                    ;


//--------------------------------------------------------------------------------------------------------------------//
// Flow Control
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

if_statement    :   TOKEN_IF TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES local_statement %prec LOWER_THAN_ELSE
                    {
                        NodeCreate(&($$.treeNode), NODE_IF);
                        NodeAddChild($$.treeNode, $3.treeNode);
                        NodeAddChild($$.treeNode, $5.treeNode);
                    }
                |   TOKEN_IF TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES local_statement TOKEN_ELSE local_statement
                    {
                        NodeCreate(&($$.treeNode), NODE_IF);
                        NodeAddChild($$.treeNode, $3.treeNode);
                        NodeAddChild($$.treeNode, $5.treeNode);
                        NodeAddChild($$.treeNode, $7.treeNode);
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
                    { $$.treeNode = $1.treeNode; }
                |   default_clause
                    { $$.treeNode = $1.treeNode; }
                ;

case_list       :   case_clause
                    { $$.treeNode = $1.treeNode; }
                |   case_list case_clause
                    {
                        TreeNode_t* pHead = $1.treeNode;
                        if (NodeAppendSibling(&pHead, $2.treeNode)) { YYERROR; }
                        $$.treeNode = pHead;
                    }
                ;

case_clause     :   TOKEN_CASE TOKEN_NUM TOKEN_COLON local_statement_list
                    {
                        NodeCreate(&($$.treeNode), NODE_CASE);
                        $$.treeNode->nodeData.dVal = $2.nodeData.dVal;
                        NodeAddChild($$.treeNode, $4.treeNode);
                    }
                |   TOKEN_CASE TOKEN_CNUM TOKEN_COLON local_statement_list
                    {
                        NodeCreate(&($$.treeNode), NODE_CASE);
                        $$.treeNode->nodeData.dVal = $2.nodeData.dVal;
                        NodeAddChild($$.treeNode, $4.treeNode);
                    }
                ;

default_clause  :   TOKEN_DEFAULT TOKEN_COLON local_statement_list
                    {
                        NodeCreate(&($$.treeNode), NODE_DEFAULT);
                        NodeAddChild($$.treeNode, $3.treeNode);
                    }
                ;


//--------------------------------------------------------------------------------------------------------------------//
// Loops
//--------------------------------------------------------------------------------------------------------------------//

while_loop      :   TOKEN_WHILE TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES local_statement
                    {
                        NodeCreate(&($$.treeNode), NODE_WHILE);
                        NodeAddChild($$.treeNode, $3.treeNode);
                        NodeAddChild($$.treeNode, $5.treeNode);
                    }
                ;

do_while_loop   :   TOKEN_DO local_statement TOKEN_WHILE TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES TOKEN_SEMI
                    {
                        NodeCreate(&($$.treeNode), NODE_DO_WHILE);
                        NodeAddChild($$.treeNode, $2.treeNode);
                        NodeAddChild($$.treeNode, $5.treeNode);
                    }
                ;

for_loop        :   TOKEN_FOR TOKEN_LEFT_PARENTHESES for_init_field TOKEN_SEMI for_exp_opt TOKEN_SEMI for_assignment_field TOKEN_RIGHT_PARENTHESES local_statement
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

for_init_field  :   
                %empty
                    { $$.treeNode = NULL; }
                |TOKEN_ID TOKEN_ASSIGN exp
                    {
                        TreeNode_t* pNode;
                        NodeCreate(&($$.treeNode), NODE_OPERATOR);
                        $$.treeNode->nodeData.dVal = OP_ASSIGN;
                        NodeAddNewChild($$.treeNode, &pNode, NODE_IDENTIFIER);
                        pNode->nodeData.sVal = $1.nodeData.sVal;
                        NodeAddChild($$.treeNode, $3.treeNode);
                    }
                |   var_preamble TOKEN_ID TOKEN_ASSIGN exp
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
                ;
for_exp_opt     :   %empty
                    { $$.treeNode = NULL; }
                |   exp
                    { $$.treeNode = $1.treeNode; }
                ;

for_assignment_field    :   %empty          { $$.treeNode = NULL; }
                        |   simple_var_assign   { $$.treeNode = $1.treeNode; }
                        |   compound_var_assign { $$.treeNode = $1.treeNode; }
                        |   inc_dec             { $$.treeNode = $1.treeNode; }
                        ;


//--------------------------------------------------------------------------------------------------------------------//
// Variable Declarations and Assignments
//--------------------------------------------------------------------------------------------------------------------//

var_declaration :   var_preamble id_list TOKEN_SEMI
                    {
                        TreeNode_t* pNode = $2.treeNode;
                        TreeNode_t nodePreambleCopy;
                        memcpy(&nodePreambleCopy, $1.treeNode, sizeof(TreeNode_t));
                        free($1.treeNode);
                        do {
                            if (pNode->nodeType == NODE_VAR_DECLARATION) {
                                NodeAddChildCopy(pNode, &nodePreambleCopy);
                            }
                            pNode = pNode->p_sibling;
                        } while (pNode != NULL);
                        $$.treeNode = $2.treeNode;
                    }
                |   arr_declaration
                    { $$.treeNode = $1.treeNode; }
                ;

arr_declaration :   var_preamble TOKEN_ID arr_size TOKEN_SEMI
                    {
                        NodeCreate(&($$.treeNode), NODE_ARRAY_DECLARATION);
                        $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                        NodeAddChild($$.treeNode, $1.treeNode);
                        NodeAddChild($$.treeNode, $3.treeNode);
                    }
                ;

arr_size    :   TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET
                { $$.treeNode = $2.treeNode; }
            |   TOKEN_LEFT_BRACKET TOKEN_RIGHT_BRACKET
                { NodeCreate(&($$.treeNode), NODE_NULL); }
            |   arr_size TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET
                {
                    TreeNode_t* pHead = $1.treeNode;
                    if (NodeAppendSibling(&pHead, $3.treeNode)) { YYERROR; }
                    $$.treeNode = pHead;
                }
            ;


      struct_declaration  :   TOKEN_STRUCT TOKEN_ID TOKEN_LEFT_BRACE struct_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI
                        {
                            NodeCreate(&($$.treeNode), NODE_STRUCT_DECLARATION);
                            $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                            NodeAddChild($$.treeNode, $4.treeNode);
                        }
                    ;
enum_declaration : TOKEN_ENUM TOKEN_ID TOKEN_LEFT_BRACE enum_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI
                   {
                       NodeCreate(&($$.treeNode), NODE_ENUM_DECLARATION);
                       $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                       NodeAddChild($$.treeNode, $4.treeNode);
                   }
                 ;

enum_member_list : enum_member
                   { $$.treeNode = $1.treeNode; }
                 | enum_member_list TOKEN_COMMA enum_member
                   {
                       TreeNode_t* pHead = $1.treeNode;
                       if (NodeAppendSibling(&pHead, $3.treeNode)) { YYERROR; }
                       $$.treeNode = pHead;
                   }
                 ;

enum_member : TOKEN_ID
              {
                  NodeCreate(&($$.treeNode), NODE_ENUM_MEMBER);
                  $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
              }
            | TOKEN_ID TOKEN_ASSIGN TOKEN_NUM
              {
                  NodeCreate(&($$.treeNode), NODE_ENUM_MEMBER);
                  $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
              }
            ;

union_declaration : TOKEN_UNION TOKEN_ID TOKEN_LEFT_BRACE struct_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI
                    {
                        NodeCreate(&($$.treeNode), NODE_UNION_DECLARATION);
                        $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                        NodeAddChild($$.treeNode, $4.treeNode);
                    }
                  ;
struct_member_list  :   struct_member
                        { $$.treeNode = $1.treeNode; }
                    |   struct_member_list struct_member
                        {
                            TreeNode_t* pHead = $1.treeNode;
                            if (NodeAppendSibling(&pHead, $2.treeNode)) { YYERROR; }
                            $$.treeNode = pHead;
                        }
                    ;

struct_member       :   declaration_specifiers TOKEN_ID TOKEN_SEMI
                        {
                            NodeCreate(&($$.treeNode), NODE_STRUCT_MEMBER);
                            $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                            NodeAddChild($$.treeNode, $1.treeNode);
                        }
                    ;      

id_list         :   TOKEN_ID
                    {
                        NodeCreate(&($$.treeNode), NODE_VAR_DECLARATION);
                        $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
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
                |   simple_var_assign
                    {
                        TreeNode_t* pNode = $1.treeNode->p_firstChild;
                        TreeNode_t* pHead;
                        NodeCreate(&($$.treeNode), NODE_VAR_DECLARATION);
                        $$.treeNode->nodeData.sVal = pNode->nodeData.sVal;
                        pHead = $$.treeNode;
                        if (NodeAppendSibling(&pHead, $1.treeNode)) { YYERROR; }
                        $$.treeNode = pHead;
                    }
                |   id_list TOKEN_COMMA simple_var_assign
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

var_assignment  :   simple_var_assign TOKEN_SEMI
                    { $$.treeNode = $1.treeNode; }
                |   compound_var_assign TOKEN_SEMI
                    { $$.treeNode = $1.treeNode; }
                |   array_index TOKEN_ASSIGN exp TOKEN_SEMI
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
                |   array_index compound_assign_operator exp TOKEN_SEMI
                    {
                        NodeAddChild($2.treeNode, $1.treeNode);
                        NodeAddChild($2.treeNode, $3.treeNode);
                        $$.treeNode = $2.treeNode;
                    }
                |   factor TOKEN_DOT TOKEN_ID TOKEN_ASSIGN exp TOKEN_SEMI
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

var_preamble    :   storage_class_specifier type_qualifier sign_qualifier type_all_specifier
                    {
                        TreeNode_t* pHead = $4.treeNode;
                        NodeAppendSibling(&pHead, $1.treeNode);
                        NodeAppendSibling(&pHead, $2.treeNode);
                        NodeAppendSibling(&pHead, $3.treeNode);
                        $$.treeNode = pHead;
                    }
                |   storage_class_specifier type_qualifier type_all_specifier
                    {
                        TreeNode_t* pHead = $3.treeNode;
                        NodeAppendSibling(&pHead, $1.treeNode);
                        NodeAppendSibling(&pHead, $2.treeNode);
                        $$.treeNode = pHead;
                    }
                |   storage_class_specifier sign_qualifier type_all_specifier
                    {
                        TreeNode_t* pHead = $3.treeNode;
                        NodeAppendSibling(&pHead, $1.treeNode);
                        NodeAppendSibling(&pHead, $2.treeNode);
                        $$.treeNode = pHead;
                    }
                |   type_qualifier sign_qualifier type_all_specifier
                    {
                        TreeNode_t* pHead = $3.treeNode;
                        NodeAppendSibling(&pHead, $1.treeNode);
                        NodeAppendSibling(&pHead, $2.treeNode);
                        $$.treeNode = pHead;
                    }
                |   storage_class_specifier type_all_specifier
                    {
                        TreeNode_t* pHead = $2.treeNode;
                        NodeAppendSibling(&pHead, $1.treeNode);
                        $$.treeNode = pHead;
                    }
                |   type_qualifier type_all_specifier
                    {
                        TreeNode_t* pHead = $2.treeNode;
                        NodeAppendSibling(&pHead, $1.treeNode);
                        $$.treeNode = pHead;
                    }
                |   sign_qualifier type_all_specifier
                    {
                        TreeNode_t* pHead = $2.treeNode;
                        NodeAppendSibling(&pHead, $1.treeNode);
                        $$.treeNode = pHead;
                    }
                |   type_all_specifier
                    { $$.treeNode = $1.treeNode; }
                ;


//--------------------------------------------------------------------------------------------------------------------//
// Expressions
//--------------------------------------------------------------------------------------------------------------------//

exp         :   TOKEN_MINUS exp
                {
                    NodeCreate(&($$.treeNode), NODE_OPERATOR);
                    $$.treeNode->nodeData.dVal = OP_MINUS;
                    NodeAddChild($$.treeNode, $2.treeNode);
                }
            |   exp arithmetic_operator term
                {
                    NodeAddChild($2.treeNode, $1.treeNode);
                    NodeAddChild($2.treeNode, $3.treeNode);
                    $$.treeNode = $2.treeNode;
                }
            |   exp condition_operator term
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
            |   TOKEN_BITWISE_NOT term
                {
                    NodeCreate(&($$.treeNode), NODE_OPERATOR);
                    $$.treeNode->nodeData.dVal = OP_BITWISE_NOT;
                    NodeAddChild($$.treeNode, $2.treeNode);
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
               |   TOKEN_ID TOKEN_ASSIGN exp
                {
                    TreeNode_t* pNode;
                    NodeCreate(&($$.treeNode), NODE_OPERATOR);
                    $$.treeNode->nodeData.dVal = OP_ASSIGN;
                    NodeAddNewChild($$.treeNode, &pNode, NODE_IDENTIFIER);
                    pNode->nodeData.sVal = $1.nodeData.sVal;
                    NodeAddChild($$.treeNode, $3.treeNode);
                } 
                |   term
                { $$.treeNode = $1.treeNode; }
            ;

term        :   term priority_operator operand
                {
                    NodeAddChild($2.treeNode, $1.treeNode);
                    NodeAddChild($2.treeNode, $3.treeNode);
                    $$.treeNode = $2.treeNode;
                }
            |   operand
                { $$.treeNode = $1.treeNode; }
            ;

operand     :   inc_dec
                { $$.treeNode = $1.treeNode; }
            |   TOKEN_LOGICAL_NOT factor
                {
                    NodeCreate(&($$.treeNode), NODE_OPERATOR);
                    $$.treeNode->nodeData.dVal = OP_LOGICAL_NOT;
                    NodeAddChild($$.treeNode, $2.treeNode);
                }
            |   type_cast_specifier factor
                {
                    NodeAddChild($1.treeNode, $2.treeNode);
                    $$.treeNode = $1.treeNode;
                }
            |   factor
                { $$.treeNode = $1.treeNode; }
            ;

factor      :   TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES
                { $$.treeNode = $2.treeNode; }
            |   array_index
                { $$.treeNode = $1.treeNode; }
            |   TOKEN_MINUS TOKEN_NUM
                {
                    NodeCreate(&($$.treeNode), NODE_INTEGER);
                    $$.treeNode->nodeData.dVal = -$2.nodeData.dVal;
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
            |   TOKEN_MINUS TOKEN_FNUM
                {
                    NodeCreate(&($$.treeNode), NODE_FLOAT);
                    $$.treeNode->nodeData.fVal = -$2.nodeData.fVal;
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
            |   TOKEN_BITWISE_AND array_index
                {
                    NodeCreate(&($$.treeNode), NODE_REFERENCE);
                    NodeAddChild($$.treeNode, $2.treeNode);
                }
            |   TOKEN_BITWISE_AND TOKEN_ID
                {
                    NodeCreate(&($$.treeNode), NODE_REFERENCE);
                    $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                }
            |   TOKEN_SIZEOF TOKEN_LEFT_PARENTHESES sizeof_operand TOKEN_RIGHT_PARENTHESES
    {
        NodeCreate(&($$.treeNode), NODE_OPERATOR);
        $$.treeNode->nodeData.dVal = OP_SIZEOF;
        NodeAddChild($$.treeNode, $3.treeNode);
    }
            |   func_call
                { $$.treeNode = $1.treeNode; }
            |   factor TOKEN_DOT TOKEN_ID
    {
        NodeCreate(&($$.treeNode), NODE_IDENTIFIER);
        $$.treeNode->nodeData.sVal = $3.nodeData.sVal;
        NodeAddChild($$.treeNode, $1.treeNode);
    }
|   factor TOKEN_ARROW TOKEN_ID
    {
        NodeCreate(&($$.treeNode), NODE_IDENTIFIER);
        $$.treeNode->nodeData.sVal = $3.nodeData.sVal;
        NodeAddChild($$.treeNode, $1.treeNode);
    }
            ;

sizeof_operand  :   data_type_specifier
                    { $$.treeNode = $1.treeNode; }
                |   exp
                    { $$.treeNode = $1.treeNode; }
                ;


array_index :   TOKEN_ID TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET
                {
                    NodeCreate(&($$.treeNode), NODE_ARRAY_INDEX);
                    $$.treeNode->nodeData.sVal = $1.nodeData.sVal;
                    NodeAddChild($$.treeNode, $3.treeNode);
                }
            |   array_index TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET
                {
                    NodeAddChild($1.treeNode, $3.treeNode);
                    $$.treeNode = $1.treeNode;
                }
            ;

pointer_content :   TOKEN_ASTERISK TOKEN_ID
                    {
                        NodeCreate(&($$.treeNode), NODE_POINTER_CONTENT);
                        $$.treeNode->nodeData.sVal = $2.nodeData.sVal;
                    }
                    |   TOKEN_ASTERISK TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES
                    {
                        NodeCreate(&($$.treeNode), NODE_POINTER_CONTENT);
                        NodeAddChild($$.treeNode, $3.treeNode);
                    }
                ;


//--------------------------------------------------------------------------------------------------------------------//
// Increment / Decrement
//--------------------------------------------------------------------------------------------------------------------//

inc_dec     :   pre_increment   { $$.treeNode = $1.treeNode; }
            |   post_increment  { $$.treeNode = $1.treeNode; }
            |   pre_decrement   { $$.treeNode = $1.treeNode; }
            |   post_decrement  { $$.treeNode = $1.treeNode; }
            ;

pre_increment   :   TOKEN_INCREMENT TOKEN_ID
                    { NodeCreate(&($$.treeNode), NODE_PRE_INC); $$.treeNode->nodeData.sVal = $2.nodeData.sVal; }
                ;

post_increment  :   TOKEN_ID TOKEN_INCREMENT
                    { NodeCreate(&($$.treeNode), NODE_POST_INC); $$.treeNode->nodeData.sVal = $1.nodeData.sVal; }
                ;

pre_decrement   :   TOKEN_DECREMENT TOKEN_ID
                    { NodeCreate(&($$.treeNode), NODE_PRE_DEC); $$.treeNode->nodeData.sVal = $2.nodeData.sVal; }
                ;

post_decrement  :   TOKEN_ID TOKEN_DECREMENT
                    { NodeCreate(&($$.treeNode), NODE_POST_DEC); $$.treeNode->nodeData.sVal = $1.nodeData.sVal; }
                ;


//--------------------------------------------------------------------------------------------------------------------//
// Operators
//--------------------------------------------------------------------------------------------------------------------//

arithmetic_operator :   TOKEN_PLUS      { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_PLUS; }
                    |   TOKEN_MINUS     { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_MINUS; }
                    |   TOKEN_RIGHT_SHIFT { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_RIGHT_SHIFT; }
                    |   TOKEN_LEFT_SHIFT  { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_LEFT_SHIFT; }
                    ;

priority_operator   :   TOKEN_ASTERISK  { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_MULTIPLY; }
                    |   TOKEN_OVER      { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_DIVIDE; }
                    |   TOKEN_PERCENT   { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_REMAIN; }
                    ;

condition_operator  :   TOKEN_GREATER_THAN          { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_GREATER_THAN; }
                    |   TOKEN_LESS_THAN_OR_EQUAL     { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_LESS_THAN_OR_EQUAL; }
                    |   TOKEN_GREATER_THAN_OR_EQUAL  { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_GREATER_THAN_OR_EQUAL; }
                    |   TOKEN_LESS_THAN              { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_LESS_THAN; }
                    |   TOKEN_EQUAL                  { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_EQUAL; }
                    |   TOKEN_NOT_EQUAL              { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_NOT_EQUAL; }
                    ;

logic_operator      :   TOKEN_LOGICAL_AND   { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_LOGICAL_AND; }
                    |   TOKEN_LOGICAL_OR    { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_LOGICAL_OR; }
                    ;

bitwise_operator    :   TOKEN_BITWISE_AND   { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_BITWISE_AND; }
                    |   TOKEN_BITWISE_OR    { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_BITWISE_OR; }
                    |   TOKEN_BITWISE_XOR   { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_BITWISE_XOR; }
                    ;

compound_assign_operator    :   TOKEN_PLUS_ASSIGN       { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_PLUS_ASSIGN; }
                            |   TOKEN_MINUS_ASSIGN      { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_MINUS_ASSIGN; }
                            |   TOKEN_MODULUS_ASSIGN    { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_MODULUS_ASSIGN; }
                            |   TOKEN_LEFT_SHIFT_ASSIGN { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_LEFT_SHIFT_ASSIGN; }
                            |   TOKEN_RIGHT_SHIFT_ASSIGN { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_RIGHT_SHIFT_ASSIGN; }
                            |   TOKEN_AND_ASSIGN        { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_BITWISE_AND_ASSIGN; }
                            |   TOKEN_OR_ASSIGN         { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_BITWISE_OR_ASSIGN; }
                            |   TOKEN_XOR_ASSIGN        { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_BITWISE_XOR_ASSIGN; }
                            |   TOKEN_MULTIPLY_ASSIGN   { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_MULTIPLY_ASSIGN; }
                            |   TOKEN_DIVIDE_ASSIGN     { NodeCreate(&($$.treeNode), NODE_OPERATOR); $$.treeNode->nodeData.dVal = OP_DIVIDE_ASSIGN; }
                            ;


//--------------------------------------------------------------------------------------------------
// Parser Support Code
//--------------------------------------------------------------------------------------------------
%%

void yyerror(const char *s)
{
    fprintf(stderr, "Parse error: %s\n", s);
}

int main(void)
{
    int result = yyparse();
    if (result == 0) {
        printf("Parse succeeded. AST:\n");
        ASTPrint(p_treeRoot); 
    }
    return result;
}
