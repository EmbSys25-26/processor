/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output, and Bison version.  */
#define YYBISON 30802

/* Bison version string.  */
#define YYBISON_VERSION "3.8.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* First part of user prologue.  */
#line 13 "Parser/parser.y"

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

#line 404 "Parser/parser.tab.c"

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif

#include "parser.tab.h"
/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* "end of file"  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL_TOKEN_NUM = 3,                  /* TOKEN_NUM  */
  YYSYMBOL_TOKEN_FNUM = 4,                 /* TOKEN_FNUM  */
  YYSYMBOL_TOKEN_CNUM = 5,                 /* TOKEN_CNUM  */
  YYSYMBOL_TOKEN_STR = 6,                  /* TOKEN_STR  */
  YYSYMBOL_TOKEN_ID = 7,                   /* TOKEN_ID  */
  YYSYMBOL_TOKEN_INT = 8,                  /* TOKEN_INT  */
  YYSYMBOL_TOKEN_CHAR = 9,                 /* TOKEN_CHAR  */
  YYSYMBOL_TOKEN_FLOAT = 10,               /* TOKEN_FLOAT  */
  YYSYMBOL_TOKEN_DOUBLE = 11,              /* TOKEN_DOUBLE  */
  YYSYMBOL_TOKEN_VOID = 12,                /* TOKEN_VOID  */
  YYSYMBOL_TOKEN_INLINE = 13,              /* TOKEN_INLINE  */
  YYSYMBOL_TOKEN_SIGNED = 14,              /* TOKEN_SIGNED  */
  YYSYMBOL_TOKEN_UNSIGNED = 15,            /* TOKEN_UNSIGNED  */
  YYSYMBOL_TOKEN_LONG = 16,                /* TOKEN_LONG  */
  YYSYMBOL_TOKEN_SHORT = 17,               /* TOKEN_SHORT  */
  YYSYMBOL_TOKEN_STATIC = 18,              /* TOKEN_STATIC  */
  YYSYMBOL_TOKEN_EXTERN = 19,              /* TOKEN_EXTERN  */
  YYSYMBOL_TOKEN_CONST = 20,               /* TOKEN_CONST  */
  YYSYMBOL_TOKEN_VOLATILE = 21,            /* TOKEN_VOLATILE  */
  YYSYMBOL_TOKEN_STRUCT = 22,              /* TOKEN_STRUCT  */
  YYSYMBOL_TOKEN_UNION = 23,               /* TOKEN_UNION  */
  YYSYMBOL_TOKEN_ENUM = 24,                /* TOKEN_ENUM  */
  YYSYMBOL_TOKEN_SIZEOF = 25,              /* TOKEN_SIZEOF  */
  YYSYMBOL_TOKEN_IF = 26,                  /* TOKEN_IF  */
  YYSYMBOL_TOKEN_ELSE = 27,                /* TOKEN_ELSE  */
  YYSYMBOL_TOKEN_SWITCH = 28,              /* TOKEN_SWITCH  */
  YYSYMBOL_TOKEN_CASE = 29,                /* TOKEN_CASE  */
  YYSYMBOL_TOKEN_DEFAULT = 30,             /* TOKEN_DEFAULT  */
  YYSYMBOL_TOKEN_FOR = 31,                 /* TOKEN_FOR  */
  YYSYMBOL_TOKEN_WHILE = 32,               /* TOKEN_WHILE  */
  YYSYMBOL_TOKEN_DO = 33,                  /* TOKEN_DO  */
  YYSYMBOL_TOKEN_BREAK = 34,               /* TOKEN_BREAK  */
  YYSYMBOL_TOKEN_CONTINUE = 35,            /* TOKEN_CONTINUE  */
  YYSYMBOL_TOKEN_RETURN = 36,              /* TOKEN_RETURN  */
  YYSYMBOL_TOKEN_PLUS = 37,                /* TOKEN_PLUS  */
  YYSYMBOL_TOKEN_MINUS = 38,               /* TOKEN_MINUS  */
  YYSYMBOL_TOKEN_ASTERISK = 39,            /* TOKEN_ASTERISK  */
  YYSYMBOL_TOKEN_DIVIDE = 40,              /* TOKEN_DIVIDE  */
  YYSYMBOL_TOKEN_MOD = 41,                 /* TOKEN_MOD  */
  YYSYMBOL_TOKEN_INCREMENT = 42,           /* TOKEN_INCREMENT  */
  YYSYMBOL_TOKEN_DECREMENT = 43,           /* TOKEN_DECREMENT  */
  YYSYMBOL_TOKEN_ASSIGN = 44,              /* TOKEN_ASSIGN  */
  YYSYMBOL_TOKEN_PLUS_ASSIGN = 45,         /* TOKEN_PLUS_ASSIGN  */
  YYSYMBOL_TOKEN_MINUS_ASSIGN = 46,        /* TOKEN_MINUS_ASSIGN  */
  YYSYMBOL_TOKEN_MULTIPLY_ASSIGN = 47,     /* TOKEN_MULTIPLY_ASSIGN  */
  YYSYMBOL_TOKEN_DIVIDE_ASSIGN = 48,       /* TOKEN_DIVIDE_ASSIGN  */
  YYSYMBOL_TOKEN_MODULUS_ASSIGN = 49,      /* TOKEN_MODULUS_ASSIGN  */
  YYSYMBOL_TOKEN_AND_ASSIGN = 50,          /* TOKEN_AND_ASSIGN  */
  YYSYMBOL_TOKEN_OR_ASSIGN = 51,           /* TOKEN_OR_ASSIGN  */
  YYSYMBOL_TOKEN_XOR_ASSIGN = 52,          /* TOKEN_XOR_ASSIGN  */
  YYSYMBOL_TOKEN_LEFT_SHIFT_ASSIGN = 53,   /* TOKEN_LEFT_SHIFT_ASSIGN  */
  YYSYMBOL_TOKEN_RIGHT_SHIFT_ASSIGN = 54,  /* TOKEN_RIGHT_SHIFT_ASSIGN  */
  YYSYMBOL_TOKEN_EQUAL = 55,               /* TOKEN_EQUAL  */
  YYSYMBOL_TOKEN_NOT_EQUAL = 56,           /* TOKEN_NOT_EQUAL  */
  YYSYMBOL_TOKEN_LESS_THAN = 57,           /* TOKEN_LESS_THAN  */
  YYSYMBOL_TOKEN_GREATER_THAN = 58,        /* TOKEN_GREATER_THAN  */
  YYSYMBOL_TOKEN_LESS_THAN_OR_EQUAL = 59,  /* TOKEN_LESS_THAN_OR_EQUAL  */
  YYSYMBOL_TOKEN_GREATER_THAN_OR_EQUAL = 60, /* TOKEN_GREATER_THAN_OR_EQUAL  */
  YYSYMBOL_TOKEN_LOGICAL_AND = 61,         /* TOKEN_LOGICAL_AND  */
  YYSYMBOL_TOKEN_LOGICAL_OR = 62,          /* TOKEN_LOGICAL_OR  */
  YYSYMBOL_TOKEN_LOGICAL_NOT = 63,         /* TOKEN_LOGICAL_NOT  */
  YYSYMBOL_TOKEN_BITWISE_AND = 64,         /* TOKEN_BITWISE_AND  */
  YYSYMBOL_TOKEN_BITWISE_OR = 65,          /* TOKEN_BITWISE_OR  */
  YYSYMBOL_TOKEN_BITWISE_XOR = 66,         /* TOKEN_BITWISE_XOR  */
  YYSYMBOL_TOKEN_BITWISE_NOT = 67,         /* TOKEN_BITWISE_NOT  */
  YYSYMBOL_TOKEN_LEFT_SHIFT = 68,          /* TOKEN_LEFT_SHIFT  */
  YYSYMBOL_TOKEN_RIGHT_SHIFT = 69,         /* TOKEN_RIGHT_SHIFT  */
  YYSYMBOL_TOKEN_ARROW = 70,               /* TOKEN_ARROW  */
  YYSYMBOL_TOKEN_ELLIPSIS = 71,            /* TOKEN_ELLIPSIS  */
  YYSYMBOL_TOKEN_DOT = 72,                 /* TOKEN_DOT  */
  YYSYMBOL_TOKEN_SEMI = 73,                /* TOKEN_SEMI  */
  YYSYMBOL_TOKEN_COMMA = 74,               /* TOKEN_COMMA  */
  YYSYMBOL_TOKEN_COLON = 75,               /* TOKEN_COLON  */
  YYSYMBOL_TOKEN_TERNARY = 76,             /* TOKEN_TERNARY  */
  YYSYMBOL_TOKEN_LEFT_PARENTHESES = 77,    /* TOKEN_LEFT_PARENTHESES  */
  YYSYMBOL_TOKEN_RIGHT_PARENTHESES = 78,   /* TOKEN_RIGHT_PARENTHESES  */
  YYSYMBOL_TOKEN_LEFT_BRACE = 79,          /* TOKEN_LEFT_BRACE  */
  YYSYMBOL_TOKEN_RIGHT_BRACE = 80,         /* TOKEN_RIGHT_BRACE  */
  YYSYMBOL_TOKEN_LEFT_BRACKET = 81,        /* TOKEN_LEFT_BRACKET  */
  YYSYMBOL_TOKEN_RIGHT_BRACKET = 82,       /* TOKEN_RIGHT_BRACKET  */
  YYSYMBOL_TOKEN_ERROR = 83,               /* TOKEN_ERROR  */
  YYSYMBOL_LOWER_THAN_ELSE = 84,           /* LOWER_THAN_ELSE  */
  YYSYMBOL_UNARY = 85,                     /* UNARY  */
  YYSYMBOL_YYACCEPT = 86,                  /* $accept  */
  YYSYMBOL_translation_unit = 87,          /* translation_unit  */
  YYSYMBOL_external_declaration = 88,      /* external_declaration  */
  YYSYMBOL_statement_sequence = 89,        /* statement_sequence  */
  YYSYMBOL_statement = 90,                 /* statement  */
  YYSYMBOL_expression_statement = 91,      /* expression_statement  */
  YYSYMBOL_selection_statement = 92,       /* selection_statement  */
  YYSYMBOL_jump_statement = 93,            /* jump_statement  */
  YYSYMBOL_iteration_statement = 94,       /* iteration_statement  */
  YYSYMBOL_compound_statement = 95,        /* compound_statement  */
  YYSYMBOL_enum_member_list = 96,          /* enum_member_list  */
  YYSYMBOL_enum_member = 97,               /* enum_member  */
  YYSYMBOL_struct_union_member_list = 98,  /* struct_union_member_list  */
  YYSYMBOL_struct_member = 99,             /* struct_member  */
  YYSYMBOL_if_statement = 100,             /* if_statement  */
  YYSYMBOL_switch_statement = 101,         /* switch_statement  */
  YYSYMBOL_switch_body = 102,              /* switch_body  */
  YYSYMBOL_case_list = 103,                /* case_list  */
  YYSYMBOL_case_clause = 104,              /* case_clause  */
  YYSYMBOL_default_clause = 105,           /* default_clause  */
  YYSYMBOL_continue_statement = 106,       /* continue_statement  */
  YYSYMBOL_break_statement = 107,          /* break_statement  */
  YYSYMBOL_return_statement = 108,         /* return_statement  */
  YYSYMBOL_while_loop = 109,               /* while_loop  */
  YYSYMBOL_do_while_loop = 110,            /* do_while_loop  */
  YYSYMBOL_for_loop = 111,                 /* for_loop  */
  YYSYMBOL_for_init_field = 112,           /* for_init_field  */
  YYSYMBOL_for_condition = 113,            /* for_condition  */
  YYSYMBOL_for_assignment_field = 114,     /* for_assignment_field  */
  YYSYMBOL_function_definition = 115,      /* function_definition  */
  YYSYMBOL_parameter_list_opt = 116,       /* parameter_list_opt  */
  YYSYMBOL_param_declaration = 117,        /* param_declaration  */
  YYSYMBOL_type_name = 118,                /* type_name  */
  YYSYMBOL_type_cast_specifier = 119,      /* type_cast_specifier  */
  YYSYMBOL_all_type_specifiers = 120,      /* all_type_specifiers  */
  YYSYMBOL_type_pointer = 121,             /* type_pointer  */
  YYSYMBOL_enum_specifier = 122,           /* enum_specifier  */
  YYSYMBOL_struct_specifier = 123,         /* struct_specifier  */
  YYSYMBOL_union_specifier = 124,          /* union_specifier  */
  YYSYMBOL_type_specifier = 125,           /* type_specifier  */
  YYSYMBOL_storage_class_specifier = 126,  /* storage_class_specifier  */
  YYSYMBOL_function_specifier = 127,       /* function_specifier  */
  YYSYMBOL_type_qualifier = 128,           /* type_qualifier  */
  YYSYMBOL_sign_specifier = 129,           /* sign_specifier  */
  YYSYMBOL_declaration_specifier = 130,    /* declaration_specifier  */
  YYSYMBOL_declaration_specifiers = 131,   /* declaration_specifiers  */
  YYSYMBOL_pointer_prefix = 132,           /* pointer_prefix  */
  YYSYMBOL_declaration = 133,              /* declaration  */
  YYSYMBOL_init_declarator_list_opt = 134, /* init_declarator_list_opt  */
  YYSYMBOL_init_declarator_list = 135,     /* init_declarator_list  */
  YYSYMBOL_init_declarator = 136,          /* init_declarator  */
  YYSYMBOL_initializer = 137,              /* initializer  */
  YYSYMBOL_declarator = 138,               /* declarator  */
  YYSYMBOL_direct_declarator = 139,        /* direct_declarator  */
  YYSYMBOL_arr_size = 140,                 /* arr_size  */
  YYSYMBOL_expression = 141,               /* expression  */
  YYSYMBOL_assignment_expression = 142,    /* assignment_expression  */
  YYSYMBOL_conditional_expression = 143,   /* conditional_expression  */
  YYSYMBOL_logical_or_expression = 144,    /* logical_or_expression  */
  YYSYMBOL_logical_and_expression = 145,   /* logical_and_expression  */
  YYSYMBOL_inclusive_or_expression = 146,  /* inclusive_or_expression  */
  YYSYMBOL_exclusive_or_expression = 147,  /* exclusive_or_expression  */
  YYSYMBOL_and_expression = 148,           /* and_expression  */
  YYSYMBOL_equality_expression = 149,      /* equality_expression  */
  YYSYMBOL_relational_expression = 150,    /* relational_expression  */
  YYSYMBOL_shift_expression = 151,         /* shift_expression  */
  YYSYMBOL_additive_expression = 152,      /* additive_expression  */
  YYSYMBOL_multiplicative_expression = 153, /* multiplicative_expression  */
  YYSYMBOL_cast_expression = 154,          /* cast_expression  */
  YYSYMBOL_unary_expression = 155,         /* unary_expression  */
  YYSYMBOL_postfix_expression = 156,       /* postfix_expression  */
  YYSYMBOL_primary_expression = 157,       /* primary_expression  */
  YYSYMBOL_argument_expression_list_opt = 158, /* argument_expression_list_opt  */
  YYSYMBOL_argument_expression_list = 159, /* argument_expression_list  */
  YYSYMBOL_assignment_operator = 160       /* assignment_operator  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;




#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

/* Work around bug in HP-UX 11.23, which defines these macros
   incorrectly for preprocessor constants.  This workaround can likely
   be removed in 2023, as HPE has promised support for HP-UX 11.23
   (aka HP-UX 11i v2) only through the end of 2022; see Table 2 of
   <https://h20195.www2.hpe.com/V2/getpdf.aspx/4AA4-7673ENW.pdf>.  */
