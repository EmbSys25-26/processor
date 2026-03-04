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

#include <stdio.h>
#include <string.h>
#include "ASTree.h"
#include "../Util/NodeTypes.h"
#include "../Util/logger.h"
#include "ASTPrint.h"

int yylex(void);
void yyerror(const char *s);
extern FILE* yyin; 

static TreeNode_t* p_treeRoot = NULL;
static char* currentFunction = NULL;

#line 87 "Parser/parser.tab.c"

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
  YYSYMBOL_TOKEN_PP_DEFINE = 37,           /* TOKEN_PP_DEFINE  */
  YYSYMBOL_TOKEN_PP_UNDEF = 38,            /* TOKEN_PP_UNDEF  */
  YYSYMBOL_TOKEN_PLUS = 39,                /* TOKEN_PLUS  */
  YYSYMBOL_TOKEN_MINUS = 40,               /* TOKEN_MINUS  */
  YYSYMBOL_TOKEN_ASTERISK = 41,            /* TOKEN_ASTERISK  */
  YYSYMBOL_TOKEN_DIVIDE = 42,              /* TOKEN_DIVIDE  */
  YYSYMBOL_TOKEN_MOD = 43,                 /* TOKEN_MOD  */
  YYSYMBOL_TOKEN_INCREMENT = 44,           /* TOKEN_INCREMENT  */
  YYSYMBOL_TOKEN_DECREMENT = 45,           /* TOKEN_DECREMENT  */
  YYSYMBOL_TOKEN_ASSIGN = 46,              /* TOKEN_ASSIGN  */
  YYSYMBOL_TOKEN_PLUS_ASSIGN = 47,         /* TOKEN_PLUS_ASSIGN  */
  YYSYMBOL_TOKEN_MINUS_ASSIGN = 48,        /* TOKEN_MINUS_ASSIGN  */
  YYSYMBOL_TOKEN_MULTIPLY_ASSIGN = 49,     /* TOKEN_MULTIPLY_ASSIGN  */
  YYSYMBOL_TOKEN_DIVIDE_ASSIGN = 50,       /* TOKEN_DIVIDE_ASSIGN  */
  YYSYMBOL_TOKEN_MODULUS_ASSIGN = 51,      /* TOKEN_MODULUS_ASSIGN  */
  YYSYMBOL_TOKEN_AND_ASSIGN = 52,          /* TOKEN_AND_ASSIGN  */
  YYSYMBOL_TOKEN_OR_ASSIGN = 53,           /* TOKEN_OR_ASSIGN  */
  YYSYMBOL_TOKEN_XOR_ASSIGN = 54,          /* TOKEN_XOR_ASSIGN  */
  YYSYMBOL_TOKEN_LEFT_SHIFT_ASSIGN = 55,   /* TOKEN_LEFT_SHIFT_ASSIGN  */
  YYSYMBOL_TOKEN_RIGHT_SHIFT_ASSIGN = 56,  /* TOKEN_RIGHT_SHIFT_ASSIGN  */
  YYSYMBOL_TOKEN_EQUAL = 57,               /* TOKEN_EQUAL  */
  YYSYMBOL_TOKEN_NOT_EQUAL = 58,           /* TOKEN_NOT_EQUAL  */
  YYSYMBOL_TOKEN_LESS_THAN = 59,           /* TOKEN_LESS_THAN  */
  YYSYMBOL_TOKEN_GREATER_THAN = 60,        /* TOKEN_GREATER_THAN  */
  YYSYMBOL_TOKEN_LESS_THAN_OR_EQUAL = 61,  /* TOKEN_LESS_THAN_OR_EQUAL  */
  YYSYMBOL_TOKEN_GREATER_THAN_OR_EQUAL = 62, /* TOKEN_GREATER_THAN_OR_EQUAL  */
  YYSYMBOL_TOKEN_LOGICAL_AND = 63,         /* TOKEN_LOGICAL_AND  */
  YYSYMBOL_TOKEN_LOGICAL_OR = 64,          /* TOKEN_LOGICAL_OR  */
  YYSYMBOL_TOKEN_LOGICAL_NOT = 65,         /* TOKEN_LOGICAL_NOT  */
  YYSYMBOL_TOKEN_BITWISE_AND = 66,         /* TOKEN_BITWISE_AND  */
  YYSYMBOL_TOKEN_BITWISE_OR = 67,          /* TOKEN_BITWISE_OR  */
  YYSYMBOL_TOKEN_BITWISE_XOR = 68,         /* TOKEN_BITWISE_XOR  */
  YYSYMBOL_TOKEN_BITWISE_NOT = 69,         /* TOKEN_BITWISE_NOT  */
  YYSYMBOL_TOKEN_LEFT_SHIFT = 70,          /* TOKEN_LEFT_SHIFT  */
  YYSYMBOL_TOKEN_RIGHT_SHIFT = 71,         /* TOKEN_RIGHT_SHIFT  */
  YYSYMBOL_TOKEN_ARROW = 72,               /* TOKEN_ARROW  */
  YYSYMBOL_TOKEN_ELLIPSIS = 73,            /* TOKEN_ELLIPSIS  */
  YYSYMBOL_TOKEN_DOT = 74,                 /* TOKEN_DOT  */
  YYSYMBOL_TOKEN_SEMI = 75,                /* TOKEN_SEMI  */
  YYSYMBOL_TOKEN_COMMA = 76,               /* TOKEN_COMMA  */
  YYSYMBOL_TOKEN_COLON = 77,               /* TOKEN_COLON  */
  YYSYMBOL_TOKEN_TERNARY = 78,             /* TOKEN_TERNARY  */
  YYSYMBOL_TOKEN_LEFT_PARENTHESES = 79,    /* TOKEN_LEFT_PARENTHESES  */
  YYSYMBOL_TOKEN_RIGHT_PARENTHESES = 80,   /* TOKEN_RIGHT_PARENTHESES  */
  YYSYMBOL_TOKEN_LEFT_BRACE = 81,          /* TOKEN_LEFT_BRACE  */
  YYSYMBOL_TOKEN_RIGHT_BRACE = 82,         /* TOKEN_RIGHT_BRACE  */
  YYSYMBOL_TOKEN_LEFT_BRACKET = 83,        /* TOKEN_LEFT_BRACKET  */
  YYSYMBOL_TOKEN_RIGHT_BRACKET = 84,       /* TOKEN_RIGHT_BRACKET  */
  YYSYMBOL_TOKEN_EOF = 85,                 /* TOKEN_EOF  */
  YYSYMBOL_TOKEN_ERROR = 86,               /* TOKEN_ERROR  */
  YYSYMBOL_LOWER_THAN_ELSE = 87,           /* LOWER_THAN_ELSE  */
  YYSYMBOL_UNARY = 88,                     /* UNARY  */
  YYSYMBOL_YYACCEPT = 89,                  /* $accept  */
  YYSYMBOL_program = 90,                   /* program  */
  YYSYMBOL_global_statement = 91,          /* global_statement  */
  YYSYMBOL_local_statement_list = 92,      /* local_statement_list  */
  YYSYMBOL_local_statement = 93,           /* local_statement  */
  YYSYMBOL_selection_statement = 94,       /* selection_statement  */
  YYSYMBOL_jump_statement = 95,            /* jump_statement  */
  YYSYMBOL_iteration_statement = 96,       /* iteration_statement  */
  YYSYMBOL_type_declaration = 97,          /* type_declaration  */
  YYSYMBOL_compound_statement = 98,        /* compound_statement  */
  YYSYMBOL_enum_declaration = 99,          /* enum_declaration  */
  YYSYMBOL_enum_member_list = 100,         /* enum_member_list  */
  YYSYMBOL_enum_member = 101,              /* enum_member  */
  YYSYMBOL_struct_declaration = 102,       /* struct_declaration  */
  YYSYMBOL_union_declaration = 103,        /* union_declaration  */
  YYSYMBOL_struct_member_list = 104,       /* struct_member_list  */
  YYSYMBOL_struct_member = 105,            /* struct_member  */
  YYSYMBOL_if_statement = 106,             /* if_statement  */
  YYSYMBOL_switch_statement = 107,         /* switch_statement  */
  YYSYMBOL_switch_body = 108,              /* switch_body  */
  YYSYMBOL_case_list = 109,                /* case_list  */
  YYSYMBOL_case_clause = 110,              /* case_clause  */
  YYSYMBOL_default_clause = 111,           /* default_clause  */
  YYSYMBOL_continue_statement = 112,       /* continue_statement  */
  YYSYMBOL_break_statement = 113,          /* break_statement  */
  YYSYMBOL_return_statement = 114,         /* return_statement  */
  YYSYMBOL_while_loop = 115,               /* while_loop  */
  YYSYMBOL_do_while_loop = 116,            /* do_while_loop  */
  YYSYMBOL_for_loop = 117,                 /* for_loop  */
  YYSYMBOL_for_init_field = 118,           /* for_init_field  */
  YYSYMBOL_for_condition = 119,            /* for_condition  */
  YYSYMBOL_for_assignment_field = 120,     /* for_assignment_field  */
  YYSYMBOL_simple_var_assign = 121,        /* simple_var_assign  */
  YYSYMBOL_compound_var_assign = 122,      /* compound_var_assign  */
  YYSYMBOL_function_prototype = 123,       /* function_prototype  */
  YYSYMBOL_function_definition = 124,      /* function_definition  */
  YYSYMBOL_function_signature = 125,       /* function_signature  */
  YYSYMBOL_param_declaration = 126,        /* param_declaration  */
  YYSYMBOL_arg_list = 127,                 /* arg_list  */
  YYSYMBOL_func_call = 128,                /* func_call  */
  YYSYMBOL_exp_list = 129,                 /* exp_list  */
  YYSYMBOL_type_cast_specifier = 130,      /* type_cast_specifier  */
  YYSYMBOL_all_type_specifiers = 131,      /* all_type_specifiers  */
  YYSYMBOL_type_pointer = 132,             /* type_pointer  */
  YYSYMBOL_data_type_specifier = 133,      /* data_type_specifier  */
  YYSYMBOL_visibility_qualifier = 134,     /* visibility_qualifier  */
  YYSYMBOL_mod_qualifier = 135,            /* mod_qualifier  */
  YYSYMBOL_sign_qualifier = 136,           /* sign_qualifier  */
  YYSYMBOL_var_declaration = 137,          /* var_declaration  */
  YYSYMBOL_arr_size = 138,                 /* arr_size  */
  YYSYMBOL_id_list = 139,                  /* id_list  */
  YYSYMBOL_var_preamble = 140,             /* var_preamble  */
  YYSYMBOL_var_assignment = 141,           /* var_assignment  */
  YYSYMBOL_exp = 142,                      /* exp  */
  YYSYMBOL_term = 143,                     /* term  */
  YYSYMBOL_operand = 144,                  /* operand  */
  YYSYMBOL_factor = 145,                   /* factor  */
  YYSYMBOL_sizeof_operand = 146,           /* sizeof_operand  */
  YYSYMBOL_array_access = 147,             /* array_access  */
  YYSYMBOL_pointer_content = 148,          /* pointer_content  */
  YYSYMBOL_priority_operator = 149,        /* priority_operator  */
  YYSYMBOL_arithmetic_operator = 150,      /* arithmetic_operator  */
  YYSYMBOL_comparison_operator = 151,      /* comparison_operator  */
  YYSYMBOL_bitwise_operator = 152,         /* bitwise_operator  */
  YYSYMBOL_logic_operator = 153,           /* logic_operator  */
  YYSYMBOL_compound_assign_operator = 154  /* compound_assign_operator  */
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
#define YYFINAL  23
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   1463

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  89
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  66
/* YYNRULES -- Number of rules.  */
#define YYNRULES  208
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  352

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   343


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
      85,    86,    87,    88
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,   120,   120,   126,   134,   141,   142,   143,   144,   146,
     150,   151,   165,   166,   167,   168,   169,   170,   171,   172,
     173,   179,   180,   183,   184,   185,   188,   189,   190,   193,
     194,   195,   198,   216,   225,   233,   235,   241,   245,   250,
     259,   271,   280,   289,   291,   300,   306,   319,   325,   334,
     342,   348,   352,   358,   362,   370,   377,   383,   391,   402,
     406,   410,   415,   427,   436,   444,   474,   475,   484,   498,
     505,   506,   509,   510,   511,   512,   515,   526,   540,   546,
     554,   564,   572,   580,   588,   591,   600,   606,   610,   619,
     623,   629,   641,   649,   650,   653,   658,   666,   671,   676,
     681,   686,   691,   696,   701,   705,   710,   715,   720,   729,
     738,   749,   750,   755,   760,   767,   768,   773,   780,   781,
     786,   799,   815,   817,   819,   829,   834,   847,   853,   862,
     873,   887,   911,   913,   915,   922,   929,   935,   946,   957,
     963,   973,   990,   996,  1002,  1008,  1014,  1030,  1037,  1043,
    1048,  1054,  1059,  1064,  1070,  1076,  1081,  1088,  1092,  1096,
    1101,  1106,  1108,  1113,  1118,  1123,  1128,  1133,  1139,  1141,
    1146,  1151,  1157,  1166,  1168,  1173,  1179,  1186,  1191,  1196,
    1201,  1212,  1217,  1222,  1229,  1234,  1239,  1244,  1251,  1256,
    1261,  1266,  1271,  1276,  1283,  1288,  1293,  1300,  1305,  1312,
    1317,  1322,  1327,  1332,  1337,  1342,  1347,  1352,  1357
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
  "TOKEN_CONTINUE", "TOKEN_RETURN", "TOKEN_PP_DEFINE", "TOKEN_PP_UNDEF",
  "TOKEN_PLUS", "TOKEN_MINUS", "TOKEN_ASTERISK", "TOKEN_DIVIDE",
  "TOKEN_MOD", "TOKEN_INCREMENT", "TOKEN_DECREMENT", "TOKEN_ASSIGN",
  "TOKEN_PLUS_ASSIGN", "TOKEN_MINUS_ASSIGN", "TOKEN_MULTIPLY_ASSIGN",
  "TOKEN_DIVIDE_ASSIGN", "TOKEN_MODULUS_ASSIGN", "TOKEN_AND_ASSIGN",
  "TOKEN_OR_ASSIGN", "TOKEN_XOR_ASSIGN", "TOKEN_LEFT_SHIFT_ASSIGN",
  "TOKEN_RIGHT_SHIFT_ASSIGN", "TOKEN_EQUAL", "TOKEN_NOT_EQUAL",
  "TOKEN_LESS_THAN", "TOKEN_GREATER_THAN", "TOKEN_LESS_THAN_OR_EQUAL",
  "TOKEN_GREATER_THAN_OR_EQUAL", "TOKEN_LOGICAL_AND", "TOKEN_LOGICAL_OR",
  "TOKEN_LOGICAL_NOT", "TOKEN_BITWISE_AND", "TOKEN_BITWISE_OR",
  "TOKEN_BITWISE_XOR", "TOKEN_BITWISE_NOT", "TOKEN_LEFT_SHIFT",
  "TOKEN_RIGHT_SHIFT", "TOKEN_ARROW", "TOKEN_ELLIPSIS", "TOKEN_DOT",
  "TOKEN_SEMI", "TOKEN_COMMA", "TOKEN_COLON", "TOKEN_TERNARY",
  "TOKEN_LEFT_PARENTHESES", "TOKEN_RIGHT_PARENTHESES", "TOKEN_LEFT_BRACE",
  "TOKEN_RIGHT_BRACE", "TOKEN_LEFT_BRACKET", "TOKEN_RIGHT_BRACKET",
  "TOKEN_EOF", "TOKEN_ERROR", "LOWER_THAN_ELSE", "UNARY", "$accept",
  "program", "global_statement", "local_statement_list", "local_statement",
  "selection_statement", "jump_statement", "iteration_statement",
  "type_declaration", "compound_statement", "enum_declaration",
  "enum_member_list", "enum_member", "struct_declaration",
  "union_declaration", "struct_member_list", "struct_member",
  "if_statement", "switch_statement", "switch_body", "case_list",
  "case_clause", "default_clause", "continue_statement", "break_statement",
  "return_statement", "while_loop", "do_while_loop", "for_loop",
  "for_init_field", "for_condition", "for_assignment_field",
  "simple_var_assign", "compound_var_assign", "function_prototype",
  "function_definition", "function_signature", "param_declaration",
  "arg_list", "func_call", "exp_list", "type_cast_specifier",
  "all_type_specifiers", "type_pointer", "data_type_specifier",
  "visibility_qualifier", "mod_qualifier", "sign_qualifier",
  "var_declaration", "arr_size", "id_list", "var_preamble",
  "var_assignment", "exp", "term", "operand", "factor", "sizeof_operand",
  "array_access", "pointer_content", "priority_operator",
  "arithmetic_operator", "comparison_operator", "bitwise_operator",
  "logic_operator", "compound_assign_operator", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-240)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-85)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
     137,  -240,  -240,  -240,    34,    46,    75,  -240,    37,  -240,
    -240,  -240,  -240,  -240,  -240,  -240,   121,   145,  -240,    92,
      98,   116,   138,  -240,  -240,  -240,  -240,    59,  -240,  -240,
    -240,   186,   -36,   132,   167,   167,   109,  -240,   529,  -240,
    -240,   283,   712,    78,    83,   -21,  -240,   196,    33,  -240,
     213,    55,   175,   122,  -240,  -240,  -240,  -240,  -240,   332,
     144,   146,   147,   149,   150,   663,   157,   158,   680,   712,
      13,   712,   712,    60,   217,   712,   165,  -240,  -240,  -240,
    -240,  -240,  -240,  -240,  -240,  -240,  -240,  -240,  -240,  -240,
    -240,   160,   161,  -240,   156,   163,    60,  -240,  -240,  1077,
     173,  -240,    35,   396,   463,  -240,  -240,  -240,  -240,  -240,
      20,   231,   233,   234,   235,  -240,   202,   204,    -2,  -240,
     586,   139,   164,  -240,  -240,    38,   241,  -240,   746,   712,
     -14,  -240,   174,  -240,   -53,   178,    31,   109,   180,   712,
    -240,  -240,  -240,  -240,  -240,  -240,  -240,  -240,  -240,  -240,
     712,   712,   712,   165,   712,   712,    65,   712,   218,  -240,
    -240,  -240,  1110,  -240,   176,   712,   164,  -240,  -240,  -240,
     712,   139,   176,   164,  -240,   182,   879,  -240,  -240,  -240,
     139,  -240,  -240,  -240,  -240,  -240,  -240,  -240,  -240,  -240,
    -240,  -240,  -240,  -240,  -240,  -240,  -240,   712,   712,   712,
     712,   712,  -240,  -240,  -240,   712,  -240,  -240,   249,   253,
     712,   712,   712,   712,   712,  -240,  -240,  -240,  -240,  -240,
    -240,  -240,  -240,  -240,   258,   259,    57,  -240,   187,  -240,
     780,   -21,  -240,  -240,   -35,  -240,  -240,   269,  -240,  -240,
     586,    77,   586,   813,   586,  -240,   586,   199,   912,   945,
     236,   206,   276,   978,   207,  -240,  1011,  -240,  -240,   519,
     173,   173,   173,   173,  -240,   719,  1407,  1143,   846,  1176,
    1209,  1242,  -240,  -240,  -240,  -240,   -21,  -240,  -240,  -240,
     712,  -240,  -240,  -240,   663,   216,   712,   712,   242,   663,
     712,  -240,   712,   712,   712,   712,   712,  -240,  -240,  -240,
    -240,  -240,   586,   260,   188,   586,   223,   586,   712,  -240,
    1044,   586,  1275,  1308,  1341,  1374,   663,    95,   224,   220,
     188,  -240,  -240,   757,   586,   228,  -240,  -240,  -240,  -240,
    -240,   248,   261,   262,  -240,  -240,  -240,  -240,   239,  -240,
    -240,   586,  -240,  -240,  -240,  -240,   596,   663,   328,   395,
     462,  -240
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
     111,   114,   112,   113,     0,     0,     0,     9,   111,     4,
       5,    29,    30,    31,     7,     8,     0,   115,     6,     0,
       0,     0,     0,     1,     2,     3,    78,    10,    79,   116,
     117,   118,   125,     0,   111,   111,     0,    33,   111,   119,
     120,     0,     0,   111,     0,   127,   121,     0,   111,    43,
       0,   111,    38,     0,    35,   159,   162,   163,   164,   160,
       0,     0,     0,     0,     0,   111,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    32,    11,    12,
      14,    13,    15,    21,    22,    25,    23,    24,    27,    26,
      28,     0,     0,    19,     0,   168,     0,    16,    17,     0,
     147,   149,   156,   158,   161,    99,    97,   104,   105,   107,
     100,    98,     0,     0,     0,   131,    94,    93,   160,   168,
     126,   156,   158,   161,    87,     0,    83,   123,     0,     0,
     128,   130,     0,    44,     0,     0,     0,    37,     0,     0,
     199,   200,   207,   208,   201,   204,   205,   206,   202,   203,
      89,     0,     0,     0,     0,     0,   111,     0,     0,    60,
      59,    61,     0,   150,   178,     0,   179,   177,   151,   152,
       0,   153,   166,   165,   154,     0,     0,   132,   133,    18,
     155,   184,   185,   188,   189,   193,   190,   191,   192,   197,
     198,   194,   195,   196,   187,   186,    20,     0,     0,     0,
       0,     0,   181,   182,   183,     0,   169,   170,     0,     0,
       0,     0,     0,     0,     0,   102,   106,   101,   103,   108,
     109,   110,    96,    95,     0,     0,   111,    80,    81,   122,
       0,   129,    41,    45,     0,    42,    39,     0,    36,    34,
      76,     0,    91,     0,    77,   173,   174,     0,     0,     0,
       0,     0,     0,     0,     0,    62,     0,    92,   157,     0,
     142,   143,   144,   145,   148,   172,   171,     0,     0,     0,
       0,     0,   172,   171,    85,    86,    82,   124,    46,    40,
       0,    88,   175,   167,   111,     0,     0,    70,    69,   111,
       0,   180,     0,     0,     0,     0,     0,   134,   176,   136,
     135,   139,    90,    47,     0,    67,     0,    71,     0,    63,
       0,   146,     0,     0,     0,     0,   111,     0,     0,     0,
      51,    53,    52,    72,    68,     0,   138,   141,   137,   140,
      48,     0,     0,     0,    10,    49,    54,    50,     0,    73,
      74,    75,    64,    10,    10,    10,   111,   111,   111,   111,
     111,    65
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -240,  -240,   305,  -239,   -62,  -240,  -240,  -240,  -240,    -1,
    -240,  -240,   200,  -240,  -240,   301,   -22,  -240,  -240,  -240,
    -240,    22,    23,  -240,  -240,  -240,  -240,  -240,  -240,  -240,
    -240,  -240,   -43,    17,  -240,   111,   113,   118,  -240,   -20,
    -240,  -240,   -59,  -240,  -240,  -240,  -240,  -240,   117,  -125,
    -240,   -27,  -240,   -19,   -56,   -58,   -38,  -240,   -32,   -26,
    -240,  -240,  -240,  -240,  -240,  -102
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,     8,     9,    38,    78,    79,    80,    81,    10,    82,
      11,    53,    54,    12,    13,    48,    49,    83,    84,   319,
     320,   321,   322,    85,    86,    87,    88,    89,    90,   251,
     306,   338,    91,    92,    14,    93,    94,   124,   125,   119,
     241,    96,   115,   116,   117,    17,    31,    41,    97,    45,
      33,    19,    98,    99,   100,   101,   121,   247,   122,   123,
     205,   198,   199,   200,   201,   152
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
     102,   212,   214,   158,   131,   231,   103,    50,    50,   234,
      42,   163,   104,   168,   169,    28,   126,   175,    95,   174,
     164,    50,   233,   120,    50,   128,   133,   102,   215,   133,
      44,   216,   139,   103,   236,   171,   217,    23,   166,   104,
     278,    20,   173,    43,   167,    95,     1,    44,   129,   162,
       1,     2,     3,    21,    70,     2,     3,   176,   180,     4,
       5,     6,   129,    55,    56,    57,    58,   118,     1,    44,
       1,   237,   250,     2,     3,     2,     3,   150,     1,   206,
     207,   151,    22,     2,     3,    60,    55,    56,    57,    58,
     118,     1,   165,    28,   245,   346,     2,     3,   331,    32,
     332,    70,   333,   276,   348,   349,   350,   208,    60,   209,
     230,    15,     7,    16,   226,   132,    52,    18,   227,    15,
     240,    16,    24,    69,    70,    18,    74,    71,    72,   252,
     274,   242,   243,   244,   246,   248,   249,   135,   253,   170,
     -66,    37,   260,   261,   262,   263,   256,   264,    73,    74,
       1,   176,    75,   280,   -84,     2,     3,   281,   -84,     4,
       5,     6,    76,   294,   296,    29,    30,   127,    55,    56,
      57,    58,   118,   105,   106,   107,   108,   109,   259,    34,
       1,   110,   111,   206,   207,     2,     3,   112,   113,   114,
      60,   267,   268,   269,   270,   271,    26,    35,   137,   126,
      39,    40,    27,   130,   138,    69,    70,    46,    47,    71,
      72,   224,     7,   225,   202,   203,   204,   317,   318,    36,
     134,   136,   303,   153,   172,   154,   155,   309,   156,   157,
      73,    74,   159,   160,    75,   177,   178,    27,   179,   218,
     219,   220,   221,   222,    76,   223,   102,   211,   228,   232,
     254,   102,   103,   235,   330,   239,   265,   103,   104,   151,
     266,   302,   257,   104,    95,   272,   273,   305,   307,    95,
      44,   310,   279,   311,   312,   313,   314,   315,   102,   283,
     339,   287,   286,   288,   103,   351,   290,   316,   308,   324,
     104,   105,   106,   107,   108,   109,    95,   304,   323,   110,
     111,   334,   335,   342,   341,   112,   113,   114,   102,   102,
     102,   102,   102,    25,   103,   103,   103,   103,   103,   347,
     104,   104,   104,   104,   104,   343,    95,    95,    95,    95,
      95,    55,    56,    57,    58,    59,    51,   238,   344,   345,
     340,     1,   336,   337,   275,     0,     2,     3,     0,     0,
       0,     0,     0,    60,    61,     0,    62,   -55,   -55,    63,
      64,    65,    66,    67,    68,     0,     0,     0,    69,    70,
       0,     0,    71,    72,     0,     0,     0,     0,   139,   140,
     141,   142,   143,   144,   145,   146,   147,   148,   149,     0,
       0,     0,     0,    73,    74,     0,     0,    75,    55,    56,
      57,    58,    59,     0,     0,     0,     0,    76,     1,    27,
     -55,   150,     0,     2,     3,   151,     0,     0,     0,     0,
      60,    61,     0,    62,   -56,   -56,    63,    64,    65,    66,
      67,    68,     0,     0,     0,    69,    70,     0,     0,    71,
      72,     0,   210,   140,   141,   142,   143,   144,   145,   146,
     147,   148,   149,     0,     0,     0,     0,     0,     0,     0,
      73,    74,     0,     0,    75,    55,    56,    57,    58,    59,
       0,     0,     0,     0,    76,     1,    27,   -56,     0,   211,
       2,     3,     0,     0,     0,     0,     0,    60,    61,     0,
      62,   -57,   -57,    63,    64,    65,    66,    67,    68,     0,
       0,     0,    69,    70,     0,     0,    71,    72,     0,   213,
     140,   141,   142,   143,   144,   145,   146,   147,   148,   149,
       0,     0,     0,     0,     0,     0,     0,    73,    74,     0,
       0,    75,    55,    56,    57,    58,    59,     0,     0,     0,
       0,    76,     1,    27,   -57,     0,     0,     2,     3,     0,
       0,     0,     0,     0,    60,    61,     0,    62,   181,   182,
      63,    64,    65,    66,    67,    68,     0,     0,     0,    69,
      70,     0,     0,    71,    72,     0,   183,   184,   185,   186,
     187,   188,   189,   190,     0,   191,   192,   193,     0,   194,
     195,     0,     0,     0,    73,    74,   292,   197,    75,    55,
      56,    57,    58,    59,     0,     0,     0,     0,    76,     1,
      27,    77,     0,     0,     2,     3,     0,     0,     0,     0,
       0,    60,    61,     0,    62,   181,   182,    63,    64,    65,
      66,    67,    68,     0,     0,     0,    69,    70,     0,     0,
      71,    72,     0,   183,   184,   185,   186,   187,   188,   189,
     190,     0,   191,   192,   193,     0,   194,   195,     0,     0,
       0,    73,    74,     0,   197,    75,    55,    56,    57,    58,
      59,     0,     0,     0,     0,    76,     1,    27,   -58,     0,
       0,     2,     3,    55,    56,    57,    58,   118,    60,    61,
       0,    62,     0,     0,    63,    64,    65,    66,    67,    68,
       0,     0,     0,    69,    70,    60,     0,    71,    72,     0,
       0,     0,     0,     0,     0,    55,    56,    57,    58,   118,
      69,    70,     0,     0,    71,    72,     0,     0,    73,    74,
       0,     0,    75,     0,     0,     0,     0,    60,     0,     0,
       0,     0,    76,     0,    27,    73,    74,     0,     0,    75,
       0,     0,    69,    70,     0,   161,    71,    72,     0,    76,
      55,    56,    57,    58,    59,   293,   140,   141,   142,   143,
     144,   145,   146,   147,   148,   149,     0,    73,    74,     0,
       0,    75,    60,     0,     0,   181,   182,     0,     0,     0,
       0,    76,     0,     0,     0,     0,     0,    69,    70,     0,
       0,    71,    72,   183,   184,   185,   186,   187,   188,   189,
     190,     0,   191,   192,   193,     0,   194,   195,     0,   181,
     182,     0,    73,    74,   197,     0,    75,     0,     0,     0,
     229,     0,     0,     0,     0,     0,    76,   183,   184,   185,
     186,   187,   188,   189,   190,     0,   191,   192,   193,     0,
     194,   195,   181,   182,     0,     0,     0,     0,   197,     0,
       0,     0,     0,     0,   277,     0,     0,     0,     0,     0,
     183,   184,   185,   186,   187,   188,   189,   190,     0,   191,
     192,   193,     0,   194,   195,   181,   182,     0,     0,     0,
       0,   197,     0,     0,     0,     0,     0,   282,     0,     0,
       0,     0,     0,   183,   184,   185,   186,   187,   188,   189,
     190,     0,   191,   192,   193,     0,   194,   195,   181,   182,
       0,     0,     0,     0,   197,     0,     0,     0,     0,     0,
     298,     0,     0,     0,     0,     0,   183,   184,   185,   186,
     187,   188,   189,   190,     0,   191,   192,   193,     0,   194,
     195,   181,   182,     0,     0,     0,     0,   197,     0,   258,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   183,
     184,   185,   186,   187,   188,   189,   190,     0,   191,   192,
     193,     0,   194,   195,   181,   182,     0,     0,     0,     0,
     197,     0,   284,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   183,   184,   185,   186,   187,   188,   189,   190,
       0,   191,   192,   193,     0,   194,   195,   181,   182,     0,
       0,     0,     0,   197,     0,   285,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   183,   184,   185,   186,   187,
     188,   189,   190,     0,   191,   192,   193,     0,   194,   195,
     181,   182,     0,     0,     0,     0,   197,     0,   289,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   183,   184,
     185,   186,   187,   188,   189,   190,     0,   191,   192,   193,
       0,   194,   195,   181,   182,     0,     0,     0,     0,   197,
       0,   291,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   183,   184,   185,   186,   187,   188,   189,   190,     0,
     191,   192,   193,     0,   194,   195,   181,   182,     0,     0,
       0,     0,   197,     0,   325,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   183,   184,   185,   186,   187,   188,
     189,   190,     0,   191,   192,   193,     0,   194,   195,   181,
     182,     0,   196,     0,     0,   197,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   183,   184,   185,
     186,   187,   188,   189,   190,     0,   191,   192,   193,     0,
     194,   195,   181,   182,     0,   255,     0,     0,   197,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     183,   184,   185,   186,   187,   188,   189,   190,     0,   191,
     192,   193,     0,   194,   195,   181,   182,     0,   297,     0,
       0,   197,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   183,   184,   185,   186,   187,   188,   189,
     190,     0,   191,   192,   193,     0,   194,   195,   181,   182,
       0,   299,     0,     0,   197,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   183,   184,   185,   186,
     187,   188,   189,   190,     0,   191,   192,   193,     0,   194,
     195,   181,   182,     0,   300,     0,     0,   197,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   183,
     184,   185,   186,   187,   188,   189,   190,     0,   191,   192,
     193,     0,   194,   195,   181,   182,     0,   301,     0,     0,
     197,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   183,   184,   185,   186,   187,   188,   189,   190,
       0,   191,   192,   193,     0,   194,   195,   181,   182,     0,
     326,     0,     0,   197,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   183,   184,   185,   186,   187,
     188,   189,   190,     0,   191,   192,   193,     0,   194,   195,
     181,   182,     0,   327,     0,     0,   197,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   183,   184,
     185,   186,   187,   188,   189,   190,     0,   191,   192,   193,
       0,   194,   195,   181,   182,     0,   328,     0,     0,   197,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   183,   184,   185,   186,   187,   188,   189,   190,     0,
     191,   192,   193,     0,   194,   195,     0,     0,     0,   329,
       0,     0,   197,   295,   140,   141,   142,   143,   144,   145,
     146,   147,   148,   149
};

