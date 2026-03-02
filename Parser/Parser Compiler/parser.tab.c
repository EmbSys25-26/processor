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
#line 12 "parser.y"

#include <stdio.h>
#include <string.h>
#include "ASTree.h"
#include "logger.h"
#include "ASTPrint.h"

int yylex(void);
void yyerror(const char *s);

static TreeNode_t* p_treeRoot = NULL;
static char* currentFunction = NULL;

#line 85 "parser.tab.c"

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
  YYSYMBOL_TOKEN_BOOL = 13,                /* TOKEN_BOOL  */
  YYSYMBOL_TOKEN_INLINE = 14,              /* TOKEN_INLINE  */
  YYSYMBOL_TOKEN_SIGNED = 15,              /* TOKEN_SIGNED  */
  YYSYMBOL_TOKEN_UNSIGNED = 16,            /* TOKEN_UNSIGNED  */
  YYSYMBOL_TOKEN_LONG = 17,                /* TOKEN_LONG  */
  YYSYMBOL_TOKEN_SHORT = 18,               /* TOKEN_SHORT  */
  YYSYMBOL_TOKEN_STATIC = 19,              /* TOKEN_STATIC  */
  YYSYMBOL_TOKEN_EXTERN = 20,              /* TOKEN_EXTERN  */
  YYSYMBOL_TOKEN_CONST = 21,               /* TOKEN_CONST  */
  YYSYMBOL_TOKEN_VOLATILE = 22,            /* TOKEN_VOLATILE  */
  YYSYMBOL_TOKEN_STRUCT = 23,              /* TOKEN_STRUCT  */
  YYSYMBOL_TOKEN_UNION = 24,               /* TOKEN_UNION  */
  YYSYMBOL_TOKEN_ENUM = 25,                /* TOKEN_ENUM  */
  YYSYMBOL_TOKEN_TYPEDEF = 26,             /* TOKEN_TYPEDEF  */
  YYSYMBOL_TOKEN_SIZEOF = 27,              /* TOKEN_SIZEOF  */
  YYSYMBOL_TOKEN_IF = 28,                  /* TOKEN_IF  */
  YYSYMBOL_TOKEN_ELSE = 29,                /* TOKEN_ELSE  */
  YYSYMBOL_TOKEN_SWITCH = 30,              /* TOKEN_SWITCH  */
  YYSYMBOL_TOKEN_CASE = 31,                /* TOKEN_CASE  */
  YYSYMBOL_TOKEN_DEFAULT = 32,             /* TOKEN_DEFAULT  */
  YYSYMBOL_TOKEN_FOR = 33,                 /* TOKEN_FOR  */
  YYSYMBOL_TOKEN_WHILE = 34,               /* TOKEN_WHILE  */
  YYSYMBOL_TOKEN_DO = 35,                  /* TOKEN_DO  */
  YYSYMBOL_TOKEN_BREAK = 36,               /* TOKEN_BREAK  */
  YYSYMBOL_TOKEN_RETURN = 37,              /* TOKEN_RETURN  */
  YYSYMBOL_TOKEN_CONTINUE = 38,            /* TOKEN_CONTINUE  */
  YYSYMBOL_TOKEN_PP_DEFINE = 39,           /* TOKEN_PP_DEFINE  */
  YYSYMBOL_TOKEN_PP_UNDEF = 40,            /* TOKEN_PP_UNDEF  */
  YYSYMBOL_TOKEN_PP_INCLUDE_SYS = 41,      /* TOKEN_PP_INCLUDE_SYS  */
  YYSYMBOL_TOKEN_PP_INCLUDE_USR = 42,      /* TOKEN_PP_INCLUDE_USR  */
  YYSYMBOL_TOKEN_PLUS = 43,                /* TOKEN_PLUS  */
  YYSYMBOL_TOKEN_MINUS = 44,               /* TOKEN_MINUS  */
  YYSYMBOL_TOKEN_ASTERISK = 45,            /* TOKEN_ASTERISK  */
  YYSYMBOL_TOKEN_OVER = 46,                /* TOKEN_OVER  */
  YYSYMBOL_TOKEN_PERCENT = 47,             /* TOKEN_PERCENT  */
  YYSYMBOL_TOKEN_INCREMENT = 48,           /* TOKEN_INCREMENT  */
  YYSYMBOL_TOKEN_DECREMENT = 49,           /* TOKEN_DECREMENT  */
  YYSYMBOL_TOKEN_ASSIGN = 50,              /* TOKEN_ASSIGN  */
  YYSYMBOL_TOKEN_PLUS_ASSIGN = 51,         /* TOKEN_PLUS_ASSIGN  */
  YYSYMBOL_TOKEN_MINUS_ASSIGN = 52,        /* TOKEN_MINUS_ASSIGN  */
  YYSYMBOL_TOKEN_MULTIPLY_ASSIGN = 53,     /* TOKEN_MULTIPLY_ASSIGN  */
  YYSYMBOL_TOKEN_DIVIDE_ASSIGN = 54,       /* TOKEN_DIVIDE_ASSIGN  */
  YYSYMBOL_TOKEN_MODULUS_ASSIGN = 55,      /* TOKEN_MODULUS_ASSIGN  */
  YYSYMBOL_TOKEN_AND_ASSIGN = 56,          /* TOKEN_AND_ASSIGN  */
  YYSYMBOL_TOKEN_OR_ASSIGN = 57,           /* TOKEN_OR_ASSIGN  */
  YYSYMBOL_TOKEN_XOR_ASSIGN = 58,          /* TOKEN_XOR_ASSIGN  */
  YYSYMBOL_TOKEN_LEFT_SHIFT_ASSIGN = 59,   /* TOKEN_LEFT_SHIFT_ASSIGN  */
  YYSYMBOL_TOKEN_RIGHT_SHIFT_ASSIGN = 60,  /* TOKEN_RIGHT_SHIFT_ASSIGN  */
  YYSYMBOL_TOKEN_EQUAL = 61,               /* TOKEN_EQUAL  */
  YYSYMBOL_TOKEN_NOT_EQUAL = 62,           /* TOKEN_NOT_EQUAL  */
  YYSYMBOL_TOKEN_LESS_THAN = 63,           /* TOKEN_LESS_THAN  */
  YYSYMBOL_TOKEN_GREATER_THAN = 64,        /* TOKEN_GREATER_THAN  */
  YYSYMBOL_TOKEN_LESS_THAN_OR_EQUAL = 65,  /* TOKEN_LESS_THAN_OR_EQUAL  */
  YYSYMBOL_TOKEN_GREATER_THAN_OR_EQUAL = 66, /* TOKEN_GREATER_THAN_OR_EQUAL  */
  YYSYMBOL_TOKEN_LOGICAL_AND = 67,         /* TOKEN_LOGICAL_AND  */
  YYSYMBOL_TOKEN_LOGICAL_OR = 68,          /* TOKEN_LOGICAL_OR  */
  YYSYMBOL_TOKEN_LOGICAL_NOT = 69,         /* TOKEN_LOGICAL_NOT  */
  YYSYMBOL_TOKEN_BITWISE_AND = 70,         /* TOKEN_BITWISE_AND  */
  YYSYMBOL_TOKEN_BITWISE_OR = 71,          /* TOKEN_BITWISE_OR  */
  YYSYMBOL_TOKEN_BITWISE_XOR = 72,         /* TOKEN_BITWISE_XOR  */
  YYSYMBOL_TOKEN_BITWISE_NOT = 73,         /* TOKEN_BITWISE_NOT  */
  YYSYMBOL_TOKEN_LEFT_SHIFT = 74,          /* TOKEN_LEFT_SHIFT  */
  YYSYMBOL_TOKEN_RIGHT_SHIFT = 75,         /* TOKEN_RIGHT_SHIFT  */
  YYSYMBOL_TOKEN_ARROW = 76,               /* TOKEN_ARROW  */
  YYSYMBOL_TOKEN_DOT = 77,                 /* TOKEN_DOT  */
  YYSYMBOL_TOKEN_SEMI = 78,                /* TOKEN_SEMI  */
  YYSYMBOL_TOKEN_COMMA = 79,               /* TOKEN_COMMA  */
  YYSYMBOL_TOKEN_COLON = 80,               /* TOKEN_COLON  */
  YYSYMBOL_TOKEN_TERNARY = 81,             /* TOKEN_TERNARY  */
  YYSYMBOL_TOKEN_LEFT_PARENTHESES = 82,    /* TOKEN_LEFT_PARENTHESES  */
  YYSYMBOL_TOKEN_RIGHT_PARENTHESES = 83,   /* TOKEN_RIGHT_PARENTHESES  */
  YYSYMBOL_TOKEN_LEFT_BRACE = 84,          /* TOKEN_LEFT_BRACE  */
  YYSYMBOL_TOKEN_RIGHT_BRACE = 85,         /* TOKEN_RIGHT_BRACE  */
  YYSYMBOL_TOKEN_LEFT_BRACKET = 86,        /* TOKEN_LEFT_BRACKET  */
  YYSYMBOL_TOKEN_RIGHT_BRACKET = 87,       /* TOKEN_RIGHT_BRACKET  */
  YYSYMBOL_TOKEN_EOF = 88,                 /* TOKEN_EOF  */
  YYSYMBOL_TOKEN_ERROR = 89,               /* TOKEN_ERROR  */
  YYSYMBOL_LOWER_THAN_ELSE = 90,           /* LOWER_THAN_ELSE  */
  YYSYMBOL_YYACCEPT = 91,                  /* $accept  */
  YYSYMBOL_program = 92,                   /* program  */
  YYSYMBOL_global_statement = 93,          /* global_statement  */
  YYSYMBOL_function_prototype = 94,        /* function_prototype  */
  YYSYMBOL_function_definition = 95,       /* function_definition  */
  YYSYMBOL_function_signature = 96,        /* function_signature  */
  YYSYMBOL_parameter_list = 97,            /* parameter_list  */
  YYSYMBOL_parameter_declaration = 98,     /* parameter_declaration  */
  YYSYMBOL_func_call = 99,                 /* func_call  */
  YYSYMBOL_exp_list = 100,                 /* exp_list  */
  YYSYMBOL_declaration = 101,              /* declaration  */
  YYSYMBOL_declaration_specifiers = 102,   /* declaration_specifiers  */
  YYSYMBOL_declaration_qualifiers = 103,   /* declaration_qualifiers  */
  YYSYMBOL_declaration_qualifier = 104,    /* declaration_qualifier  */
  YYSYMBOL_init_declarator_list_opt = 105, /* init_declarator_list_opt  */
  YYSYMBOL_type_cast_specifier = 106,      /* type_cast_specifier  */
  YYSYMBOL_type_all_specifier = 107,       /* type_all_specifier  */
  YYSYMBOL_type_pointer = 108,             /* type_pointer  */
  YYSYMBOL_data_type_specifier = 109,      /* data_type_specifier  */
  YYSYMBOL_storage_class_specifier = 110,  /* storage_class_specifier  */
  YYSYMBOL_type_qualifier = 111,           /* type_qualifier  */
  YYSYMBOL_sign_qualifier = 112,           /* sign_qualifier  */
  YYSYMBOL_local_statement_list = 113,     /* local_statement_list  */
  YYSYMBOL_local_statement = 114,          /* local_statement  */
  YYSYMBOL_compound_statement = 115,       /* compound_statement  */
  YYSYMBOL_continue_statement = 116,       /* continue_statement  */
  YYSYMBOL_break_statement = 117,          /* break_statement  */
  YYSYMBOL_return_statement = 118,         /* return_statement  */
  YYSYMBOL_if_statement = 119,             /* if_statement  */
  YYSYMBOL_switch_statement = 120,         /* switch_statement  */
  YYSYMBOL_switch_body = 121,              /* switch_body  */
  YYSYMBOL_case_list = 122,                /* case_list  */
  YYSYMBOL_case_clause = 123,              /* case_clause  */
  YYSYMBOL_default_clause = 124,           /* default_clause  */
  YYSYMBOL_while_loop = 125,               /* while_loop  */
  YYSYMBOL_do_while_loop = 126,            /* do_while_loop  */
  YYSYMBOL_for_loop = 127,                 /* for_loop  */
  YYSYMBOL_for_init_field = 128,           /* for_init_field  */
  YYSYMBOL_for_exp_opt = 129,              /* for_exp_opt  */
  YYSYMBOL_for_assignment_field = 130,     /* for_assignment_field  */
  YYSYMBOL_var_declaration = 131,          /* var_declaration  */
  YYSYMBOL_arr_declaration = 132,          /* arr_declaration  */
  YYSYMBOL_arr_size = 133,                 /* arr_size  */
  YYSYMBOL_struct_declaration = 134,       /* struct_declaration  */
  YYSYMBOL_enum_declaration = 135,         /* enum_declaration  */
  YYSYMBOL_enum_member_list = 136,         /* enum_member_list  */
  YYSYMBOL_enum_member = 137,              /* enum_member  */
  YYSYMBOL_union_declaration = 138,        /* union_declaration  */
  YYSYMBOL_struct_member_list = 139,       /* struct_member_list  */
  YYSYMBOL_struct_member = 140,            /* struct_member  */
  YYSYMBOL_id_list = 141,                  /* id_list  */
  YYSYMBOL_var_assignment = 142,           /* var_assignment  */
  YYSYMBOL_simple_var_assign = 143,        /* simple_var_assign  */
  YYSYMBOL_compound_var_assign = 144,      /* compound_var_assign  */
  YYSYMBOL_var_preamble = 145,             /* var_preamble  */
  YYSYMBOL_exp = 146,                      /* exp  */
  YYSYMBOL_term = 147,                     /* term  */
  YYSYMBOL_operand = 148,                  /* operand  */
  YYSYMBOL_factor = 149,                   /* factor  */
  YYSYMBOL_sizeof_operand = 150,           /* sizeof_operand  */
  YYSYMBOL_array_index = 151,              /* array_index  */
  YYSYMBOL_pointer_content = 152,          /* pointer_content  */
  YYSYMBOL_inc_dec = 153,                  /* inc_dec  */
  YYSYMBOL_pre_increment = 154,            /* pre_increment  */
  YYSYMBOL_post_increment = 155,           /* post_increment  */
  YYSYMBOL_pre_decrement = 156,            /* pre_decrement  */
  YYSYMBOL_post_decrement = 157,           /* post_decrement  */
  YYSYMBOL_arithmetic_operator = 158,      /* arithmetic_operator  */
  YYSYMBOL_priority_operator = 159,        /* priority_operator  */
  YYSYMBOL_condition_operator = 160,       /* condition_operator  */
  YYSYMBOL_logic_operator = 161,           /* logic_operator  */
  YYSYMBOL_bitwise_operator = 162,         /* bitwise_operator  */
  YYSYMBOL_compound_assign_operator = 163  /* compound_assign_operator  */
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
#define YYFINAL  21
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   1352

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  91
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  73
/* YYNRULES -- Number of rules.  */
#define YYNRULES  210
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  364

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   345


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
      85,    86,    87,    88,    89,    90
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,    90,    90,    97,   104,   111,   113,   115,   117,   119,
     121,   123,   129,   137,   141,   148,   158,   160,   162,   170,
     177,   187,   195,   197,   199,   220,   226,   234,   242,   244,
     252,   254,   256,   260,   262,   271,   278,   280,   284,   289,
     296,   298,   300,   302,   304,   306,   308,   310,   312,   316,
     318,   320,   324,   326,   330,   332,   341,   343,   349,   353,
     354,   355,   356,   357,   358,   359,   360,   361,   362,   363,
     364,   365,   369,   387,   396,   400,   404,   409,   417,   423,
     432,   440,   446,   448,   452,   454,   462,   468,   476,   488,
     496,   504,   535,   537,   546,   561,   563,   567,   568,   569,
     570,   578,   592,   596,   605,   607,   609,   618,   625,   633,
     635,   643,   648,   655,   662,   664,   672,   680,   685,   694,
     704,   717,   719,   721,   728,   735,   741,   752,   765,   776,
     786,   794,   801,   808,   815,   821,   827,   833,   842,   848,
     854,   860,   866,   872,   878,   885,   894,   898,   904,   908,
     910,   916,   921,   925,   927,   929,   934,   939,   944,   946,
     951,   956,   961,   966,   971,   976,   982,   984,   990,   998,
    1000,  1005,  1011,  1018,  1023,  1035,  1036,  1037,  1038,  1041,
    1045,  1049,  1053,  1062,  1063,  1064,  1065,  1068,  1069,  1070,
    1073,  1074,  1075,  1076,  1077,  1078,  1081,  1082,  1085,  1086,
    1087,  1090,  1091,  1092,  1093,  1094,  1095,  1096,  1097,  1098,
    1099
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
  "TOKEN_CHAR", "TOKEN_FLOAT", "TOKEN_DOUBLE", "TOKEN_VOID", "TOKEN_BOOL",
  "TOKEN_INLINE", "TOKEN_SIGNED", "TOKEN_UNSIGNED", "TOKEN_LONG",
  "TOKEN_SHORT", "TOKEN_STATIC", "TOKEN_EXTERN", "TOKEN_CONST",
  "TOKEN_VOLATILE", "TOKEN_STRUCT", "TOKEN_UNION", "TOKEN_ENUM",
  "TOKEN_TYPEDEF", "TOKEN_SIZEOF", "TOKEN_IF", "TOKEN_ELSE",
  "TOKEN_SWITCH", "TOKEN_CASE", "TOKEN_DEFAULT", "TOKEN_FOR",
  "TOKEN_WHILE", "TOKEN_DO", "TOKEN_BREAK", "TOKEN_RETURN",
  "TOKEN_CONTINUE", "TOKEN_PP_DEFINE", "TOKEN_PP_UNDEF",
  "TOKEN_PP_INCLUDE_SYS", "TOKEN_PP_INCLUDE_USR", "TOKEN_PLUS",
  "TOKEN_MINUS", "TOKEN_ASTERISK", "TOKEN_OVER", "TOKEN_PERCENT",
  "TOKEN_INCREMENT", "TOKEN_DECREMENT", "TOKEN_ASSIGN",
  "TOKEN_PLUS_ASSIGN", "TOKEN_MINUS_ASSIGN", "TOKEN_MULTIPLY_ASSIGN",
  "TOKEN_DIVIDE_ASSIGN", "TOKEN_MODULUS_ASSIGN", "TOKEN_AND_ASSIGN",
  "TOKEN_OR_ASSIGN", "TOKEN_XOR_ASSIGN", "TOKEN_LEFT_SHIFT_ASSIGN",
  "TOKEN_RIGHT_SHIFT_ASSIGN", "TOKEN_EQUAL", "TOKEN_NOT_EQUAL",
  "TOKEN_LESS_THAN", "TOKEN_GREATER_THAN", "TOKEN_LESS_THAN_OR_EQUAL",
  "TOKEN_GREATER_THAN_OR_EQUAL", "TOKEN_LOGICAL_AND", "TOKEN_LOGICAL_OR",
  "TOKEN_LOGICAL_NOT", "TOKEN_BITWISE_AND", "TOKEN_BITWISE_OR",
  "TOKEN_BITWISE_XOR", "TOKEN_BITWISE_NOT", "TOKEN_LEFT_SHIFT",
  "TOKEN_RIGHT_SHIFT", "TOKEN_ARROW", "TOKEN_DOT", "TOKEN_SEMI",
  "TOKEN_COMMA", "TOKEN_COLON", "TOKEN_TERNARY", "TOKEN_LEFT_PARENTHESES",
  "TOKEN_RIGHT_PARENTHESES", "TOKEN_LEFT_BRACE", "TOKEN_RIGHT_BRACE",
  "TOKEN_LEFT_BRACKET", "TOKEN_RIGHT_BRACKET", "TOKEN_EOF", "TOKEN_ERROR",
  "LOWER_THAN_ELSE", "$accept", "program", "global_statement",
  "function_prototype", "function_definition", "function_signature",
  "parameter_list", "parameter_declaration", "func_call", "exp_list",
  "declaration", "declaration_specifiers", "declaration_qualifiers",
  "declaration_qualifier", "init_declarator_list_opt",
  "type_cast_specifier", "type_all_specifier", "type_pointer",
  "data_type_specifier", "storage_class_specifier", "type_qualifier",
  "sign_qualifier", "local_statement_list", "local_statement",
  "compound_statement", "continue_statement", "break_statement",
  "return_statement", "if_statement", "switch_statement", "switch_body",
  "case_list", "case_clause", "default_clause", "while_loop",
  "do_while_loop", "for_loop", "for_init_field", "for_exp_opt",
  "for_assignment_field", "var_declaration", "arr_declaration", "arr_size",
  "struct_declaration", "enum_declaration", "enum_member_list",
  "enum_member", "union_declaration", "struct_member_list",
  "struct_member", "id_list", "var_assignment", "simple_var_assign",
  "compound_var_assign", "var_preamble", "exp", "term", "operand",
  "factor", "sizeof_operand", "array_index", "pointer_content", "inc_dec",
  "pre_increment", "post_increment", "pre_decrement", "post_decrement",
  "arithmetic_operator", "priority_operator", "condition_operator",
  "logic_operator", "bitwise_operator", "compound_assign_operator", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-316)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-17)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
      -3,     9,    60,    69,  -316,  -316,    26,  -316,  -316,  -316,
     -44,  -316,    74,  1330,  -316,  -316,  -316,     6,    16,    23,
      81,  -316,  -316,  -316,  -316,   474,  -316,   -26,    39,    40,
    -316,  -316,  -316,  -316,  -316,  -316,  -316,  -316,  -316,    28,
    -316,  -316,  -316,  -316,  -316,  -316,  -316,    75,    76,  -316,
    -316,  -316,  -316,  -316,   115,    45,  -316,  -316,  -316,  -316,
    1251,    44,    46,    53,    73,    77,   685,    47,   133,    49,
      61,     4,   149,   150,   151,   241,  -316,    83,  -316,   210,
     565,   245,   602,  -316,  -316,  -316,  -316,  -316,  -316,  -316,
    -316,  -316,  -316,  -316,  -316,  -316,    87,    89,   155,    17,
      93,   119,    95,  -316,  -316,  -316,  -316,   241,    -1,   127,
     -59,  -316,   167,  -316,  -316,  -316,  -316,   173,    98,  -316,
     100,   136,    -2,  -316,  -316,  -316,  -316,  -316,  -316,  -316,
    -316,  -316,  -316,  -316,  -316,  -316,  -316,   241,   241,   241,
     732,   241,   241,  1305,   241,   154,  -316,   -20,   358,   405,
     234,  -316,   732,  -316,   405,   986,    52,  -316,    29,   105,
    -316,  -316,  -316,  -316,  -316,  -316,   241,  -316,  -316,   106,
     105,   471,  -316,  -316,   565,   245,  -316,   245,  -316,  -316,
    -316,  -316,  -316,   -14,    30,   186,   187,   241,   241,   241,
     241,  -316,  1217,     1,  -316,  1330,  -316,   722,  -316,   241,
     145,  -316,   120,   121,  -316,   123,   201,   115,   129,     8,
    1217,   755,  1217,  -316,  1217,   122,   599,   854,   158,   132,
     205,   887,   131,   241,  -316,  -316,  -316,   -68,    29,    10,
      52,   134,    29,  -316,  -316,  -316,  -316,  -316,  -316,  -316,
    -316,  -316,  -316,  -316,  -316,  -316,  -316,  -316,  -316,   241,
     234,   234,   234,   234,  -316,  -316,  -316,   234,   209,   216,
     920,  -316,  -316,   245,  -316,  -316,   -53,  -316,   180,   183,
    1019,   788,  1052,  1085,  -316,  -316,   227,  -316,   821,  -316,
    -316,  -316,  -316,  -316,  -316,   241,  -316,  -316,  -316,   685,
     152,   241,   241,   185,   685,   241,  1217,  -316,  1118,    52,
      52,    52,    52,  -316,  -316,  -316,  -316,  -316,  -316,   241,
     241,  -316,  -316,  -316,  -316,  -316,   156,  -316,  1217,   214,
      84,  1217,   171,  1217,   241,  -316,   953,   241,  1151,  1184,
     164,   685,    43,   178,   166,    84,  -316,  -316,     5,  1217,
     181,  1217,  -316,  -316,  -316,   191,   192,   685,  -316,  -316,
    -316,   403,   177,  -316,  -316,  -316,  -316,   685,   685,   685,
     685,   685,   685,  -316
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
      28,     0,     0,     0,    28,    12,    28,     4,     6,     7,
       0,     5,    33,     0,     8,     9,    10,     0,     0,     0,
       0,     1,     2,     3,    13,     0,    14,   117,     0,    34,
     119,    42,    40,    45,    46,    48,    51,    54,    55,    43,
      41,    49,    50,    52,    53,    29,    27,    37,    36,    30,
      31,    32,    28,    28,     0,     0,   156,   160,   161,   162,
     157,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    73,   166,   137,     0,
       0,     0,     0,    58,    66,    62,    61,    67,    59,    60,
      64,    63,    65,    68,   102,    69,     0,     0,     0,     0,
     154,   158,     0,   175,   176,   177,   178,     0,    28,     0,
       0,    25,     0,    47,    44,    39,    38,     0,    28,   114,
      28,   111,     0,   109,    11,   180,   182,   201,   202,   209,
     210,   203,   206,   207,   208,   204,   205,    22,     0,     0,
       0,     0,     0,    92,     0,     0,    75,   157,     0,     0,
       0,    76,     0,   166,     0,     0,   146,   148,   152,   154,
     158,   149,    74,   155,   159,   173,     0,   179,   181,   164,
     163,     0,    70,   134,     0,     0,   135,     0,   136,    72,
      57,   121,   122,   117,     0,     0,     0,     0,     0,     0,
       0,    71,   128,     0,    17,     0,   105,     0,    26,     0,
     118,   120,     0,     0,   115,     0,     0,     0,     0,     0,
      23,     0,   129,   169,   170,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   155,   159,   138,   157,   150,   157,
     142,     0,   151,   183,   184,   194,   195,   193,   190,   191,
     192,   196,   197,   198,   199,   200,   186,   185,    77,     0,
       0,     0,     0,     0,   187,   188,   189,     0,     0,     0,
       0,   153,   131,     0,   132,   133,     0,   101,   168,   167,
       0,     0,     0,     0,    28,    15,     0,   104,     0,   116,
     107,   113,   112,   110,   108,     0,    21,   171,   165,     0,
       0,     0,    95,     0,     0,     0,   145,    35,     0,   139,
     140,   143,   141,   147,   168,   167,   174,   130,   103,     0,
       0,   123,   172,   125,   124,    18,    19,   106,    24,    78,
       0,    93,     0,    96,     0,    89,     0,     0,     0,     0,
      20,     0,     0,     0,     0,    82,    84,    83,    97,    94,
       0,   144,   127,   126,    79,     0,     0,    56,    80,    85,
      81,     0,     0,    98,    99,   100,    90,    56,    56,    88,
       0,    86,    87,    91
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -316,  -316,   259,  -316,  -316,  -316,  -316,    -7,    19,  -316,
    -316,    31,  -104,  -316,  -316,  -316,   -11,  -316,   137,    -5,
      -8,    -6,  -315,   -65,   263,  -316,  -316,  -316,  -316,  -316,
    -316,  -316,   -61,   -55,  -316,  -316,  -316,  -316,  -316,  -316,
    -316,  -316,  -174,  -316,  -316,  -316,    80,  -316,   223,  -105,
     190,  -316,    -9,   -57,   141,   277,  -140,    34,   -25,  -316,
     -19,    36,    13,  -316,  -316,  -316,  -316,  -316,  -316,  -316,
    -316,  -316,   193
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,     6,     7,     8,     9,    10,   193,   194,   153,   209,
      11,   117,    13,    45,    28,   154,    78,    47,    48,    79,
      80,    81,    82,    83,    84,    85,    86,    87,    88,    89,
     334,   335,   336,   337,    90,    91,    92,   219,   322,   352,
      93,    94,   110,    14,    15,   122,   123,    16,   118,   119,
      29,    95,    96,    97,    98,   171,   156,   157,   158,   215,
     159,   160,   161,   103,   104,   105,   106,   250,   257,   251,
     252,   253,   139
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      99,   145,    46,    30,   195,    50,   100,    51,    49,   266,
     230,   165,   351,   204,   137,   204,    17,   180,   138,   198,
       1,     2,     3,     4,   107,   308,    21,   199,   125,   126,
     223,    12,   359,   199,    24,    20,   107,    12,   102,   113,
      25,    99,   361,   362,    77,   114,   345,   100,   346,     1,
       2,     3,     4,    72,    73,   170,   108,    99,   125,   126,
     109,   101,   137,   100,   163,   164,   138,    18,   173,   176,
     178,   174,   109,   175,   177,     5,    19,   207,   -16,   102,
     274,    27,   -16,   208,   275,    77,   166,   285,    55,    30,
      52,   286,   137,   185,   186,   102,   138,   254,   255,   256,
      53,    77,   101,   201,     5,   258,   259,    54,   267,   112,
     299,   300,   301,   302,    22,   332,   333,   111,   101,   112,
     115,   116,   121,   124,   228,   146,   140,   162,   141,   232,
      56,    57,    58,    59,   147,   142,    56,    57,    58,    59,
     147,   231,   330,   187,   127,   128,   129,   130,   131,   132,
     133,   134,   135,   136,    61,   143,   167,   168,   169,   144,
      61,   172,   183,   262,   264,   181,   265,   182,   263,   190,
     195,   148,    71,   191,   200,    72,    73,   148,    71,   188,
     202,    72,    73,   203,   276,   205,   206,    50,   222,    51,
      49,   188,   138,   268,   269,   107,   149,    74,   279,   280,
     150,   281,   149,    74,   282,   288,   150,   284,   291,   152,
     292,   151,   293,   295,   196,   152,   304,   297,    31,    32,
      33,    34,    35,   305,   319,    37,    38,    39,    40,   325,
     309,    43,    44,   310,   316,   324,   320,    56,    57,    58,
      59,   229,   109,   331,    56,    57,    58,    59,   147,   338,
     199,   348,   307,    31,    32,    33,    34,    35,   347,   356,
     360,    61,    39,    40,    99,    23,   344,   315,    61,    99,
     100,   357,   358,    26,   349,   100,   120,   213,    70,    71,
     350,   354,    72,    73,   220,   148,    71,   283,   184,    72,
      73,   303,     0,   189,   180,   363,   180,   180,     0,     0,
       0,     0,   102,   149,    74,     0,    99,   102,    77,     0,
     149,    74,   100,    77,   150,     0,   152,     0,     0,     0,
       0,     0,    99,   152,     0,   101,     0,     0,   100,   353,
     101,     0,    99,    99,    99,    99,    99,    99,   100,   100,
     100,   100,   100,   100,   102,   155,     0,     0,     0,     0,
      77,   355,     0,     0,     0,     0,     0,     0,     0,     0,
     102,   224,   225,    58,    59,   147,    77,   101,     0,     0,
     102,   102,   102,   102,   102,   102,    77,    77,    77,    77,
      77,    77,     0,   101,   192,    61,   197,     0,     0,     0,
       0,     0,     0,   101,   101,   101,   101,   101,   101,     0,
       0,     0,   148,    71,     0,     0,    72,    73,    56,    57,
      58,    59,   227,     0,   210,   211,   212,   214,   216,   217,
       0,   221,     0,     0,     0,   226,     0,   149,    74,     0,
       0,   150,    61,     0,     0,     0,     0,     0,     0,     0,
     152,     0,     0,   260,     0,     0,     0,     0,     0,    70,
      71,   125,   126,   107,   127,   128,   129,   130,   131,   132,
     133,   134,   135,   136,   270,   271,   272,   273,     0,     0,
       0,     0,     0,     0,     0,    74,   278,    56,    57,    58,
      59,    60,    31,    32,    33,    34,    35,    75,    36,    37,
      38,    39,    40,    41,    42,    43,    44,     0,     0,     0,
     296,    61,    62,     0,    63,     0,     0,    64,    65,    66,
      67,    68,    69,     0,   233,   234,     0,     0,    70,    71,
       0,     0,    72,    73,     0,     0,   298,     0,     0,     0,
       0,     0,   235,   236,   237,   238,   239,   240,   241,   242,
       0,   243,   244,   245,    74,   246,   247,     0,     0,     0,
       0,     0,   249,     0,   261,     0,    75,     0,    25,    76,
       0,     0,   318,     0,     0,     0,     0,     0,   321,   323,
       0,     0,   326,    31,    32,    33,    34,    35,     0,     0,
      37,    38,    39,    40,     0,     0,   328,   329,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   339,     0,     0,   341,    56,    57,    58,    59,    60,
      31,    32,    33,    34,    35,     0,    36,    37,    38,    39,
      40,    41,    42,    43,    44,     0,     0,     0,     0,    61,
      62,     0,    63,     0,     0,    64,    65,    66,    67,    68,
      69,     0,   233,   234,     0,     0,    70,    71,     0,     0,
      72,    73,     0,     0,     0,     0,     0,     0,     0,     0,
     235,   236,   237,   238,   239,   240,   241,   242,     0,   243,
     244,   245,    74,   246,   247,     0,     0,     0,     0,     0,
     249,     0,   289,     0,    75,     0,    25,   179,    56,    57,
      58,    59,    60,    31,    32,    33,    34,    35,     0,    36,
      37,    38,    39,    40,    41,    42,    43,    44,     0,     0,
       0,     0,    61,    62,     0,    63,     0,     0,    64,    65,
      66,    67,    68,    69,     0,     0,     0,     0,     0,    70,
      71,     0,     0,    72,    73,    56,    57,    58,    59,   147,
      31,    32,    33,    34,    35,     0,     0,     0,     0,    39,
      40,     0,     0,     0,     0,    74,     0,     0,     0,    61,
       0,     0,     0,     0,     0,   233,   234,    75,     0,    25,
       0,     0,     0,     0,     0,     0,   148,    71,     0,     0,
      72,    73,     0,   235,   236,   237,   238,   239,   240,   241,
     242,     0,   243,   244,   245,     0,   246,   247,   233,   234,
       0,   149,    74,   249,     0,   150,     0,     0,     0,   277,
       0,     0,     0,     0,   152,     0,   235,   236,   237,   238,
     239,   240,   241,   242,     0,   243,   244,   245,     0,   246,
     247,   233,   234,     0,     0,     0,   249,     0,     0,     0,
       0,     0,   287,     0,     0,     0,     0,     0,     0,   235,
     236,   237,   238,   239,   240,   241,   242,     0,   243,   244,
     245,     0,   246,   247,   233,   234,     0,     0,     0,   249,
       0,     0,     0,     0,     0,   312,     0,     0,     0,     0,
       0,     0,   235,   236,   237,   238,   239,   240,   241,   242,
       0,   243,   244,   245,     0,   246,   247,   233,   234,     0,
       0,     0,   249,     0,     0,     0,     0,     0,   317,     0,
       0,     0,     0,     0,     0,   235,   236,   237,   238,   239,
     240,   241,   242,     0,   243,   244,   245,     0,   246,   247,
     233,   234,     0,     0,     0,   249,     0,   290,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   235,   236,
     237,   238,   239,   240,   241,   242,     0,   243,   244,   245,
       0,   246,   247,   233,   234,     0,     0,     0,   249,     0,
     294,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   235,   236,   237,   238,   239,   240,   241,   242,     0,
     243,   244,   245,     0,   246,   247,   233,   234,     0,     0,
       0,   249,     0,   306,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   235,   236,   237,   238,   239,   240,
     241,   242,     0,   243,   244,   245,     0,   246,   247,   233,
     234,     0,     0,     0,   249,     0,   340,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   235,   236,   237,
     238,   239,   240,   241,   242,     0,   243,   244,   245,     0,
     246,   247,   233,   234,   248,     0,     0,   249,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     235,   236,   237,   238,   239,   240,   241,   242,     0,   243,
     244,   245,     0,   246,   247,   233,   234,   311,     0,     0,
     249,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   235,   236,   237,   238,   239,   240,   241,
     242,     0,   243,   244,   245,     0,   246,   247,   233,   234,
     313,     0,     0,   249,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   235,   236,   237,   238,
     239,   240,   241,   242,     0,   243,   244,   245,     0,   246,
     247,   233,   234,   314,     0,     0,   249,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   235,
     236,   237,   238,   239,   240,   241,   242,     0,   243,   244,
     245,     0,   246,   247,   233,   234,     0,     0,   327,   249,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   235,   236,   237,   238,   239,   240,   241,   242,
       0,   243,   244,   245,     0,   246,   247,   233,   234,   342,
       0,     0,   249,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   235,   236,   237,   238,   239,
     240,   241,   242,     0,   243,   244,   245,     0,   246,   247,
     233,   234,   343,     0,     0,   249,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   235,   236,
     237,   238,   239,   240,   241,   242,     0,   243,   244,   245,
       0,   246,   247,     0,     0,     0,     0,     0,   249,   125,
     126,   107,   127,   128,   129,   130,   131,   132,   133,   134,
     135,   136,   218,    31,    32,    33,    34,    35,     0,    36,
      37,    38,    39,    40,    41,    42,    43,    44,     0,     0,
       0,     0,     0,   137,     0,     0,     0,   138,    31,    32,
      33,    34,    35,     0,    36,    37,    38,    39,    40,    41,
      42,    43,    44
};

