#ifndef ASTREE_H
#define ASTREE_H
#include <stddef.h>
#include <stdlib.h> 

typedef enum{
    NODE_SIGN = 0, 
    NODE_VISIBILITY,  
    NODE_MODIFIER, 
    NODE_TYPE,                        

    NODE_OPERATOR,         
    NODE_TERNARY,                         
    NODE_IDENTIFIER,        
    NODE_STRING,          
    NODE_INTEGER,           
    NODE_FLOAT,
    NODE_CHAR,
    NODE_STRUCT,

    NODE_IF,               
    NODE_WHILE,            
    NODE_DO_WHILE,                           
    NODE_RETURN,             
    NODE_CONTINUE,           
    NODE_BREAK,

    NODE_SWITCH,            
    NODE_CASE,               
    NODE_DEFAULT, 

    NODE_REFERENCE,           
    NODE_POINTER,              
    NODE_POINTER_CONTENT,
    NODE_TYPE_CAST,           

    NODE_POST_DEC,           
    NODE_PRE_DEC,            
    NODE_POST_INC,           
    NODE_PRE_INC,  

    NODE_VAR_DECLARATION,
    NODE_ARRAY_DECLARATION,
    NODE_ARRAY_INDEX,

    NODE_FUNCTION,
    NODE_FUNCTION_CALL,
    NODE_PARAMETER,

    NODE_NULL,
    //for when it enters { } (compound)
    NODE_START_SCOPE,
    NODE_END_SCOPE,

    NODE_TYPE_NOT_DEFINED,

    NODE_STRUCT_DECLARATION,
    NODE_STRUCT_MEMBER,
    NODE_ENUM_DECLARATION,
    NODE_ENUM_MEMBER,
     NODE_UNION_DECLARATION
}NodeType_t;

typedef union {
    double fVal;    // floating-point literals
    long int dVal;  // integer literals
    char* sVal;     // string literals and identifiers
}NodeData_t;

// Adicionei (PEDRO)-------------------------------------------------------
typedef enum {
    OP_PLUS,
    OP_MINUS,
    OP_MULTIPLY,
    OP_DIVIDE,
    OP_REMAIN,
    OP_LEFT_SHIFT,
    OP_RIGHT_SHIFT,
    OP_ASSIGN,
    OP_PLUS_ASSIGN,
    OP_MINUS_ASSIGN,
    OP_MULTIPLY_ASSIGN,
    OP_DIVIDE_ASSIGN,
    OP_MODULUS_ASSIGN,
    OP_LEFT_SHIFT_ASSIGN,
    OP_RIGHT_SHIFT_ASSIGN,
    OP_BITWISE_AND_ASSIGN,
    OP_BITWISE_OR_ASSIGN,
    OP_BITWISE_XOR_ASSIGN,
    OP_BITWISE_AND,
    OP_BITWISE_OR,
    OP_BITWISE_XOR,
    OP_LOGICAL_AND,
    OP_LOGICAL_OR,
    OP_LOGICAL_NOT,
    OP_BITWISE_NOT,
    OP_EQUAL,
    OP_NOT_EQUAL,
    OP_GREATER_THAN,
    OP_LESS_THAN,
    OP_GREATER_THAN_OR_EQUAL,
    OP_LESS_THAN_OR_EQUAL,
    
    OP_SIZEOF,
} OperatorType_t;
//-------------------------------------------------------------------
typedef enum{
    TYPE_CHAR = 0,
    TYPE_SHORT,
    TYPE_INT,
    TYPE_LONG,
    TYPE_FLOAT,
    TYPE_DOUBLE,
    TYPE_LONG_DOUBLE, 
    TYPE_STRING,
    TYPE_VOID
}VarType_t;

typedef struct TreeNode{

    struct TreeNode* p_firstChild;
    struct TreeNode* p_sibling;
    size_t childNumber;
    size_t lineNumber;
   
    NodeType_t nodeType;
    NodeData_t nodeData;
    VarType_t nodeVarType;
    
    /* ── Ligação à tabela de símbolos ── */
    //SymbolEntry* p_Symbol;    /* entrada na tabela de símbolos    */
    //SymbolTable* p_Scope;     /* scope onde o nó foi declarado    */
   
}TreeNode_t;



int NodeCreate(TreeNode_t** pp_NewNode, NodeType_t nodeType);

int NodeAddChild(TreeNode_t* p_Parent, TreeNode_t* p_Child);
int NodeAddNewChild(TreeNode_t* p_Parent, TreeNode_t** pp_NewChild, NodeType_t nodeType);
// Adicionei (PEDRO)-------------------------------------------------------
int NodeAddChildCopy(TreeNode_t* p_Parent, const TreeNode_t* p_Source);
//--------------------------------------------------------------------------
int NodeAppendSibling(TreeNode_t** pp_Head, TreeNode_t* p_NewSibling);


// Adicionei (PEDRO)------------------------------------------------------------------------------------
typedef union{
    TreeNode_t* treeNode;   // name of the variable, function, struct, etc. (for identifiers)
    NodeData_t nodeData;    // value of the literal (for literals)
}ParserObject_t;  //to use in bison for this to be the type of the tokens

/* ── Visibility/storage-class stored in nodeData.dVal for NODE_VISIBILITY nodes ── */
typedef enum {
    VIS_STATIC,
    VIS_EXTERN,
} VisibilityType_t;

/* ── Type qualifiers stored in nodeData.dVal for NODE_MODIFIER nodes ── */
typedef enum {
    MOD_CONST,
    MOD_VOLATILE,
} ModifierType_t;

/* ── Sign qualifiers stored in nodeData.dVal for NODE_SIGN nodes ── */
typedef enum {
    SIGN_SIGNED,
    SIGN_UNSIGNED,
} SignType_t;

//-----------------------------------------------------------------------------------------------------
#endif //ASTREE_H