static const yytype_int16 yycheck[] =
{
      38,   103,   104,    65,    47,   130,    38,    34,    35,   134,
      46,    69,    38,    71,    72,    16,    43,    76,    38,    75,
       7,    48,    75,    42,    51,    44,    48,    65,     8,    51,
      83,    11,    46,    65,     3,    73,    16,     0,    70,    65,
      75,     7,    74,    79,    70,    65,    13,    83,    83,    68,
      13,    18,    19,     7,    41,    18,    19,    76,    96,    22,
      23,    24,    83,     3,     4,     5,     6,     7,    13,    83,
      13,    40,     7,    18,    19,    18,    19,    79,    13,    44,
      45,    83,     7,    18,    19,    25,     3,     4,     5,     6,
       7,    13,    79,    94,   153,   334,    18,    19,     3,     7,
       5,    41,     7,   228,   343,   344,   345,    72,    25,    74,
     129,     0,    75,     0,    76,    82,     7,     0,    80,     8,
     139,     8,    85,    40,    41,     8,    66,    44,    45,   156,
      73,   150,   151,   152,   153,   154,   155,    82,   157,    79,
      75,    82,   198,   199,   200,   201,   165,   205,    65,    66,
      13,   170,    69,    76,    76,    18,    19,    80,    80,    22,
      23,    24,    79,   265,   266,    20,    21,    84,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,   197,    81,
      13,    16,    17,    44,    45,    18,    19,    22,    23,    24,
      25,   210,   211,   212,   213,   214,    75,    81,    76,   226,
      14,    15,    81,     7,    82,    40,    41,    75,    76,    44,
      45,    72,    75,    74,    41,    42,    43,    29,    30,    81,
       7,    46,   284,    79,     7,    79,    79,   289,    79,    79,
      65,    66,    75,    75,    69,    75,    75,    81,    75,     8,
       7,     7,     7,    41,    79,    41,   284,    83,     7,    75,
      32,   289,   284,    75,   316,    75,     7,   289,   284,    83,
       7,   280,    80,   289,   284,     7,     7,   286,   287,   289,
      83,   290,     3,   292,   293,   294,   295,   296,   316,    80,
     323,    75,    46,     7,   316,   347,    79,    27,    46,   308,
     316,     8,     9,    10,    11,    12,   316,    81,    75,    16,
      17,    77,    82,    75,   323,    22,    23,    24,   346,   347,
     348,   349,   350,     8,   346,   347,   348,   349,   350,    80,
     346,   347,   348,   349,   350,    77,   346,   347,   348,   349,
     350,     3,     4,     5,     6,     7,    35,   137,    77,    77,
     323,    13,   320,   320,   226,    -1,    18,    19,    -1,    -1,
      -1,    -1,    -1,    25,    26,    -1,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    -1,    -1,    -1,    40,    41,
      -1,    -1,    44,    45,    -1,    -1,    -1,    -1,    46,    47,
      48,    49,    50,    51,    52,    53,    54,    55,    56,    -1,
      -1,    -1,    -1,    65,    66,    -1,    -1,    69,     3,     4,
       5,     6,     7,    -1,    -1,    -1,    -1,    79,    13,    81,
      82,    79,    -1,    18,    19,    83,    -1,    -1,    -1,    -1,
      25,    26,    -1,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    -1,    -1,    -1,    40,    41,    -1,    -1,    44,
      45,    -1,    46,    47,    48,    49,    50,    51,    52,    53,
      54,    55,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      65,    66,    -1,    -1,    69,     3,     4,     5,     6,     7,
      -1,    -1,    -1,    -1,    79,    13,    81,    82,    -1,    83,
      18,    19,    -1,    -1,    -1,    -1,    -1,    25,    26,    -1,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    -1,
      -1,    -1,    40,    41,    -1,    -1,    44,    45,    -1,    46,
      47,    48,    49,    50,    51,    52,    53,    54,    55,    56,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    65,    66,    -1,
      -1,    69,     3,     4,     5,     6,     7,    -1,    -1,    -1,
      -1,    79,    13,    81,    82,    -1,    -1,    18,    19,    -1,
      -1,    -1,    -1,    -1,    25,    26,    -1,    28,    39,    40,
      31,    32,    33,    34,    35,    36,    -1,    -1,    -1,    40,
      41,    -1,    -1,    44,    45,    -1,    57,    58,    59,    60,
      61,    62,    63,    64,    -1,    66,    67,    68,    -1,    70,
      71,    -1,    -1,    -1,    65,    66,    77,    78,    69,     3,
       4,     5,     6,     7,    -1,    -1,    -1,    -1,    79,    13,
      81,    82,    -1,    -1,    18,    19,    -1,    -1,    -1,    -1,
      -1,    25,    26,    -1,    28,    39,    40,    31,    32,    33,
      34,    35,    36,    -1,    -1,    -1,    40,    41,    -1,    -1,
      44,    45,    -1,    57,    58,    59,    60,    61,    62,    63,
      64,    -1,    66,    67,    68,    -1,    70,    71,    -1,    -1,
      -1,    65,    66,    -1,    78,    69,     3,     4,     5,     6,
       7,    -1,    -1,    -1,    -1,    79,    13,    81,    82,    -1,
      -1,    18,    19,     3,     4,     5,     6,     7,    25,    26,
      -1,    28,    -1,    -1,    31,    32,    33,    34,    35,    36,
      -1,    -1,    -1,    40,    41,    25,    -1,    44,    45,    -1,
      -1,    -1,    -1,    -1,    -1,     3,     4,     5,     6,     7,
      40,    41,    -1,    -1,    44,    45,    -1,    -1,    65,    66,
      -1,    -1,    69,    -1,    -1,    -1,    -1,    25,    -1,    -1,
      -1,    -1,    79,    -1,    81,    65,    66,    -1,    -1,    69,
      -1,    -1,    40,    41,    -1,    75,    44,    45,    -1,    79,
       3,     4,     5,     6,     7,    46,    47,    48,    49,    50,
      51,    52,    53,    54,    55,    56,    -1,    65,    66,    -1,
      -1,    69,    25,    -1,    -1,    39,    40,    -1,    -1,    -1,
      -1,    79,    -1,    -1,    -1,    -1,    -1,    40,    41,    -1,
      -1,    44,    45,    57,    58,    59,    60,    61,    62,    63,
      64,    -1,    66,    67,    68,    -1,    70,    71,    -1,    39,
      40,    -1,    65,    66,    78,    -1,    69,    -1,    -1,    -1,
      84,    -1,    -1,    -1,    -1,    -1,    79,    57,    58,    59,
      60,    61,    62,    63,    64,    -1,    66,    67,    68,    -1,
      70,    71,    39,    40,    -1,    -1,    -1,    -1,    78,    -1,
      -1,    -1,    -1,    -1,    84,    -1,    -1,    -1,    -1,    -1,
      57,    58,    59,    60,    61,    62,    63,    64,    -1,    66,
      67,    68,    -1,    70,    71,    39,    40,    -1,    -1,    -1,
      -1,    78,    -1,    -1,    -1,    -1,    -1,    84,    -1,    -1,
      -1,    -1,    -1,    57,    58,    59,    60,    61,    62,    63,
      64,    -1,    66,    67,    68,    -1,    70,    71,    39,    40,
      -1,    -1,    -1,    -1,    78,    -1,    -1,    -1,    -1,    -1,
      84,    -1,    -1,    -1,    -1,    -1,    57,    58,    59,    60,
      61,    62,    63,    64,    -1,    66,    67,    68,    -1,    70,
      71,    39,    40,    -1,    -1,    -1,    -1,    78,    -1,    80,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    57,
      58,    59,    60,    61,    62,    63,    64,    -1,    66,    67,
      68,    -1,    70,    71,    39,    40,    -1,    -1,    -1,    -1,
      78,    -1,    80,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    57,    58,    59,    60,    61,    62,    63,    64,
      -1,    66,    67,    68,    -1,    70,    71,    39,    40,    -1,
      -1,    -1,    -1,    78,    -1,    80,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    57,    58,    59,    60,    61,
      62,    63,    64,    -1,    66,    67,    68,    -1,    70,    71,
      39,    40,    -1,    -1,    -1,    -1,    78,    -1,    80,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    57,    58,
      59,    60,    61,    62,    63,    64,    -1,    66,    67,    68,
      -1,    70,    71,    39,    40,    -1,    -1,    -1,    -1,    78,
      -1,    80,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    57,    58,    59,    60,    61,    62,    63,    64,    -1,
      66,    67,    68,    -1,    70,    71,    39,    40,    -1,    -1,
      -1,    -1,    78,    -1,    80,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    57,    58,    59,    60,    61,    62,
      63,    64,    -1,    66,    67,    68,    -1,    70,    71,    39,
      40,    -1,    75,    -1,    -1,    78,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    57,    58,    59,
      60,    61,    62,    63,    64,    -1,    66,    67,    68,    -1,
      70,    71,    39,    40,    -1,    75,    -1,    -1,    78,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      57,    58,    59,    60,    61,    62,    63,    64,    -1,    66,
      67,    68,    -1,    70,    71,    39,    40,    -1,    75,    -1,
      -1,    78,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    57,    58,    59,    60,    61,    62,    63,
      64,    -1,    66,    67,    68,    -1,    70,    71,    39,    40,
      -1,    75,    -1,    -1,    78,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    57,    58,    59,    60,
      61,    62,    63,    64,    -1,    66,    67,    68,    -1,    70,
      71,    39,    40,    -1,    75,    -1,    -1,    78,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    57,
      58,    59,    60,    61,    62,    63,    64,    -1,    66,    67,
      68,    -1,    70,    71,    39,    40,    -1,    75,    -1,    -1,
      78,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    57,    58,    59,    60,    61,    62,    63,    64,
      -1,    66,    67,    68,    -1,    70,    71,    39,    40,    -1,
      75,    -1,    -1,    78,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    57,    58,    59,    60,    61,
      62,    63,    64,    -1,    66,    67,    68,    -1,    70,    71,
      39,    40,    -1,    75,    -1,    -1,    78,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    57,    58,
      59,    60,    61,    62,    63,    64,    -1,    66,    67,    68,
      -1,    70,    71,    39,    40,    -1,    75,    -1,    -1,    78,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    57,    58,    59,    60,    61,    62,    63,    64,    -1,
      66,    67,    68,    -1,    70,    71,    -1,    -1,    -1,    75,
      -1,    -1,    78,    46,    47,    48,    49,    50,    51,    52,
      53,    54,    55,    56
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,    13,    18,    19,    22,    23,    24,    75,    90,    91,
      97,    99,   102,   103,   123,   124,   125,   134,   137,   140,
       7,     7,     7,     0,    85,    91,    75,    81,    98,    20,
      21,   135,     7,   139,    81,    81,    81,    82,    92,    14,
      15,   136,    46,    79,    83,   138,    75,    76,   104,   105,
     140,   104,     7,   100,   101,     3,     4,     5,     6,     7,
      25,    26,    28,    31,    32,    33,    34,    35,    36,    40,
      41,    44,    45,    65,    66,    69,    79,    82,    93,    94,
      95,    96,    98,   106,   107,   112,   113,   114,   115,   116,
     117,   121,   122,   124,   125,   128,   130,   137,   141,   142,
     143,   144,   145,   147,   148,     8,     9,    10,    11,    12,
      16,    17,    22,    23,    24,   131,   132,   133,     7,   128,
     142,   145,   147,   148,   126,   127,   140,    84,   142,    83,
       7,   121,    82,   105,     7,    82,    46,    76,    82,    46,
      47,    48,    49,    50,    51,    52,    53,    54,    55,    56,
      79,    83,   154,    79,    79,    79,    79,    79,    93,    75,
      75,    75,   142,   144,     7,    79,   147,   148,   144,   144,
      79,   145,     7,   147,   143,   131,   142,    75,    75,    75,
     145,    39,    40,    57,    58,    59,    60,    61,    62,    63,
      64,    66,    67,    68,    70,    71,    75,    78,   150,   151,
     152,   153,    41,    42,    43,   149,    44,    45,    72,    74,
      46,    83,   154,    46,   154,     8,    11,    16,     8,     7,
       7,     7,    41,    41,    72,    74,    76,    80,     7,    84,
     142,   138,    75,    75,   138,    75,     3,    40,   101,    75,
     142,   129,   142,   142,   142,   131,   142,   146,   142,   142,
       7,   118,   140,   142,    32,    75,   142,    80,    80,   142,
     143,   143,   143,   143,   144,     7,     7,   142,   142,   142,
     142,   142,     7,     7,    73,   126,   138,    84,    75,     3,
      76,    80,    84,    80,    80,    80,    46,    75,     7,    80,
      79,    80,    77,    46,   154,    46,   154,    75,    84,    75,
      75,    75,   142,    93,    81,   142,   119,   142,    46,    93,
     142,   142,   142,   142,   142,   142,    27,    29,    30,   108,
     109,   110,   111,    75,   142,    80,    75,    75,    75,    75,
      93,     3,     5,     7,    77,    82,   110,   111,   120,   121,
     122,   142,    75,    77,    77,    77,    92,    80,    92,    92,
      92,    93
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_uint8 yyr1[] =
{
       0,    89,    90,    90,    90,    91,    91,    91,    91,    91,
      92,    92,    93,    93,    93,    93,    93,    93,    93,    93,
      93,    94,    94,    95,    95,    95,    96,    96,    96,    97,
      97,    97,    98,    98,    99,   100,   100,   100,   101,   101,
     101,   102,   103,   104,   104,   105,   105,   106,   106,   107,
     108,   108,   108,   109,   109,   110,   110,   110,   111,   112,
     113,   114,   114,   115,   116,   117,   118,   118,   118,   118,
     119,   119,   120,   120,   120,   120,   121,   122,   123,   124,
     125,   126,   126,   126,   127,   127,   127,   127,   128,   129,
     129,   129,   130,   131,   131,   132,   132,   133,   133,   133,
     133,   133,   133,   133,   133,   133,   133,   133,   133,   133,
     133,   134,   134,   134,   134,   135,   135,   135,   136,   136,
     136,   137,   138,   138,   138,   139,   139,   139,   139,   139,
     139,   140,   141,   141,   141,   141,   141,   141,   141,   141,
     141,   141,   142,   142,   142,   142,   142,   142,   143,   143,
     144,   144,   144,   144,   144,   144,   144,   145,   145,   145,
     145,   145,   145,   145,   145,   145,   145,   145,   145,   145,
     145,   145,   145,   146,   146,   147,   147,   148,   148,   148,
     148,   149,   149,   149,   150,   150,   150,   150,   151,   151,
     151,   151,   151,   151,   152,   152,   152,   153,   153,   154,
     154,   154,   154,   154,   154,   154,   154,   154,   154
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     2,     2,     1,     1,     1,     1,     1,     1,
       0,     2,     1,     1,     1,     1,     1,     1,     2,     1,
       2,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     3,     2,     6,     1,     3,     2,     1,     3,
       4,     6,     6,     1,     2,     3,     4,     5,     7,     7,
       2,     1,     1,     1,     2,     4,     4,     4,     3,     2,
       2,     2,     3,     5,     7,     9,     0,     3,     4,     2,
       0,     1,     0,     1,     1,     1,     3,     3,     2,     2,
       5,     2,     3,     1,     0,     3,     3,     1,     4,     0,
       3,     1,     3,     1,     1,     2,     2,     1,     1,     1,
       1,     2,     2,     2,     1,     1,     2,     1,     2,     2,
       2,     0,     1,     1,     1,     0,     1,     1,     0,     1,
       1,     3,     3,     2,     4,     1,     3,     2,     3,     4,
       3,     4,     2,     2,     4,     4,     4,     6,     6,     4,
       6,     6,     3,     3,     3,     3,     5,     1,     3,     1,
       2,     2,     2,     2,     2,     2,     1,     3,     1,     1,
       1,     1,     1,     1,     1,     2,     2,     4,     1,     2,
       2,     3,     3,     1,     1,     4,     4,     2,     2,     2,
       4,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1
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
#line 121 "Parser/parser.y"
                    {
                        p_treeRoot = yyvsp[-1].treeNode;
                        LOG_DEBUG("Reached end of file!\n");
                        return 0;
                    }
#line 1737 "Parser/parser.tab.c"
    break;

  case 3: /* program: program global_statement  */
#line 127 "Parser/parser.y"
                    {
                        TreeNode_t* p_Head = yyvsp[-1].treeNode;
                        if (yyvsp[0].treeNode != NULL) {
                            if (NodeAppendSibling(&p_Head, yyvsp[0].treeNode)) { YYERROR; }
                        }
                        yyval.treeNode = p_Head;
                    }
#line 1749 "Parser/parser.tab.c"
    break;

  case 4: /* program: global_statement  */
#line 135 "Parser/parser.y"
                    {
                        yyval.treeNode = yyvsp[0].treeNode;
                    }
#line 1757 "Parser/parser.tab.c"
    break;

  case 5: /* global_statement: type_declaration  */
#line 141 "Parser/parser.y"
                                         { yyval.treeNode = yyvsp[0].treeNode; }
#line 1763 "Parser/parser.tab.c"
    break;

  case 6: /* global_statement: var_declaration  */
#line 142 "Parser/parser.y"
                                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 1769 "Parser/parser.tab.c"
    break;

  case 7: /* global_statement: function_prototype  */
#line 143 "Parser/parser.y"
                                           { yyval.treeNode = yyvsp[0].treeNode; }
#line 1775 "Parser/parser.tab.c"
    break;

  case 8: /* global_statement: function_definition  */
#line 144 "Parser/parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 1781 "Parser/parser.tab.c"
    break;

  case 9: /* global_statement: TOKEN_SEMI  */
#line 146 "Parser/parser.y"
                                   { yyval.treeNode = NULL; }
#line 1787 "Parser/parser.tab.c"
    break;

  case 10: /* local_statement_list: %empty  */
#line 150 "Parser/parser.y"
                                       { yyval.treeNode = NULL; }
#line 1793 "Parser/parser.tab.c"
    break;

  case 11: /* local_statement_list: local_statement_list local_statement  */
#line 152 "Parser/parser.y"
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
#line 1809 "Parser/parser.tab.c"
    break;

  case 12: /* local_statement: selection_statement  */
#line 165 "Parser/parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 1815 "Parser/parser.tab.c"
    break;

  case 13: /* local_statement: iteration_statement  */
#line 166 "Parser/parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 1821 "Parser/parser.tab.c"
    break;

  case 14: /* local_statement: jump_statement  */
#line 167 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[0].treeNode; }
#line 1827 "Parser/parser.tab.c"
    break;

  case 15: /* local_statement: compound_statement  */
#line 168 "Parser/parser.y"
                                           { yyval.treeNode = yyvsp[0].treeNode; }
#line 1833 "Parser/parser.tab.c"
    break;

  case 16: /* local_statement: var_declaration  */
#line 169 "Parser/parser.y"
                                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 1839 "Parser/parser.tab.c"
    break;

  case 17: /* local_statement: var_assignment  */
#line 170 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[0].treeNode; }
#line 1845 "Parser/parser.tab.c"
    break;

  case 18: /* local_statement: func_call TOKEN_SEMI  */
#line 171 "Parser/parser.y"
                                             { yyval.treeNode = yyvsp[-1].treeNode; }
#line 1851 "Parser/parser.tab.c"
    break;

  case 19: /* local_statement: function_definition  */
#line 172 "Parser/parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 1857 "Parser/parser.tab.c"
    break;

  case 20: /* local_statement: exp TOKEN_SEMI  */
#line 173 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[-1].treeNode; }
#line 1863 "Parser/parser.tab.c"
    break;

  case 21: /* selection_statement: if_statement  */
#line 179 "Parser/parser.y"
                                   { yyval.treeNode = yyvsp[0].treeNode; }
#line 1869 "Parser/parser.tab.c"
    break;

  case 22: /* selection_statement: switch_statement  */
#line 180 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[0].treeNode; }
#line 1875 "Parser/parser.tab.c"
    break;

  case 23: /* jump_statement: break_statement  */
#line 183 "Parser/parser.y"
                                      { yyval.treeNode = yyvsp[0].treeNode; }
#line 1881 "Parser/parser.tab.c"
    break;

  case 24: /* jump_statement: return_statement  */
#line 184 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[0].treeNode; }
#line 1887 "Parser/parser.tab.c"
    break;

  case 25: /* jump_statement: continue_statement  */
#line 185 "Parser/parser.y"
                                         { yyval.treeNode = yyvsp[0].treeNode; }
#line 1893 "Parser/parser.tab.c"
    break;

  case 26: /* iteration_statement: do_while_loop  */
#line 188 "Parser/parser.y"
                                      { yyval.treeNode = yyvsp[0].treeNode; }
#line 1899 "Parser/parser.tab.c"
    break;

  case 27: /* iteration_statement: while_loop  */
#line 189 "Parser/parser.y"
                                   { yyval.treeNode = yyvsp[0].treeNode; }
#line 1905 "Parser/parser.tab.c"
    break;

  case 28: /* iteration_statement: for_loop  */
#line 190 "Parser/parser.y"
                                 { yyval.treeNode = yyvsp[0].treeNode; }
#line 1911 "Parser/parser.tab.c"
    break;

  case 29: /* type_declaration: enum_declaration  */
#line 193 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[0].treeNode; }
#line 1917 "Parser/parser.tab.c"
    break;

  case 30: /* type_declaration: struct_declaration  */
#line 194 "Parser/parser.y"
                                          { yyval.treeNode = yyvsp[0].treeNode; }
#line 1923 "Parser/parser.tab.c"
    break;

  case 31: /* type_declaration: union_declaration  */
#line 195 "Parser/parser.y"
                                         { yyval.treeNode = yyvsp[0].treeNode; }
#line 1929 "Parser/parser.tab.c"
    break;

  case 32: /* compound_statement: TOKEN_LEFT_BRACE local_statement_list TOKEN_RIGHT_BRACE  */
#line 199 "Parser/parser.y"
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
#line 1951 "Parser/parser.tab.c"
    break;

  case 33: /* compound_statement: TOKEN_LEFT_BRACE TOKEN_RIGHT_BRACE  */
#line 217 "Parser/parser.y"
                        { yyval.treeNode = NULL; }
#line 1957 "Parser/parser.tab.c"
    break;

  case 34: /* enum_declaration: TOKEN_ENUM TOKEN_ID TOKEN_LEFT_BRACE enum_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI  */
#line 226 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_ENUM_DECLARATION);
                            yyval.treeNode->nodeData.sVal = yyvsp[-4].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                        }
#line 1967 "Parser/parser.tab.c"
    break;

  case 35: /* enum_member_list: enum_member  */
#line 234 "Parser/parser.y"
                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 1973 "Parser/parser.tab.c"
    break;

  case 36: /* enum_member_list: enum_member_list TOKEN_COMMA enum_member  */
#line 236 "Parser/parser.y"
                        {
                            TreeNode_t* pHead = yyvsp[-2].treeNode;
                            if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                            yyval.treeNode = pHead;
                        }
#line 1983 "Parser/parser.tab.c"
    break;

  case 37: /* enum_member_list: enum_member_list TOKEN_COMMA  */
#line 242 "Parser/parser.y"
                        { yyval.treeNode = yyvsp[-1].treeNode; }
#line 1989 "Parser/parser.tab.c"
    break;

  case 38: /* enum_member: TOKEN_ID  */
#line 246 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_ENUM_MEMBER);
                            yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                        }