static const yytype_int16 yycheck[] =
{
      25,    66,    13,    12,   108,    13,    25,    13,    13,   183,
     150,     7,     7,   118,    82,   120,     7,    82,    86,    78,
      23,    24,    25,    26,    50,    78,     0,    86,    48,    49,
      50,     0,   347,    86,    78,     4,    50,     6,    25,    11,
      84,    66,   357,   358,    25,    17,     3,    66,     5,    23,
      24,    25,    26,    48,    49,    74,    82,    82,    48,    49,
      86,    25,    82,    82,     3,     4,    86,     7,    79,    80,
      81,    79,    86,    79,    80,    78,     7,    79,    79,    66,
      79,     7,    83,    85,    83,    66,    82,    79,     7,    98,
      84,    83,    82,    76,    77,    82,    86,    45,    46,    47,
      84,    82,    66,   112,    78,    76,    77,    84,    78,    79,
     250,   251,   252,   253,    88,    31,    32,    78,    82,    79,
      45,    45,     7,    78,   149,    78,    82,    78,    82,   154,
       3,     4,     5,     6,     7,    82,     3,     4,     5,     6,
       7,   152,   316,    50,    51,    52,    53,    54,    55,    56,
      57,    58,    59,    60,    27,    82,     7,     7,     7,    82,
      27,    78,     7,   174,   175,    78,   177,    78,   174,    50,
     274,    44,    45,    78,     7,    48,    49,    44,    45,    86,
       7,    48,    49,    85,   195,    85,    50,   195,    34,   195,
     195,    86,    86,     7,     7,    50,    69,    70,    78,    78,
      73,    78,    69,    70,     3,    83,    73,    78,    50,    82,
      78,    78,     7,    82,    87,    82,     7,    83,     8,     9,
      10,    11,    12,     7,   289,    15,    16,    17,    18,   294,
      50,    21,    22,    50,     7,    50,    84,     3,     4,     5,
       6,     7,    86,    29,     3,     4,     5,     6,     7,    78,
      86,    85,   263,     8,     9,    10,    11,    12,    80,    78,
      83,    27,    17,    18,   289,     6,   331,   274,    27,   294,
     289,    80,    80,    10,   335,   294,    53,   140,    44,    45,
     335,   338,    48,    49,   143,    44,    45,   207,    98,    48,
      49,   257,    -1,   100,   359,   360,   361,   362,    -1,    -1,
      -1,    -1,   289,    69,    70,    -1,   331,   294,   289,    -1,
      69,    70,   331,   294,    73,    -1,    82,    -1,    -1,    -1,
      -1,    -1,   347,    82,    -1,   289,    -1,    -1,   347,   338,
     294,    -1,   357,   358,   359,   360,   361,   362,   357,   358,
     359,   360,   361,   362,   331,    68,    -1,    -1,    -1,    -1,
     331,   338,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     347,     3,     4,     5,     6,     7,   347,   331,    -1,    -1,
     357,   358,   359,   360,   361,   362,   357,   358,   359,   360,
     361,   362,    -1,   347,   107,    27,   109,    -1,    -1,    -1,
      -1,    -1,    -1,   357,   358,   359,   360,   361,   362,    -1,
      -1,    -1,    44,    45,    -1,    -1,    48,    49,     3,     4,
       5,     6,     7,    -1,   137,   138,   139,   140,   141,   142,
      -1,   144,    -1,    -1,    -1,   148,    -1,    69,    70,    -1,
      -1,    73,    27,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      82,    -1,    -1,   166,    -1,    -1,    -1,    -1,    -1,    44,
      45,    48,    49,    50,    51,    52,    53,    54,    55,    56,
      57,    58,    59,    60,   187,   188,   189,   190,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    70,   199,     3,     4,     5,
       6,     7,     8,     9,    10,    11,    12,    82,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    -1,    -1,    -1,
     223,    27,    28,    -1,    30,    -1,    -1,    33,    34,    35,
      36,    37,    38,    -1,    43,    44,    -1,    -1,    44,    45,
      -1,    -1,    48,    49,    -1,    -1,   249,    -1,    -1,    -1,
      -1,    -1,    61,    62,    63,    64,    65,    66,    67,    68,
      -1,    70,    71,    72,    70,    74,    75,    -1,    -1,    -1,
      -1,    -1,    81,    -1,    83,    -1,    82,    -1,    84,    85,
      -1,    -1,   285,    -1,    -1,    -1,    -1,    -1,   291,   292,
      -1,    -1,   295,     8,     9,    10,    11,    12,    -1,    -1,
      15,    16,    17,    18,    -1,    -1,   309,   310,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   324,    -1,    -1,   327,     3,     4,     5,     6,     7,
       8,     9,    10,    11,    12,    -1,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    -1,    -1,    -1,    -1,    27,
      28,    -1,    30,    -1,    -1,    33,    34,    35,    36,    37,
      38,    -1,    43,    44,    -1,    -1,    44,    45,    -1,    -1,
      48,    49,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      61,    62,    63,    64,    65,    66,    67,    68,    -1,    70,
      71,    72,    70,    74,    75,    -1,    -1,    -1,    -1,    -1,
      81,    -1,    83,    -1,    82,    -1,    84,    85,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    -1,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    -1,    -1,
      -1,    -1,    27,    28,    -1,    30,    -1,    -1,    33,    34,
      35,    36,    37,    38,    -1,    -1,    -1,    -1,    -1,    44,
      45,    -1,    -1,    48,    49,     3,     4,     5,     6,     7,
       8,     9,    10,    11,    12,    -1,    -1,    -1,    -1,    17,
      18,    -1,    -1,    -1,    -1,    70,    -1,    -1,    -1,    27,
      -1,    -1,    -1,    -1,    -1,    43,    44,    82,    -1,    84,
      -1,    -1,    -1,    -1,    -1,    -1,    44,    45,    -1,    -1,
      48,    49,    -1,    61,    62,    63,    64,    65,    66,    67,
      68,    -1,    70,    71,    72,    -1,    74,    75,    43,    44,
      -1,    69,    70,    81,    -1,    73,    -1,    -1,    -1,    87,
      -1,    -1,    -1,    -1,    82,    -1,    61,    62,    63,    64,
      65,    66,    67,    68,    -1,    70,    71,    72,    -1,    74,
      75,    43,    44,    -1,    -1,    -1,    81,    -1,    -1,    -1,
      -1,    -1,    87,    -1,    -1,    -1,    -1,    -1,    -1,    61,
      62,    63,    64,    65,    66,    67,    68,    -1,    70,    71,
      72,    -1,    74,    75,    43,    44,    -1,    -1,    -1,    81,
      -1,    -1,    -1,    -1,    -1,    87,    -1,    -1,    -1,    -1,
      -1,    -1,    61,    62,    63,    64,    65,    66,    67,    68,
      -1,    70,    71,    72,    -1,    74,    75,    43,    44,    -1,
      -1,    -1,    81,    -1,    -1,    -1,    -1,    -1,    87,    -1,
      -1,    -1,    -1,    -1,    -1,    61,    62,    63,    64,    65,
      66,    67,    68,    -1,    70,    71,    72,    -1,    74,    75,
      43,    44,    -1,    -1,    -1,    81,    -1,    83,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    61,    62,
      63,    64,    65,    66,    67,    68,    -1,    70,    71,    72,
      -1,    74,    75,    43,    44,    -1,    -1,    -1,    81,    -1,
      83,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    61,    62,    63,    64,    65,    66,    67,    68,    -1,
      70,    71,    72,    -1,    74,    75,    43,    44,    -1,    -1,
      -1,    81,    -1,    83,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    61,    62,    63,    64,    65,    66,
      67,    68,    -1,    70,    71,    72,    -1,    74,    75,    43,
      44,    -1,    -1,    -1,    81,    -1,    83,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    61,    62,    63,
      64,    65,    66,    67,    68,    -1,    70,    71,    72,    -1,
      74,    75,    43,    44,    78,    -1,    -1,    81,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      61,    62,    63,    64,    65,    66,    67,    68,    -1,    70,
      71,    72,    -1,    74,    75,    43,    44,    78,    -1,    -1,
      81,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    61,    62,    63,    64,    65,    66,    67,
      68,    -1,    70,    71,    72,    -1,    74,    75,    43,    44,
      78,    -1,    -1,    81,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    61,    62,    63,    64,
      65,    66,    67,    68,    -1,    70,    71,    72,    -1,    74,
      75,    43,    44,    78,    -1,    -1,    81,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    61,
      62,    63,    64,    65,    66,    67,    68,    -1,    70,    71,
      72,    -1,    74,    75,    43,    44,    -1,    -1,    80,    81,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    61,    62,    63,    64,    65,    66,    67,    68,
      -1,    70,    71,    72,    -1,    74,    75,    43,    44,    78,
      -1,    -1,    81,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    61,    62,    63,    64,    65,
      66,    67,    68,    -1,    70,    71,    72,    -1,    74,    75,
      43,    44,    78,    -1,    -1,    81,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    61,    62,
      63,    64,    65,    66,    67,    68,    -1,    70,    71,    72,
      -1,    74,    75,    -1,    -1,    -1,    -1,    -1,    81,    48,
      49,    50,    51,    52,    53,    54,    55,    56,    57,    58,
      59,    60,     7,     8,     9,    10,    11,    12,    -1,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    -1,    -1,
      -1,    -1,    -1,    82,    -1,    -1,    -1,    86,     8,     9,
      10,    11,    12,    -1,    14,    15,    16,    17,    18,    19,
      20,    21,    22
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,    23,    24,    25,    26,    78,    92,    93,    94,    95,
      96,   101,   102,   103,   134,   135,   138,     7,     7,     7,
     102,     0,    88,    93,    78,    84,   115,     7,   105,   141,
     143,     8,     9,    10,    11,    12,    14,    15,    16,    17,
      18,    19,    20,    21,    22,   104,   107,   108,   109,   110,
     111,   112,    84,    84,    84,     7,     3,     4,     5,     6,
       7,    27,    28,    30,    33,    34,    35,    36,    37,    38,
      44,    45,    48,    49,    70,    82,    85,    99,   107,   110,
     111,   112,   113,   114,   115,   116,   117,   118,   119,   120,
     125,   126,   127,   131,   132,   142,   143,   144,   145,   149,
     151,   152,   153,   154,   155,   156,   157,    50,    82,    86,
     133,    78,    79,    11,    17,    45,    45,   102,   139,   140,
     139,     7,   136,   137,    78,    48,    49,    51,    52,    53,
      54,    55,    56,    57,    58,    59,    60,    82,    86,   163,
      82,    82,    82,    82,    82,   114,    78,     7,    44,    69,
      73,    78,    82,    99,   106,   146,   147,   148,   149,   151,
     152,   153,    78,     3,     4,     7,    82,     7,     7,     7,
     151,   146,    78,   107,   111,   112,   107,   112,   107,    85,
     114,    78,    78,     7,   141,    76,    77,    50,    86,   163,
      50,    78,   146,    97,    98,   103,    87,   146,    78,    86,
       7,   143,     7,    85,   140,    85,    50,    79,    85,   100,
     146,   146,   146,   109,   146,   150,   146,   146,     7,   128,
     145,   146,    34,    50,     3,     4,   146,     7,   149,     7,
     147,   107,   149,    43,    44,    61,    62,    63,    64,    65,
      66,    67,    68,    70,    71,    72,    74,    75,    78,    81,
     158,   160,   161,   162,    45,    46,    47,   159,    76,    77,
     146,    83,   107,   112,   107,   107,   133,    78,     7,     7,
     146,   146,   146,   146,    79,    83,   107,    87,   146,    78,
      78,    78,     3,   137,    78,    79,    83,    87,    83,    83,
      83,    50,    78,     7,    83,    82,   146,    83,   146,   147,
     147,   147,   147,   148,     7,     7,    83,   107,    78,    50,
      50,    78,    87,    78,    78,    98,     7,    87,   146,   114,
      84,   146,   129,   146,    50,   114,   146,    80,   146,   146,
     133,    29,    31,    32,   121,   122,   123,   124,    78,   146,
      83,   146,    78,    78,   114,     3,     5,    80,    85,   123,
     124,     7,   130,   143,   144,   153,    78,    80,    80,   113,
      83,   113,   113,   114
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_uint8 yyr1[] =
{
       0,    91,    92,    92,    92,    93,    93,    93,    93,    93,
      93,    93,    93,    94,    95,    96,    97,    97,    97,    98,
      98,    99,   100,   100,   100,   101,   101,   102,   103,   103,
     104,   104,   104,   105,   105,   106,   107,   107,   108,   108,
     109,   109,   109,   109,   109,   109,   109,   109,   109,   110,
     110,   110,   111,   111,   112,   112,   113,   113,   113,   114,
     114,   114,   114,   114,   114,   114,   114,   114,   114,   114,
     114,   114,   115,   115,   116,   117,   118,   118,   119,   119,
     120,   121,   121,   121,   122,   122,   123,   123,   124,   125,
     126,   127,   128,   128,   128,   129,   129,   130,   130,   130,
     130,   131,   131,   132,   133,   133,   133,   134,   135,   136,
     136,   137,   137,   138,   139,   139,   140,   141,   141,   141,
     141,   142,   142,   142,   142,   142,   142,   142,   143,   144,
     145,   145,   145,   145,   145,   145,   145,   145,   146,   146,
     146,   146,   146,   146,   146,   146,   146,   147,   147,   148,
     148,   148,   148,   149,   149,   149,   149,   149,   149,   149,
     149,   149,   149,   149,   149,   149,   149,   149,   149,   150,
     150,   151,   151,   152,   152,   153,   153,   153,   153,   154,
     155,   156,   157,   158,   158,   158,   158,   159,   159,   159,
     160,   160,   160,   160,   160,   160,   161,   161,   162,   162,
     162,   163,   163,   163,   163,   163,   163,   163,   163,   163,
     163
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     2,     2,     1,     1,     1,     1,     1,     1,
       1,     4,     1,     2,     2,     5,     0,     1,     3,     3,
       4,     4,     0,     1,     3,     3,     4,     2,     0,     2,
       1,     1,     1,     0,     1,     3,     1,     1,     2,     2,
       1,     1,     1,     1,     2,     1,     1,     2,     1,     1,
       1,     1,     1,     1,     1,     1,     0,     2,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       2,     2,     3,     2,     2,     2,     2,     3,     5,     7,
       7,     2,     1,     1,     1,     2,     4,     4,     3,     5,
       7,     9,     0,     3,     4,     0,     1,     0,     1,     1,
       1,     3,     1,     4,     3,     2,     4,     6,     6,     1,
       3,     1,     3,     6,     1,     2,     3,     1,     3,     1,
       3,     2,     2,     4,     4,     4,     6,     6,     3,     3,
       4,     3,     3,     3,     2,     2,     2,     1,     2,     3,
       3,     3,     2,     3,     5,     3,     1,     3,     1,     1,
       2,     2,     1,     3,     1,     2,     1,     1,     1,     2,
       1,     1,     1,     2,     2,     4,     1,     3,     3,     1,
       1,     4,     4,     2,     4,     1,     1,     1,     1,     2,
       2,     2,     2,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1
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
  case 2: /* program: program TOKEN_EOF  */
#line 91 "parser.y"
                    {
                        p_treeRoot = yyvsp[-1].treeNode;
                        LOG_DEBUG("Reached end of file!\n");
                        return 0;
                    }
#line 1733 "parser.tab.c"
    break;

  case 3: /* program: program global_statement  */
#line 98 "parser.y"
                    {
                        TreeNode_t* p_Head = yyvsp[-1].treeNode;
                        if (NodeAppendSibling(&p_Head, yyvsp[0].treeNode)) { YYERROR; }
                        yyval.treeNode = p_Head;
                    }
#line 1743 "parser.tab.c"
    break;

  case 4: /* program: global_statement  */
#line 105 "parser.y"
                    {
                        yyval.treeNode = yyvsp[0].treeNode;
                    }
#line 1751 "parser.tab.c"
    break;

  case 5: /* global_statement: declaration  */
#line 112 "parser.y"
                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 1757 "parser.tab.c"
    break;

  case 6: /* global_statement: function_prototype  */
#line 114 "parser.y"
                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 1763 "parser.tab.c"
    break;

  case 7: /* global_statement: function_definition  */
#line 116 "parser.y"
                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 1769 "parser.tab.c"
    break;

  case 8: /* global_statement: struct_declaration  */
#line 118 "parser.y"
                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 1775 "parser.tab.c"
    break;

  case 9: /* global_statement: enum_declaration  */
#line 120 "parser.y"
                   { yyval.treeNode = yyvsp[0].treeNode; }
#line 1781 "parser.tab.c"
    break;

  case 10: /* global_statement: union_declaration  */
#line 122 "parser.y"
                   { yyval.treeNode = yyvsp[0].treeNode; }
#line 1787 "parser.tab.c"
    break;

  case 11: /* global_statement: TOKEN_TYPEDEF declaration_specifiers TOKEN_ID TOKEN_SEMI  */
#line 124 "parser.y"
                        {
                        NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
                        yyval.treeNode->nodeData.sVal = yyvsp[-1].nodeData.sVal;
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                        }
#line 1797 "parser.tab.c"
    break;

  case 12: /* global_statement: TOKEN_SEMI  */
#line 129 "parser.y"
                                 { yyval.treeNode = NULL; }
#line 1803 "parser.tab.c"
    break;

  case 13: /* function_prototype: function_signature TOKEN_SEMI  */
#line 138 "parser.y"
                        { yyval.treeNode = yyvsp[-1].treeNode; }
#line 1809 "parser.tab.c"
    break;

  case 14: /* function_definition: function_signature compound_statement  */
#line 142 "parser.y"
                        {
                            yyval.treeNode = yyvsp[-1].treeNode;
                            NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                        }
#line 1818 "parser.tab.c"
    break;

  case 15: /* function_signature: declaration_specifiers TOKEN_ID TOKEN_LEFT_PARENTHESES parameter_list TOKEN_RIGHT_PARENTHESES  */
#line 149 "parser.y"
                        {
                            NodeCreate(&yyval.treeNode, NODE_FUNCTION);
                            yyval.treeNode->nodeData.sVal = yyvsp[-3].nodeData.sVal;
                            currentFunction = yyvsp[-3].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-4].treeNode);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 1830 "parser.tab.c"
    break;

  case 16: /* parameter_list: %empty  */
#line 159 "parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_NULL); }
#line 1836 "parser.tab.c"
    break;

  case 17: /* parameter_list: parameter_declaration  */
#line 161 "parser.y"
                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 1842 "parser.tab.c"
    break;

  case 18: /* parameter_list: parameter_list TOKEN_COMMA parameter_declaration  */
#line 163 "parser.y"
                        {
                            TreeNode_t* p_Head = yyvsp[-2].treeNode;
                            if (NodeAppendSibling(&p_Head, yyvsp[0].treeNode)) { YYERROR; }
                            yyval.treeNode = p_Head;
                        }
#line 1852 "parser.tab.c"
    break;

  case 19: /* parameter_declaration: declaration_qualifiers type_all_specifier TOKEN_ID  */
#line 171 "parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_PARAMETER);
                                yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                                NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                                NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                            }