#ifdef __hpux
# undef UINT_LEAST8_MAX
# undef UINT_LEAST16_MAX
# define UINT_LEAST8_MAX 255
# define UINT_LEAST16_MAX 65535
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))


/* Stored state numbers (used for stacks). */
typedef yytype_int16 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif


#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YY_USE(E) ((void) (E))
#else
# define YY_USE(E) /* empty */
#endif

/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
#if defined __GNUC__ && ! defined __ICC && 406 <= __GNUC__ * 100 + __GNUC_MINOR__
# if __GNUC__ * 100 + __GNUC_MINOR__ < 407
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")
# else
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# endif
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if !defined yyoverflow

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* !defined yyoverflow */

#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  35
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   716

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  86
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  75
/* YYNRULES -- Number of rules.  */
#define YYNRULES  195
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  310

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   340


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK                     \
   ? YY_CAST (yysymbol_kind_t, yytranslate[YYX])        \
   : YYSYMBOL_YYUNDEF)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_int8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      65,    66,    67,    68,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,   437,   437,   443,   457,   458,   462,   463,   477,   478,
     479,   480,   481,   482,   486,   490,   500,   501,   504,   505,
     506,   509,   510,   511,   514,   524,   525,   531,   535,   540,
     549,   562,   563,   572,   587,   593,   602,   610,   616,   620,
     626,   630,   638,   645,   651,   659,   670,   674,   678,   682,
     693,   702,   710,   746,   747,   760,   765,   766,   769,   770,
     777,   789,   791,   800,   806,   810,   816,   835,   841,   849,
     850,   853,   858,   865,   873,   883,   891,   901,   909,   920,
     925,   930,   935,   940,   944,   949,   954,   958,   962,   968,
     973,   980,   987,   992,   999,  1004,  1016,  1020,  1024,  1028,
    1032,  1038,  1042,  1057,  1061,  1068,  1094,  1098,  1104,  1108,
    1116,  1120,  1137,  1143,  1147,  1160,  1165,  1171,  1181,  1183,
    1185,  1199,  1203,  1209,  1213,  1222,  1226,  1235,  1239,  1245,
    1249,  1255,  1259,  1265,  1269,  1275,  1279,  1285,  1289,  1293,
    1299,  1303,  1307,  1311,  1315,  1321,  1325,  1329,  1335,  1339,
    1343,  1350,  1354,  1358,  1362,  1368,  1372,  1379,  1383,  1388,
    1393,  1398,  1403,  1407,  1411,  1415,  1419,  1423,  1429,  1433,
    1437,  1441,  1445,  1449,  1454,  1461,  1466,  1471,  1476,  1481,
    1486,  1493,  1497,  1504,  1508,  1516,  1521,  1526,  1531,  1536,
    1541,  1546,  1551,  1556,  1561,  1566
};
#endif

/** Accessing symbol of state STATE.  */
#define YY_ACCESSING_SYMBOL(State) YY_CAST (yysymbol_kind_t, yystos[State])

#if YYDEBUG || 0
/* The user-facing name of the symbol whose (internal) number is
   YYSYMBOL.  No bounds checking.  */
static const char *yysymbol_name (yysymbol_kind_t yysymbol) YY_ATTRIBUTE_UNUSED;