#line 1998 "Parser/parser.tab.c"
    break;

  case 39: /* enum_member: TOKEN_ID TOKEN_ASSIGN TOKEN_NUM  */
#line 251 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_ENUM_MEMBER);
                            yyval.treeNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                            TreeNode_t* pVal;
                            NodeCreate(&pVal, NODE_INTEGER);
                            pVal->nodeData.dVal = yyvsp[0].nodeData.dVal;  // guarda o valor!
                            NodeAddChild(yyval.treeNode, pVal);
                        }
#line 2011 "Parser/parser.tab.c"
    break;

  case 40: /* enum_member: TOKEN_ID TOKEN_ASSIGN TOKEN_MINUS TOKEN_NUM  */
#line 260 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_ENUM_MEMBER);
                            yyval.treeNode->nodeData.sVal = yyvsp[-3].nodeData.sVal;
                            TreeNode_t* pVal;
                            NodeCreate(&pVal, NODE_INTEGER);
                            pVal->nodeData.dVal = -yyvsp[0].nodeData.dVal;
                            NodeAddChild(yyval.treeNode, pVal);
                        }
#line 2024 "Parser/parser.tab.c"
    break;

  case 41: /* struct_declaration: TOKEN_STRUCT TOKEN_ID TOKEN_LEFT_BRACE struct_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI  */