#line 1863 "parser.tab.c"
    break;

  case 20: /* parameter_declaration: declaration_qualifiers type_all_specifier TOKEN_ID arr_size  */
#line 178 "parser.y"
                             {
                                NodeCreate(&(yyval.treeNode), NODE_PARAMETER);
                                yyval.treeNode->nodeData.sVal = yyvsp[-1].nodeData.sVal;
                                NodeAddChild(yyval.treeNode, yyvsp[-3].treeNode);
                                NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                                NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                            }
#line 1875 "parser.tab.c"
    break;

  case 21: /* func_call: TOKEN_ID TOKEN_LEFT_PARENTHESES exp_list TOKEN_RIGHT_PARENTHESES  */
#line 188 "parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_FUNCTION_CALL);
                            yyval.treeNode->nodeData.sVal = yyvsp[-3].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 1885 "parser.tab.c"
    break;

  case 22: /* exp_list: %empty  */
#line 196 "parser.y"
                        { yyval.treeNode = NULL; }
#line 1891 "parser.tab.c"
    break;

  case 23: /* exp_list: exp  */
#line 198 "parser.y"
                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 1897 "parser.tab.c"
    break;

  case 24: /* exp_list: exp_list TOKEN_COMMA exp  */
#line 200 "parser.y"
                        {
                            TreeNode_t* pHead = yyvsp[-2].treeNode;
                            if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                            yyval.treeNode = pHead;
                        }