/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "\"end of file\"", "error", "\"invalid token\"", "TOKEN_NUM",
  "TOKEN_FNUM", "TOKEN_CNUM", "TOKEN_STR", "TOKEN_ID", "TOKEN_INT",
  "TOKEN_CHAR", "TOKEN_FLOAT", "TOKEN_DOUBLE", "TOKEN_VOID",
  "TOKEN_INLINE", "TOKEN_SIGNED", "TOKEN_UNSIGNED", "TOKEN_LONG",
  "TOKEN_SHORT", "TOKEN_STATIC", "TOKEN_EXTERN", "TOKEN_CONST",
  "TOKEN_VOLATILE", "TOKEN_STRUCT", "TOKEN_UNION", "TOKEN_ENUM",
  "TOKEN_SIZEOF", "TOKEN_IF", "TOKEN_ELSE", "TOKEN_SWITCH", "TOKEN_CASE",
  "TOKEN_DEFAULT", "TOKEN_FOR", "TOKEN_WHILE", "TOKEN_DO", "TOKEN_BREAK",
  "TOKEN_CONTINUE", "TOKEN_RETURN", "TOKEN_PLUS", "TOKEN_MINUS",
  "TOKEN_ASTERISK", "TOKEN_DIVIDE", "TOKEN_MOD", "TOKEN_INCREMENT",
  "TOKEN_DECREMENT", "TOKEN_ASSIGN", "TOKEN_PLUS_ASSIGN",
  "TOKEN_MINUS_ASSIGN", "TOKEN_MULTIPLY_ASSIGN", "TOKEN_DIVIDE_ASSIGN",
  "TOKEN_MODULUS_ASSIGN", "TOKEN_AND_ASSIGN", "TOKEN_OR_ASSIGN",
  "TOKEN_XOR_ASSIGN", "TOKEN_LEFT_SHIFT_ASSIGN",
  "TOKEN_RIGHT_SHIFT_ASSIGN", "TOKEN_EQUAL", "TOKEN_NOT_EQUAL",
  "TOKEN_LESS_THAN", "TOKEN_GREATER_THAN", "TOKEN_LESS_THAN_OR_EQUAL",
  "TOKEN_GREATER_THAN_OR_EQUAL", "TOKEN_LOGICAL_AND", "TOKEN_LOGICAL_OR",
  "TOKEN_LOGICAL_NOT", "TOKEN_BITWISE_AND", "TOKEN_BITWISE_OR",
  "TOKEN_BITWISE_XOR", "TOKEN_BITWISE_NOT", "TOKEN_LEFT_SHIFT",
  "TOKEN_RIGHT_SHIFT", "TOKEN_ARROW", "TOKEN_ELLIPSIS", "TOKEN_DOT",
  "TOKEN_SEMI", "TOKEN_COMMA", "TOKEN_COLON", "TOKEN_TERNARY",
  "TOKEN_LEFT_PARENTHESES", "TOKEN_RIGHT_PARENTHESES", "TOKEN_LEFT_BRACE",
  "TOKEN_RIGHT_BRACE", "TOKEN_LEFT_BRACKET", "TOKEN_RIGHT_BRACKET",
  "TOKEN_ERROR", "LOWER_THAN_ELSE", "UNARY", "$accept", "translation_unit",
  "external_declaration", "statement_sequence", "statement",
  "expression_statement", "selection_statement", "jump_statement",
  "iteration_statement", "compound_statement", "enum_member_list",
  "enum_member", "struct_union_member_list", "struct_member",
  "if_statement", "switch_statement", "switch_body", "case_list",
  "case_clause", "default_clause", "continue_statement", "break_statement",
  "return_statement", "while_loop", "do_while_loop", "for_loop",
  "for_init_field", "for_condition", "for_assignment_field",
  "function_definition", "parameter_list_opt", "param_declaration",
  "type_name", "type_cast_specifier", "all_type_specifiers",
  "type_pointer", "enum_specifier", "struct_specifier", "union_specifier",
  "type_specifier", "storage_class_specifier", "function_specifier",
  "type_qualifier", "sign_specifier", "declaration_specifier",
  "declaration_specifiers", "pointer_prefix", "declaration",
  "init_declarator_list_opt", "init_declarator_list", "init_declarator",
  "initializer", "declarator", "direct_declarator", "arr_size",
  "expression", "assignment_expression", "conditional_expression",
  "logical_or_expression", "logical_and_expression",
  "inclusive_or_expression", "exclusive_or_expression", "and_expression",
  "equality_expression", "relational_expression", "shift_expression",
  "additive_expression", "multiplicative_expression", "cast_expression",
  "unary_expression", "postfix_expression", "primary_expression",
  "argument_expression_list_opt", "argument_expression_list",
  "assignment_operator", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-276)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-1)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
     658,  -276,  -276,  -276,  -276,  -276,  -276,  -276,  -276,  -276,
    -276,  -276,  -276,  -276,  -276,    22,    59,    65,   692,  -276,
    -276,  -276,  -276,  -276,  -276,  -276,  -276,  -276,  -276,  -276,
     401,  -276,    -5,    13,    25,  -276,  -276,   -20,    67,  -276,
      89,    48,    51,  -276,   -41,  -276,   658,   658,   127,   658,
     204,    55,  -276,  -276,  -276,    14,   538,  -276,  -276,   132,
    -276,   401,   324,    95,   -44,  -276,   -11,  -276,   401,  -276,
    -276,  -276,  -276,  -276,   581,   538,   538,   538,   622,   622,
     538,   538,   538,   490,  -276,   538,   -50,  -276,  -276,   -45,
     107,   106,   133,   129,    28,    41,    21,    57,    40,  -276,
     113,   -33,  -276,   538,  -276,   154,  -276,  -276,   286,  -276,
    -276,   128,  -276,    17,   127,  -276,   242,  -276,  -276,   490,
    -276,  -276,  -276,  -276,  -276,   538,  -276,  -276,  -276,  -276,
    -276,   122,  -276,   163,   164,   -10,  -276,   538,  -276,   538,
     538,   538,   538,   538,   538,   538,   538,   538,   538,   538,
     538,   538,   538,   538,   538,   538,   538,   538,  -276,  -276,
    -276,  -276,  -276,  -276,  -276,  -276,  -276,  -276,  -276,   538,
    -276,  -276,   197,   199,   538,   538,   -39,   136,   137,   138,
     139,   364,   144,   145,   531,  -276,  -276,  -276,  -276,  -276,
    -276,  -276,  -276,  -276,  -276,  -276,  -276,  -276,  -276,  -276,
    -276,   401,  -276,    29,  -276,  -276,   216,  -276,  -276,  -276,
     142,  -276,  -276,  -276,  -276,  -276,   107,    45,   106,   133,
     129,    28,    41,    41,    21,    21,    21,    21,    57,    57,
      40,    40,  -276,  -276,  -276,  -276,  -276,  -276,  -276,   143,
     149,   -32,  -276,   538,   538,   441,   538,   192,  -276,  -276,
    -276,    50,  -276,  -276,  -276,   538,  -276,   538,  -276,    -9,
      -3,   153,   401,   156,    -1,   150,  -276,  -276,  -276,   364,
     152,   538,    51,   364,   538,   201,    98,   159,   156,  -276,
       4,   364,    53,   158,   155,    98,  -276,  -276,   538,   165,
    -276,   161,   162,   169,  -276,  -276,  -276,  -276,   170,   156,
    -276,  -276,  -276,  -276,   364,   364,   364,   364,   364,  -276
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       0,    81,    79,    83,    84,    85,    91,    94,    95,    82,
      80,    89,    90,    92,    93,     0,     0,     0,     0,     2,
       4,    88,    86,    87,    97,    96,    99,    98,   100,   101,
     106,     5,    75,    77,    73,     1,     3,   115,   103,   102,
       0,     0,   107,   108,   110,   113,     0,     0,     0,    61,
       0,   116,   104,   114,   105,     0,     0,     6,    60,     0,
      31,     0,     0,    28,     0,    25,     0,    64,    66,   176,
     177,   178,   179,   175,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   119,     0,     0,   121,   123,   125,
     127,   129,   131,   133,   135,   137,   140,   145,   148,   151,
     155,   157,   168,     0,   109,   110,   111,   112,     0,    76,
      32,     0,    78,     0,    27,    74,     0,   117,    65,     0,
     166,   162,   155,   163,   161,     0,   158,   159,   164,   160,
     165,     0,    67,    70,    69,     0,   156,     0,   118,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   185,   186,
     187,   194,   195,   188,   191,   192,   193,   189,   190,     0,
     173,   174,     0,     0,   181,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    14,    24,     7,    13,     8,
      10,     9,    11,    16,    17,    20,    18,    19,    22,    21,
      23,   106,    12,     0,    33,    29,     0,    26,    62,    63,
       0,    68,    72,    71,   180,   122,   128,     0,   130,   132,
     134,   136,   138,   139,   141,   142,   143,   144,   146,   147,
     149,   150,   152,   153,   154,   124,   172,   171,   183,     0,
     182,     0,   120,     0,     0,    53,     0,     0,    47,    46,
      48,     0,    15,    30,   167,     0,   170,     0,   169,     0,
       0,     0,     0,    55,     0,     0,    49,   126,   184,     0,
       0,    56,    54,     0,     0,    34,     0,     0,    57,    50,
       0,     0,     0,     0,     0,    38,    40,    39,    58,     0,
      35,     0,     0,     0,     6,    36,    41,    37,     0,    59,
      51,     6,     6,     6,    45,     0,    42,    43,    44,    52
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -276,  -276,   222,  -275,  -176,  -276,  -276,  -276,  -276,   205,
    -276,   160,   223,   -37,  -276,  -276,  -276,  -276,   -13,   -12,
    -276,  -276,  -276,  -276,  -276,  -276,  -276,  -276,  -276,  -276,
    -276,   166,   157,  -276,  -276,  -276,  -276,  -276,  -276,   -68,
    -276,  -276,  -276,  -276,   -28,     0,   231,    23,  -276,    15,
     220,  -276,   -16,   238,  -276,   -49,   -52,    24,  -276,   141,
     146,   173,   140,   172,    -8,   -17,    18,    38,   -69,    33,
    -276,  -276,  -276,  -276,  -276
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,    18,    19,   108,   187,   188,   189,   190,   191,   192,
      64,    65,    59,    60,   193,   194,   284,   285,   286,   287,
     195,   196,   197,   198,   199,   200,   261,   277,   298,    20,
      66,    67,   131,    85,   132,   133,    21,    22,    23,    24,
      25,    26,    27,    28,    29,   201,    40,   202,    41,    42,
      43,   106,   105,    45,    51,   203,    87,    88,    89,    90,
      91,    92,    93,    94,    95,    96,    97,    98,    99,   100,
     101,   102,   239,   240,   169
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      30,    86,    39,    56,   107,   247,   121,   123,   124,   170,
     171,   128,   129,   130,    44,   134,   136,   139,    30,   304,
     205,    37,   110,    31,   137,   110,   306,   307,   308,    32,
     114,   140,   138,    39,   135,   137,   115,   172,    57,   173,
      39,    31,   137,   242,   174,   111,    61,    61,   175,    68,
     258,   134,   118,    38,   176,   206,   291,    49,   292,    61,
     293,    50,    61,   116,   137,   137,    33,   117,   214,   269,
     135,   137,    34,   137,    46,   270,   135,   273,   137,   155,
     156,   157,   289,   145,   146,   215,   232,   233,   234,   151,
     152,   217,    47,   275,   153,   154,    37,   279,   147,   148,
     149,   150,   252,   137,    48,   290,    38,   120,   122,   122,
     122,   126,   127,   122,   122,   122,    68,   235,   122,   137,
     255,    54,   238,   266,   137,    55,   241,   282,   283,   309,
     224,   225,   226,   227,    63,   251,   103,   222,   223,   113,
       1,     2,     3,     4,     5,     6,     7,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,   158,   159,   160,
     161,   162,   163,   164,   165,   166,   167,   168,   141,   228,
     229,   142,   122,    39,   122,   122,   122,   122,   122,   122,
     122,   122,   122,   122,   122,   122,   122,   122,   122,   122,
     122,   230,   231,   144,   259,   260,   263,   264,    56,   143,
     211,   204,   212,   213,   236,   268,   237,    69,    70,    71,
      72,    73,   109,   243,   244,   245,   246,   248,   249,   253,
     254,   256,   278,   257,   265,   280,   271,   274,   281,    74,
     137,   276,   288,   294,    39,   295,   301,   302,   300,   299,
      36,    75,    76,    77,   303,   262,    78,    79,   305,    58,
       1,     2,     3,     4,     5,     6,     7,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    80,    81,    52,
      62,    82,   296,   297,   207,   104,   210,   272,    53,   267,
     216,    83,   209,   220,     0,     0,    84,   218,   122,    69,
      70,    71,    72,    73,     1,     2,     3,     4,     5,     6,
       7,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    74,   177,   208,   178,   219,   221,   179,   180,   181,
     182,   183,   184,    75,    76,    77,     0,     0,    78,    79,
       0,     0,     1,     2,     3,     4,     5,     6,     7,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    80,
      81,     0,     0,    82,     0,     0,     0,     0,     0,   185,
       0,     0,     0,    83,     0,    57,   186,    69,    70,    71,
      72,    73,     1,     2,     3,     4,     5,     6,     7,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    74,
     177,     0,   178,     0,     0,   179,   180,   181,   182,   183,
     184,    75,    76,    77,   112,     0,    78,    79,    37,     1,
       2,     3,     4,     5,     6,     7,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,     0,    80,    81,     0,
       0,    82,     0,     0,     0,     0,     0,   185,     0,     0,
      38,    83,     0,    57,    69,    70,    71,    72,    73,     1,
       2,     3,     4,     5,     6,     7,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    74,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    75,    76,
      77,     0,     0,    78,    79,     0,     0,     0,     0,     0,
       0,     0,     0,    69,    70,    71,    72,    73,     1,     2,
       3,     4,     5,     0,    80,    81,     9,    10,    82,     0,
       0,     0,    15,    16,    17,    74,     0,     0,    83,     0,
       0,     0,     0,     0,     0,     0,     0,    75,    76,    77,
       0,     0,    78,    79,    69,    70,    71,    72,    73,     0,
       0,    69,    70,    71,    72,    73,     0,     0,     0,     0,
       0,     0,     0,    80,    81,     0,    74,    82,     0,     0,
       0,     0,     0,    74,     0,     0,     0,    83,    75,    76,
      77,     0,     0,    78,    79,    75,    76,    77,     0,     0,
      78,    79,     0,     0,    69,    70,    71,    72,    73,     0,
       0,     0,     0,     0,    80,    81,     0,     0,    82,     0,
       0,    80,    81,     0,   250,    82,    74,     0,    83,     0,
       0,     0,     0,     0,     0,    83,     0,     0,    75,    76,
      77,     0,     0,    78,    79,    69,    70,    71,    72,    73,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    80,    81,     0,    74,    82,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   119,    75,
      76,    77,     0,     0,    78,    79,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,     0,     0,    80,    81,     0,     0,    82,
       0,     0,    35,     0,     0,     0,     0,     0,     0,   125,
       1,     2,     3,     4,     5,     6,     7,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17
};

