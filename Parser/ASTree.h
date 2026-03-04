#ifndef ASTREE_H
#define ASTREE_H

#include <stddef.h>
#include <stdlib.h> 

typedef enum{
    NODE_SIGN = 0,          // signed/unsigned qualifier
    NODE_VISIBILITY,        // static/extern/inline
    NODE_MODIFIER,          // const/volatile
    NODE_TYPE,              // int, float, char, void, struct X, etc.

    NODE_OPERATOR,          // binary/unary operators (+, -, *, /, etc.)
    NODE_TERNARY,           // ? :

    NODE_IDENTIFIER,        // variable/function names
    NODE_STRING,            // "hello"
    NODE_INTEGER,           // 42
    NODE_FLOAT,             // 3.14
    NODE_CHAR,              // 'a'

    NODE_IF,
    NODE_WHILE,
    NODE_DO_WHILE,
    NODE_RETURN,
    NODE_CONTINUE,
    NODE_BREAK,

    NODE_SWITCH,
    NODE_CASE,
    NODE_DEFAULT,

    NODE_REFERENCE,         // &x
    NODE_POINTER,           // int* (type context)
    NODE_POINTER_CONTENT,   // *x  (expression context)
    NODE_TYPE_CAST,         // (int) x

    NODE_POST_DEC,          // x--
    NODE_PRE_DEC,           // --x
    NODE_POST_INC,          // x++
    NODE_PRE_INC,           // ++x

    NODE_VAR_DECLARATION,   // int x;
    NODE_ARRAY_DECLARATION, // int arr[10];
    NODE_ARRAY_ACCESS,      // arr[i]

    NODE_STRUCT_DECLARATION,// struct Point { ... };
    NODE_STRUCT_MEMBER,     // int x; inside struct
    NODE_ENUM_DECLARATION,  // enum Color { ... };
    NODE_ENUM_MEMBER,       // RED, GREEN = 5
    NODE_UNION_DECLARATION, // union Data { ... };

    NODE_FUNCTION,          // function definition/prototype
    NODE_FUNCTION_CALL,     // func(args)
    NODE_PARAMETER,         // parameter in function signature

    NODE_NULL,              // empty/placeholder node
    NODE_START_SCOPE,       // {
    NODE_END_SCOPE,         // }

    NODE_TYPE_NOT_DEFINED
} NodeType_t;

typedef union {
    double fVal;
    long int dVal;
    char* sVal;
}NodeData_t;

typedef enum{
    TYPE_CHAR = 0,
    TYPE_SHORT,
    TYPE_INT,
    TYPE_LONG,
    TYPE_FLOAT,
    TYPE_DOUBLE,
    TYPE_LONG_DOUBLE, 
    TYPE_STRING,
    TYPE_VOID,
    TYPE_STRUCT,
    TYPE_UNION,
    TYPE_ENUM
}VarType_t; //for semantic analysis

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
int NodeAddChildCopy(TreeNode_t* p_Parent, TreeNode_t *p_Child);
int NodeAppendSibling(TreeNode_t** pp_Head, TreeNode_t* p_NewSibling);

typedef union{
    TreeNode_t* treeNode;
    NodeData_t nodeData;
}ParserObject_t;  //to use in bison for this to be the type of the tokens

#endif //ASTREE_H

