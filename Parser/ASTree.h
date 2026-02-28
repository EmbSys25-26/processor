#ifndef ASTREE_H
#define ASTREE_H

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

    NODE_TYPE_NOT_DEFINED
}NodeType_t;

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


typedef union{
    TreeNode_t* treeNode;
    NodeData_t nodeData;
}ParserObject_t;  //to use in bison for this to be the type of the tokens

#endif //ASTREE_H