static const yytype_int16 yycheck[] =
{
       0,    50,    30,    44,    56,   181,    75,    76,    77,    42,
      43,    80,    81,    82,    30,    83,    85,    62,    18,   294,
       3,     7,    59,     0,    74,    62,   301,   302,   303,     7,
      74,    76,    82,    61,    83,    74,    80,    70,    79,    72,
      68,    18,    74,    82,    77,    61,    46,    47,    81,    49,
      82,   119,    68,    39,   103,    38,     3,    77,     5,    59,
       7,    81,    62,    74,    74,    74,     7,    78,    78,    78,
     119,    74,     7,    74,    79,    78,   125,    78,    74,    39,
      40,    41,    78,    55,    56,   137,   155,   156,   157,    68,
      69,   140,    79,   269,    37,    38,     7,   273,    57,    58,
      59,    60,    73,    74,    79,   281,    39,    74,    75,    76,
      77,    78,    79,    80,    81,    82,   116,   169,    85,    74,
      75,    73,   174,    73,    74,    74,   175,    29,    30,   305,
     147,   148,   149,   150,     7,   184,    81,   145,   146,    44,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,    24,    44,    45,    46,
      47,    48,    49,    50,    51,    52,    53,    54,    61,   151,
     152,    65,   139,   201,   141,   142,   143,   144,   145,   146,
     147,   148,   149,   150,   151,   152,   153,   154,   155,   156,
     157,   153,   154,    64,   243,   244,   245,   246,    44,    66,
      78,    73,    39,    39,     7,   257,     7,     3,     4,     5,
       6,     7,    80,    77,    77,    77,    77,    73,    73,     3,
      78,    78,   271,    74,    32,   274,    73,    77,    27,    25,
      74,    79,    73,    75,   262,    80,    75,    75,    73,   288,
      18,    37,    38,    39,    75,   245,    42,    43,    78,    44,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,    24,    63,    64,    38,
      47,    67,   285,   285,   114,    55,   119,   262,    40,   255,
     139,    77,   116,   143,    -1,    -1,    82,   141,   255,     3,
       4,     5,     6,     7,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,    71,    28,   142,   144,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    -1,    -1,    42,    43,
      -1,    -1,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    63,
      64,    -1,    -1,    67,    -1,    -1,    -1,    -1,    -1,    73,
      -1,    -1,    -1,    77,    -1,    79,    80,     3,     4,     5,
       6,     7,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26,    -1,    28,    -1,    -1,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    80,    -1,    42,    43,     7,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,    -1,    63,    64,    -1,
      -1,    67,    -1,    -1,    -1,    -1,    -1,    73,    -1,    -1,
      39,    77,    -1,    79,     3,     4,     5,     6,     7,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,    25,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    37,    38,
      39,    -1,    -1,    42,    43,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,     3,     4,     5,     6,     7,     8,     9,
      10,    11,    12,    -1,    63,    64,    16,    17,    67,    -1,
      -1,    -1,    22,    23,    24,    25,    -1,    -1,    77,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    37,    38,    39,
      -1,    -1,    42,    43,     3,     4,     5,     6,     7,    -1,
      -1,     3,     4,     5,     6,     7,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    63,    64,    -1,    25,    67,    -1,    -1,
      -1,    -1,    -1,    25,    -1,    -1,    -1,    77,    37,    38,
      39,    -1,    -1,    42,    43,    37,    38,    39,    -1,    -1,
      42,    43,    -1,    -1,     3,     4,     5,     6,     7,    -1,
      -1,    -1,    -1,    -1,    63,    64,    -1,    -1,    67,    -1,
      -1,    63,    64,    -1,    73,    67,    25,    -1,    77,    -1,
      -1,    -1,    -1,    -1,    -1,    77,    -1,    -1,    37,    38,
      39,    -1,    -1,    42,    43,     3,     4,     5,     6,     7,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    63,    64,    -1,    25,    67,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    77,    37,
      38,    39,    -1,    -1,    42,    43,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,    24,    -1,    -1,    63,    64,    -1,    -1,    67,
      -1,    -1,     0,    -1,    -1,    -1,    -1,    -1,    -1,    77,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,    24
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,    87,    88,
     115,   122,   123,   124,   125,   126,   127,   128,   129,   130,
     131,   133,     7,     7,     7,     0,    88,     7,    39,   130,
     132,   134,   135,   136,   138,   139,    79,    79,    79,    77,
      81,   140,   132,   139,    73,    74,    44,    79,    95,    98,
      99,   131,    98,     7,    96,    97,   116,   117,   131,     3,
       4,     5,     6,     7,    25,    37,    38,    39,    42,    43,
      63,    64,    67,    77,    82,   119,   141,   142,   143,   144,
     145,   146,   147,   148,   149,   150,   151,   152,   153,   154,
     155,   156,   157,    81,   136,   138,   137,   142,    89,    80,
      99,   138,    80,    44,    74,    80,    74,    78,   138,    77,
     155,   154,   155,   154,   154,    77,   155,   155,   154,   154,
     154,   118,   120,   121,   125,   141,   154,    74,    82,    62,
      76,    61,    65,    66,    64,    55,    56,    57,    58,    59,
      60,    68,    69,    37,    38,    39,    40,    41,    44,    45,
      46,    47,    48,    49,    50,    51,    52,    53,    54,   160,
      42,    43,    70,    72,    77,    81,   141,    26,    28,    31,
      32,    33,    34,    35,    36,    73,    80,    90,    91,    92,
      93,    94,    95,   100,   101,   106,   107,   108,   109,   110,
     111,   131,   133,   141,    73,     3,    38,    97,    71,   117,
     118,    78,    39,    39,    78,   142,   145,   141,   146,   147,
     148,   149,   150,   150,   151,   151,   151,   151,   152,   152,
     153,   153,   154,   154,   154,   142,     7,     7,   142,   158,
     159,   141,    82,    77,    77,    77,    77,    90,    73,    73,
      73,   141,    73,     3,    78,    75,    78,    74,    82,   141,
     141,   112,   131,   141,   141,    32,    73,   143,   142,    78,
      78,    73,   135,    78,    77,    90,    79,   113,   141,    90,
     141,    27,    29,    30,   102,   103,   104,   105,    73,    78,
      90,     3,     5,     7,    75,    80,   104,   105,   114,   141,
      73,    75,    75,    75,    89,    78,    89,    89,    89,    90
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_uint8 yyr1[] =
{
       0,    86,    87,    87,    88,    88,    89,    89,    90,    90,
      90,    90,    90,    90,    91,    91,    92,    92,    93,    93,
      93,    94,    94,    94,    95,    96,    96,    96,    97,    97,
      97,    98,    98,    99,   100,   100,   101,   102,   102,   102,
     103,   103,   104,   104,   104,   105,   106,   107,   108,   108,
     109,   110,   111,   112,   112,   112,   113,   113,   114,   114,
     115,   116,   116,   116,   116,   117,   117,   118,   119,   120,
     120,   121,   121,   122,   122,   123,   123,   124,   124,   125,
     125,   125,   125,   125,   125,   125,   125,   125,   125,   126,
     126,   127,   128,   128,   129,   129,   130,   130,   130,   130,
     130,   131,   131,   132,   132,   133,   134,   134,   135,   135,
     136,   136,   137,   138,   138,   139,   139,   139,   140,   140,
     140,   141,   141,   142,   142,   143,   143,   144,   144,   145,
     145,   146,   146,   147,   147,   148,   148,   149,   149,   149,
     150,   150,   150,   150,   150,   151,   151,   151,   152,   152,
     152,   153,   153,   153,   153,   154,   154,   155,   155,   155,
     155,   155,   155,   155,   155,   155,   155,   155,   156,   156,
     156,   156,   156,   156,   156,   157,   157,   157,   157,   157,
     157,   158,   158,   159,   159,   160,   160,   160,   160,   160,
     160,   160,   160,   160,   160,   160
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     1,     2,     1,     1,     0,     2,     1,     1,
       1,     1,     1,     1,     1,     2,     1,     1,     1,     1,
       1,     1,     1,     1,     3,     1,     3,     2,     1,     3,
       4,     1,     2,     3,     5,     7,     7,     2,     1,     1,
       1,     2,     4,     4,     4,     3,     2,     2,     2,     3,
       5,     7,     9,     0,     2,     1,     0,     1,     0,     1,
       3,     0,     3,     3,     1,     2,     1,     1,     3,     1,
       1,     2,     2,     2,     5,     2,     5,     2,     5,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     2,     1,     2,     3,     0,     1,     1,     3,
       1,     3,     1,     1,     2,     1,     2,     4,     3,     2,
       4,     1,     3,     1,     3,     1,     5,     1,     3,     1,
       3,     1,     3,     1,     3,     1,     3,     1,     3,     3,
       1,     3,     3,     3,     3,     1,     3,     3,     1,     3,
       3,     1,     3,     3,     3,     1,     2,     1,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     4,     1,     4,
       4,     3,     3,     2,     2,     1,     1,     1,     1,     1,
       3,     0,     1,     1,     3,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1
};


enum { YYENOMEM = -2 };

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYNOMEM         goto yyexhaustedlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == YYEMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Backward compatibility with an undocumented macro.
   Use YYerror or YYUNDEF. */
#define YYERRCODE YYUNDEF


/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)




# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Kind, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
  if (!yyvaluep)
    return;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo,
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  yy_symbol_value_print (yyo, yykind, yyvaluep);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp,
                 int yyrule)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       YY_ACCESSING_SYMBOL (+yyssp[yyi + 1 - yynrhs]),
                       &yyvsp[(yyi + 1) - (yynrhs)]);
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args) ((void) 0)
# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif






/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg,
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep)
{
  YY_USE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yykind, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/* Lookahead token kind.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;




/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    yy_state_fast_t yystate = 0;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus = 0;

    /* Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* Their size.  */
    YYPTRDIFF_T yystacksize = YYINITDEPTH;

    /* The state stack: array, bottom, top.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss = yyssa;
    yy_state_t *yyssp = yyss;

    /* The semantic value stack: array, bottom, top.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs = yyvsa;
    YYSTYPE *yyvsp = yyvs;

  int yyn;
  /* The return value of yyparse.  */
  int yyresult;
  /* Lookahead symbol kind.  */
  yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yychar = YYEMPTY; /* Cause a token to be read.  */

  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END
  YY_STACK_PRINT (yyss, yyssp);

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    YYNOMEM;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        YYNOMEM;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          YYNOMEM;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */


  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:
  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either empty, or end-of-input, or a valid lookahead.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token\n"));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = YYEOF;
      yytoken = YYSYMBOL_YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else if (yychar == YYerror)
    {
      /* The scanner already issued an error message, process directly
         to error recovery.  But do not keep the error token as
         lookahead, it is too special and may lead us to an endless
         loop in error recovery. */
      yychar = YYUNDEF;
      yytoken = YYSYMBOL_YYerror;
      goto yyerrlab1;
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  /* Discard the shifted token.  */
  yychar = YYEMPTY;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 2: /* translation_unit: external_declaration  */
#line 438 "Parser/parser.y"
                    {
                        NodeCreate(&yyval.treeNode, NODE_TRANSLATION_UNIT);
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                        p_treeRoot = yyval.treeNode;
                    }
#line 1899 "Parser/parser.tab.c"
    break;

  case 3: /* translation_unit: translation_unit external_declaration  */
#line 444 "Parser/parser.y"
                    {
                        TreeNode_t* pRoot = yyvsp[-1].treeNode;
                        TreeNode_t* pHead = pRoot->p_firstChild;
                        if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                        pRoot->p_firstChild = pHead;
                        pRoot->childNumber++;
                        yyval.treeNode = pRoot;
                        p_treeRoot = yyval.treeNode;
                    }
#line 1913 "Parser/parser.tab.c"
    break;

  case 4: /* external_declaration: function_definition  */
#line 457 "Parser/parser.y"
                                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 1919 "Parser/parser.tab.c"
    break;

  case 5: /* external_declaration: declaration  */
#line 458 "Parser/parser.y"
                                { yyval.treeNode = yyvsp[0].treeNode; }
#line 1925 "Parser/parser.tab.c"
    break;

  case 6: /* statement_sequence: %empty  */
#line 462 "Parser/parser.y"
                                     { yyval.treeNode = NULL; }
#line 1931 "Parser/parser.tab.c"
    break;

  case 7: /* statement_sequence: statement_sequence statement  */
#line 464 "Parser/parser.y"
                       {
                           TreeNode_t* pHead = yyvsp[-1].treeNode;
                           if (yyvsp[0].treeNode != NULL) {
                               if (pHead == NULL) {
                                   pHead = yyvsp[0].treeNode;
                               } else {
                                   if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                               }
                           }
                           yyval.treeNode = pHead;
                       }
#line 1947 "Parser/parser.tab.c"
    break;

  case 8: /* statement: selection_statement  */
#line 477 "Parser/parser.y"
                                      { yyval.treeNode = yyvsp[0].treeNode; }
#line 1953 "Parser/parser.tab.c"
    break;

  case 9: /* statement: iteration_statement  */
#line 478 "Parser/parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 1959 "Parser/parser.tab.c"
    break;

  case 10: /* statement: jump_statement  */
#line 479 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[0].treeNode; }
#line 1965 "Parser/parser.tab.c"
    break;

  case 11: /* statement: compound_statement  */
#line 480 "Parser/parser.y"
                                           { yyval.treeNode = yyvsp[0].treeNode; }
#line 1971 "Parser/parser.tab.c"
    break;

  case 12: /* statement: declaration  */
#line 481 "Parser/parser.y"
                                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 1977 "Parser/parser.tab.c"
    break;

  case 13: /* statement: expression_statement  */
#line 482 "Parser/parser.y"
                                             { yyval.treeNode = yyvsp[0].treeNode; }
#line 1983 "Parser/parser.tab.c"
    break;

  case 14: /* expression_statement: TOKEN_SEMI  */
#line 487 "Parser/parser.y"
                    {
                        yyval.treeNode = NULL;
                    }
#line 1991 "Parser/parser.tab.c"
    break;

  case 15: /* expression_statement: expression TOKEN_SEMI  */
#line 491 "Parser/parser.y"
                    {
                        yyval.treeNode = yyvsp[-1].treeNode;
                    }
#line 1999 "Parser/parser.tab.c"
    break;

  case 16: /* selection_statement: if_statement  */
#line 500 "Parser/parser.y"
                                   { yyval.treeNode = yyvsp[0].treeNode; }
#line 2005 "Parser/parser.tab.c"
    break;

  case 17: /* selection_statement: switch_statement  */
#line 501 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[0].treeNode; }
#line 2011 "Parser/parser.tab.c"
    break;

  case 18: /* jump_statement: break_statement  */
#line 504 "Parser/parser.y"
                                      { yyval.treeNode = yyvsp[0].treeNode; }
#line 2017 "Parser/parser.tab.c"
    break;

  case 19: /* jump_statement: return_statement  */
#line 505 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[0].treeNode; }
#line 2023 "Parser/parser.tab.c"
    break;

  case 20: /* jump_statement: continue_statement  */
#line 506 "Parser/parser.y"
                                         { yyval.treeNode = yyvsp[0].treeNode; }
#line 2029 "Parser/parser.tab.c"
    break;

  case 21: /* iteration_statement: do_while_loop  */
#line 509 "Parser/parser.y"
                                      { yyval.treeNode = yyvsp[0].treeNode; }
#line 2035 "Parser/parser.tab.c"
    break;

  case 22: /* iteration_statement: while_loop  */
#line 510 "Parser/parser.y"
                                   { yyval.treeNode = yyvsp[0].treeNode; }
#line 2041 "Parser/parser.tab.c"
    break;

  case 23: /* iteration_statement: for_loop  */
#line 511 "Parser/parser.y"
                                 { yyval.treeNode = yyvsp[0].treeNode; }
#line 2047 "Parser/parser.tab.c"
    break;

  case 24: /* compound_statement: TOKEN_LEFT_BRACE statement_sequence TOKEN_RIGHT_BRACE  */
#line 515 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_BLOCK);
                            if (yyvsp[-1].treeNode != NULL) {
                                NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                            }
                        }
#line 2058 "Parser/parser.tab.c"
    break;

  case 25: /* enum_member_list: enum_member  */
#line 524 "Parser/parser.y"
                                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 2064 "Parser/parser.tab.c"
    break;

  case 26: /* enum_member_list: enum_member_list TOKEN_COMMA enum_member  */
#line 526 "Parser/parser.y"
                        {
                            TreeNode_t* pHead = yyvsp[-2].treeNode;
                            if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                            yyval.treeNode = pHead;
                        }
#line 2074 "Parser/parser.tab.c"
    break;

  case 27: /* enum_member_list: enum_member_list TOKEN_COMMA  */
#line 532 "Parser/parser.y"
                        { yyval.treeNode = yyvsp[-1].treeNode; }
#line 2080 "Parser/parser.tab.c"
    break;

  case 28: /* enum_member: TOKEN_ID  */
#line 536 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_ENUM_MEMBER);
                            yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                        }