#line 272 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_STRUCT_DECLARATION);
                            yyval.treeNode->nodeData.sVal = yyvsp[-4].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                        }
#line 2034 "Parser/parser.tab.c"
    break;

  case 42: /* union_declaration: TOKEN_UNION TOKEN_ID TOKEN_LEFT_BRACE struct_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI  */
#line 281 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_UNION_DECLARATION);
                            yyval.treeNode->nodeData.sVal = yyvsp[-4].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                        }
#line 2044 "Parser/parser.tab.c"
    break;

  case 43: /* struct_member_list: struct_member  */
#line 290 "Parser/parser.y"
                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 2050 "Parser/parser.tab.c"
    break;

  case 44: /* struct_member_list: struct_member_list struct_member  */
#line 292 "Parser/parser.y"
                        {
                            TreeNode_t* pHead = yyvsp[-1].treeNode;
                            if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                            yyval.treeNode = pHead;
                        }
#line 2060 "Parser/parser.tab.c"
    break;

  case 45: /* struct_member: var_preamble TOKEN_ID TOKEN_SEMI  */
#line 301 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_STRUCT_MEMBER);
                            yyval.treeNode->nodeData.sVal = yyvsp[-1].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                        }
#line 2070 "Parser/parser.tab.c"
    break;

  case 46: /* struct_member: var_preamble TOKEN_ID arr_size TOKEN_SEMI  */
