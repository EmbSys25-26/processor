#ifndef NODE_TYPES_H
#define NODE_TYPES_H

typedef enum
{
    OP_PLUS,                    // 0
    OP_MINUS,                   // 1
    OP_RIGHT_SHIFT,             // 2
    OP_LEFT_SHIFT,              // 3
    OP_MULTIPLY,                // 4
    OP_DIVIDE,                  // 5
    OP_REMAIN,                  // 6
    OP_GREATER_THAN,            // 7
    OP_LESS_THAN_OR_EQUAL,      // 8
    OP_GREATER_THAN_OR_EQUAL,   // 9
    OP_LESS_THAN,               // 10
    OP_EQUAL,                   // 11
    OP_NOT_EQUAL,               // 12
    OP_LOGICAL_AND,             // 13
    OP_LOGICAL_OR,              // 14
    OP_LOGICAL_NOT,             // 15
    OP_BITWISE_AND,             // 16
    OP_BITWISE_NOT,             // 17
    OP_BITWISE_OR,              // 18
    OP_BITWISE_XOR,             // 19
    OP_ASSIGN,                  // 20
    OP_PLUS_ASSIGN,             // 21
    OP_MINUS_ASSIGN,            // 22
    OP_MODULUS_ASSIGN,          // 23
    OP_LEFT_SHIFT_ASSIGN,       // 24
    OP_RIGHT_SHIFT_ASSIGN,      // 25
    OP_BITWISE_AND_ASSIGN,      // 26
    OP_BITWISE_OR_ASSIGN,       // 27
    OP_BITWISE_XOR_ASSIGN,      // 28
    OP_MULTIPLY_ASSIGN,         // 29
    OP_DIVIDE_ASSIGN,           // 30
    OP_SIZEOF,                  // 31
    OP_NEGATIVE,
    OP_NOT_DEFINED
}OperatorType_t;

typedef enum
{
    SIGN_SIGNED,
    SIGN_UNSIGNED
}SignQualifier_t;

typedef enum
{
    MOD_NONE,
    MOD_CONST,
    MOD_VOLATILE
}ModQualifier_t;

typedef enum
{
    VIS_NONE,
    VIS_STATIC,
    VIS_EXTERN
}VisQualifier_t;

#endif //NODE_TYPES_H