#line 1907 "parser.tab.c"
    break;

  case 25: /* declaration: declaration_specifiers init_declarator_list_opt TOKEN_SEMI  */
#line 221 "parser.y"
              {
                  NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
                  NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                  NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
              }
#line 1917 "parser.tab.c"
    break;

  case 26: /* declaration: declaration_specifiers TOKEN_ID arr_size TOKEN_SEMI  */
#line 227 "parser.y"
              {
                  NodeCreate(&(yyval.treeNode), NODE_ARRAY_DECLARATION);
                  yyval.treeNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                  NodeAddChild(yyval.treeNode, yyvsp[-3].treeNode);
                  NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
              }
#line 1928 "parser.tab.c"
    break;

  case 27: /* declaration_specifiers: declaration_qualifiers type_all_specifier  */
#line 235 "parser.y"
                            {
                                TreeNode_t* pHead = yyvsp[-1].treeNode;
                                if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                                yyval.treeNode = pHead;
                            }
#line 1938 "parser.tab.c"
    break;

  case 28: /* declaration_qualifiers: %empty  */
#line 243 "parser.y"
                            { NodeCreate(&(yyval.treeNode), NODE_NULL); }
#line 1944 "parser.tab.c"
    break;

  case 29: /* declaration_qualifiers: declaration_qualifiers declaration_qualifier  */