#line 2089 "Parser/parser.tab.c"
    break;

  case 29: /* enum_member: TOKEN_ID TOKEN_ASSIGN TOKEN_NUM  */
#line 541 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_ENUM_MEMBER);
                            yyval.treeNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                            TreeNode_t* pVal;
                            NodeCreate(&pVal, NODE_INTEGER);
                            pVal->nodeData.dVal = yyvsp[0].nodeData.dVal;  // guarda o valor!
                            NodeAddChild(yyval.treeNode, pVal);
                        }
#line 2102 "Parser/parser.tab.c"
    break;

  case 30: /* enum_member: TOKEN_ID TOKEN_ASSIGN TOKEN_MINUS TOKEN_NUM  */
#line 550 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_ENUM_MEMBER);
                            yyval.treeNode->nodeData.sVal = yyvsp[-3].nodeData.sVal;
                            TreeNode_t* pVal;
                            NodeCreate(&pVal, NODE_INTEGER);
                            pVal->nodeData.dVal = -yyvsp[0].nodeData.dVal;
                            NodeAddChild(yyval.treeNode, pVal);
                        }
#line 2115 "Parser/parser.tab.c"
    break;

  case 31: /* struct_union_member_list: struct_member  */
#line 562 "Parser/parser.y"
                                             { yyval.treeNode = yyvsp[0].treeNode; }
#line 2121 "Parser/parser.tab.c"
    break;

  case 32: /* struct_union_member_list: struct_union_member_list struct_member  */
#line 564 "Parser/parser.y"
                              {
                                  TreeNode_t* pHead = yyvsp[-1].treeNode;
                                  if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                                  yyval.treeNode = pHead;
                              }
#line 2131 "Parser/parser.tab.c"
    break;

  case 33: /* struct_member: declaration_specifiers declarator TOKEN_SEMI  */
#line 573 "Parser/parser.y"
                        {
                            if (NodeAttachDeclSpecifiers(yyvsp[-1].treeNode, yyvsp[-2].treeNode)) { YYERROR; }
                            if (yyvsp[-1].treeNode->nodeType == NODE_VAR_DECLARATION) {
                                yyvsp[-1].treeNode->nodeType = NODE_STRUCT_MEMBER;
                            }
                            NodeFree(yyvsp[-2].treeNode);
                            yyval.treeNode = yyvsp[-1].treeNode;
                        }
#line 2144 "Parser/parser.tab.c"
    break;

  case 34: /* if_statement: TOKEN_IF TOKEN_LEFT_PARENTHESES expression TOKEN_RIGHT_PARENTHESES statement  */
#line 588 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_IF);
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);    //condition
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);    //if true
                    }
#line 2154 "Parser/parser.tab.c"
    break;

  case 35: /* if_statement: TOKEN_IF TOKEN_LEFT_PARENTHESES expression TOKEN_RIGHT_PARENTHESES statement TOKEN_ELSE statement  */
#line 594 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_IF);
                        NodeAddChild(yyval.treeNode, yyvsp[-4].treeNode);   //condition
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);   //if true
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);   //else
                    }
#line 2165 "Parser/parser.tab.c"
    break;

  case 36: /* switch_statement: TOKEN_SWITCH TOKEN_LEFT_PARENTHESES expression TOKEN_RIGHT_PARENTHESES TOKEN_LEFT_BRACE switch_body TOKEN_RIGHT_BRACE  */
#line 603 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_SWITCH);
                            NodeAddChild(yyval.treeNode, yyvsp[-4].treeNode);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2175 "Parser/parser.tab.c"
    break;

  case 37: /* switch_body: case_list default_clause  */
#line 611 "Parser/parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[-1].treeNode;
                        if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                        yyval.treeNode = pHead;
                    }
#line 2185 "Parser/parser.tab.c"
    break;

  case 38: /* switch_body: case_list  */
#line 617 "Parser/parser.y"
                    {
                        yyval.treeNode = yyvsp[0].treeNode;
                    }
#line 2193 "Parser/parser.tab.c"
    break;

  case 39: /* switch_body: default_clause  */
#line 621 "Parser/parser.y"
                    {
                        yyval.treeNode = yyvsp[0].treeNode;
                    }
#line 2201 "Parser/parser.tab.c"
    break;

  case 40: /* case_list: case_clause  */
#line 627 "Parser/parser.y"
                    {
                        yyval.treeNode = yyvsp[0].treeNode;
                    }
#line 2209 "Parser/parser.tab.c"
    break;

  case 41: /* case_list: case_list case_clause  */
#line 631 "Parser/parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[-1].treeNode;
                        if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                        yyval.treeNode = pHead;
                    }
#line 2219 "Parser/parser.tab.c"
    break;

  case 42: /* case_clause: TOKEN_CASE TOKEN_NUM TOKEN_COLON statement_sequence  */
#line 639 "Parser/parser.y"
                    {
                          NodeCreate(&(yyval.treeNode), NODE_CASE);
                          yyval.treeNode->nodeData.sVal = NULL;
                          yyval.treeNode->nodeData.dVal = yyvsp[-2].nodeData.dVal;
                          NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2230 "Parser/parser.tab.c"
    break;

  case 43: /* case_clause: TOKEN_CASE TOKEN_CNUM TOKEN_COLON statement_sequence  */
#line 646 "Parser/parser.y"
                    {
                          NodeCreate(&(yyval.treeNode), NODE_CASE);
                          yyval.treeNode->nodeData.dVal = yyvsp[-2].nodeData.dVal;
                          NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2240 "Parser/parser.tab.c"
    break;

  case 44: /* case_clause: TOKEN_CASE TOKEN_ID TOKEN_COLON statement_sequence  */
#line 652 "Parser/parser.y"
                    {
                          NodeCreate(&(yyval.treeNode), NODE_CASE);
                          yyval.treeNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;  /* guarda o nome */
                          NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2250 "Parser/parser.tab.c"
    break;

  case 45: /* default_clause: TOKEN_DEFAULT TOKEN_COLON statement_sequence  */
#line 660 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_DEFAULT);
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2259 "Parser/parser.tab.c"
    break;

  case 46: /* continue_statement: TOKEN_CONTINUE TOKEN_SEMI  */
#line 671 "Parser/parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_CONTINUE); }
#line 2265 "Parser/parser.tab.c"
    break;

  case 47: /* break_statement: TOKEN_BREAK TOKEN_SEMI  */
#line 675 "Parser/parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_BREAK); }
#line 2271 "Parser/parser.tab.c"
    break;

  case 48: /* return_statement: TOKEN_RETURN TOKEN_SEMI  */
#line 679 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_RETURN);
                        }
#line 2279 "Parser/parser.tab.c"
    break;

  case 49: /* return_statement: TOKEN_RETURN expression TOKEN_SEMI  */
#line 683 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_RETURN);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2288 "Parser/parser.tab.c"
    break;

  case 50: /* while_loop: TOKEN_WHILE TOKEN_LEFT_PARENTHESES expression TOKEN_RIGHT_PARENTHESES statement  */
#line 694 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_WHILE);
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);    // Condition
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);    // if true
                    }
#line 2298 "Parser/parser.tab.c"
    break;

  case 51: /* do_while_loop: TOKEN_DO statement TOKEN_WHILE TOKEN_LEFT_PARENTHESES expression TOKEN_RIGHT_PARENTHESES TOKEN_SEMI  */
#line 703 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_DO_WHILE);
                        NodeAddChild(yyval.treeNode, yyvsp[-5].treeNode);
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                    }
#line 2308 "Parser/parser.tab.c"
    break;

  case 52: /* for_loop: TOKEN_FOR TOKEN_LEFT_PARENTHESES for_init_field TOKEN_SEMI for_condition TOKEN_SEMI for_assignment_field TOKEN_RIGHT_PARENTHESES statement  */
#line 711 "Parser/parser.y"
                    {
                        TreeNode_t* pNull;

                        NodeCreate(&(yyval.treeNode), NODE_FOR);

                        if (yyvsp[-6].treeNode != NULL) {
                            NodeAddChild(yyval.treeNode, yyvsp[-6].treeNode);
                        } else {
                            NodeCreate(&pNull, NODE_NULL);
                            NodeAddChild(yyval.treeNode, pNull);
                        }

                        if (yyvsp[-4].treeNode != NULL) {
                            NodeAddChild(yyval.treeNode, yyvsp[-4].treeNode);
                        } else {
                            NodeCreate(&pNull, NODE_NULL);
                            NodeAddChild(yyval.treeNode, pNull);
                        }

                        if (yyvsp[-2].treeNode != NULL) {
                            NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                        } else {
                            NodeCreate(&pNull, NODE_NULL);
                            NodeAddChild(yyval.treeNode, pNull);
                        }

                        if (yyvsp[0].treeNode != NULL) {
                            NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                        } else {
                            NodeCreate(&pNull, NODE_NULL);
                            NodeAddChild(yyval.treeNode, pNull);
                        }
                    }
#line 2346 "Parser/parser.tab.c"
    break;

  case 53: /* for_init_field: %empty  */
#line 746 "Parser/parser.y"
                           { yyval.treeNode = NULL; }
#line 2352 "Parser/parser.tab.c"
    break;

  case 54: /* for_init_field: declaration_specifiers init_declarator_list  */
#line 748 "Parser/parser.y"
                    {
                        TreeNode_t *pNode = yyvsp[0].treeNode;
                        do {
                            if (pNode->nodeType == NODE_VAR_DECLARATION ||
                                pNode->nodeType == NODE_ARRAY_DECLARATION) {
                                if (NodeAttachDeclSpecifiers(pNode, yyvsp[-1].treeNode)) { YYERROR; }
                            }
                            pNode = pNode->p_sibling;
                        } while (pNode != NULL);
                        NodeFree(yyvsp[-1].treeNode);
                        yyval.treeNode = yyvsp[0].treeNode;
                    }
#line 2369 "Parser/parser.tab.c"
    break;

  case 55: /* for_init_field: expression  */
#line 761 "Parser/parser.y"
                    {
                        yyval.treeNode = yyvsp[0].treeNode;
                    }
#line 2377 "Parser/parser.tab.c"
    break;

  case 56: /* for_condition: %empty  */
#line 765 "Parser/parser.y"
                             { yyval.treeNode = NULL; }
#line 2383 "Parser/parser.tab.c"
    break;

  case 57: /* for_condition: expression  */
#line 766 "Parser/parser.y"
                                 { yyval.treeNode = yyvsp[0].treeNode; }