#line 307 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_ARRAY_DECLARATION);
                            yyval.treeNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-3].treeNode);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2081 "Parser/parser.tab.c"
    break;

  case 47: /* if_statement: TOKEN_IF TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES local_statement  */
#line 320 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_IF);
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);    //condition
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);    //if true
                    }
#line 2091 "Parser/parser.tab.c"
    break;

  case 48: /* if_statement: TOKEN_IF TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES local_statement TOKEN_ELSE local_statement  */
#line 326 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_IF);
                        NodeAddChild(yyval.treeNode, yyvsp[-4].treeNode);   //condition
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);   //if true
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);   //else
                    }
#line 2102 "Parser/parser.tab.c"
    break;

  case 49: /* switch_statement: TOKEN_SWITCH TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES TOKEN_LEFT_BRACE switch_body TOKEN_RIGHT_BRACE  */
#line 335 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_SWITCH);
                            NodeAddChild(yyval.treeNode, yyvsp[-4].treeNode);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2112 "Parser/parser.tab.c"
    break;

  case 50: /* switch_body: case_list default_clause  */
#line 343 "Parser/parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[-1].treeNode;
                        if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                        yyval.treeNode = pHead;
                    }
#line 2122 "Parser/parser.tab.c"
    break;

  case 51: /* switch_body: case_list  */
#line 349 "Parser/parser.y"
                    {
                        yyval.treeNode = yyvsp[0].treeNode;
                    }
#line 2130 "Parser/parser.tab.c"
    break;

  case 52: /* switch_body: default_clause  */
#line 353 "Parser/parser.y"
                    {
                        yyval.treeNode = yyvsp[0].treeNode;
                    }
#line 2138 "Parser/parser.tab.c"
    break;

  case 53: /* case_list: case_clause  */
#line 359 "Parser/parser.y"
                    {
                        yyval.treeNode = yyvsp[0].treeNode;
                    }
#line 2146 "Parser/parser.tab.c"
    break;

  case 54: /* case_list: case_list case_clause  */
#line 363 "Parser/parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[-1].treeNode;
                        if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                        yyval.treeNode = pHead;
                    }
#line 2156 "Parser/parser.tab.c"
    break;

  case 55: /* case_clause: TOKEN_CASE TOKEN_NUM TOKEN_COLON local_statement_list  */
#line 371 "Parser/parser.y"
                    {
                         NodeCreate(&(yyval.treeNode), NODE_CASE);
		          yyval.treeNode->nodeData.sVal = NULL;   
		          yyval.treeNode->nodeData.dVal = yyvsp[-2].nodeData.dVal;
		          NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2167 "Parser/parser.tab.c"
    break;

  case 56: /* case_clause: TOKEN_CASE TOKEN_CNUM TOKEN_COLON local_statement_list  */
#line 378 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_CASE);
                        yyval.treeNode->nodeData.dVal = yyvsp[-2].nodeData.dVal;
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2177 "Parser/parser.tab.c"
    break;

  case 57: /* case_clause: TOKEN_CASE TOKEN_ID TOKEN_COLON local_statement_list  */
#line 384 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_CASE);
                        yyval.treeNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;  /* guarda o nome */
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2187 "Parser/parser.tab.c"
    break;

  case 58: /* default_clause: TOKEN_DEFAULT TOKEN_COLON local_statement_list  */
#line 392 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_DEFAULT);
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2196 "Parser/parser.tab.c"
    break;

  case 59: /* continue_statement: TOKEN_CONTINUE TOKEN_SEMI  */
#line 403 "Parser/parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_CONTINUE); }
#line 2202 "Parser/parser.tab.c"
    break;

  case 60: /* break_statement: TOKEN_BREAK TOKEN_SEMI  */
#line 407 "Parser/parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_BREAK); }
#line 2208 "Parser/parser.tab.c"
    break;

  case 61: /* return_statement: TOKEN_RETURN TOKEN_SEMI  */
#line 411 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_RETURN);
                            yyval.treeNode->nodeData.sVal = currentFunction;
                        }