#line 245 "parser.y"
                            {
                                TreeNode_t* p_Head = yyvsp[-1].treeNode;
                                if (NodeAppendSibling(&p_Head, yyvsp[0].treeNode)) { YYERROR; }
                                yyval.treeNode = p_Head;
                            }
#line 1954 "parser.tab.c"
    break;

  case 30: /* declaration_qualifier: storage_class_specifier  */
#line 253 "parser.y"
                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 1960 "parser.tab.c"
    break;

  case 31: /* declaration_qualifier: type_qualifier  */
#line 255 "parser.y"
                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 1966 "parser.tab.c"
    break;

  case 32: /* declaration_qualifier: sign_qualifier  */
#line 257 "parser.y"
                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 1972 "parser.tab.c"
    break;

  case 33: /* init_declarator_list_opt: %empty  */
#line 261 "parser.y"
                                { NodeCreate(&(yyval.treeNode), NODE_NULL); }
#line 1978 "parser.tab.c"
    break;

  case 34: /* init_declarator_list_opt: id_list  */
#line 263 "parser.y"
                                { yyval.treeNode = yyvsp[0].treeNode; }
#line 1984 "parser.tab.c"
    break;

  case 35: /* type_cast_specifier: TOKEN_LEFT_PARENTHESES type_all_specifier TOKEN_RIGHT_PARENTHESES  */
#line 272 "parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE_CAST);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 1993 "parser.tab.c"
    break;

  case 36: /* type_all_specifier: data_type_specifier  */
#line 279 "parser.y"
                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 1999 "parser.tab.c"
    break;

  case 37: /* type_all_specifier: type_pointer  */
#line 281 "parser.y"
                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 2005 "parser.tab.c"
    break;

  case 38: /* type_pointer: data_type_specifier TOKEN_ASTERISK  */
#line 285 "parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_POINTER);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2014 "parser.tab.c"
    break;

  case 39: /* type_pointer: type_pointer TOKEN_ASTERISK  */
#line 290 "parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_POINTER);
                        NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                    }
#line 2023 "parser.tab.c"
    break;

  case 40: /* data_type_specifier: TOKEN_CHAR  */
#line 297 "parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_TYPE); yyval.treeNode->nodeData.dVal = TYPE_CHAR; }
#line 2029 "parser.tab.c"
    break;

  case 41: /* data_type_specifier: TOKEN_SHORT  */
#line 299 "parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_TYPE); yyval.treeNode->nodeData.dVal = TYPE_SHORT; }
#line 2035 "parser.tab.c"
    break;

  case 42: /* data_type_specifier: TOKEN_INT  */
#line 301 "parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_TYPE); yyval.treeNode->nodeData.dVal = TYPE_INT; }
#line 2041 "parser.tab.c"
    break;

  case 43: /* data_type_specifier: TOKEN_LONG  */
#line 303 "parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_TYPE); yyval.treeNode->nodeData.dVal = TYPE_LONG; }
#line 2047 "parser.tab.c"
    break;

  case 44: /* data_type_specifier: TOKEN_LONG TOKEN_LONG  */
#line 305 "parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_TYPE); yyval.treeNode->nodeData.dVal = TYPE_LONG; }
#line 2053 "parser.tab.c"
    break;

  case 45: /* data_type_specifier: TOKEN_FLOAT  */
#line 307 "parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_TYPE); yyval.treeNode->nodeData.dVal = TYPE_FLOAT; }
#line 2059 "parser.tab.c"
    break;

  case 46: /* data_type_specifier: TOKEN_DOUBLE  */
#line 309 "parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_TYPE); yyval.treeNode->nodeData.dVal = TYPE_DOUBLE; }
#line 2065 "parser.tab.c"
    break;

  case 47: /* data_type_specifier: TOKEN_LONG TOKEN_DOUBLE  */
#line 311 "parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_TYPE); yyval.treeNode->nodeData.dVal = TYPE_LONG_DOUBLE; }
#line 2071 "parser.tab.c"
    break;

  case 48: /* data_type_specifier: TOKEN_VOID  */
#line 313 "parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_TYPE); yyval.treeNode->nodeData.dVal = TYPE_VOID; }
#line 2077 "parser.tab.c"
    break;

  case 49: /* storage_class_specifier: TOKEN_STATIC  */
#line 317 "parser.y"
                            { NodeCreate(&(yyval.treeNode), NODE_VISIBILITY); yyval.treeNode->nodeData.dVal = (long int) VIS_STATIC; }
#line 2083 "parser.tab.c"
    break;

  case 50: /* storage_class_specifier: TOKEN_EXTERN  */
#line 319 "parser.y"
                            { NodeCreate(&(yyval.treeNode), NODE_VISIBILITY); yyval.treeNode->nodeData.dVal = (long int) VIS_EXTERN; }
#line 2089 "parser.tab.c"
    break;

  case 51: /* storage_class_specifier: TOKEN_INLINE  */
#line 321 "parser.y"
                            { NodeCreate(&(yyval.treeNode), NODE_VISIBILITY); yyval.treeNode->nodeData.dVal = (long int) VIS_STATIC; }
#line 2095 "parser.tab.c"
    break;

  case 52: /* type_qualifier: TOKEN_CONST  */
#line 325 "parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_MODIFIER); yyval.treeNode->nodeData.dVal = (long int) MOD_CONST; }
#line 2101 "parser.tab.c"
    break;

  case 53: /* type_qualifier: TOKEN_VOLATILE  */
#line 327 "parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_MODIFIER); yyval.treeNode->nodeData.dVal = (long int) MOD_VOLATILE; }
#line 2107 "parser.tab.c"
    break;

  case 54: /* sign_qualifier: TOKEN_SIGNED  */
#line 331 "parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_SIGN); yyval.treeNode->nodeData.dVal = (long int) SIGN_SIGNED; }
#line 2113 "parser.tab.c"
    break;

  case 55: /* sign_qualifier: TOKEN_UNSIGNED  */
#line 333 "parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_SIGN); yyval.treeNode->nodeData.dVal = (long int) SIGN_UNSIGNED; }
#line 2119 "parser.tab.c"
    break;

  case 56: /* local_statement_list: %empty  */