#line 2389 "Parser/parser.tab.c"
    break;

  case 58: /* for_assignment_field: %empty  */
#line 769 "Parser/parser.y"
                                   { yyval.treeNode = NULL; }
#line 2395 "Parser/parser.tab.c"
    break;

  case 59: /* for_assignment_field: expression  */
#line 770 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[0].treeNode; }
#line 2401 "Parser/parser.tab.c"
    break;

  case 60: /* function_definition: declaration_specifiers declarator compound_statement  */
#line 778 "Parser/parser.y"
                        {
                            if (yyvsp[-1].treeNode->nodeType != NODE_FUNCTION) { YYERROR; }
                            if (NodeAttachDeclSpecifiers(yyvsp[-1].treeNode, yyvsp[-2].treeNode)) { YYERROR; }
                            NodeFree(yyvsp[-2].treeNode);
                            yyval.treeNode = yyvsp[-1].treeNode;
                            NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                        }
#line 2413 "Parser/parser.tab.c"
    break;

  case 61: /* parameter_list_opt: %empty  */
#line 789 "Parser/parser.y"
                            { yyval.treeNode = NULL; }
#line 2419 "Parser/parser.tab.c"
    break;

  case 62: /* parameter_list_opt: parameter_list_opt TOKEN_COMMA TOKEN_ELLIPSIS  */
#line 792 "Parser/parser.y"
                    {
                        TreeNode_t* pNode;
                        TreeNode_t* p_Head = yyvsp[-2].treeNode;
                        NodeCreate(&pNode, NODE_PARAMETER);
                        pNode->nodeData.sVal = strdup("...");
                        if (NodeAppendSibling(&p_Head, pNode)) { YYERROR; }
                        yyval.treeNode = p_Head;
                    }
#line 2432 "Parser/parser.tab.c"
    break;

  case 63: /* parameter_list_opt: parameter_list_opt TOKEN_COMMA param_declaration  */
#line 801 "Parser/parser.y"
                    {
                        TreeNode_t* p_Head = yyvsp[-2].treeNode;
                        if (NodeAppendSibling(&p_Head, yyvsp[0].treeNode)) { YYERROR; }
                        yyval.treeNode = p_Head;
                    }
#line 2442 "Parser/parser.tab.c"
    break;

  case 64: /* parameter_list_opt: param_declaration  */
#line 806 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[0].treeNode; }
#line 2448 "Parser/parser.tab.c"
    break;

  case 65: /* param_declaration: declaration_specifiers declarator  */
#line 811 "Parser/parser.y"
                        {
                            if (NodeAttachDeclSpecifiers(yyvsp[0].treeNode, yyvsp[-1].treeNode)) { YYERROR; }
                            NodeFree(yyvsp[-1].treeNode);
                            yyval.treeNode = yyvsp[0].treeNode;
                        }
#line 2458 "Parser/parser.tab.c"
    break;

  case 66: /* param_declaration: declaration_specifiers  */
#line 817 "Parser/parser.y"
                        {
                            if (is_void_parameter_specifier(yyvsp[0].treeNode)) {
                                yyval.treeNode = NULL;
                            } else {
                                NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
                                if (NodeAddChildCloneChain(yyval.treeNode, yyvsp[0].treeNode)) { YYERROR; }
                            }
                            NodeFree(yyvsp[0].treeNode);
                        }
#line 2472 "Parser/parser.tab.c"
    break;

  case 67: /* type_name: all_type_specifiers  */
#line 836 "Parser/parser.y"
                        {
                            yyval.treeNode = yyvsp[0].treeNode;
                        }
#line 2480 "Parser/parser.tab.c"
    break;

  case 68: /* type_cast_specifier: TOKEN_LEFT_PARENTHESES type_name TOKEN_RIGHT_PARENTHESES  */
#line 842 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE_CAST);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2489 "Parser/parser.tab.c"
    break;

  case 69: /* all_type_specifiers: type_specifier  */
#line 849 "Parser/parser.y"
                                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 2495 "Parser/parser.tab.c"
    break;

  case 70: /* all_type_specifiers: type_pointer  */
#line 850 "Parser/parser.y"
                                      { yyval.treeNode = yyvsp[0].treeNode; }
#line 2501 "Parser/parser.tab.c"
    break;

  case 71: /* type_pointer: type_specifier TOKEN_ASTERISK  */
#line 854 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_POINTER);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2510 "Parser/parser.tab.c"
    break;

  case 72: /* type_pointer: type_pointer TOKEN_ASTERISK  */
#line 859 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_POINTER);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2519 "Parser/parser.tab.c"
    break;

  case 73: /* enum_specifier: TOKEN_ENUM TOKEN_ID  */
#line 866 "Parser/parser.y"
                    {
                        if (build_tag_type_node(&yyval.treeNode,
                                                TYPE_ENUM,
                                                NODE_ENUM_DECLARATION,
                                                yyvsp[0].nodeData.sVal,
                                                NULL) < 0) { YYERROR; }
                    }
#line 2531 "Parser/parser.tab.c"
    break;

  case 74: /* enum_specifier: TOKEN_ENUM TOKEN_ID TOKEN_LEFT_BRACE enum_member_list TOKEN_RIGHT_BRACE  */
#line 874 "Parser/parser.y"
                    {
                        if (build_tag_type_node(&yyval.treeNode,
                                                TYPE_ENUM,
                                                NODE_ENUM_DECLARATION,
                                                yyvsp[-3].nodeData.sVal,
                                                yyvsp[-1].treeNode) < 0) { YYERROR; }
                    }
#line 2543 "Parser/parser.tab.c"
    break;

  case 75: /* struct_specifier: TOKEN_STRUCT TOKEN_ID  */
#line 884 "Parser/parser.y"
                    {
                        if (build_tag_type_node(&yyval.treeNode,
                                                TYPE_STRUCT,
                                                NODE_STRUCT_DECLARATION,
                                                yyvsp[0].nodeData.sVal,
                                                NULL) < 0) { YYERROR; }
                    }
#line 2555 "Parser/parser.tab.c"
    break;

  case 76: /* struct_specifier: TOKEN_STRUCT TOKEN_ID TOKEN_LEFT_BRACE struct_union_member_list TOKEN_RIGHT_BRACE  */
#line 892 "Parser/parser.y"
                    {
                        if (build_tag_type_node(&yyval.treeNode,
                                                TYPE_STRUCT,
                                                NODE_STRUCT_DECLARATION,
                                                yyvsp[-3].nodeData.sVal,
                                                yyvsp[-1].treeNode) < 0) { YYERROR; }
                    }
#line 2567 "Parser/parser.tab.c"
    break;

  case 77: /* union_specifier: TOKEN_UNION TOKEN_ID  */
#line 902 "Parser/parser.y"
                    {
                        if (build_tag_type_node(&yyval.treeNode,
                                                TYPE_UNION,
                                                NODE_UNION_DECLARATION,
                                                yyvsp[0].nodeData.sVal,
                                                NULL) < 0) { YYERROR; }
                    }
#line 2579 "Parser/parser.tab.c"
    break;

  case 78: /* union_specifier: TOKEN_UNION TOKEN_ID TOKEN_LEFT_BRACE struct_union_member_list TOKEN_RIGHT_BRACE  */
#line 910 "Parser/parser.y"
                    {
                        if (build_tag_type_node(&yyval.treeNode,
                                                TYPE_UNION,
                                                NODE_UNION_DECLARATION,
                                                yyvsp[-3].nodeData.sVal,
                                                yyvsp[-1].treeNode) < 0) { YYERROR; }
                    }
#line 2591 "Parser/parser.tab.c"
    break;

  case 79: /* type_specifier: TOKEN_CHAR  */
#line 921 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_CHAR;
                        }
#line 2600 "Parser/parser.tab.c"
    break;

  case 80: /* type_specifier: TOKEN_SHORT  */
#line 926 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_SHORT;
                        }
#line 2609 "Parser/parser.tab.c"
    break;

  case 81: /* type_specifier: TOKEN_INT  */
#line 931 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_INT;
                        }
#line 2618 "Parser/parser.tab.c"
    break;

  case 82: /* type_specifier: TOKEN_LONG  */
#line 936 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_LONG;
                        }
#line 2627 "Parser/parser.tab.c"
    break;

  case 83: /* type_specifier: TOKEN_FLOAT  */
#line 941 "Parser/parser.y"
                            { NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_FLOAT;
                        }
#line 2635 "Parser/parser.tab.c"
    break;

  case 84: /* type_specifier: TOKEN_DOUBLE  */
#line 945 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_DOUBLE;
                        }
#line 2644 "Parser/parser.tab.c"
    break;

  case 85: /* type_specifier: TOKEN_VOID  */
#line 950 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_VOID;
                        }
#line 2653 "Parser/parser.tab.c"
    break;

  case 86: /* type_specifier: struct_specifier  */
#line 955 "Parser/parser.y"
                        {
                            yyval.treeNode = yyvsp[0].treeNode;
                        }
#line 2661 "Parser/parser.tab.c"
    break;

  case 87: /* type_specifier: union_specifier  */
#line 959 "Parser/parser.y"
                        {
                            yyval.treeNode = yyvsp[0].treeNode;
                        }
#line 2669 "Parser/parser.tab.c"
    break;

  case 88: /* type_specifier: enum_specifier  */
#line 963 "Parser/parser.y"
                        {
                            yyval.treeNode = yyvsp[0].treeNode;
                        }
#line 2677 "Parser/parser.tab.c"
    break;

  case 89: /* storage_class_specifier: TOKEN_STATIC  */
#line 969 "Parser/parser.y"
                             {
                                 NodeCreate(&(yyval.treeNode), NODE_VISIBILITY);
                                 yyval.treeNode->nodeData.dVal = VIS_STATIC;
                             }
#line 2686 "Parser/parser.tab.c"
    break;

  case 90: /* storage_class_specifier: TOKEN_EXTERN  */
#line 974 "Parser/parser.y"
                             {
                                 NodeCreate(&(yyval.treeNode), NODE_VISIBILITY);
                                 yyval.treeNode->nodeData.dVal = VIS_EXTERN;
                             }
#line 2695 "Parser/parser.tab.c"
    break;

  case 91: /* function_specifier: TOKEN_INLINE  */
#line 981 "Parser/parser.y"
                             {
                                 NodeCreate(&(yyval.treeNode), NODE_VISIBILITY);
                                 yyval.treeNode->nodeData.dVal = VIS_INLINE;
                             }
#line 2704 "Parser/parser.tab.c"
    break;

  case 92: /* type_qualifier: TOKEN_CONST  */
#line 988 "Parser/parser.y"
                        {
                        NodeCreate(&(yyval.treeNode), NODE_MODIFIER);
                        yyval.treeNode->nodeData.dVal = (long int) MOD_CONST;
                        }
#line 2713 "Parser/parser.tab.c"
    break;

  case 93: /* type_qualifier: TOKEN_VOLATILE  */
#line 993 "Parser/parser.y"
                        {
                        NodeCreate(&(yyval.treeNode), NODE_MODIFIER);
                        yyval.treeNode->nodeData.dVal = (long int) MOD_VOLATILE;
                        }
#line 2722 "Parser/parser.tab.c"
    break;

  case 94: /* sign_specifier: TOKEN_SIGNED  */
#line 1000 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_SIGN);
                            yyval.treeNode->nodeData.dVal = (long int) SIGN_SIGNED;
                        }
#line 2731 "Parser/parser.tab.c"
    break;

  case 95: /* sign_specifier: TOKEN_UNSIGNED  */
#line 1005 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_SIGN);
                            yyval.treeNode->nodeData.dVal = (long int) SIGN_UNSIGNED;
                        }
#line 2740 "Parser/parser.tab.c"
    break;

  case 96: /* declaration_specifier: storage_class_specifier  */
#line 1017 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 2748 "Parser/parser.tab.c"
    break;

  case 97: /* declaration_specifier: type_specifier  */
#line 1021 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 2756 "Parser/parser.tab.c"
    break;

  case 98: /* declaration_specifier: type_qualifier  */
#line 1025 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 2764 "Parser/parser.tab.c"
    break;

  case 99: /* declaration_specifier: function_specifier  */
#line 1029 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 2772 "Parser/parser.tab.c"
    break;

  case 100: /* declaration_specifier: sign_specifier  */