#line 2217 "Parser/parser.tab.c"
    break;

  case 62: /* return_statement: TOKEN_RETURN exp TOKEN_SEMI  */
#line 416 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_RETURN);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                            yyval.treeNode->nodeData.sVal = currentFunction;
                        }
#line 2227 "Parser/parser.tab.c"
    break;

  case 63: /* while_loop: TOKEN_WHILE TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES local_statement  */
#line 428 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_WHILE);
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);    // Condition
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);    // if true
                    }
#line 2237 "Parser/parser.tab.c"
    break;

  case 64: /* do_while_loop: TOKEN_DO local_statement TOKEN_WHILE TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES TOKEN_SEMI  */
#line 437 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_DO_WHILE);
                        NodeAddChild(yyval.treeNode, yyvsp[-5].treeNode);
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                    }
#line 2247 "Parser/parser.tab.c"
    break;

  case 65: /* for_loop: TOKEN_FOR TOKEN_LEFT_PARENTHESES for_init_field TOKEN_SEMI for_condition TOKEN_SEMI for_assignment_field TOKEN_RIGHT_PARENTHESES local_statement  */
#line 445 "Parser/parser.y"
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
#line 2279 "Parser/parser.tab.c"
    break;

  case 66: /* for_init_field: %empty  */
#line 474 "Parser/parser.y"
                           { yyval.treeNode = NULL; }
#line 2285 "Parser/parser.tab.c"
    break;

  case 67: /* for_init_field: TOKEN_ID TOKEN_ASSIGN exp  */
#line 476 "Parser/parser.y"
                    {
                        TreeNode_t* pNode;
                        NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                        yyval.treeNode->nodeData.dVal = OP_ASSIGN;
                        NodeAddNewChild(yyval.treeNode, &pNode, NODE_IDENTIFIER);
                        pNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2298 "Parser/parser.tab.c"
    break;

  case 68: /* for_init_field: var_preamble TOKEN_ID TOKEN_ASSIGN exp  */
#line 485 "Parser/parser.y"
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
#line 2316 "Parser/parser.tab.c"
    break;

  case 69: /* for_init_field: var_preamble TOKEN_ID  */
#line 499 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
                        yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                        NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                    }
#line 2326 "Parser/parser.tab.c"
    break;

  case 70: /* for_condition: %empty  */
#line 505 "Parser/parser.y"
                             { yyval.treeNode = NULL; }
#line 2332 "Parser/parser.tab.c"
    break;

  case 71: /* for_condition: exp  */
#line 506 "Parser/parser.y"
                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 2338 "Parser/parser.tab.c"
    break;

  case 72: /* for_assignment_field: %empty  */
#line 509 "Parser/parser.y"
                                            { yyval.treeNode = NULL; }
#line 2344 "Parser/parser.tab.c"
    break;

  case 73: /* for_assignment_field: simple_var_assign  */
#line 510 "Parser/parser.y"
                                                { yyval.treeNode = yyvsp[0].treeNode; }
#line 2350 "Parser/parser.tab.c"
    break;

  case 74: /* for_assignment_field: compound_var_assign  */
#line 511 "Parser/parser.y"
                                                { yyval.treeNode = yyvsp[0].treeNode; }
#line 2356 "Parser/parser.tab.c"
    break;

  case 75: /* for_assignment_field: exp  */
#line 512 "Parser/parser.y"
                                { yyval.treeNode = yyvsp[0].treeNode; }
#line 2362 "Parser/parser.tab.c"
    break;

  case 76: /* simple_var_assign: TOKEN_ID TOKEN_ASSIGN exp  */
#line 516 "Parser/parser.y"
                        {
                            TreeNode_t* pNode;
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_ASSIGN;
                            NodeAddNewChild(yyval.treeNode, &pNode, NODE_IDENTIFIER);
                            pNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                        }
#line 2375 "Parser/parser.tab.c"
    break;

  case 77: /* compound_var_assign: TOKEN_ID compound_assign_operator exp  */
#line 527 "Parser/parser.y"
                        {
                            TreeNode_t* pNode;
                            NodeAddNewChild(yyvsp[-1].treeNode, &pNode, NODE_IDENTIFIER);
                            pNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                            NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                            yyval.treeNode = yyvsp[-1].treeNode;
                        }
#line 2387 "Parser/parser.tab.c"
    break;

  case 78: /* function_prototype: function_signature TOKEN_SEMI  */
#line 541 "Parser/parser.y"
                        {
                            yyval.treeNode = yyvsp[-1].treeNode;
                        }
#line 2395 "Parser/parser.tab.c"
    break;

  case 79: /* function_definition: function_signature compound_statement  */
#line 547 "Parser/parser.y"
                        {
                            yyval.treeNode = yyvsp[-1].treeNode;
                            NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                        }
#line 2404 "Parser/parser.tab.c"
    break;

  case 80: /* function_signature: var_preamble TOKEN_ID TOKEN_LEFT_PARENTHESES arg_list TOKEN_RIGHT_PARENTHESES  */
#line 555 "Parser/parser.y"
                        {
                            NodeCreate(&yyval.treeNode, NODE_FUNCTION);
                            yyval.treeNode->nodeData.sVal = yyvsp[-3].nodeData.sVal;
                            currentFunction = yyvsp[-3].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-4].treeNode);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2416 "Parser/parser.tab.c"
    break;

  case 81: /* param_declaration: var_preamble TOKEN_ID  */
#line 565 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
                        yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                        NodeAddChildCopy(yyval.treeNode, yyvsp[-1].treeNode);
                        free(yyvsp[-1].treeNode);
                    }
#line 2427 "Parser/parser.tab.c"
    break;

  case 82: /* param_declaration: var_preamble TOKEN_ID arr_size  */
#line 573 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_ARRAY_DECLARATION);
                        yyval.treeNode->nodeData.sVal = yyvsp[-1].nodeData.sVal;
                        NodeAddChildCopy(yyval.treeNode, yyvsp[-2].treeNode);
                        free(yyvsp[-2].treeNode);
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2439 "Parser/parser.tab.c"
    break;

  case 83: /* param_declaration: var_preamble  */
#line 581 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2448 "Parser/parser.tab.c"
    break;

  case 84: /* arg_list: %empty  */
#line 589 "Parser/parser.y"
                { yyval.treeNode = NULL; }
#line 2454 "Parser/parser.tab.c"
    break;

  case 85: /* arg_list: arg_list TOKEN_COMMA TOKEN_ELLIPSIS  */
#line 592 "Parser/parser.y"
                    {
                        TreeNode_t* pNode;
                        TreeNode_t* p_Head = yyvsp[-2].treeNode;
                        NodeCreate(&pNode, NODE_PARAMETER);
                        pNode->nodeData.sVal = "...";
                        if (NodeAppendSibling(&p_Head, pNode)) { YYERROR; }
                        yyval.treeNode = p_Head;
                    }
#line 2467 "Parser/parser.tab.c"
    break;

  case 86: /* arg_list: arg_list TOKEN_COMMA param_declaration  */
#line 601 "Parser/parser.y"
                    {
                        TreeNode_t* p_Head = yyvsp[-2].treeNode;
                        if (NodeAppendSibling(&p_Head, yyvsp[0].treeNode)) { YYERROR; }
                        yyval.treeNode = p_Head;
                    }
#line 2477 "Parser/parser.tab.c"
    break;

  case 87: /* arg_list: param_declaration  */
#line 607 "Parser/parser.y"
                { yyval.treeNode = yyvsp[0].treeNode; }
#line 2483 "Parser/parser.tab.c"
    break;

  case 88: /* func_call: TOKEN_ID TOKEN_LEFT_PARENTHESES exp_list TOKEN_RIGHT_PARENTHESES  */
#line 611 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_FUNCTION_CALL);
                            yyval.treeNode->nodeData.sVal = yyvsp[-3].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2493 "Parser/parser.tab.c"
    break;

  case 89: /* exp_list: %empty  */
#line 620 "Parser/parser.y"
                        {
                            yyval.treeNode = NULL;
                        }
#line 2501 "Parser/parser.tab.c"
    break;

  case 90: /* exp_list: exp_list TOKEN_COMMA exp  */
#line 624 "Parser/parser.y"
                        {
                            TreeNode_t* pHead = yyvsp[-2].treeNode;
                            if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                            yyval.treeNode = pHead;
                        }
#line 2511 "Parser/parser.tab.c"
    break;

  case 91: /* exp_list: exp  */
#line 630 "Parser/parser.y"
                        {
                            yyval.treeNode = yyvsp[0].treeNode;
                        }
#line 2519 "Parser/parser.tab.c"
    break;

  case 92: /* type_cast_specifier: TOKEN_LEFT_PARENTHESES all_type_specifiers TOKEN_RIGHT_PARENTHESES  */
#line 642 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE_CAST);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2528 "Parser/parser.tab.c"
    break;

  case 93: /* all_type_specifiers: data_type_specifier  */
#line 649 "Parser/parser.y"
                                             { yyval.treeNode = yyvsp[0].treeNode; }
#line 2534 "Parser/parser.tab.c"
    break;

  case 94: /* all_type_specifiers: type_pointer  */
#line 650 "Parser/parser.y"
                                      { yyval.treeNode = yyvsp[0].treeNode; }
#line 2540 "Parser/parser.tab.c"
    break;

  case 95: /* type_pointer: data_type_specifier TOKEN_ASTERISK  */
#line 654 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_POINTER);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2549 "Parser/parser.tab.c"
    break;

  case 96: /* type_pointer: type_pointer TOKEN_ASTERISK  */
#line 659 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_POINTER);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2558 "Parser/parser.tab.c"
    break;

  case 97: /* data_type_specifier: TOKEN_CHAR  */
#line 667 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_CHAR;
                        }
#line 2567 "Parser/parser.tab.c"
    break;

  case 98: /* data_type_specifier: TOKEN_SHORT  */
#line 672 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_SHORT;
                        }
#line 2576 "Parser/parser.tab.c"
    break;

  case 99: /* data_type_specifier: TOKEN_INT  */
#line 677 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_INT;
                        }
#line 2585 "Parser/parser.tab.c"
    break;

  case 100: /* data_type_specifier: TOKEN_LONG  */
#line 682 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_LONG;
                        }
#line 2594 "Parser/parser.tab.c"
    break;

  case 101: /* data_type_specifier: TOKEN_LONG TOKEN_LONG  */
#line 687 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_LONG;
                        }
#line 2603 "Parser/parser.tab.c"
    break;

  case 102: /* data_type_specifier: TOKEN_LONG TOKEN_INT  */
#line 692 "Parser/parser.y"
                      {
                          NodeCreate(&(yyval.treeNode), NODE_TYPE);
                          yyval.treeNode->nodeData.dVal = TYPE_LONG;
                      }
#line 2612 "Parser/parser.tab.c"
    break;

  case 103: /* data_type_specifier: TOKEN_SHORT TOKEN_INT  */
#line 697 "Parser/parser.y"
                      {
                          NodeCreate(&(yyval.treeNode), NODE_TYPE);
                          yyval.treeNode->nodeData.dVal = TYPE_SHORT;
                      }
#line 2621 "Parser/parser.tab.c"
    break;

  case 104: /* data_type_specifier: TOKEN_FLOAT  */
#line 702 "Parser/parser.y"
                            { NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_FLOAT;
                        }
#line 2629 "Parser/parser.tab.c"
    break;

  case 105: /* data_type_specifier: TOKEN_DOUBLE  */
#line 706 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_DOUBLE;
                        }
#line 2638 "Parser/parser.tab.c"
    break;

  case 106: /* data_type_specifier: TOKEN_LONG TOKEN_DOUBLE  */
#line 711 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_LONG_DOUBLE;
                        }
#line 2647 "Parser/parser.tab.c"
    break;

  case 107: /* data_type_specifier: TOKEN_VOID  */
#line 716 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_VOID;
                        }
#line 2656 "Parser/parser.tab.c"
    break;

  case 108: /* data_type_specifier: TOKEN_STRUCT TOKEN_ID  */
#line 721 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_STRUCT;
                            TreeNode_t* pName;
                            NodeCreate(&pName, NODE_IDENTIFIER);
                            pName->nodeData.sVal = yyvsp[0].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, pName);
                        }
#line 2669 "Parser/parser.tab.c"
    break;

  case 109: /* data_type_specifier: TOKEN_UNION TOKEN_ID  */
#line 730 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_UNION;
                            TreeNode_t* pName;
                            NodeCreate(&pName, NODE_IDENTIFIER);
                            pName->nodeData.sVal = yyvsp[0].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, pName);
                        }
#line 2682 "Parser/parser.tab.c"
    break;

  case 110: /* data_type_specifier: TOKEN_ENUM TOKEN_ID  */