#line 342 "parser.y"
                            { yyval.treeNode = NULL; }
#line 2125 "parser.tab.c"
    break;

  case 57: /* local_statement_list: local_statement_list local_statement  */
#line 344 "parser.y"
                            {
                                TreeNode_t* pHead = yyvsp[-1].treeNode;
                                if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                                yyval.treeNode = pHead;
                            }
#line 2135 "parser.tab.c"
    break;

  case 58: /* local_statement_list: local_statement  */
#line 350 "parser.y"
                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 2141 "parser.tab.c"
    break;

  case 59: /* local_statement: if_statement  */
#line 353 "parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 2147 "parser.tab.c"
    break;

  case 60: /* local_statement: switch_statement  */
#line 354 "parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 2153 "parser.tab.c"
    break;

  case 61: /* local_statement: break_statement  */
#line 355 "parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 2159 "parser.tab.c"
    break;

  case 62: /* local_statement: continue_statement  */
#line 356 "parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 2165 "parser.tab.c"
    break;

  case 63: /* local_statement: do_while_loop  */
#line 357 "parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 2171 "parser.tab.c"
    break;

  case 64: /* local_statement: while_loop  */
#line 358 "parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 2177 "parser.tab.c"
    break;

  case 65: /* local_statement: for_loop  */
#line 359 "parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 2183 "parser.tab.c"
    break;

  case 66: /* local_statement: compound_statement  */
#line 360 "parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 2189 "parser.tab.c"
    break;

  case 67: /* local_statement: return_statement  */
#line 361 "parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 2195 "parser.tab.c"
    break;

  case 68: /* local_statement: var_declaration  */
#line 362 "parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 2201 "parser.tab.c"
    break;

  case 69: /* local_statement: var_assignment  */
#line 363 "parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 2207 "parser.tab.c"
    break;

  case 70: /* local_statement: func_call TOKEN_SEMI  */
#line 364 "parser.y"
                                             { yyval.treeNode = yyvsp[-1].treeNode; }
#line 2213 "parser.tab.c"
    break;

  case 71: /* local_statement: inc_dec TOKEN_SEMI  */
#line 365 "parser.y"
                                             { yyval.treeNode = yyvsp[-1].treeNode; }
#line 2219 "parser.tab.c"
    break;

  case 72: /* compound_statement: TOKEN_LEFT_BRACE local_statement_list TOKEN_RIGHT_BRACE  */
#line 370 "parser.y"
                        {
                            if (yyvsp[-1].treeNode != NULL) {
                                TreeNode_t* pEnd;
                                TreeNode_t* pStart;
                                TreeNode_t* pHead;
                                NodeCreate(&pEnd,   NODE_END_SCOPE);
                                NodeCreate(&pStart, NODE_START_SCOPE);
                                pHead = yyvsp[-1].treeNode;
                                if (NodeAppendSibling(&pHead, pEnd))   { YYERROR; }
                                if (NodeAppendSibling(&pStart, pHead)) { YYERROR; }
                                yyval.treeNode = pStart;
                            } else {
                                TreeNode_t* pNull;
                                NodeCreate(&pNull, NODE_NULL);
                                yyval.treeNode = pNull;
                            }
                        }
#line 2241 "parser.tab.c"
    break;

  case 73: /* compound_statement: TOKEN_LEFT_BRACE TOKEN_RIGHT_BRACE  */
#line 388 "parser.y"
                        { yyval.treeNode = NULL; }
#line 2247 "parser.tab.c"
    break;

  case 74: /* continue_statement: TOKEN_CONTINUE TOKEN_SEMI  */
#line 397 "parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_CONTINUE); }
#line 2253 "parser.tab.c"
    break;

  case 75: /* break_statement: TOKEN_BREAK TOKEN_SEMI  */
#line 401 "parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_BREAK); }
#line 2259 "parser.tab.c"
    break;

  case 76: /* return_statement: TOKEN_RETURN TOKEN_SEMI  */
#line 405 "parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_RETURN);
                            yyval.treeNode->nodeData.sVal = currentFunction;
                        }
#line 2268 "parser.tab.c"
    break;

  case 77: /* return_statement: TOKEN_RETURN exp TOKEN_SEMI  */
#line 410 "parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_RETURN);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                            yyval.treeNode->nodeData.sVal = currentFunction;
                        }
#line 2278 "parser.tab.c"
    break;

  case 78: /* if_statement: TOKEN_IF TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES local_statement  */
#line 418 "parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_IF);
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2288 "parser.tab.c"
    break;

  case 79: /* if_statement: TOKEN_IF TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES local_statement TOKEN_ELSE local_statement  */
#line 424 "parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_IF);
                        NodeAddChild(yyval.treeNode, yyvsp[-4].treeNode);
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2299 "parser.tab.c"
    break;

  case 80: /* switch_statement: TOKEN_SWITCH TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES TOKEN_LEFT_BRACE switch_body TOKEN_RIGHT_BRACE  */
#line 433 "parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_SWITCH);
                            NodeAddChild(yyval.treeNode, yyvsp[-4].treeNode);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2309 "parser.tab.c"
    break;

  case 81: /* switch_body: case_list default_clause  */
#line 441 "parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[-1].treeNode;
                        if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                        yyval.treeNode = pHead;
                    }
#line 2319 "parser.tab.c"
    break;

  case 82: /* switch_body: case_list  */
#line 447 "parser.y"
                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 2325 "parser.tab.c"
    break;

  case 83: /* switch_body: default_clause  */
#line 449 "parser.y"
                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 2331 "parser.tab.c"
    break;

  case 84: /* case_list: case_clause  */
#line 453 "parser.y"
                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 2337 "parser.tab.c"
    break;

  case 85: /* case_list: case_list case_clause  */
#line 455 "parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[-1].treeNode;
                        if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                        yyval.treeNode = pHead;
                    }
#line 2347 "parser.tab.c"
    break;

  case 86: /* case_clause: TOKEN_CASE TOKEN_NUM TOKEN_COLON local_statement_list  */
#line 463 "parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_CASE);
                        yyval.treeNode->nodeData.dVal = yyvsp[-2].nodeData.dVal;
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2357 "parser.tab.c"
    break;

  case 87: /* case_clause: TOKEN_CASE TOKEN_CNUM TOKEN_COLON local_statement_list  */
#line 469 "parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_CASE);
                        yyval.treeNode->nodeData.dVal = yyvsp[-2].nodeData.dVal;
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2367 "parser.tab.c"
    break;

  case 88: /* default_clause: TOKEN_DEFAULT TOKEN_COLON local_statement_list  */
#line 477 "parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_DEFAULT);
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2376 "parser.tab.c"
    break;

  case 89: /* while_loop: TOKEN_WHILE TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES local_statement  */
#line 489 "parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_WHILE);
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2386 "parser.tab.c"
    break;

  case 90: /* do_while_loop: TOKEN_DO local_statement TOKEN_WHILE TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES TOKEN_SEMI  */
#line 497 "parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_DO_WHILE);
                        NodeAddChild(yyval.treeNode, yyvsp[-5].treeNode);
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                    }
#line 2396 "parser.tab.c"
    break;

  case 91: /* for_loop: TOKEN_FOR TOKEN_LEFT_PARENTHESES for_init_field TOKEN_SEMI for_exp_opt TOKEN_SEMI for_assignment_field TOKEN_RIGHT_PARENTHESES local_statement  */
#line 505 "parser.y"
                    {
    TreeNode_t* pNodeWhile;
    TreeNode_t* pLoopBody = yyvsp[0].treeNode;

    /* só append do assignment se não for vazio */
    if (yyvsp[-2].treeNode != NULL) {
        if (NodeAppendSibling(&pLoopBody, yyvsp[-2].treeNode)) { YYERROR; }
    }

    NodeCreate(&pNodeWhile, NODE_WHILE);

    /* só adiciona condição se não for vazia */
    if (yyvsp[-4].treeNode != NULL) {
        NodeAddChild(pNodeWhile, yyvsp[-4].treeNode);
    }

    NodeAddChild(pNodeWhile, pLoopBody);

    /* só faz sequence se o init não for vazio */
    if (yyvsp[-6].treeNode != NULL) {
        TreeNode_t* pForSequence = yyvsp[-6].treeNode;
        if (NodeAppendSibling(&pForSequence, pNodeWhile)) { YYERROR; }
        yyval.treeNode = pForSequence;
    } else {
        yyval.treeNode = pNodeWhile;
    }
}
#line 2428 "parser.tab.c"
    break;

  case 92: /* for_init_field: %empty  */
#line 536 "parser.y"
                    { yyval.treeNode = NULL; }
#line 2434 "parser.tab.c"
    break;

  case 93: /* for_init_field: TOKEN_ID TOKEN_ASSIGN exp  */
#line 538 "parser.y"
                    {
                        TreeNode_t* pNode;
                        NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                        yyval.treeNode->nodeData.dVal = OP_ASSIGN;
                        NodeAddNewChild(yyval.treeNode, &pNode, NODE_IDENTIFIER);
                        pNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2447 "parser.tab.c"
    break;

  case 94: /* for_init_field: var_preamble TOKEN_ID TOKEN_ASSIGN exp  */
#line 547 "parser.y"
                    {
                        TreeNode_t* pNode;
                        NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
                        yyval.treeNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                        NodeAddChild(yyval.treeNode, yyvsp[-3].treeNode);
                        TreeNode_t* pAssign;
                        NodeCreate(&pAssign, NODE_OPERATOR);
                        pAssign->nodeData.dVal = OP_ASSIGN;
                        NodeAddNewChild(pAssign, &pNode, NODE_IDENTIFIER);
                        pNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                        NodeAddChild(pAssign, yyvsp[0].treeNode);
                        if (NodeAppendSibling(&(yyval.treeNode), pAssign)) { YYERROR; }
                    }
#line 2465 "parser.tab.c"
    break;

  case 95: /* for_exp_opt: %empty  */
#line 562 "parser.y"
                    { yyval.treeNode = NULL; }
#line 2471 "parser.tab.c"
    break;

  case 96: /* for_exp_opt: exp  */
#line 564 "parser.y"
                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 2477 "parser.tab.c"
    break;

  case 97: /* for_assignment_field: %empty  */
#line 567 "parser.y"
                                            { yyval.treeNode = NULL; }
#line 2483 "parser.tab.c"
    break;

  case 98: /* for_assignment_field: simple_var_assign  */
#line 568 "parser.y"
                                                { yyval.treeNode = yyvsp[0].treeNode; }
#line 2489 "parser.tab.c"
    break;

  case 99: /* for_assignment_field: compound_var_assign  */
#line 569 "parser.y"
                                                { yyval.treeNode = yyvsp[0].treeNode; }
#line 2495 "parser.tab.c"
    break;

  case 100: /* for_assignment_field: inc_dec  */
#line 570 "parser.y"
                                                { yyval.treeNode = yyvsp[0].treeNode; }
#line 2501 "parser.tab.c"
    break;

  case 101: /* var_declaration: var_preamble id_list TOKEN_SEMI  */
#line 579 "parser.y"
                    {
                        TreeNode_t* pNode = yyvsp[-1].treeNode;
                        TreeNode_t nodePreambleCopy;
                        memcpy(&nodePreambleCopy, yyvsp[-2].treeNode, sizeof(TreeNode_t));
                        free(yyvsp[-2].treeNode);
                        do {
                            if (pNode->nodeType == NODE_VAR_DECLARATION) {
                                NodeAddChildCopy(pNode, &nodePreambleCopy);
                            }
                            pNode = pNode->p_sibling;
                        } while (pNode != NULL);
                        yyval.treeNode = yyvsp[-1].treeNode;
                    }
#line 2519 "parser.tab.c"
    break;

  case 102: /* var_declaration: arr_declaration  */
#line 593 "parser.y"
                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 2525 "parser.tab.c"
    break;

  case 103: /* arr_declaration: var_preamble TOKEN_ID arr_size TOKEN_SEMI  */
#line 597 "parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_ARRAY_DECLARATION);
                        yyval.treeNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                        NodeAddChild(yyval.treeNode, yyvsp[-3].treeNode);
                        NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                    }
#line 2536 "parser.tab.c"
    break;

  case 104: /* arr_size: TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET  */
#line 606 "parser.y"
                { yyval.treeNode = yyvsp[-1].treeNode; }
#line 2542 "parser.tab.c"
    break;

  case 105: /* arr_size: TOKEN_LEFT_BRACKET TOKEN_RIGHT_BRACKET  */
#line 608 "parser.y"
                { NodeCreate(&(yyval.treeNode), NODE_NULL); }
#line 2548 "parser.tab.c"
    break;

  case 106: /* arr_size: arr_size TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET  */
#line 610 "parser.y"
                {
                    TreeNode_t* pHead = yyvsp[-3].treeNode;
                    if (NodeAppendSibling(&pHead, yyvsp[-1].treeNode)) { YYERROR; }
                    yyval.treeNode = pHead;
                }
#line 2558 "parser.tab.c"
    break;

  case 107: /* struct_declaration: TOKEN_STRUCT TOKEN_ID TOKEN_LEFT_BRACE struct_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI  */