#line 1033 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 2780 "Parser/parser.tab.c"
    break;

  case 101: /* declaration_specifiers: declaration_specifier  */
#line 1039 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 2788 "Parser/parser.tab.c"
    break;

  case 102: /* declaration_specifiers: declaration_specifiers declaration_specifier  */
#line 1043 "Parser/parser.y"
                            {
                                TreeNode_t *pHead = yyvsp[-1].treeNode;

                                if (yyvsp[0].treeNode->nodeType == NODE_TYPE) {
                                    yyvsp[0].treeNode->p_sibling = pHead;
                                    pHead = yyvsp[0].treeNode;
                                } else {
                                    if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                                }

                                yyval.treeNode = pHead;
                            }
#line 2805 "Parser/parser.tab.c"
    break;

  case 103: /* pointer_prefix: TOKEN_ASTERISK  */
#line 1058 "Parser/parser.y"
                    {
                        NodeCreate(&yyval.treeNode, NODE_POINTER);
                    }
#line 2813 "Parser/parser.tab.c"
    break;

  case 104: /* pointer_prefix: TOKEN_ASTERISK pointer_prefix  */
#line 1062 "Parser/parser.y"
                    {
                        NodeCreate(&yyval.treeNode, NODE_POINTER);
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2822 "Parser/parser.tab.c"
    break;

  case 105: /* declaration: declaration_specifiers init_declarator_list_opt TOKEN_SEMI  */
#line 1069 "Parser/parser.y"
                    {
                        TreeNode_t *result = NULL;

                        if (yyvsp[-1].treeNode != NULL) {
                            TreeNode_t *pNode = yyvsp[-1].treeNode;
                            while (pNode != NULL) {
                                if (pNode->nodeType == NODE_VAR_DECLARATION ||
                                    pNode->nodeType == NODE_ARRAY_DECLARATION ||
                                    pNode->nodeType == NODE_FUNCTION) {
                                    if (NodeAttachDeclSpecifiers(pNode, yyvsp[-2].treeNode)) { YYERROR; }
                                }
                                pNode = pNode->p_sibling;
                            }

                            result = yyvsp[-1].treeNode;
                        } else {
                            if (clone_or_synthesize_tag_declaration(yyvsp[-2].treeNode, &result) < 0) { YYERROR; }
                        }

                        NodeFree(yyvsp[-2].treeNode);
                        yyval.treeNode = result;
                    }
#line 2849 "Parser/parser.tab.c"
    break;

  case 106: /* init_declarator_list_opt: %empty  */
#line 1095 "Parser/parser.y"
                            {
                                yyval.treeNode = NULL;
                            }
#line 2857 "Parser/parser.tab.c"
    break;

  case 107: /* init_declarator_list_opt: init_declarator_list  */
#line 1099 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 2865 "Parser/parser.tab.c"
    break;

  case 108: /* init_declarator_list: init_declarator  */
#line 1105 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 2873 "Parser/parser.tab.c"
    break;

  case 109: /* init_declarator_list: init_declarator_list TOKEN_COMMA init_declarator  */
#line 1109 "Parser/parser.y"
                            {
                                TreeNode_t *pHead = yyvsp[-2].treeNode;
                                if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                                yyval.treeNode = pHead;
                            }
#line 2883 "Parser/parser.tab.c"
    break;

  case 110: /* init_declarator: declarator  */
#line 1117 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 2891 "Parser/parser.tab.c"
    break;

  case 111: /* init_declarator: declarator TOKEN_ASSIGN initializer  */
#line 1121 "Parser/parser.y"
                            {
                                TreeNode_t *pAssign;
                                TreeNode_t *pId;
                                TreeNode_t *pHead = yyvsp[-2].treeNode;

                                NodeCreate(&pAssign, NODE_OPERATOR);
                                pAssign->nodeData.dVal = OP_ASSIGN;
                                NodeAddNewChild(pAssign, &pId, NODE_IDENTIFIER);
                                pId->nodeData.sVal = strdup(yyvsp[-2].treeNode->nodeData.sVal);
                                if (!pId->nodeData.sVal) { YYERROR; }
                                NodeAddChild(pAssign, yyvsp[0].treeNode);
                                if (NodeAppendSibling(&pHead, pAssign)) { YYERROR; }
                                yyval.treeNode = pHead;
                            }
#line 2910 "Parser/parser.tab.c"
    break;

  case 112: /* initializer: assignment_expression  */
#line 1138 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 2918 "Parser/parser.tab.c"
    break;

  case 113: /* declarator: direct_declarator  */
#line 1144 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 2926 "Parser/parser.tab.c"
    break;

  case 114: /* declarator: pointer_prefix direct_declarator  */
#line 1148 "Parser/parser.y"
                            {
                                if (yyvsp[0].treeNode->nodeType == NODE_FUNCTION) {
                                    yyvsp[-1].treeNode->p_sibling = yyvsp[0].treeNode->p_firstChild;
                                    yyvsp[0].treeNode->p_firstChild = yyvsp[-1].treeNode;
                                    yyvsp[0].treeNode->childNumber++;
                                } else {
                                    NodeAddChild(yyvsp[0].treeNode, yyvsp[-1].treeNode);
                                }
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 2941 "Parser/parser.tab.c"
    break;

  case 115: /* direct_declarator: TOKEN_ID  */
#line 1161 "Parser/parser.y"
                            {
                                NodeCreate(&yyval.treeNode, NODE_VAR_DECLARATION);
                                yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                            }
#line 2950 "Parser/parser.tab.c"
    break;

  case 116: /* direct_declarator: TOKEN_ID arr_size  */
#line 1166 "Parser/parser.y"
                            {
                                NodeCreate(&yyval.treeNode, NODE_ARRAY_DECLARATION);
                                yyval.treeNode->nodeData.sVal = yyvsp[-1].nodeData.sVal;
                                NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                            }
#line 2960 "Parser/parser.tab.c"
    break;

  case 117: /* direct_declarator: TOKEN_ID TOKEN_LEFT_PARENTHESES parameter_list_opt TOKEN_RIGHT_PARENTHESES  */
#line 1172 "Parser/parser.y"
                            {
                                NodeCreate(&yyval.treeNode, NODE_FUNCTION);
                                yyval.treeNode->nodeData.sVal = yyvsp[-3].nodeData.sVal;
                                if (yyvsp[-1].treeNode != NULL) {
                                    NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                                }
                            }
#line 2972 "Parser/parser.tab.c"
    break;

  case 118: /* arr_size: TOKEN_LEFT_BRACKET expression TOKEN_RIGHT_BRACKET  */
#line 1182 "Parser/parser.y"
                { yyval.treeNode = yyvsp[-1].treeNode; }
#line 2978 "Parser/parser.tab.c"
    break;

  case 119: /* arr_size: TOKEN_LEFT_BRACKET TOKEN_RIGHT_BRACKET  */
#line 1184 "Parser/parser.y"
                { NodeCreate(&(yyval.treeNode), NODE_NULL); }
#line 2984 "Parser/parser.tab.c"
    break;

  case 120: /* arr_size: arr_size TOKEN_LEFT_BRACKET expression TOKEN_RIGHT_BRACKET  */
#line 1186 "Parser/parser.y"
                {
                    TreeNode_t* pHead = yyvsp[-3].treeNode;
                    if (NodeAppendSibling(&pHead, yyvsp[-1].treeNode)) { YYERROR; }
                    yyval.treeNode = pHead;
                }
#line 2994 "Parser/parser.tab.c"
    break;

  case 121: /* expression: assignment_expression  */
#line 1200 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3002 "Parser/parser.tab.c"
    break;

  case 122: /* expression: expression TOKEN_COMMA assignment_expression  */
#line 1204 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_COMMA, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3010 "Parser/parser.tab.c"
    break;

  case 123: /* assignment_expression: conditional_expression  */
#line 1210 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3018 "Parser/parser.tab.c"
    break;

  case 124: /* assignment_expression: unary_expression assignment_operator assignment_expression  */
#line 1214 "Parser/parser.y"
                            {
                                if (yyvsp[-1].treeNode->nodeType != NODE_OPERATOR) { YYERROR; }
                                if (NodeAddChild(yyvsp[-1].treeNode, yyvsp[-2].treeNode) < 0) { YYERROR; }
                                if (NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                                yyval.treeNode = yyvsp[-1].treeNode;
                            }
#line 3029 "Parser/parser.tab.c"
    break;

  case 125: /* conditional_expression: logical_or_expression  */
#line 1223 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3037 "Parser/parser.tab.c"
    break;

  case 126: /* conditional_expression: logical_or_expression TOKEN_TERNARY expression TOKEN_COLON conditional_expression  */
#line 1227 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_TERNARY);
                                NodeAddChild(yyval.treeNode, yyvsp[-4].treeNode);
                                NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                                NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                            }
#line 3048 "Parser/parser.tab.c"
    break;

  case 127: /* logical_or_expression: logical_and_expression  */
#line 1236 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3056 "Parser/parser.tab.c"
    break;

  case 128: /* logical_or_expression: logical_or_expression TOKEN_LOGICAL_OR logical_and_expression  */
#line 1240 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_LOGICAL_OR, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3064 "Parser/parser.tab.c"
    break;

  case 129: /* logical_and_expression: inclusive_or_expression  */
#line 1246 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3072 "Parser/parser.tab.c"
    break;

  case 130: /* logical_and_expression: logical_and_expression TOKEN_LOGICAL_AND inclusive_or_expression  */
#line 1250 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_LOGICAL_AND, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3080 "Parser/parser.tab.c"
    break;

  case 131: /* inclusive_or_expression: exclusive_or_expression  */
#line 1256 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3088 "Parser/parser.tab.c"
    break;

  case 132: /* inclusive_or_expression: inclusive_or_expression TOKEN_BITWISE_OR exclusive_or_expression  */
#line 1260 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_BITWISE_OR, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3096 "Parser/parser.tab.c"
    break;

  case 133: /* exclusive_or_expression: and_expression  */
#line 1266 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3104 "Parser/parser.tab.c"
    break;

  case 134: /* exclusive_or_expression: exclusive_or_expression TOKEN_BITWISE_XOR and_expression  */
#line 1270 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_BITWISE_XOR, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3112 "Parser/parser.tab.c"
    break;

  case 135: /* and_expression: equality_expression  */
#line 1276 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3120 "Parser/parser.tab.c"
    break;

  case 136: /* and_expression: and_expression TOKEN_BITWISE_AND equality_expression  */
#line 1280 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_BITWISE_AND, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3128 "Parser/parser.tab.c"
    break;

  case 137: /* equality_expression: relational_expression  */
#line 1286 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3136 "Parser/parser.tab.c"
    break;

  case 138: /* equality_expression: equality_expression TOKEN_EQUAL relational_expression  */
#line 1290 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_EQUAL, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3144 "Parser/parser.tab.c"
    break;

  case 139: /* equality_expression: equality_expression TOKEN_NOT_EQUAL relational_expression  */
#line 1294 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_NOT_EQUAL, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3152 "Parser/parser.tab.c"
    break;

  case 140: /* relational_expression: shift_expression  */
#line 1300 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3160 "Parser/parser.tab.c"
    break;

  case 141: /* relational_expression: relational_expression TOKEN_LESS_THAN shift_expression  */
#line 1304 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_LESS_THAN, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3168 "Parser/parser.tab.c"
    break;

  case 142: /* relational_expression: relational_expression TOKEN_GREATER_THAN shift_expression  */
#line 1308 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_GREATER_THAN, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3176 "Parser/parser.tab.c"
    break;

  case 143: /* relational_expression: relational_expression TOKEN_LESS_THAN_OR_EQUAL shift_expression  */
#line 1312 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_LESS_THAN_OR_EQUAL, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3184 "Parser/parser.tab.c"
    break;

  case 144: /* relational_expression: relational_expression TOKEN_GREATER_THAN_OR_EQUAL shift_expression  */
#line 1316 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_GREATER_THAN_OR_EQUAL, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3192 "Parser/parser.tab.c"
    break;

  case 145: /* shift_expression: additive_expression  */
#line 1322 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3200 "Parser/parser.tab.c"
    break;

  case 146: /* shift_expression: shift_expression TOKEN_LEFT_SHIFT additive_expression  */
#line 1326 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_LEFT_SHIFT, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3208 "Parser/parser.tab.c"
    break;

  case 147: /* shift_expression: shift_expression TOKEN_RIGHT_SHIFT additive_expression  */
#line 1330 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_RIGHT_SHIFT, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3216 "Parser/parser.tab.c"
    break;

  case 148: /* additive_expression: multiplicative_expression  */
#line 1336 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3224 "Parser/parser.tab.c"
    break;

  case 149: /* additive_expression: additive_expression TOKEN_PLUS multiplicative_expression  */
#line 1340 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_PLUS, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3232 "Parser/parser.tab.c"
    break;

  case 150: /* additive_expression: additive_expression TOKEN_MINUS multiplicative_expression  */
#line 1344 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_MINUS, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3240 "Parser/parser.tab.c"
    break;

  case 151: /* multiplicative_expression: cast_expression  */
#line 1351 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3248 "Parser/parser.tab.c"
    break;

  case 152: /* multiplicative_expression: multiplicative_expression TOKEN_ASTERISK cast_expression  */
#line 1355 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_MULTIPLY, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3256 "Parser/parser.tab.c"
    break;

  case 153: /* multiplicative_expression: multiplicative_expression TOKEN_DIVIDE cast_expression  */
#line 1359 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_DIVIDE, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3264 "Parser/parser.tab.c"
    break;

  case 154: /* multiplicative_expression: multiplicative_expression TOKEN_MOD cast_expression  */
#line 1363 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_MODULE, yyvsp[-2].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                            }
#line 3272 "Parser/parser.tab.c"
    break;

  case 155: /* cast_expression: unary_expression  */
#line 1369 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3280 "Parser/parser.tab.c"
    break;

  case 156: /* cast_expression: type_cast_specifier cast_expression  */
#line 1373 "Parser/parser.y"
                            {
                                if (NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode) < 0) { YYERROR; }
                                yyval.treeNode = yyvsp[-1].treeNode;
                            }
#line 3289 "Parser/parser.tab.c"
    break;

  case 157: /* unary_expression: postfix_expression  */
#line 1380 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3297 "Parser/parser.tab.c"
    break;

  case 158: /* unary_expression: TOKEN_INCREMENT unary_expression  */
#line 1384 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_PRE_INC);
                                NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                            }