#line 739 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_ENUM;
                            TreeNode_t* pName;
                            NodeCreate(&pName, NODE_IDENTIFIER);
                            pName->nodeData.sVal = yyvsp[0].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, pName);
                        }
#line 2695 "Parser/parser.tab.c"
    break;

  case 111: /* visibility_qualifier: %empty  */
#line 749 "Parser/parser.y"
                              { NodeCreate(&(yyval.treeNode), NODE_NULL); }
#line 2701 "Parser/parser.tab.c"
    break;

  case 112: /* visibility_qualifier: TOKEN_STATIC  */
#line 751 "Parser/parser.y"
                       {
                           NodeCreate(&(yyval.treeNode), NODE_VISIBILITY);
                           yyval.treeNode->nodeData.dVal = VIS_STATIC;
                       }
#line 2710 "Parser/parser.tab.c"
    break;

  case 113: /* visibility_qualifier: TOKEN_EXTERN  */
#line 756 "Parser/parser.y"
                       {
                           NodeCreate(&(yyval.treeNode), NODE_VISIBILITY);
                           yyval.treeNode->nodeData.dVal = VIS_EXTERN;
                       }
#line 2719 "Parser/parser.tab.c"
    break;

  case 114: /* visibility_qualifier: TOKEN_INLINE  */
#line 761 "Parser/parser.y"
                       {
                           NodeCreate(&(yyval.treeNode), NODE_VISIBILITY);
                           yyval.treeNode->nodeData.dVal = VIS_INLINE;
                       }
#line 2728 "Parser/parser.tab.c"
    break;

  case 115: /* mod_qualifier: %empty  */
#line 767 "Parser/parser.y"
                               { NodeCreate(&(yyval.treeNode), NODE_NULL); }
#line 2734 "Parser/parser.tab.c"
    break;

  case 116: /* mod_qualifier: TOKEN_CONST  */
#line 769 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_MODIFIER);
                            yyval.treeNode->nodeData.dVal = (long int) MOD_CONST;
                        }
#line 2743 "Parser/parser.tab.c"
    break;

  case 117: /* mod_qualifier: TOKEN_VOLATILE  */
#line 774 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_MODIFIER);
                            yyval.treeNode->nodeData.dVal = (long int) MOD_VOLATILE;
                        }
#line 2752 "Parser/parser.tab.c"
    break;

  case 118: /* sign_qualifier: %empty  */
#line 780 "Parser/parser.y"
                               { NodeCreate(&(yyval.treeNode), NODE_NULL); }
#line 2758 "Parser/parser.tab.c"
    break;

  case 119: /* sign_qualifier: TOKEN_SIGNED  */
#line 782 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_SIGN);
                            yyval.treeNode->nodeData.dVal = (long int) SIGN_SIGNED;
                        }
#line 2767 "Parser/parser.tab.c"
    break;

  case 120: /* sign_qualifier: TOKEN_UNSIGNED  */
#line 787 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_SIGN);
                            yyval.treeNode->nodeData.dVal = (long int) SIGN_UNSIGNED;
                        }
#line 2776 "Parser/parser.tab.c"
    break;

  case 121: /* var_declaration: var_preamble id_list TOKEN_SEMI  */
#line 800 "Parser/parser.y"
                    {
                        TreeNode_t* pNode = yyvsp[-1].treeNode;
                        do {
                            if (pNode->nodeType == NODE_VAR_DECLARATION ||
                                pNode->nodeType == NODE_ARRAY_DECLARATION) { 
                                NodeAddChildCopy(pNode, yyvsp[-2].treeNode);
                            }
                            pNode = pNode->p_sibling;
                        } while (pNode != NULL);
                        free(yyvsp[-2].treeNode);
                        yyval.treeNode = yyvsp[-1].treeNode;
                    }
#line 2793 "Parser/parser.tab.c"
    break;

  case 122: /* arr_size: TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET  */
#line 816 "Parser/parser.y"
                { yyval.treeNode = yyvsp[-1].treeNode; }
#line 2799 "Parser/parser.tab.c"
    break;

  case 123: /* arr_size: TOKEN_LEFT_BRACKET TOKEN_RIGHT_BRACKET  */
#line 818 "Parser/parser.y"
                { NodeCreate(&(yyval.treeNode), NODE_NULL); }
#line 2805 "Parser/parser.tab.c"
    break;

  case 124: /* arr_size: arr_size TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET  */
#line 820 "Parser/parser.y"
                {
                    TreeNode_t* pHead = yyvsp[-3].treeNode;
                    if (NodeAppendSibling(&pHead, yyvsp[-1].treeNode)) { YYERROR; }
                    yyval.treeNode = pHead;
                }
#line 2815 "Parser/parser.tab.c"
    break;

  case 125: /* id_list: TOKEN_ID  */
#line 830 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
                        yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                    }
#line 2824 "Parser/parser.tab.c"
    break;

  case 126: /* id_list: TOKEN_ID TOKEN_ASSIGN exp  */
#line 835 "Parser/parser.y"
                  {
		      TreeNode_t* pNode;
		      NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
		      yyval.treeNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
		      TreeNode_t* pAssign;
		      NodeCreate(&pAssign, NODE_OPERATOR);
		      pAssign->nodeData.dVal = OP_ASSIGN;
		      NodeAddNewChild(pAssign, &pNode, NODE_IDENTIFIER);
		      pNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
		      NodeAddChild(pAssign, yyvsp[0].treeNode);
		      if (NodeAppendSibling(&(yyval.treeNode), pAssign)) { YYERROR; }
		  }
#line 2841 "Parser/parser.tab.c"
    break;

  case 127: /* id_list: TOKEN_ID arr_size  */
#line 848 "Parser/parser.y"
                    {
	                NodeCreate(&(yyval.treeNode), NODE_ARRAY_DECLARATION);
	                yyval.treeNode->nodeData.sVal = yyvsp[-1].nodeData.sVal;
	                NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
	            }
#line 2851 "Parser/parser.tab.c"
    break;

  case 128: /* id_list: id_list TOKEN_COMMA TOKEN_ID  */
#line 854 "Parser/parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[-2].treeNode;
                        TreeNode_t* pNewNode;
                        NodeCreate(&pNewNode, NODE_VAR_DECLARATION);
                        pNewNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                        if (NodeAppendSibling(&pHead, pNewNode)) { YYERROR; }
                        yyval.treeNode = pHead;
                    }
#line 2864 "Parser/parser.tab.c"
    break;

  case 129: /* id_list: id_list TOKEN_COMMA TOKEN_ID arr_size  */
#line 863 "Parser/parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[-3].treeNode;
                        TreeNode_t* pNewNode;
                        NodeCreate(&pNewNode, NODE_ARRAY_DECLARATION);
                        pNewNode->nodeData.sVal = yyvsp[-1].nodeData.sVal;
                        NodeAddChild(pNewNode, yyvsp[0].treeNode);
                        if (NodeAppendSibling(&pHead, pNewNode)) { YYERROR; }
                        yyval.treeNode = pHead;
                    }
#line 2878 "Parser/parser.tab.c"
    break;

  case 130: /* id_list: id_list TOKEN_COMMA simple_var_assign  */
#line 874 "Parser/parser.y"
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
#line 2893 "Parser/parser.tab.c"
    break;

  case 131: /* var_preamble: visibility_qualifier mod_qualifier sign_qualifier all_type_specifiers  */
#line 888 "Parser/parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[0].treeNode;

                        if (yyvsp[-1].treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, yyvsp[-1].treeNode);
                        else
                            free(yyvsp[-1].treeNode);

                        if (yyvsp[-2].treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, yyvsp[-2].treeNode);
                        else
                            free(yyvsp[-2].treeNode);

                        if (yyvsp[-3].treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, yyvsp[-3].treeNode);
                        else
                            free(yyvsp[-3].treeNode);

                        yyval.treeNode = pHead;
                    }
#line 2918 "Parser/parser.tab.c"
    break;

  case 132: /* var_assignment: simple_var_assign TOKEN_SEMI  */
#line 912 "Parser/parser.y"
                    { yyval.treeNode = yyvsp[-1].treeNode; }
#line 2924 "Parser/parser.tab.c"
    break;

  case 133: /* var_assignment: compound_var_assign TOKEN_SEMI  */
#line 914 "Parser/parser.y"
                    { yyval.treeNode = yyvsp[-1].treeNode; }
#line 2930 "Parser/parser.tab.c"
    break;

  case 134: /* var_assignment: array_access TOKEN_ASSIGN exp TOKEN_SEMI  */
#line 916 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                        yyval.treeNode->nodeData.dVal = OP_ASSIGN;
                        NodeAddChild(yyval.treeNode, yyvsp[-3].treeNode);
                        NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                    }
#line 2941 "Parser/parser.tab.c"
    break;

  case 135: /* var_assignment: pointer_content TOKEN_ASSIGN exp TOKEN_SEMI  */
#line 923 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                        yyval.treeNode->nodeData.dVal = OP_ASSIGN;
                        NodeAddChild(yyval.treeNode, yyvsp[-3].treeNode);
                        NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                    }
#line 2952 "Parser/parser.tab.c"
    break;

  case 136: /* var_assignment: array_access compound_assign_operator exp TOKEN_SEMI  */
#line 930 "Parser/parser.y"
                    {
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-3].treeNode);
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-1].treeNode);
                        yyval.treeNode = yyvsp[-2].treeNode;
                    }
#line 2962 "Parser/parser.tab.c"
    break;

  case 137: /* var_assignment: factor TOKEN_DOT TOKEN_ID TOKEN_ASSIGN exp TOKEN_SEMI  */
#line 936 "Parser/parser.y"
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
#line 2977 "Parser/parser.tab.c"
    break;

  case 138: /* var_assignment: factor TOKEN_ARROW TOKEN_ID TOKEN_ASSIGN exp TOKEN_SEMI  */
#line 947 "Parser/parser.y"
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
#line 2992 "Parser/parser.tab.c"
    break;

  case 139: /* var_assignment: pointer_content compound_assign_operator exp TOKEN_SEMI  */
#line 958 "Parser/parser.y"
                    {
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-3].treeNode);
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-1].treeNode);
                        yyval.treeNode = yyvsp[-2].treeNode;
                    }
#line 3002 "Parser/parser.tab.c"
    break;

  case 140: /* var_assignment: factor TOKEN_DOT TOKEN_ID compound_assign_operator exp TOKEN_SEMI  */
#line 964 "Parser/parser.y"
                    {
                        TreeNode_t* pMember;
                        NodeCreate(&pMember, NODE_IDENTIFIER);
                        pMember->nodeData.sVal = yyvsp[-3].nodeData.sVal;
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-5].treeNode);
                        NodeAddChild(yyvsp[-2].treeNode, pMember);
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-1].treeNode);
                        yyval.treeNode = yyvsp[-2].treeNode;
                    }
#line 3016 "Parser/parser.tab.c"
    break;

  case 141: /* var_assignment: factor TOKEN_ARROW TOKEN_ID compound_assign_operator exp TOKEN_SEMI  */
#line 974 "Parser/parser.y"
                    {
                        TreeNode_t* pMember;
                        NodeCreate(&pMember, NODE_IDENTIFIER);
                        pMember->nodeData.sVal = yyvsp[-3].nodeData.sVal;
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-5].treeNode);
                        NodeAddChild(yyvsp[-2].treeNode, pMember);
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-1].treeNode);
                        yyval.treeNode = yyvsp[-2].treeNode;
                    }
#line 3030 "Parser/parser.tab.c"
    break;

  case 142: /* exp: exp arithmetic_operator term  */
#line 991 "Parser/parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode; //sets the operator as the root
                }
#line 3040 "Parser/parser.tab.c"
    break;

  case 143: /* exp: exp comparison_operator term  */
#line 997 "Parser/parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 3050 "Parser/parser.tab.c"
    break;

  case 144: /* exp: exp bitwise_operator term  */
#line 1003 "Parser/parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 3060 "Parser/parser.tab.c"
    break;

  case 145: /* exp: exp logic_operator term  */
#line 1009 "Parser/parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 3070 "Parser/parser.tab.c"
    break;

  case 146: /* exp: exp TOKEN_TERNARY exp TOKEN_COLON exp  */
#line 1015 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_TERNARY);
                    NodeAddChild(yyval.treeNode, yyvsp[-4].treeNode);
                    NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 3081 "Parser/parser.tab.c"
    break;

  case 147: /* exp: term  */
#line 1031 "Parser/parser.y"
                {
                    yyval.treeNode = yyvsp[0].treeNode;
                }
#line 3089 "Parser/parser.tab.c"
    break;

  case 148: /* term: term priority_operator operand  */
#line 1038 "Parser/parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 3099 "Parser/parser.tab.c"
    break;

  case 149: /* term: operand  */
#line 1044 "Parser/parser.y"
                { yyval.treeNode = yyvsp[0].treeNode; }