#line 619 "parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_STRUCT_DECLARATION);
                            yyval.treeNode->nodeData.sVal = yyvsp[-4].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                        }
#line 2568 "parser.tab.c"
    break;

  case 108: /* enum_declaration: TOKEN_ENUM TOKEN_ID TOKEN_LEFT_BRACE enum_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI  */
#line 626 "parser.y"
                   {
                       NodeCreate(&(yyval.treeNode), NODE_ENUM_DECLARATION);
                       yyval.treeNode->nodeData.sVal = yyvsp[-4].nodeData.sVal;
                       NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                   }
#line 2578 "parser.tab.c"
    break;

  case 109: /* enum_member_list: enum_member  */
#line 634 "parser.y"
                   { yyval.treeNode = yyvsp[0].treeNode; }
#line 2584 "parser.tab.c"
    break;

  case 110: /* enum_member_list: enum_member_list TOKEN_COMMA enum_member  */
#line 636 "parser.y"
                   {
                       TreeNode_t* pHead = yyvsp[-2].treeNode;
                       if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                       yyval.treeNode = pHead;
                   }
#line 2594 "parser.tab.c"
    break;

  case 111: /* enum_member: TOKEN_ID  */
#line 644 "parser.y"
              {
                  NodeCreate(&(yyval.treeNode), NODE_ENUM_MEMBER);
                  yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
              }
#line 2603 "parser.tab.c"
    break;

  case 112: /* enum_member: TOKEN_ID TOKEN_ASSIGN TOKEN_NUM  */
#line 649 "parser.y"
              {
                  NodeCreate(&(yyval.treeNode), NODE_ENUM_MEMBER);
                  yyval.treeNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
              }
#line 2612 "parser.tab.c"
    break;

  case 113: /* union_declaration: TOKEN_UNION TOKEN_ID TOKEN_LEFT_BRACE struct_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI  */
#line 656 "parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_UNION_DECLARATION);
                        yyval.treeNode->nodeData.sVal = yyvsp[-4].nodeData.sVal;
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                    }
#line 2622 "parser.tab.c"
    break;

  case 114: /* struct_member_list: struct_member  */
#line 663 "parser.y"
                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 2628 "parser.tab.c"
    break;

  case 115: /* struct_member_list: struct_member_list struct_member  */
#line 665 "parser.y"
                        {
                            TreeNode_t* pHead = yyvsp[-1].treeNode;
                            if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                            yyval.treeNode = pHead;
                        }
#line 2638 "parser.tab.c"
    break;

  case 116: /* struct_member: declaration_specifiers TOKEN_ID TOKEN_SEMI  */
#line 673 "parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_STRUCT_MEMBER);
                            yyval.treeNode->nodeData.sVal = yyvsp[-1].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                        }
#line 2648 "parser.tab.c"
    break;

  case 117: /* id_list: TOKEN_ID  */
#line 681 "parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
                        yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                    }
#line 2657 "parser.tab.c"
    break;

  case 118: /* id_list: id_list TOKEN_COMMA TOKEN_ID  */
#line 686 "parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[-2].treeNode;
                        TreeNode_t* pNewNode;
                        NodeCreate(&pNewNode, NODE_VAR_DECLARATION);
                        pNewNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                        if (NodeAppendSibling(&pHead, pNewNode)) { YYERROR; }
                        yyval.treeNode = pHead;
                    }
#line 2670 "parser.tab.c"
    break;

  case 119: /* id_list: simple_var_assign  */
#line 695 "parser.y"
                    {
                        TreeNode_t* pNode = yyvsp[0].treeNode->p_firstChild;
                        TreeNode_t* pHead;
                        NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
                        yyval.treeNode->nodeData.sVal = pNode->nodeData.sVal;
                        pHead = yyval.treeNode;
                        if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                        yyval.treeNode = pHead;
                    }
#line 2684 "parser.tab.c"
    break;

  case 120: /* id_list: id_list TOKEN_COMMA simple_var_assign  */
#line 705 "parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[-2].treeNode;
                        TreeNode_t* pNode = yyvsp[0].treeNode->p_firstChild;
                        TreeNode_t* pNewNode;
                        NodeCreate(&pNewNode, NODE_VAR_DECLARATION);
                        pNewNode->nodeData.sVal = pNode->nodeData.sVal;
                        if (NodeAppendSibling(&pHead, pNewNode)) { YYERROR; }
                        if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                        yyval.treeNode = pHead;
                    }
#line 2699 "parser.tab.c"
    break;

  case 121: /* var_assignment: simple_var_assign TOKEN_SEMI  */
#line 718 "parser.y"
                    { yyval.treeNode = yyvsp[-1].treeNode; }
#line 2705 "parser.tab.c"
    break;

  case 122: /* var_assignment: compound_var_assign TOKEN_SEMI  */
#line 720 "parser.y"
                    { yyval.treeNode = yyvsp[-1].treeNode; }
#line 2711 "parser.tab.c"
    break;

  case 123: /* var_assignment: array_index TOKEN_ASSIGN exp TOKEN_SEMI  */
#line 722 "parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                        yyval.treeNode->nodeData.dVal = OP_ASSIGN;
                        NodeAddChild(yyval.treeNode, yyvsp[-3].treeNode);
                        NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                    }
#line 2722 "parser.tab.c"
    break;

  case 124: /* var_assignment: pointer_content TOKEN_ASSIGN exp TOKEN_SEMI  */
#line 729 "parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                        yyval.treeNode->nodeData.dVal = OP_ASSIGN;
                        NodeAddChild(yyval.treeNode, yyvsp[-3].treeNode);
                        NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                    }
#line 2733 "parser.tab.c"
    break;

  case 125: /* var_assignment: array_index compound_assign_operator exp TOKEN_SEMI  */
#line 736 "parser.y"
                    {
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-3].treeNode);
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-1].treeNode);
                        yyval.treeNode = yyvsp[-2].treeNode;
                    }
#line 2743 "parser.tab.c"
    break;

  case 126: /* var_assignment: factor TOKEN_DOT TOKEN_ID TOKEN_ASSIGN exp TOKEN_SEMI  */
#line 742 "parser.y"
    {
        NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
        yyval.treeNode->nodeData.dVal = OP_ASSIGN;
        TreeNode_t* pMember;
        NodeCreate(&pMember, NODE_IDENTIFIER);
        pMember->nodeData.sVal = yyvsp[-3].nodeData.sVal;
        NodeAddChild(yyval.treeNode, yyvsp[-5].treeNode);
        NodeAddChild(yyval.treeNode, pMember);
        NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
    }
#line 2758 "parser.tab.c"
    break;

  case 127: /* var_assignment: factor TOKEN_ARROW TOKEN_ID TOKEN_ASSIGN exp TOKEN_SEMI  */
#line 753 "parser.y"
    {
        NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
        yyval.treeNode->nodeData.dVal = OP_ASSIGN;
        TreeNode_t* pMember;
        NodeCreate(&pMember, NODE_IDENTIFIER);
        pMember->nodeData.sVal = yyvsp[-3].nodeData.sVal;
        NodeAddChild(yyval.treeNode, yyvsp[-5].treeNode);
        NodeAddChild(yyval.treeNode, pMember);
        NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
    }
#line 2773 "parser.tab.c"
    break;

  case 128: /* simple_var_assign: TOKEN_ID TOKEN_ASSIGN exp  */
#line 766 "parser.y"
                        {
                            TreeNode_t* pNode;
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_ASSIGN;
                            NodeAddNewChild(yyval.treeNode, &pNode, NODE_IDENTIFIER);
                            pNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                        }
#line 2786 "parser.tab.c"
    break;

  case 129: /* compound_var_assign: TOKEN_ID compound_assign_operator exp  */
#line 777 "parser.y"
                        {
                            TreeNode_t* pNode;
                            NodeAddNewChild(yyvsp[-1].treeNode, &pNode, NODE_IDENTIFIER);
                            pNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                            NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                            yyval.treeNode = yyvsp[-1].treeNode;
                        }
#line 2798 "parser.tab.c"
    break;

  case 130: /* var_preamble: storage_class_specifier type_qualifier sign_qualifier type_all_specifier  */
#line 787 "parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[0].treeNode;
                        NodeAppendSibling(&pHead, yyvsp[-3].treeNode);
                        NodeAppendSibling(&pHead, yyvsp[-2].treeNode);
                        NodeAppendSibling(&pHead, yyvsp[-1].treeNode);
                        yyval.treeNode = pHead;
                    }
#line 2810 "parser.tab.c"
    break;

  case 131: /* var_preamble: storage_class_specifier type_qualifier type_all_specifier  */
#line 795 "parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[0].treeNode;
                        NodeAppendSibling(&pHead, yyvsp[-2].treeNode);
                        NodeAppendSibling(&pHead, yyvsp[-1].treeNode);
                        yyval.treeNode = pHead;
                    }
#line 2821 "parser.tab.c"
    break;

  case 132: /* var_preamble: storage_class_specifier sign_qualifier type_all_specifier  */
#line 802 "parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[0].treeNode;
                        NodeAppendSibling(&pHead, yyvsp[-2].treeNode);
                        NodeAppendSibling(&pHead, yyvsp[-1].treeNode);
                        yyval.treeNode = pHead;
                    }
#line 2832 "parser.tab.c"
    break;

  case 133: /* var_preamble: type_qualifier sign_qualifier type_all_specifier  */
#line 809 "parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[0].treeNode;
                        NodeAppendSibling(&pHead, yyvsp[-2].treeNode);
                        NodeAppendSibling(&pHead, yyvsp[-1].treeNode);
                        yyval.treeNode = pHead;
                    }
#line 2843 "parser.tab.c"
    break;

  case 134: /* var_preamble: storage_class_specifier type_all_specifier  */
#line 816 "parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[0].treeNode;
                        NodeAppendSibling(&pHead, yyvsp[-1].treeNode);
                        yyval.treeNode = pHead;
                    }
#line 2853 "parser.tab.c"
    break;

  case 135: /* var_preamble: type_qualifier type_all_specifier  */
#line 822 "parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[0].treeNode;
                        NodeAppendSibling(&pHead, yyvsp[-1].treeNode);
                        yyval.treeNode = pHead;
                    }
#line 2863 "parser.tab.c"
    break;

  case 136: /* var_preamble: sign_qualifier type_all_specifier  */
#line 828 "parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[0].treeNode;
                        NodeAppendSibling(&pHead, yyvsp[-1].treeNode);
                        yyval.treeNode = pHead;
                    }
#line 2873 "parser.tab.c"
    break;

  case 137: /* var_preamble: type_all_specifier  */
#line 834 "parser.y"
                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 2879 "parser.tab.c"
    break;

  case 138: /* exp: TOKEN_MINUS exp  */
#line 843 "parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                    yyval.treeNode->nodeData.dVal = OP_MINUS;
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 2889 "parser.tab.c"
    break;

  case 139: /* exp: exp arithmetic_operator term  */
#line 849 "parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 2899 "parser.tab.c"
    break;

  case 140: /* exp: exp condition_operator term  */
#line 855 "parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 2909 "parser.tab.c"
    break;

  case 141: /* exp: exp bitwise_operator term  */
#line 861 "parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 2919 "parser.tab.c"
    break;

  case 142: /* exp: TOKEN_BITWISE_NOT term  */
#line 867 "parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                    yyval.treeNode->nodeData.dVal = OP_BITWISE_NOT;
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 2929 "parser.tab.c"
    break;

  case 143: /* exp: exp logic_operator term  */
#line 873 "parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 2939 "parser.tab.c"
    break;

  case 144: /* exp: exp TOKEN_TERNARY exp TOKEN_COLON exp  */
#line 879 "parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_TERNARY);
                    NodeAddChild(yyval.treeNode, yyvsp[-4].treeNode);
                    NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 2950 "parser.tab.c"
    break;

  case 145: /* exp: TOKEN_ID TOKEN_ASSIGN exp  */
#line 886 "parser.y"
                {
                    TreeNode_t* pNode;
                    NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                    yyval.treeNode->nodeData.dVal = OP_ASSIGN;
                    NodeAddNewChild(yyval.treeNode, &pNode, NODE_IDENTIFIER);
                    pNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 2963 "parser.tab.c"
    break;

  case 146: /* exp: term  */
#line 895 "parser.y"
                { yyval.treeNode = yyvsp[0].treeNode; }
#line 2969 "parser.tab.c"
    break;

  case 147: /* term: term priority_operator operand  */
#line 899 "parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 2979 "parser.tab.c"
    break;

  case 148: /* term: operand  */
#line 905 "parser.y"
                { yyval.treeNode = yyvsp[0].treeNode; }
#line 2985 "parser.tab.c"
    break;

  case 149: /* operand: inc_dec  */
#line 909 "parser.y"
                { yyval.treeNode = yyvsp[0].treeNode; }
#line 2991 "parser.tab.c"
    break;

  case 150: /* operand: TOKEN_LOGICAL_NOT factor  */
#line 911 "parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                    yyval.treeNode->nodeData.dVal = OP_LOGICAL_NOT;
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 3001 "parser.tab.c"
    break;

  case 151: /* operand: type_cast_specifier factor  */
#line 917 "parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 3010 "parser.tab.c"
    break;

  case 152: /* operand: factor  */
#line 922 "parser.y"
                { yyval.treeNode = yyvsp[0].treeNode; }
#line 3016 "parser.tab.c"
    break;

  case 153: /* factor: TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES  */
#line 926 "parser.y"
                { yyval.treeNode = yyvsp[-1].treeNode; }
#line 3022 "parser.tab.c"
    break;

  case 154: /* factor: array_index  */
#line 928 "parser.y"
                { yyval.treeNode = yyvsp[0].treeNode; }
#line 3028 "parser.tab.c"
    break;

  case 155: /* factor: TOKEN_MINUS TOKEN_NUM  */
#line 930 "parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_INTEGER);
                    yyval.treeNode->nodeData.dVal = -yyvsp[0].nodeData.dVal;
                }