#line 3306 "Parser/parser.tab.c"
    break;

  case 159: /* unary_expression: TOKEN_DECREMENT unary_expression  */
#line 1389 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_PRE_DEC);
                                NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                            }
#line 3315 "Parser/parser.tab.c"
    break;

  case 160: /* unary_expression: TOKEN_BITWISE_AND cast_expression  */
#line 1394 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_REFERENCE);
                                NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                            }
#line 3324 "Parser/parser.tab.c"
    break;

  case 161: /* unary_expression: TOKEN_ASTERISK cast_expression  */
#line 1399 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_POINTER_CONTENT);
                                NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                            }
#line 3333 "Parser/parser.tab.c"
    break;

  case 162: /* unary_expression: TOKEN_PLUS cast_expression  */
#line 1404 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3341 "Parser/parser.tab.c"
    break;

  case 163: /* unary_expression: TOKEN_MINUS cast_expression  */
#line 1408 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_UNARY_MINUS, yyvsp[0].treeNode, NULL) < 0) { YYERROR; }
                            }
#line 3349 "Parser/parser.tab.c"
    break;

  case 164: /* unary_expression: TOKEN_LOGICAL_NOT cast_expression  */
#line 1412 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_LOGICAL_NOT, yyvsp[0].treeNode, NULL) < 0) { YYERROR; }
                            }
#line 3357 "Parser/parser.tab.c"
    break;

  case 165: /* unary_expression: TOKEN_BITWISE_NOT cast_expression  */
#line 1416 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_BITWISE_NOT, yyvsp[0].treeNode, NULL) < 0) { YYERROR; }
                            }
#line 3365 "Parser/parser.tab.c"
    break;

  case 166: /* unary_expression: TOKEN_SIZEOF unary_expression  */
#line 1420 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_SIZEOF, yyvsp[0].treeNode, NULL) < 0) { YYERROR; }
                            }
#line 3373 "Parser/parser.tab.c"
    break;

  case 167: /* unary_expression: TOKEN_SIZEOF TOKEN_LEFT_PARENTHESES type_name TOKEN_RIGHT_PARENTHESES  */
#line 1424 "Parser/parser.y"
                            {
                                if (build_operator_node(&yyval.treeNode, OP_SIZEOF, yyvsp[-1].treeNode, NULL) < 0) { YYERROR; }
                            }
#line 3381 "Parser/parser.tab.c"
    break;

  case 168: /* postfix_expression: primary_expression  */
#line 1430 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3389 "Parser/parser.tab.c"
    break;

  case 169: /* postfix_expression: postfix_expression TOKEN_LEFT_BRACKET expression TOKEN_RIGHT_BRACKET  */
#line 1434 "Parser/parser.y"
                            {
                                if (build_array_access_node(&yyval.treeNode, yyvsp[-3].treeNode, yyvsp[-1].treeNode) < 0) { YYERROR; }
                            }
#line 3397 "Parser/parser.tab.c"
    break;

  case 170: /* postfix_expression: postfix_expression TOKEN_LEFT_PARENTHESES argument_expression_list_opt TOKEN_RIGHT_PARENTHESES  */
#line 1438 "Parser/parser.y"
                            {
                                if (build_function_call_node(&yyval.treeNode, yyvsp[-3].treeNode, yyvsp[-1].treeNode) < 0) { YYERROR; }
                            }
#line 3405 "Parser/parser.tab.c"
    break;

  case 171: /* postfix_expression: postfix_expression TOKEN_DOT TOKEN_ID  */
#line 1442 "Parser/parser.y"
                            {
                                if (build_member_access_node(&yyval.treeNode, NODE_MEMBER_ACCESS, yyvsp[-2].treeNode, yyvsp[0].nodeData.sVal) < 0) { YYERROR; }
                            }
#line 3413 "Parser/parser.tab.c"
    break;

  case 172: /* postfix_expression: postfix_expression TOKEN_ARROW TOKEN_ID  */
#line 1446 "Parser/parser.y"
                            {
                                if (build_member_access_node(&yyval.treeNode, NODE_PTR_MEMBER_ACCESS, yyvsp[-2].treeNode, yyvsp[0].nodeData.sVal) < 0) { YYERROR; }
                            }
#line 3421 "Parser/parser.tab.c"
    break;

  case 173: /* postfix_expression: postfix_expression TOKEN_INCREMENT  */
#line 1450 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_POST_INC);
                                NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                            }
#line 3430 "Parser/parser.tab.c"
    break;

  case 174: /* postfix_expression: postfix_expression TOKEN_DECREMENT  */
#line 1455 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_POST_DEC);
                                NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                            }
#line 3439 "Parser/parser.tab.c"
    break;

  case 175: /* primary_expression: TOKEN_ID  */
#line 1462 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_IDENTIFIER);
                                yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                            }
#line 3448 "Parser/parser.tab.c"
    break;

  case 176: /* primary_expression: TOKEN_NUM  */
#line 1467 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_INTEGER);
                                yyval.treeNode->nodeData.dVal = yyvsp[0].nodeData.dVal;
                            }
#line 3457 "Parser/parser.tab.c"
    break;

  case 177: /* primary_expression: TOKEN_FNUM  */
#line 1472 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_FLOAT);
                                yyval.treeNode->nodeData.fVal = yyvsp[0].nodeData.fVal;
                            }
#line 3466 "Parser/parser.tab.c"
    break;

  case 178: /* primary_expression: TOKEN_CNUM  */
#line 1477 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_CHAR);
                                yyval.treeNode->nodeData.dVal = yyvsp[0].nodeData.dVal;
                            }
#line 3475 "Parser/parser.tab.c"
    break;

  case 179: /* primary_expression: TOKEN_STR  */
#line 1482 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_STRING);
                                yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                            }
#line 3484 "Parser/parser.tab.c"
    break;

  case 180: /* primary_expression: TOKEN_LEFT_PARENTHESES expression TOKEN_RIGHT_PARENTHESES  */
#line 1487 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[-1].treeNode;
                            }
#line 3492 "Parser/parser.tab.c"
    break;

  case 181: /* argument_expression_list_opt: %empty  */
#line 1494 "Parser/parser.y"
                            {
                                yyval.treeNode = NULL;
                            }
#line 3500 "Parser/parser.tab.c"
    break;

  case 182: /* argument_expression_list_opt: argument_expression_list  */
#line 1498 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3508 "Parser/parser.tab.c"
    break;

  case 183: /* argument_expression_list: assignment_expression  */
#line 1505 "Parser/parser.y"
                            {
                                yyval.treeNode = yyvsp[0].treeNode;
                            }
#line 3516 "Parser/parser.tab.c"
    break;

  case 184: /* argument_expression_list: argument_expression_list TOKEN_COMMA assignment_expression  */
#line 1509 "Parser/parser.y"
                            {
                                TreeNode_t *pHead = yyvsp[-2].treeNode;
                                if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                                yyval.treeNode = pHead;
                            }
#line 3526 "Parser/parser.tab.c"
    break;

  case 185: /* assignment_operator: TOKEN_ASSIGN  */
#line 1517 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_ASSIGN;
                            }
#line 3535 "Parser/parser.tab.c"
    break;

  case 186: /* assignment_operator: TOKEN_PLUS_ASSIGN  */
#line 1522 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_PLUS_ASSIGN;
                            }
#line 3544 "Parser/parser.tab.c"
    break;

  case 187: /* assignment_operator: TOKEN_MINUS_ASSIGN  */
#line 1527 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_MINUS_ASSIGN;
                            }
#line 3553 "Parser/parser.tab.c"
    break;

  case 188: /* assignment_operator: TOKEN_MODULUS_ASSIGN  */
#line 1532 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_MODULUS_ASSIGN;
                            }
#line 3562 "Parser/parser.tab.c"
    break;

  case 189: /* assignment_operator: TOKEN_LEFT_SHIFT_ASSIGN  */
#line 1537 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_LEFT_SHIFT_ASSIGN;
                            }
#line 3571 "Parser/parser.tab.c"
    break;

  case 190: /* assignment_operator: TOKEN_RIGHT_SHIFT_ASSIGN  */
#line 1542 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_RIGHT_SHIFT_ASSIGN;
                            }
#line 3580 "Parser/parser.tab.c"
    break;

  case 191: /* assignment_operator: TOKEN_AND_ASSIGN  */
#line 1547 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_BITWISE_AND_ASSIGN;
                            }
#line 3589 "Parser/parser.tab.c"
    break;

  case 192: /* assignment_operator: TOKEN_OR_ASSIGN  */
#line 1552 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_BITWISE_OR_ASSIGN;
                            }
#line 3598 "Parser/parser.tab.c"
    break;

  case 193: /* assignment_operator: TOKEN_XOR_ASSIGN  */
#line 1557 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_BITWISE_XOR_ASSIGN;
                            }
#line 3607 "Parser/parser.tab.c"
    break;

  case 194: /* assignment_operator: TOKEN_MULTIPLY_ASSIGN  */
#line 1562 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_MULTIPLY_ASSIGN;
                            }
#line 3616 "Parser/parser.tab.c"
    break;

  case 195: /* assignment_operator: TOKEN_DIVIDE_ASSIGN  */
#line 1567 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_DIVIDE_ASSIGN;
                            }
#line 3625 "Parser/parser.tab.c"
    break;


#line 3629 "Parser/parser.tab.c"

      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", YY_CAST (yysymbol_kind_t, yyr1[yyn]), &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYSYMBOL_YYEMPTY : YYTRANSLATE (yychar);
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
      yyerror (YY_("syntax error"));
    }

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;
  ++yynerrs;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  /* Pop stack until we find a state that shifts the error token.  */
  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYSYMBOL_YYerror;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYSYMBOL_YYerror)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  YY_ACCESSING_SYMBOL (yystate), yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", YY_ACCESSING_SYMBOL (yyn), yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturnlab;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturnlab;


/*-----------------------------------------------------------.
| yyexhaustedlab -- YYNOMEM (memory exhaustion) comes here.  |
`-----------------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  goto yyreturnlab;


/*----------------------------------------------------------.
| yyreturnlab -- parsing is finished, clean up and return.  |
`----------------------------------------------------------*/
yyreturnlab:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif

  return yyresult;
}

#line 1576 "Parser/parser.y"


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