#line 3105 "Parser/parser.tab.c"
    break;

  case 150: /* operand: TOKEN_MINUS operand  */
#line 1049 "Parser/parser.y"
                {
		      NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
		      yyval.treeNode->nodeData.dVal = OP_UNARY_MINUS;
		      NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
		 }
#line 3115 "Parser/parser.tab.c"
    break;

  case 151: /* operand: TOKEN_INCREMENT operand  */
#line 1055 "Parser/parser.y"
                {
		    NodeCreate(&(yyval.treeNode), NODE_PRE_INC);
		    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
		}
#line 3124 "Parser/parser.tab.c"
    break;

  case 152: /* operand: TOKEN_DECREMENT operand  */
#line 1060 "Parser/parser.y"
                {
		    NodeCreate(&(yyval.treeNode), NODE_PRE_DEC);
		    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
		}
#line 3133 "Parser/parser.tab.c"
    break;

  case 153: /* operand: TOKEN_LOGICAL_NOT factor  */
#line 1065 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                    yyval.treeNode->nodeData.dVal = OP_LOGICAL_NOT;
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 3143 "Parser/parser.tab.c"
    break;

  case 154: /* operand: TOKEN_BITWISE_NOT term  */
#line 1071 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                    yyval.treeNode->nodeData.dVal = OP_BITWISE_NOT;
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 3153 "Parser/parser.tab.c"
    break;

  case 155: /* operand: type_cast_specifier factor  */
#line 1077 "Parser/parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 3162 "Parser/parser.tab.c"
    break;

  case 156: /* operand: factor  */
#line 1082 "Parser/parser.y"
                {
                    yyval.treeNode = yyvsp[0].treeNode;
                }
#line 3170 "Parser/parser.tab.c"
    break;

  case 157: /* factor: TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES  */
#line 1089 "Parser/parser.y"
                {
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 3178 "Parser/parser.tab.c"
    break;

  case 158: /* factor: array_access  */
#line 1093 "Parser/parser.y"
                {
                    yyval.treeNode = yyvsp[0].treeNode;
                }
#line 3186 "Parser/parser.tab.c"
    break;

  case 159: /* factor: TOKEN_NUM  */
#line 1097 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_INTEGER);
                    yyval.treeNode->nodeData.dVal = yyvsp[0].nodeData.dVal;
                }
#line 3195 "Parser/parser.tab.c"
    break;

  case 160: /* factor: TOKEN_ID  */
#line 1102 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_IDENTIFIER);
                    yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                }
#line 3204 "Parser/parser.tab.c"
    break;

  case 161: /* factor: pointer_content  */
#line 1107 "Parser/parser.y"
                { yyval.treeNode = yyvsp[0].treeNode; }
#line 3210 "Parser/parser.tab.c"
    break;

  case 162: /* factor: TOKEN_FNUM  */
#line 1109 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_FLOAT);
                    yyval.treeNode->nodeData.fVal = yyvsp[0].nodeData.fVal;
                }
#line 3219 "Parser/parser.tab.c"
    break;

  case 163: /* factor: TOKEN_CNUM  */
#line 1114 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_CHAR);
                    yyval.treeNode->nodeData.dVal = yyvsp[0].nodeData.dVal;
                }
#line 3228 "Parser/parser.tab.c"
    break;

  case 164: /* factor: TOKEN_STR  */
#line 1119 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_STRING);
                    yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                }
#line 3237 "Parser/parser.tab.c"
    break;

  case 165: /* factor: TOKEN_BITWISE_AND array_access  */
#line 1124 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_REFERENCE);
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 3246 "Parser/parser.tab.c"
    break;

  case 166: /* factor: TOKEN_BITWISE_AND TOKEN_ID  */
#line 1129 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_REFERENCE);
                    yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                }
#line 3255 "Parser/parser.tab.c"
    break;

  case 167: /* factor: TOKEN_SIZEOF TOKEN_LEFT_PARENTHESES sizeof_operand TOKEN_RIGHT_PARENTHESES  */
#line 1134 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                    yyval.treeNode->nodeData.dVal = OP_SIZEOF;
                    NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                }
#line 3265 "Parser/parser.tab.c"
    break;

  case 168: /* factor: func_call  */
#line 1140 "Parser/parser.y"
                     { yyval.treeNode = yyvsp[0].treeNode; }
#line 3271 "Parser/parser.tab.c"
    break;

  case 169: /* factor: factor TOKEN_INCREMENT  */
#line 1142 "Parser/parser.y"
                {
		    NodeCreate(&(yyval.treeNode), NODE_POST_INC);
		    NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
		}
#line 3280 "Parser/parser.tab.c"
    break;

  case 170: /* factor: factor TOKEN_DECREMENT  */
#line 1147 "Parser/parser.y"
                {
		    NodeCreate(&(yyval.treeNode), NODE_POST_DEC);
		    NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
		}
#line 3289 "Parser/parser.tab.c"
    break;

  case 171: /* factor: factor TOKEN_DOT TOKEN_ID  */
#line 1152 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_IDENTIFIER);
                    yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                    NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                }
#line 3299 "Parser/parser.tab.c"
    break;

  case 172: /* factor: factor TOKEN_ARROW TOKEN_ID  */
#line 1158 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_IDENTIFIER);
                    yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                    NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                }
#line 3309 "Parser/parser.tab.c"
    break;

  case 173: /* sizeof_operand: all_type_specifiers  */
#line 1167 "Parser/parser.y"
                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 3315 "Parser/parser.tab.c"
    break;

  case 174: /* sizeof_operand: exp  */
#line 1169 "Parser/parser.y"
                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 3321 "Parser/parser.tab.c"
    break;

  case 175: /* array_access: TOKEN_ID TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET  */
#line 1174 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_ARRAY_ACCESS);
                    yyval.treeNode->nodeData.sVal = yyvsp[-3].nodeData.sVal;
                    NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                }
#line 3331 "Parser/parser.tab.c"
    break;

  case 176: /* array_access: array_access TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET  */
#line 1180 "Parser/parser.y"
                {
                    NodeAddChild(yyvsp[-3].treeNode, yyvsp[-1].treeNode);
                    yyval.treeNode = yyvsp[-3].treeNode;
                }
#line 3340 "Parser/parser.tab.c"
    break;

  case 177: /* pointer_content: TOKEN_ASTERISK pointer_content  */
#line 1187 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_POINTER_CONTENT);
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 3349 "Parser/parser.tab.c"
    break;

  case 178: /* pointer_content: TOKEN_ASTERISK TOKEN_ID  */
#line 1192 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_POINTER_CONTENT);
                        yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                    }
#line 3358 "Parser/parser.tab.c"
    break;

  case 179: /* pointer_content: TOKEN_ASTERISK array_access  */
#line 1197 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_POINTER_CONTENT);
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 3367 "Parser/parser.tab.c"
    break;

  case 180: /* pointer_content: TOKEN_ASTERISK TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES  */
#line 1202 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_POINTER_CONTENT);
                        NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                    }
#line 3376 "Parser/parser.tab.c"
    break;

  case 181: /* priority_operator: TOKEN_ASTERISK  */
#line 1213 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_MULTIPLY;
                        }
#line 3385 "Parser/parser.tab.c"
    break;

  case 182: /* priority_operator: TOKEN_DIVIDE  */
#line 1218 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_DIVIDE;
                        }
#line 3394 "Parser/parser.tab.c"
    break;

  case 183: /* priority_operator: TOKEN_MOD  */
#line 1223 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_MODULE;
                        }
#line 3403 "Parser/parser.tab.c"
    break;

  case 184: /* arithmetic_operator: TOKEN_PLUS  */
#line 1230 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_PLUS;
                        }
#line 3412 "Parser/parser.tab.c"
    break;

  case 185: /* arithmetic_operator: TOKEN_MINUS  */
#line 1235 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_MINUS;
                        }
#line 3421 "Parser/parser.tab.c"
    break;

  case 186: /* arithmetic_operator: TOKEN_RIGHT_SHIFT  */
#line 1240 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_RIGHT_SHIFT;
                        }
#line 3430 "Parser/parser.tab.c"
    break;

  case 187: /* arithmetic_operator: TOKEN_LEFT_SHIFT  */
#line 1245 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_LEFT_SHIFT;
                        }
#line 3439 "Parser/parser.tab.c"
    break;

  case 188: /* comparison_operator: TOKEN_EQUAL  */
#line 1252 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_EQUAL;
                        }
#line 3448 "Parser/parser.tab.c"
    break;

  case 189: /* comparison_operator: TOKEN_NOT_EQUAL  */
#line 1257 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_NOT_EQUAL;
                        }
#line 3457 "Parser/parser.tab.c"
    break;

  case 190: /* comparison_operator: TOKEN_GREATER_THAN  */
#line 1262 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_GREATER_THAN;
                        }
#line 3466 "Parser/parser.tab.c"
    break;

  case 191: /* comparison_operator: TOKEN_LESS_THAN_OR_EQUAL  */
#line 1267 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_LESS_THAN_OR_EQUAL;
                        }
#line 3475 "Parser/parser.tab.c"
    break;

  case 192: /* comparison_operator: TOKEN_GREATER_THAN_OR_EQUAL  */
#line 1272 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_GREATER_THAN_OR_EQUAL;
                        }
#line 3484 "Parser/parser.tab.c"
    break;

  case 193: /* comparison_operator: TOKEN_LESS_THAN  */
#line 1277 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_LESS_THAN;
                        }
#line 3493 "Parser/parser.tab.c"
    break;

  case 194: /* bitwise_operator: TOKEN_BITWISE_AND  */
#line 1284 "Parser/parser.y"
                        {
                             NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                             yyval.treeNode->nodeData.dVal = OP_BITWISE_AND;
                         }
#line 3502 "Parser/parser.tab.c"
    break;

  case 195: /* bitwise_operator: TOKEN_BITWISE_OR  */
#line 1289 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_BITWISE_OR;
                        }
#line 3511 "Parser/parser.tab.c"
    break;

  case 196: /* bitwise_operator: TOKEN_BITWISE_XOR  */
#line 1294 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_BITWISE_XOR;
                        }
#line 3520 "Parser/parser.tab.c"
    break;

  case 197: /* logic_operator: TOKEN_LOGICAL_AND  */
#line 1301 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_LOGICAL_AND;
                        }
#line 3529 "Parser/parser.tab.c"
    break;

  case 198: /* logic_operator: TOKEN_LOGICAL_OR  */
#line 1306 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_LOGICAL_OR;
                        }
#line 3538 "Parser/parser.tab.c"
    break;

  case 199: /* compound_assign_operator: TOKEN_PLUS_ASSIGN  */
#line 1313 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_PLUS_ASSIGN;
                        }
#line 3547 "Parser/parser.tab.c"
    break;

  case 200: /* compound_assign_operator: TOKEN_MINUS_ASSIGN  */
#line 1318 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_MINUS_ASSIGN;
                        }
#line 3556 "Parser/parser.tab.c"
    break;

  case 201: /* compound_assign_operator: TOKEN_MODULUS_ASSIGN  */
#line 1323 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_MODULUS_ASSIGN;
                        }
#line 3565 "Parser/parser.tab.c"
    break;

  case 202: /* compound_assign_operator: TOKEN_LEFT_SHIFT_ASSIGN  */
#line 1328 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_LEFT_SHIFT_ASSIGN;
                        }
#line 3574 "Parser/parser.tab.c"
    break;

  case 203: /* compound_assign_operator: TOKEN_RIGHT_SHIFT_ASSIGN  */
#line 1333 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_RIGHT_SHIFT_ASSIGN;
                        }
#line 3583 "Parser/parser.tab.c"
    break;

  case 204: /* compound_assign_operator: TOKEN_AND_ASSIGN  */
#line 1338 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_BITWISE_AND_ASSIGN;
                        }
#line 3592 "Parser/parser.tab.c"
    break;

  case 205: /* compound_assign_operator: TOKEN_OR_ASSIGN  */
#line 1343 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_BITWISE_OR_ASSIGN;
                        }
#line 3601 "Parser/parser.tab.c"
    break;

  case 206: /* compound_assign_operator: TOKEN_XOR_ASSIGN  */
#line 1348 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_BITWISE_XOR_ASSIGN;
                        }
#line 3610 "Parser/parser.tab.c"
    break;

  case 207: /* compound_assign_operator: TOKEN_MULTIPLY_ASSIGN  */
#line 1353 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_MULTIPLY_ASSIGN;
                        }
#line 3619 "Parser/parser.tab.c"
    break;

  case 208: /* compound_assign_operator: TOKEN_DIVIDE_ASSIGN  */
#line 1358 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_DIVIDE_ASSIGN;
                        }
#line 3628 "Parser/parser.tab.c"
    break;


#line 3632 "Parser/parser.tab.c"

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

#line 1367 "Parser/parser.y"


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
    }
    return result;
}