#line 3037 "parser.tab.c"
    break;

  case 156: /* factor: TOKEN_NUM  */
#line 935 "parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_INTEGER);
                    yyval.treeNode->nodeData.dVal = yyvsp[0].nodeData.dVal;
                }
#line 3046 "parser.tab.c"
    break;

  case 157: /* factor: TOKEN_ID  */
#line 940 "parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_IDENTIFIER);
                    yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                }
#line 3055 "parser.tab.c"
    break;

  case 158: /* factor: pointer_content  */
#line 945 "parser.y"
                { yyval.treeNode = yyvsp[0].treeNode; }
#line 3061 "parser.tab.c"
    break;

  case 159: /* factor: TOKEN_MINUS TOKEN_FNUM  */
#line 947 "parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_FLOAT);
                    yyval.treeNode->nodeData.fVal = -yyvsp[0].nodeData.fVal;
                }
#line 3070 "parser.tab.c"
    break;

  case 160: /* factor: TOKEN_FNUM  */
#line 952 "parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_FLOAT);
                    yyval.treeNode->nodeData.fVal = yyvsp[0].nodeData.fVal;
                }
#line 3079 "parser.tab.c"
    break;

  case 161: /* factor: TOKEN_CNUM  */
#line 957 "parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_CHAR);
                    yyval.treeNode->nodeData.dVal = yyvsp[0].nodeData.dVal;
                }
#line 3088 "parser.tab.c"
    break;

  case 162: /* factor: TOKEN_STR  */
#line 962 "parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_STRING);
                    yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                }
#line 3097 "parser.tab.c"
    break;

  case 163: /* factor: TOKEN_BITWISE_AND array_index  */
#line 967 "parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_REFERENCE);
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 3106 "parser.tab.c"
    break;

  case 164: /* factor: TOKEN_BITWISE_AND TOKEN_ID  */
#line 972 "parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_REFERENCE);
                    yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                }
#line 3115 "parser.tab.c"
    break;

  case 165: /* factor: TOKEN_SIZEOF TOKEN_LEFT_PARENTHESES sizeof_operand TOKEN_RIGHT_PARENTHESES  */
#line 977 "parser.y"
    {
        NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
        yyval.treeNode->nodeData.dVal = OP_SIZEOF;
        NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
    }
#line 3125 "parser.tab.c"
    break;

  case 166: /* factor: func_call  */
#line 983 "parser.y"
                { yyval.treeNode = yyvsp[0].treeNode; }
#line 3131 "parser.tab.c"
    break;

  case 167: /* factor: factor TOKEN_DOT TOKEN_ID  */
#line 985 "parser.y"
    {
        NodeCreate(&(yyval.treeNode), NODE_IDENTIFIER);
        yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
    }
#line 3141 "parser.tab.c"
    break;

  case 168: /* factor: factor TOKEN_ARROW TOKEN_ID  */
#line 991 "parser.y"
    {
        NodeCreate(&(yyval.treeNode), NODE_IDENTIFIER);
        yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
    }
#line 3151 "parser.tab.c"
    break;

  case 169: /* sizeof_operand: data_type_specifier  */
#line 999 "parser.y"
                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 3157 "parser.tab.c"
    break;

  case 170: /* sizeof_operand: exp  */
#line 1001 "parser.y"
                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 3163 "parser.tab.c"
    break;

  case 171: /* array_index: TOKEN_ID TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET  */
#line 1006 "parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_ARRAY_INDEX);
                    yyval.treeNode->nodeData.sVal = yyvsp[-3].nodeData.sVal;
                    NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                }
#line 3173 "parser.tab.c"
    break;

  case 172: /* array_index: array_index TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET  */
#line 1012 "parser.y"
                {
                    NodeAddChild(yyvsp[-3].treeNode, yyvsp[-1].treeNode);
                    yyval.treeNode = yyvsp[-3].treeNode;
                }
#line 3182 "parser.tab.c"
    break;

  case 173: /* pointer_content: TOKEN_ASTERISK TOKEN_ID  */
#line 1019 "parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_POINTER_CONTENT);
                        yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                    }
#line 3191 "parser.tab.c"
    break;

  case 174: /* pointer_content: TOKEN_ASTERISK TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES  */
#line 1024 "parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_POINTER_CONTENT);
                        NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                    }
#line 3200 "parser.tab.c"
    break;

  case 175: /* inc_dec: pre_increment  */
#line 1035 "parser.y"
                                { yyval.treeNode = yyvsp[0].treeNode; }
#line 3206 "parser.tab.c"
    break;

  case 176: /* inc_dec: post_increment  */
#line 1036 "parser.y"
                                { yyval.treeNode = yyvsp[0].treeNode; }
#line 3212 "parser.tab.c"
    break;

  case 177: /* inc_dec: pre_decrement  */
#line 1037 "parser.y"
                                { yyval.treeNode = yyvsp[0].treeNode; }
#line 3218 "parser.tab.c"
    break;

  case 178: /* inc_dec: post_decrement  */
#line 1038 "parser.y"
                                { yyval.treeNode = yyvsp[0].treeNode; }
#line 3224 "parser.tab.c"
    break;

  case 179: /* pre_increment: TOKEN_INCREMENT TOKEN_ID  */
#line 1042 "parser.y"
                    { NodeCreate(&(yyval.treeNode), NODE_PRE_INC); yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal; }
#line 3230 "parser.tab.c"
    break;

  case 180: /* post_increment: TOKEN_ID TOKEN_INCREMENT  */
#line 1046 "parser.y"
                    { NodeCreate(&(yyval.treeNode), NODE_POST_INC); yyval.treeNode->nodeData.sVal = yyvsp[-1].nodeData.sVal; }
#line 3236 "parser.tab.c"
    break;

  case 181: /* pre_decrement: TOKEN_DECREMENT TOKEN_ID  */
#line 1050 "parser.y"
                    { NodeCreate(&(yyval.treeNode), NODE_PRE_DEC); yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal; }
#line 3242 "parser.tab.c"
    break;

  case 182: /* post_decrement: TOKEN_ID TOKEN_DECREMENT  */
#line 1054 "parser.y"
                    { NodeCreate(&(yyval.treeNode), NODE_POST_DEC); yyval.treeNode->nodeData.sVal = yyvsp[-1].nodeData.sVal; }
#line 3248 "parser.tab.c"
    break;

  case 183: /* arithmetic_operator: TOKEN_PLUS  */
#line 1062 "parser.y"
                                        { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_PLUS; }
#line 3254 "parser.tab.c"
    break;

  case 184: /* arithmetic_operator: TOKEN_MINUS  */
#line 1063 "parser.y"
                                        { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_MINUS; }
#line 3260 "parser.tab.c"
    break;

  case 185: /* arithmetic_operator: TOKEN_RIGHT_SHIFT  */
#line 1064 "parser.y"
                                          { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_RIGHT_SHIFT; }
#line 3266 "parser.tab.c"
    break;

  case 186: /* arithmetic_operator: TOKEN_LEFT_SHIFT  */
#line 1065 "parser.y"
                                          { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_LEFT_SHIFT; }
#line 3272 "parser.tab.c"
    break;

  case 187: /* priority_operator: TOKEN_ASTERISK  */
#line 1068 "parser.y"
                                        { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_MULTIPLY; }
#line 3278 "parser.tab.c"
    break;

  case 188: /* priority_operator: TOKEN_OVER  */
#line 1069 "parser.y"
                                        { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_DIVIDE; }
#line 3284 "parser.tab.c"
    break;

  case 189: /* priority_operator: TOKEN_PERCENT  */
#line 1070 "parser.y"
                                        { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_REMAIN; }
#line 3290 "parser.tab.c"
    break;

  case 190: /* condition_operator: TOKEN_GREATER_THAN  */
#line 1073 "parser.y"
                                                    { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_GREATER_THAN; }
#line 3296 "parser.tab.c"
    break;

  case 191: /* condition_operator: TOKEN_LESS_THAN_OR_EQUAL  */
#line 1074 "parser.y"
                                                     { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_LESS_THAN_OR_EQUAL; }
#line 3302 "parser.tab.c"
    break;

  case 192: /* condition_operator: TOKEN_GREATER_THAN_OR_EQUAL  */
#line 1075 "parser.y"
                                                     { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_GREATER_THAN_OR_EQUAL; }
#line 3308 "parser.tab.c"
    break;

  case 193: /* condition_operator: TOKEN_LESS_THAN  */
#line 1076 "parser.y"
                                                     { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_LESS_THAN; }
#line 3314 "parser.tab.c"
    break;

  case 194: /* condition_operator: TOKEN_EQUAL  */
#line 1077 "parser.y"
                                                     { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_EQUAL; }
#line 3320 "parser.tab.c"
    break;

  case 195: /* condition_operator: TOKEN_NOT_EQUAL  */
#line 1078 "parser.y"
                                                     { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_NOT_EQUAL; }
#line 3326 "parser.tab.c"
    break;

  case 196: /* logic_operator: TOKEN_LOGICAL_AND  */
#line 1081 "parser.y"
                                            { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_LOGICAL_AND; }
#line 3332 "parser.tab.c"
    break;

  case 197: /* logic_operator: TOKEN_LOGICAL_OR  */
#line 1082 "parser.y"
                                            { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_LOGICAL_OR; }
#line 3338 "parser.tab.c"
    break;

  case 198: /* bitwise_operator: TOKEN_BITWISE_AND  */
#line 1085 "parser.y"
                                            { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_BITWISE_AND; }
#line 3344 "parser.tab.c"
    break;

  case 199: /* bitwise_operator: TOKEN_BITWISE_OR  */
#line 1086 "parser.y"
                                            { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_BITWISE_OR; }
#line 3350 "parser.tab.c"
    break;

  case 200: /* bitwise_operator: TOKEN_BITWISE_XOR  */
#line 1087 "parser.y"
                                            { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_BITWISE_XOR; }
#line 3356 "parser.tab.c"
    break;

  case 201: /* compound_assign_operator: TOKEN_PLUS_ASSIGN  */
#line 1090 "parser.y"
                                                        { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_PLUS_ASSIGN; }
#line 3362 "parser.tab.c"
    break;

  case 202: /* compound_assign_operator: TOKEN_MINUS_ASSIGN  */
#line 1091 "parser.y"
                                                        { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_MINUS_ASSIGN; }
#line 3368 "parser.tab.c"
    break;

  case 203: /* compound_assign_operator: TOKEN_MODULUS_ASSIGN  */
#line 1092 "parser.y"
                                                        { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_MODULUS_ASSIGN; }
#line 3374 "parser.tab.c"
    break;

  case 204: /* compound_assign_operator: TOKEN_LEFT_SHIFT_ASSIGN  */
#line 1093 "parser.y"
                                                        { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_LEFT_SHIFT_ASSIGN; }
#line 3380 "parser.tab.c"
    break;

  case 205: /* compound_assign_operator: TOKEN_RIGHT_SHIFT_ASSIGN  */
#line 1094 "parser.y"
                                                         { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_RIGHT_SHIFT_ASSIGN; }
#line 3386 "parser.tab.c"
    break;

  case 206: /* compound_assign_operator: TOKEN_AND_ASSIGN  */
#line 1095 "parser.y"
                                                        { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_BITWISE_AND_ASSIGN; }
#line 3392 "parser.tab.c"
    break;

  case 207: /* compound_assign_operator: TOKEN_OR_ASSIGN  */
#line 1096 "parser.y"
                                                        { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_BITWISE_OR_ASSIGN; }
#line 3398 "parser.tab.c"
    break;

  case 208: /* compound_assign_operator: TOKEN_XOR_ASSIGN  */
#line 1097 "parser.y"
                                                        { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_BITWISE_XOR_ASSIGN; }
#line 3404 "parser.tab.c"
    break;

  case 209: /* compound_assign_operator: TOKEN_MULTIPLY_ASSIGN  */
#line 1098 "parser.y"
                                                        { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_MULTIPLY_ASSIGN; }
#line 3410 "parser.tab.c"
    break;

  case 210: /* compound_assign_operator: TOKEN_DIVIDE_ASSIGN  */
#line 1099 "parser.y"
                                                        { NodeCreate(&(yyval.treeNode), NODE_OPERATOR); yyval.treeNode->nodeData.dVal = OP_DIVIDE_ASSIGN; }
#line 3416 "parser.tab.c"
    break;


#line 3420 "parser.tab.c"

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

#line 1106 "parser.y"


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
