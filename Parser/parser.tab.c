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

//for preprocessor #define/#undef directives
extern char pp_name[256];
extern char pp_value[512];

#line 91 "Parser/parser.tab.c"

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
  YYSYMBOL_statement_sequence = 92,        /* statement_sequence  */
  YYSYMBOL_statement = 93,                 /* statement  */
  YYSYMBOL_def_undef_definition = 94,      /* def_undef_definition  */
  YYSYMBOL_define = 95,                    /* define  */
  YYSYMBOL_undef = 96,                     /* undef  */
  YYSYMBOL_selection_statement = 97,       /* selection_statement  */
  YYSYMBOL_jump_statement = 98,            /* jump_statement  */
  YYSYMBOL_iteration_statement = 99,       /* iteration_statement  */
  YYSYMBOL_type_declaration = 100,         /* type_declaration  */
  YYSYMBOL_compound_statement = 101,       /* compound_statement  */
  YYSYMBOL_enum_declaration = 102,         /* enum_declaration  */
  YYSYMBOL_enum_member_list = 103,         /* enum_member_list  */
  YYSYMBOL_enum_member = 104,              /* enum_member  */
  YYSYMBOL_struct_declaration = 105,       /* struct_declaration  */
  YYSYMBOL_union_declaration = 106,        /* union_declaration  */
  YYSYMBOL_struct_union_member_list = 107, /* struct_union_member_list  */
  YYSYMBOL_struct_member = 108,            /* struct_member  */
  YYSYMBOL_if_statement = 109,             /* if_statement  */
  YYSYMBOL_switch_statement = 110,         /* switch_statement  */
  YYSYMBOL_switch_body = 111,              /* switch_body  */
  YYSYMBOL_case_list = 112,                /* case_list  */
  YYSYMBOL_case_clause = 113,              /* case_clause  */
  YYSYMBOL_default_clause = 114,           /* default_clause  */
  YYSYMBOL_continue_statement = 115,       /* continue_statement  */
  YYSYMBOL_break_statement = 116,          /* break_statement  */
  YYSYMBOL_return_statement = 117,         /* return_statement  */
  YYSYMBOL_while_loop = 118,               /* while_loop  */
  YYSYMBOL_do_while_loop = 119,            /* do_while_loop  */
  YYSYMBOL_for_loop = 120,                 /* for_loop  */
  YYSYMBOL_for_init_field = 121,           /* for_init_field  */
  YYSYMBOL_for_condition = 122,            /* for_condition  */
  YYSYMBOL_for_assignment_field = 123,     /* for_assignment_field  */
  YYSYMBOL_simple_var_assign = 124,        /* simple_var_assign  */
  YYSYMBOL_compound_var_assign = 125,      /* compound_var_assign  */
  YYSYMBOL_function_prototype = 126,       /* function_prototype  */
  YYSYMBOL_function_definition = 127,      /* function_definition  */
  YYSYMBOL_function_signature = 128,       /* function_signature  */
  YYSYMBOL_arg_list = 129,                 /* arg_list  */
  YYSYMBOL_param_declaration = 130,        /* param_declaration  */
  YYSYMBOL_func_call = 131,                /* func_call  */
  YYSYMBOL_exp_list = 132,                 /* exp_list  */
  YYSYMBOL_type_cast_specifier = 133,      /* type_cast_specifier  */
  YYSYMBOL_all_type_specifiers = 134,      /* all_type_specifiers  */
  YYSYMBOL_type_pointer = 135,             /* type_pointer  */
  YYSYMBOL_data_type_specifier = 136,      /* data_type_specifier  */
  YYSYMBOL_visibility_qualifier = 137,     /* visibility_qualifier  */
  YYSYMBOL_mod_qualifier = 138,            /* mod_qualifier  */
  YYSYMBOL_sign_qualifier = 139,           /* sign_qualifier  */
  YYSYMBOL_var_declaration = 140,          /* var_declaration  */
  YYSYMBOL_arr_size = 141,                 /* arr_size  */
  YYSYMBOL_id_list = 142,                  /* id_list  */
  YYSYMBOL_var_preamble = 143,             /* var_preamble  */
  YYSYMBOL_var_assignment = 144,           /* var_assignment  */
  YYSYMBOL_exp = 145,                      /* exp  */
  YYSYMBOL_term = 146,                     /* term  */
  YYSYMBOL_operand = 147,                  /* operand  */
  YYSYMBOL_factor = 148,                   /* factor  */
  YYSYMBOL_sizeof_operand = 149,           /* sizeof_operand  */
  YYSYMBOL_array_access = 150,             /* array_access  */
  YYSYMBOL_pointer_content = 151,          /* pointer_content  */
  YYSYMBOL_priority_operator = 152,        /* priority_operator  */
  YYSYMBOL_arithmetic_operator = 153,      /* arithmetic_operator  */
  YYSYMBOL_comparison_operator = 154,      /* comparison_operator  */
  YYSYMBOL_bitwise_operator = 155,         /* bitwise_operator  */
  YYSYMBOL_logic_operator = 156,           /* logic_operator  */
  YYSYMBOL_compound_assign_operator = 157  /* compound_assign_operator  */
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
#define YYFINAL  47
#define YYFINAL  47
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   1460
#define YYLAST   1460

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  89
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  69
#define YYNNTS  69
/* YYNRULES -- Number of rules.  */
#define YYNRULES  214
#define YYNRULES  214
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  364
#define YYNSTATES  364

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
       0,   124,   124,   130,   138,   145,   146,   147,   148,   149,
     150,   154,   155,   169,   170,   171,   172,   173,   174,   175,
     176,   183,   184,   187,   201,   214,   215,   218,   219,   220,
     223,   224,   225,   228,   229,   230,   233,   258,   266,   267,
     273,   277,   282,   291,   303,   312,   322,   323,   332,   338,
     351,   357,   366,   374,   380,   384,   390,   394,   402,   409,
     415,   423,   434,   438,   442,   447,   459,   468,   476,   506,
     507,   516,   530,   537,   538,   541,   542,   543,   544,   547,
     558,   572,   578,   586,   597,   599,   608,   614,   618,   626,
     634,   643,   652,   656,   662,   674,   682,   683,   686,   691,
     699,   704,   709,   714,   719,   724,   729,   733,   738,   743,
     748,   757,   766,   777,   782,   787,   794,   799,   806,   811,
     823,   840,   842,   844,   852,   857,   870,   876,   885,   896,
     911,   915,   924,   933,   942,   955,   968,   981,  1001,  1002,
    1003,  1010,  1017,  1023,  1034,  1045,  1051,  1061,  1078,  1084,
    1090,  1096,  1102,  1109,  1116,  1122,  1126,  1132,  1137,  1142,
    1148,  1154,  1159,  1166,  1170,  1174,  1179,  1184,  1186,  1191,
    1196,  1201,  1206,  1211,  1217,  1218,  1223,  1228,  1234,  1243,
    1245,  1250,  1256,  1263,  1268,  1273,  1278,  1289,  1294,  1299,
    1306,  1311,  1316,  1321,  1328,  1333,  1338,  1343,  1348,  1353,
    1360,  1365,  1370,  1377,  1382,  1389,  1394,  1399,  1404,  1409,
    1414,  1419,  1424,  1429,  1434
       0,   124,   124,   130,   138,   145,   146,   147,   148,   149,
     150,   154,   155,   169,   170,   171,   172,   173,   174,   175,
     176,   183,   184,   187,   201,   214,   215,   218,   219,   220,
     223,   224,   225,   228,   229,   230,   233,   258,   266,   267,
     273,   277,   282,   291,   303,   312,   322,   323,   332,   338,
     351,   357,   366,   374,   380,   384,   390,   394,   402,   409,
     415,   423,   434,   438,   442,   447,   459,   468,   476,   506,
     507,   516,   530,   537,   538,   541,   542,   543,   544,   547,
     558,   572,   578,   586,   597,   599,   608,   614,   618,   626,
     634,   643,   652,   656,   662,   674,   682,   683,   686,   691,
     699,   704,   709,   714,   719,   724,   729,   733,   738,   743,
     748,   757,   766,   777,   782,   787,   794,   799,   806,   811,
     823,   840,   842,   844,   852,   857,   870,   876,   885,   896,
     911,   915,   924,   933,   942,   955,   968,   981,  1001,  1002,
    1003,  1010,  1017,  1023,  1034,  1045,  1051,  1061,  1078,  1084,
    1090,  1096,  1102,  1109,  1116,  1122,  1126,  1132,  1137,  1142,
    1148,  1154,  1159,  1166,  1170,  1174,  1179,  1184,  1186,  1191,
    1196,  1201,  1206,  1211,  1217,  1218,  1223,  1228,  1234,  1243,
    1245,  1250,  1256,  1263,  1268,  1273,  1278,  1289,  1294,  1299,
    1306,  1311,  1316,  1321,  1328,  1333,  1338,  1343,  1348,  1353,
    1360,  1365,  1370,  1377,  1382,  1389,  1394,  1399,  1404,  1409,
    1414,  1419,  1424,  1429,  1434
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
  "program", "global_statement", "statement_sequence", "statement",
  "def_undef_definition", "define", "undef", "selection_statement",
  "jump_statement", "iteration_statement", "type_declaration",
  "compound_statement", "enum_declaration", "enum_member_list",
  "enum_member", "struct_declaration", "union_declaration",
  "struct_union_member_list", "struct_member", "if_statement",
  "switch_statement", "switch_body", "case_list", "case_clause",
  "default_clause", "continue_statement", "break_statement",
  "return_statement", "while_loop", "do_while_loop", "for_loop",
  "for_init_field", "for_condition", "for_assignment_field",
  "simple_var_assign", "compound_var_assign", "function_prototype",
  "function_definition", "function_signature", "arg_list",
  "param_declaration", "func_call", "exp_list", "type_cast_specifier",
  "function_definition", "function_signature", "arg_list",
  "param_declaration", "func_call", "exp_list", "type_cast_specifier",
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

#define YYPACT_NINF (-199)
#define YYPACT_NINF (-199)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-1)
#define YYTABLE_NINF (-1)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
     559,  -199,  -199,  -199,  -199,  -199,  -199,  -199,  -199,   124,
      26,  -199,  -199,  -199,  -199,    50,    85,    91,  -199,  -199,
    -199,    59,  -199,  -199,  -199,  -199,  -199,  -199,  -199,  -199,
    -199,  -199,   -37,  -199,    92,    96,  1397,   258,  1414,  -199,
     144,  -199,  -199,  -199,    72,    80,    99,  -199,  -199,  -199,
    -199,  -199,  -199,  -199,  -199,   162,   174,   175,  -199,   258,
    1414,  -199,  1414,  -199,   -38,    88,  1380,  1380,   176,   303,
    -199,  -199,  -199,  -199,  1414,  -199,  -199,   481,  1380,   105,
     103,  -199,   180,   195,  -199,   181,   343,   145,   -22,  -199,
    -199,  -199,  -199,  -199,   574,   111,   113,   114,   115,   116,
     383,   121,   123,   464,   481,    10,   481,   481,    81,   192,
     481,   434,  -199,  -199,  -199,  -199,  -199,  -199,  -199,  -199,
    -199,  -199,  -199,  -199,  -199,  -199,   126,   146,  -199,   119,
    -199,    81,  -199,  -199,   908,   125,  -199,    -9,  1304,   538,
    -199,    21,  1271,    82,   137,  -199,    27,  -199,   215,  -199,
     578,   481,   -30,  -199,   148,  -199,   -51,   149,    16,   176,
     150,   481,  -199,  -199,  -199,  -199,  -199,  -199,  -199,  -199,
    -199,  -199,   481,   481,   481,   434,   481,   481,  1354,   481,
     194,  -199,  -199,  -199,   941,  -199,   147,   481,   137,  -199,
    -199,  -199,   481,    82,   147,   137,  -199,   151,   710,  -199,
    -199,    82,  -199,  -199,  -199,  -199,  -199,  -199,  -199,  -199,
    -199,  -199,  -199,  -199,  -199,  -199,  -199,  -199,   481,   481,
     481,   481,   481,  -199,  -199,  -199,   481,  -199,  -199,   221,
     227,   481,   481,   481,   481,   481,   228,   230,   590,  -199,
     157,  -199,   611,   103,  -199,  -199,   -17,  -199,  -199,   238,
    -199,  -199,  1271,    48,  1271,   644,  1271,  -199,  1271,   165,
     743,   776,   201,   178,   247,   809,   177,  -199,   842,  -199,
    -199,   974,   125,   125,   125,   125,  -199,  1393,  1404,  1007,
     677,  1040,  1073,  1106,  -199,  -199,  -199,  -199,   103,  -199,
    -199,  -199,   481,  -199,  -199,  -199,   383,   182,   481,   481,
     211,   383,   481,  -199,   481,   481,   481,   481,   481,  -199,
    -199,  -199,  -199,  -199,  1271,   231,   143,  1271,   186,  1271,
     481,  -199,   875,  1271,  1139,  1172,  1205,  1238,   383,    15,
     185,   196,   143,  -199,  -199,   487,  1271,   208,  -199,  -199,
    -199,  -199,  -199,   199,   207,   209,  -199,  -199,  -199,  -199,
     205,  -199,  -199,  1271,  -199,  -199,  -199,  -199,   383,   383,
     383,   383,   383,  -199
     559,  -199,  -199,  -199,  -199,  -199,  -199,  -199,  -199,   124,
      26,  -199,  -199,  -199,  -199,    50,    85,    91,  -199,  -199,
    -199,    59,  -199,  -199,  -199,  -199,  -199,  -199,  -199,  -199,
    -199,  -199,   -37,  -199,    92,    96,  1397,   258,  1414,  -199,
     144,  -199,  -199,  -199,    72,    80,    99,  -199,  -199,  -199,
    -199,  -199,  -199,  -199,  -199,   162,   174,   175,  -199,   258,
    1414,  -199,  1414,  -199,   -38,    88,  1380,  1380,   176,   303,
    -199,  -199,  -199,  -199,  1414,  -199,  -199,   481,  1380,   105,
     103,  -199,   180,   195,  -199,   181,   343,   145,   -22,  -199,
    -199,  -199,  -199,  -199,   574,   111,   113,   114,   115,   116,
     383,   121,   123,   464,   481,    10,   481,   481,    81,   192,
     481,   434,  -199,  -199,  -199,  -199,  -199,  -199,  -199,  -199,
    -199,  -199,  -199,  -199,  -199,  -199,   126,   146,  -199,   119,
    -199,    81,  -199,  -199,   908,   125,  -199,    -9,  1304,   538,
    -199,    21,  1271,    82,   137,  -199,    27,  -199,   215,  -199,
     578,   481,   -30,  -199,   148,  -199,   -51,   149,    16,   176,
     150,   481,  -199,  -199,  -199,  -199,  -199,  -199,  -199,  -199,
    -199,  -199,   481,   481,   481,   434,   481,   481,  1354,   481,
     194,  -199,  -199,  -199,   941,  -199,   147,   481,   137,  -199,
    -199,  -199,   481,    82,   147,   137,  -199,   151,   710,  -199,
    -199,    82,  -199,  -199,  -199,  -199,  -199,  -199,  -199,  -199,
    -199,  -199,  -199,  -199,  -199,  -199,  -199,  -199,   481,   481,
     481,   481,   481,  -199,  -199,  -199,   481,  -199,  -199,   221,
     227,   481,   481,   481,   481,   481,   228,   230,   590,  -199,
     157,  -199,   611,   103,  -199,  -199,   -17,  -199,  -199,   238,
    -199,  -199,  1271,    48,  1271,   644,  1271,  -199,  1271,   165,
     743,   776,   201,   178,   247,   809,   177,  -199,   842,  -199,
    -199,   974,   125,   125,   125,   125,  -199,  1393,  1404,  1007,
     677,  1040,  1073,  1106,  -199,  -199,  -199,  -199,   103,  -199,
    -199,  -199,   481,  -199,  -199,  -199,   383,   182,   481,   481,
     211,   383,   481,  -199,   481,   481,   481,   481,   481,  -199,
    -199,  -199,  -199,  -199,  1271,   231,   143,  1271,   186,  1271,
     481,  -199,   875,  1271,  1139,  1172,  1205,  1238,   383,    15,
     185,   196,   143,  -199,  -199,   487,  1271,   208,  -199,  -199,
    -199,  -199,  -199,   199,   207,   209,  -199,  -199,  -199,  -199,
     205,  -199,  -199,  1271,  -199,  -199,  -199,  -199,   383,   383,
     383,   383,   383,  -199
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       0,   102,   100,   106,   107,   109,   115,   118,   119,   103,
     101,   113,   114,   116,   117,     0,     0,     0,    23,    24,
      10,     0,     4,     9,    21,    22,     5,    33,    34,    35,
       7,     8,     0,   130,    97,    96,     0,     0,     0,     6,
       0,   104,   108,   105,   110,   111,   112,     1,     2,     3,
      81,    11,    82,    99,    98,     0,     0,     0,   131,     0,
       0,   132,     0,   133,   124,     0,     0,     0,     0,     0,
     110,   111,   112,   134,     0,   135,   136,     0,    84,     0,
     126,   120,     0,     0,    46,     0,     0,    41,     0,    38,
     165,   168,   169,   170,   166,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    36,    12,    13,    15,    14,    16,    25,    26,
      29,    27,    28,    31,    30,    32,     0,     0,    19,     0,
     174,     0,    17,    18,     0,   153,   155,   162,   164,   167,
     137,   166,   125,   162,   164,   167,     0,    87,    90,   122,
       0,     0,   127,   129,     0,    47,     0,     0,     0,    40,
       0,     0,   205,   206,   213,   214,   207,   210,   211,   212,
     208,   209,    92,     0,     0,     0,     0,     0,    69,     0,
       0,    63,    62,    64,     0,   156,   184,     0,   185,   183,
     157,   158,     0,   159,   172,   171,   160,     0,     0,   138,
     139,   161,   190,   191,   194,   195,   199,   196,   197,   198,
     203,   204,   200,   201,   202,   193,   192,    20,     0,     0,
       0,     0,     0,   187,   188,   189,     0,   175,   176,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    83,
      88,   121,     0,   128,    44,    48,     0,    45,    42,     0,
      39,    37,    79,     0,    94,     0,    80,   179,   180,     0,
       0,     0,     0,     0,     0,     0,     0,    65,     0,    95,
     163,     0,   148,   149,   150,   151,   154,   178,   177,     0,
       0,     0,     0,     0,   178,   177,    85,    86,    89,   123,
      49,    43,     0,    91,   181,   173,     0,     0,     0,    73,
      72,     0,     0,   186,     0,     0,     0,     0,     0,   140,
     182,   142,   141,   145,    93,    50,     0,    70,     0,    74,
       0,    66,     0,   152,     0,     0,     0,     0,     0,     0,
       0,     0,    54,    56,    55,    75,    71,     0,   144,   147,
     143,   146,    51,     0,     0,     0,    11,    52,    57,    53,
       0,    76,    77,    78,    67,    11,    11,    11,    61,     0,
      58,    59,    60,    68
       0,   102,   100,   106,   107,   109,   115,   118,   119,   103,
     101,   113,   114,   116,   117,     0,     0,     0,    23,    24,
      10,     0,     4,     9,    21,    22,     5,    33,    34,    35,
       7,     8,     0,   130,    97,    96,     0,     0,     0,     6,
       0,   104,   108,   105,   110,   111,   112,     1,     2,     3,
      81,    11,    82,    99,    98,     0,     0,     0,   131,     0,
       0,   132,     0,   133,   124,     0,     0,     0,     0,     0,
     110,   111,   112,   134,     0,   135,   136,     0,    84,     0,
     126,   120,     0,     0,    46,     0,     0,    41,     0,    38,
     165,   168,   169,   170,   166,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    36,    12,    13,    15,    14,    16,    25,    26,
      29,    27,    28,    31,    30,    32,     0,     0,    19,     0,
     174,     0,    17,    18,     0,   153,   155,   162,   164,   167,
     137,   166,   125,   162,   164,   167,     0,    87,    90,   122,
       0,     0,   127,   129,     0,    47,     0,     0,     0,    40,
       0,     0,   205,   206,   213,   214,   207,   210,   211,   212,
     208,   209,    92,     0,     0,     0,     0,     0,    69,     0,
       0,    63,    62,    64,     0,   156,   184,     0,   185,   183,
     157,   158,     0,   159,   172,   171,   160,     0,     0,   138,
     139,   161,   190,   191,   194,   195,   199,   196,   197,   198,
     203,   204,   200,   201,   202,   193,   192,    20,     0,     0,
       0,     0,     0,   187,   188,   189,     0,   175,   176,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    83,
      88,   121,     0,   128,    44,    48,     0,    45,    42,     0,
      39,    37,    79,     0,    94,     0,    80,   179,   180,     0,
       0,     0,     0,     0,     0,     0,     0,    65,     0,    95,
     163,     0,   148,   149,   150,   151,   154,   178,   177,     0,
       0,     0,     0,     0,   178,   177,    85,    86,    89,   123,
      49,    43,     0,    91,   181,   173,     0,     0,     0,    73,
      72,     0,     0,   186,     0,     0,     0,     0,     0,   140,
     182,   142,   141,   145,    93,    50,     0,    70,     0,    74,
       0,    66,     0,   152,     0,     0,     0,     0,     0,     0,
       0,     0,    54,    56,    55,    75,    71,     0,   144,   147,
     143,   146,    51,     0,     0,     0,    11,    52,    57,    53,
       0,    76,    77,    78,    67,    11,    11,    11,    61,     0,
      58,    59,    60,    68
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -199,  -199,   266,  -198,   -99,  -199,  -199,  -199,  -199,  -199,
    -199,  -199,   -27,  -199,  -199,   129,  -199,  -199,   233,    69,
    -199,  -199,  -199,  -199,    -2,     0,  -199,  -199,  -199,  -199,
    -199,  -199,  -199,  -199,  -199,   -80,   -41,  -199,    40,    93,
    -199,    95,  -199,  -199,  -199,   -10,  -199,  -199,  -199,   304,
      54,    94,  -141,  -199,   -53,  -199,   -56,   -81,   -97,   -69,
    -199,   -63,   -57,  -199,  -199,  -199,  -199,  -199,  -135
    -199,  -199,   266,  -198,   -99,  -199,  -199,  -199,  -199,  -199,
    -199,  -199,   -27,  -199,  -199,   129,  -199,  -199,   233,    69,
    -199,  -199,  -199,  -199,    -2,     0,  -199,  -199,  -199,  -199,
    -199,  -199,  -199,  -199,  -199,   -80,   -41,  -199,    40,    93,
    -199,    95,  -199,  -199,  -199,   -10,  -199,  -199,  -199,   304,
      54,    94,  -141,  -199,   -53,  -199,   -56,   -81,   -97,   -69,
    -199,   -63,   -57,  -199,  -199,  -199,  -199,  -199,  -135
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,    21,    22,    69,   113,    23,    24,    25,   114,   115,
     116,    26,   117,    27,    88,    89,    28,    29,    83,    84,
     118,   119,   331,   332,   333,   334,   120,   121,   122,   123,
     124,   125,   263,   318,   350,   126,   127,    30,   128,   129,
     146,   147,   130,   253,   131,    33,    34,    35,    36,    37,
      38,   132,    80,    65,    40,   133,   134,   135,   136,   143,
     259,   144,   145,   226,   219,   220,   221,   222,   174
       0,    21,    22,    69,   113,    23,    24,    25,   114,   115,
     116,    26,   117,    27,    88,    89,    28,    29,    83,    84,
     118,   119,   331,   332,   333,   334,   120,   121,   122,   123,
     124,   125,   263,   318,   350,   126,   127,    30,   128,   129,
     146,   147,   130,   253,   131,    33,    34,    35,    36,    37,
      38,   132,    80,    65,    40,   133,   134,   135,   136,   143,
     259,   144,   145,   226,   219,   220,   221,   222,   174
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
     137,   180,   153,   233,   235,    52,   138,   185,    77,   190,
     191,   243,   139,    85,    85,   246,   161,   186,   343,   248,
     344,   142,   345,   150,   245,   148,    58,    61,    63,   196,
      85,   137,    79,    85,    43,   227,   228,   138,    50,   193,
      31,    78,   188,   139,    51,    79,   195,   184,   189,    73,
      75,   105,    76,    79,   159,   198,   249,    44,   290,    47,
     160,    31,   201,   229,   140,   230,   151,     1,     2,     3,
       4,     5,     6,     7,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    90,    91,    92,    93,   141,   187,
      60,    62,    45,    32,    39,   242,    18,    19,    46,   288,
     172,   197,    52,   238,   173,   252,    95,   239,    90,    91,
      92,    93,   141,    74,    32,    39,   254,   255,   256,   258,
     260,   261,   105,   265,   292,   264,   227,   228,   293,   276,
      95,   268,    41,    53,    20,    42,   198,    54,   272,   273,
     274,   275,   306,   308,    48,   104,   105,   109,   358,   106,
     107,    64,   155,    66,   236,   155,   237,   360,   361,   362,
     192,    67,   271,    81,    82,   257,   223,   224,   225,    70,
     108,   109,   329,   330,   110,   279,   280,   281,   282,   283,
      68,    71,    72,    87,   111,   148,   151,   152,   156,   149,
     175,   158,   176,   177,   178,   179,   181,   315,   182,   194,
      51,   199,   321,     1,     2,     3,     4,     5,     6,     7,
       8,     9,    10,    11,    12,    13,    14,    55,    56,    57,
     232,   200,   240,   244,   247,   251,   266,   137,   277,   342,
     173,   269,   137,   138,   278,   284,   314,   285,   138,   139,
      79,   291,   317,   319,   139,   295,   322,   298,   323,   324,
     325,   326,   327,   299,   300,   351,   302,   320,   328,   137,
     363,   335,   346,   316,   336,   138,     1,     2,     3,     4,
       5,   139,     7,     8,     9,    10,   355,   154,   347,   353,
      55,    56,    57,   354,   356,   359,   357,    49,   250,   137,
     137,   137,   137,   137,   352,   138,   138,   138,   138,   138,
      86,   139,   139,   139,   139,   139,    90,    91,    92,    93,
      94,     1,     2,     3,     4,     5,     6,     7,     8,     9,
      10,    11,    12,    13,    14,    55,    56,    57,    95,    96,
     348,    97,   349,   287,    98,    99,   100,   101,   102,   103,
      59,     0,     0,   104,   105,     0,     0,   106,   107,     0,
       0,     1,     2,     3,     4,     5,     6,     7,     8,     9,
      10,    11,    12,    13,    14,    55,    56,    57,   108,   109,
       0,     0,   110,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   111,     0,    51,   112,    90,    91,    92,    93,
      94,     1,     2,     3,     4,     5,     6,     7,     8,     9,
      10,    11,    12,    13,    14,    55,    56,    57,    95,    96,
       0,    97,     0,     0,    98,    99,   100,   101,   102,   103,
       0,     0,     0,   104,   105,   157,     0,   106,   107,     0,
       0,     0,     0,     0,     0,     0,     0,    90,    91,    92,
      93,   141,     1,     2,     3,     4,     5,     0,   108,   109,
       9,    10,   110,     0,     0,     0,    55,    56,    57,    95,
       0,     0,   111,     0,    51,     0,     0,    90,    91,    92,
      93,   141,     0,     0,   104,   105,     0,     0,   106,   107,
       0,     0,     0,     0,    90,    91,    92,    93,   141,    95,
      90,    91,    92,    93,    94,     0,     0,     0,     0,   108,
     109,     0,     0,   110,   104,   105,    95,     0,   106,   107,
       0,     0,    95,   111,     0,     0,     0,     0,     0,     0,
       0,   104,   105,     0,     0,   106,   107,   104,   105,   108,
     109,   106,   107,   110,     0,     0,     0,     0,     0,   183,
       0,     0,     0,   111,     0,     0,   108,   109,     0,     0,
     110,     0,   108,   109,     0,     0,   110,     0,     0,     0,
     111,     0,     0,     0,     0,     0,   111,     1,     2,     3,
       4,     5,     6,     7,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,   234,   162,   163,   164,   165,   166,
     167,   168,   169,   170,   171,     0,    18,    19,     1,     2,
       3,     4,     5,     6,     7,     8,     9,    10,    11,    12,
      13,    14,    55,    56,    57,     0,     0,   202,   203,     0,
     161,   162,   163,   164,   165,   166,   167,   168,   169,   170,
     171,     0,     0,     0,    20,   204,   205,   206,   207,   208,
     209,   210,   211,     0,   212,   213,   214,     0,   215,   216,
     202,   203,     0,   172,     0,     0,   218,   173,     0,     0,
       0,     0,   241,   286,     0,     0,     0,     0,   204,   205,
     206,   207,   208,   209,   210,   211,     0,   212,   213,   214,
       0,   215,   216,   202,   203,     0,     0,     0,     0,   218,
       0,     0,     0,     0,     0,   289,     0,     0,     0,     0,
       0,   204,   205,   206,   207,   208,   209,   210,   211,     0,
     212,   213,   214,     0,   215,   216,   202,   203,     0,     0,
       0,     0,   218,     0,     0,     0,     0,     0,   294,     0,
       0,     0,     0,     0,   204,   205,   206,   207,   208,   209,
     210,   211,     0,   212,   213,   214,     0,   215,   216,   202,
     203,     0,     0,     0,     0,   218,     0,     0,     0,     0,
       0,   310,     0,     0,     0,     0,     0,   204,   205,   206,
     207,   208,   209,   210,   211,     0,   212,   213,   214,     0,
     215,   216,   202,   203,     0,     0,     0,     0,   218,     0,
     270,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     204,   205,   206,   207,   208,   209,   210,   211,     0,   212,
     213,   214,     0,   215,   216,   202,   203,     0,     0,     0,
       0,   218,     0,   296,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   204,   205,   206,   207,   208,   209,   210,
     211,     0,   212,   213,   214,     0,   215,   216,   202,   203,
       0,     0,     0,     0,   218,     0,   297,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   204,   205,   206,   207,
     208,   209,   210,   211,     0,   212,   213,   214,     0,   215,
     216,   202,   203,     0,     0,     0,     0,   218,     0,   301,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   204,
     205,   206,   207,   208,   209,   210,   211,     0,   212,   213,
     214,     0,   215,   216,   202,   203,     0,     0,     0,     0,
     218,     0,   303,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   204,   205,   206,   207,   208,   209,   210,   211,
       0,   212,   213,   214,     0,   215,   216,   202,   203,     0,
       0,     0,     0,   218,     0,   337,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   204,   205,   206,   207,   208,
     209,   210,   211,     0,   212,   213,   214,     0,   215,   216,
     202,   203,     0,   217,     0,     0,   218,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   204,   205,
     206,   207,   208,   209,   210,   211,     0,   212,   213,   214,
       0,   215,   216,   202,   203,     0,   267,     0,     0,   218,
     137,   180,   153,   233,   235,    52,   138,   185,    77,   190,
     191,   243,   139,    85,    85,   246,   161,   186,   343,   248,
     344,   142,   345,   150,   245,   148,    58,    61,    63,   196,
      85,   137,    79,    85,    43,   227,   228,   138,    50,   193,
      31,    78,   188,   139,    51,    79,   195,   184,   189,    73,
      75,   105,    76,    79,   159,   198,   249,    44,   290,    47,
     160,    31,   201,   229,   140,   230,   151,     1,     2,     3,
       4,     5,     6,     7,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    90,    91,    92,    93,   141,   187,
      60,    62,    45,    32,    39,   242,    18,    19,    46,   288,
     172,   197,    52,   238,   173,   252,    95,   239,    90,    91,
      92,    93,   141,    74,    32,    39,   254,   255,   256,   258,
     260,   261,   105,   265,   292,   264,   227,   228,   293,   276,
      95,   268,    41,    53,    20,    42,   198,    54,   272,   273,
     274,   275,   306,   308,    48,   104,   105,   109,   358,   106,
     107,    64,   155,    66,   236,   155,   237,   360,   361,   362,
     192,    67,   271,    81,    82,   257,   223,   224,   225,    70,
     108,   109,   329,   330,   110,   279,   280,   281,   282,   283,
      68,    71,    72,    87,   111,   148,   151,   152,   156,   149,
     175,   158,   176,   177,   178,   179,   181,   315,   182,   194,
      51,   199,   321,     1,     2,     3,     4,     5,     6,     7,
       8,     9,    10,    11,    12,    13,    14,    55,    56,    57,
     232,   200,   240,   244,   247,   251,   266,   137,   277,   342,
     173,   269,   137,   138,   278,   284,   314,   285,   138,   139,
      79,   291,   317,   319,   139,   295,   322,   298,   323,   324,
     325,   326,   327,   299,   300,   351,   302,   320,   328,   137,
     363,   335,   346,   316,   336,   138,     1,     2,     3,     4,
       5,   139,     7,     8,     9,    10,   355,   154,   347,   353,
      55,    56,    57,   354,   356,   359,   357,    49,   250,   137,
     137,   137,   137,   137,   352,   138,   138,   138,   138,   138,
      86,   139,   139,   139,   139,   139,    90,    91,    92,    93,
      94,     1,     2,     3,     4,     5,     6,     7,     8,     9,
      10,    11,    12,    13,    14,    55,    56,    57,    95,    96,
     348,    97,   349,   287,    98,    99,   100,   101,   102,   103,
      59,     0,     0,   104,   105,     0,     0,   106,   107,     0,
       0,     1,     2,     3,     4,     5,     6,     7,     8,     9,
      10,    11,    12,    13,    14,    55,    56,    57,   108,   109,
       0,     0,   110,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   111,     0,    51,   112,    90,    91,    92,    93,
      94,     1,     2,     3,     4,     5,     6,     7,     8,     9,
      10,    11,    12,    13,    14,    55,    56,    57,    95,    96,
       0,    97,     0,     0,    98,    99,   100,   101,   102,   103,
       0,     0,     0,   104,   105,   157,     0,   106,   107,     0,
       0,     0,     0,     0,     0,     0,     0,    90,    91,    92,
      93,   141,     1,     2,     3,     4,     5,     0,   108,   109,
       9,    10,   110,     0,     0,     0,    55,    56,    57,    95,
       0,     0,   111,     0,    51,     0,     0,    90,    91,    92,
      93,   141,     0,     0,   104,   105,     0,     0,   106,   107,
       0,     0,     0,     0,    90,    91,    92,    93,   141,    95,
      90,    91,    92,    93,    94,     0,     0,     0,     0,   108,
     109,     0,     0,   110,   104,   105,    95,     0,   106,   107,
       0,     0,    95,   111,     0,     0,     0,     0,     0,     0,
       0,   104,   105,     0,     0,   106,   107,   104,   105,   108,
     109,   106,   107,   110,     0,     0,     0,     0,     0,   183,
       0,     0,     0,   111,     0,     0,   108,   109,     0,     0,
     110,     0,   108,   109,     0,     0,   110,     0,     0,     0,
     111,     0,     0,     0,     0,     0,   111,     1,     2,     3,
       4,     5,     6,     7,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,   234,   162,   163,   164,   165,   166,
     167,   168,   169,   170,   171,     0,    18,    19,     1,     2,
       3,     4,     5,     6,     7,     8,     9,    10,    11,    12,
      13,    14,    55,    56,    57,     0,     0,   202,   203,     0,
     161,   162,   163,   164,   165,   166,   167,   168,   169,   170,
     171,     0,     0,     0,    20,   204,   205,   206,   207,   208,
     209,   210,   211,     0,   212,   213,   214,     0,   215,   216,
     202,   203,     0,   172,     0,     0,   218,   173,     0,     0,
       0,     0,   241,   286,     0,     0,     0,     0,   204,   205,
     206,   207,   208,   209,   210,   211,     0,   212,   213,   214,
       0,   215,   216,   202,   203,     0,     0,     0,     0,   218,
       0,     0,     0,     0,     0,   289,     0,     0,     0,     0,
       0,   204,   205,   206,   207,   208,   209,   210,   211,     0,
     212,   213,   214,     0,   215,   216,   202,   203,     0,     0,
       0,     0,   218,     0,     0,     0,     0,     0,   294,     0,
       0,     0,     0,     0,   204,   205,   206,   207,   208,   209,
     210,   211,     0,   212,   213,   214,     0,   215,   216,   202,
     203,     0,     0,     0,     0,   218,     0,     0,     0,     0,
       0,   310,     0,     0,     0,     0,     0,   204,   205,   206,
     207,   208,   209,   210,   211,     0,   212,   213,   214,     0,
     215,   216,   202,   203,     0,     0,     0,     0,   218,     0,
     270,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     204,   205,   206,   207,   208,   209,   210,   211,     0,   212,
     213,   214,     0,   215,   216,   202,   203,     0,     0,     0,
       0,   218,     0,   296,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   204,   205,   206,   207,   208,   209,   210,
     211,     0,   212,   213,   214,     0,   215,   216,   202,   203,
       0,     0,     0,     0,   218,     0,   297,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   204,   205,   206,   207,
     208,   209,   210,   211,     0,   212,   213,   214,     0,   215,
     216,   202,   203,     0,     0,     0,     0,   218,     0,   301,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   204,
     205,   206,   207,   208,   209,   210,   211,     0,   212,   213,
     214,     0,   215,   216,   202,   203,     0,     0,     0,     0,
     218,     0,   303,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   204,   205,   206,   207,   208,   209,   210,   211,
       0,   212,   213,   214,     0,   215,   216,   202,   203,     0,
       0,     0,     0,   218,     0,   337,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   204,   205,   206,   207,   208,
     209,   210,   211,     0,   212,   213,   214,     0,   215,   216,
     202,   203,     0,   217,     0,     0,   218,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   204,   205,
     206,   207,   208,   209,   210,   211,     0,   212,   213,   214,
       0,   215,   216,   202,   203,     0,   267,     0,     0,   218,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   204,   205,   206,   207,   208,   209,   210,   211,     0,
     212,   213,   214,     0,   215,   216,   202,   203,     0,     0,
       0,   304,   218,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   204,   205,   206,   207,   208,   209,
     210,   211,     0,   212,   213,   214,     0,   215,   216,   202,
     203,     0,   309,     0,     0,   218,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   204,   205,   206,
     207,   208,   209,   210,   211,     0,   212,   213,   214,     0,
     215,   216,   202,   203,     0,   311,     0,     0,   218,     0,
       0,   204,   205,   206,   207,   208,   209,   210,   211,     0,
     212,   213,   214,     0,   215,   216,   202,   203,     0,     0,
       0,   304,   218,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   204,   205,   206,   207,   208,   209,
     210,   211,     0,   212,   213,   214,     0,   215,   216,   202,
     203,     0,   309,     0,     0,   218,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   204,   205,   206,
     207,   208,   209,   210,   211,     0,   212,   213,   214,     0,
     215,   216,   202,   203,     0,   311,     0,     0,   218,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     204,   205,   206,   207,   208,   209,   210,   211,     0,   212,
     213,   214,     0,   215,   216,   202,   203,     0,   312,     0,
       0,   218,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   204,   205,   206,   207,   208,   209,   210,
     211,     0,   212,   213,   214,     0,   215,   216,   202,   203,
       0,   313,     0,     0,   218,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   204,   205,   206,   207,
     208,   209,   210,   211,     0,   212,   213,   214,     0,   215,
     216,   202,   203,     0,   338,     0,     0,   218,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   204,
     205,   206,   207,   208,   209,   210,   211,     0,   212,   213,
     214,     0,   215,   216,   202,   203,     0,   339,     0,     0,
     218,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   204,   205,   206,   207,   208,   209,   210,   211,
       0,   212,   213,   214,     0,   215,   216,   202,   203,     0,
     340,     0,     0,   218,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   204,   205,   206,   207,   208,
     209,   210,   211,     0,   212,   213,   214,     0,   215,   216,
     202,   203,     0,   341,     0,     0,   218,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   204,   205,
     206,   207,   208,   209,   210,   211,     0,   212,   213,   214,
       0,   215,   216,     0,     0,     0,     0,     0,     0,   218,
     231,   162,   163,   164,   165,   166,   167,   168,   169,   170,
     171,   262,     1,     2,     3,     4,     5,     6,     7,     8,
       9,    10,    11,    12,    13,    14,    55,    56,    57,     0,
       0,     0,     0,     0,     0,     0,     0,   232,     1,     2,
       3,     4,     5,     6,     7,     8,     9,    10,    11,    12,
      13,    14,    55,    56,    57,     1,     2,     3,     4,     5,
       0,     7,     8,     9,    10,     0,     0,    13,    14,    55,
      56,    57,     1,     2,     3,     4,     5,     0,     0,     0,
       9,    10,     0,     0,     0,     0,    55,    56,    57,   305,
     162,   163,   164,   165,   166,   167,   168,   169,   170,   171,
     307,   162,   163,   164,   165,   166,   167,   168,   169,   170,
     171
     204,   205,   206,   207,   208,   209,   210,   211,     0,   212,
     213,   214,     0,   215,   216,   202,   203,     0,   312,     0,
       0,   218,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   204,   205,   206,   207,   208,   209,   210,
     211,     0,   212,   213,   214,     0,   215,   216,   202,   203,
       0,   313,     0,     0,   218,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   204,   205,   206,   207,
     208,   209,   210,   211,     0,   212,   213,   214,     0,   215,
     216,   202,   203,     0,   338,     0,     0,   218,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   204,
     205,   206,   207,   208,   209,   210,   211,     0,   212,   213,
     214,     0,   215,   216,   202,   203,     0,   339,     0,     0,
     218,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   204,   205,   206,   207,   208,   209,   210,   211,
       0,   212,   213,   214,     0,   215,   216,   202,   203,     0,
     340,     0,     0,   218,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   204,   205,   206,   207,   208,
     209,   210,   211,     0,   212,   213,   214,     0,   215,   216,
     202,   203,     0,   341,     0,     0,   218,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   204,   205,
     206,   207,   208,   209,   210,   211,     0,   212,   213,   214,
       0,   215,   216,     0,     0,     0,     0,     0,     0,   218,
     231,   162,   163,   164,   165,   166,   167,   168,   169,   170,
     171,   262,     1,     2,     3,     4,     5,     6,     7,     8,
       9,    10,    11,    12,    13,    14,    55,    56,    57,     0,
       0,     0,     0,     0,     0,     0,     0,   232,     1,     2,
       3,     4,     5,     6,     7,     8,     9,    10,    11,    12,
      13,    14,    55,    56,    57,     1,     2,     3,     4,     5,
       0,     7,     8,     9,    10,     0,     0,    13,    14,    55,
      56,    57,     1,     2,     3,     4,     5,     0,     0,     0,
       9,    10,     0,     0,     0,     0,    55,    56,    57,   305,
     162,   163,   164,   165,   166,   167,   168,   169,   170,   171,
     307,   162,   163,   164,   165,   166,   167,   168,   169,   170,
     171
};

static const yytype_int16 yycheck[] =
{
      69,   100,    82,   138,   139,    32,    69,   104,    46,   106,
     107,   152,    69,    66,    67,   156,    46,     7,     3,     3,
       5,    77,     7,    79,    75,    78,    36,    37,    38,   110,
      83,   100,    83,    86,     8,    44,    45,   100,    75,   108,
       0,    79,   105,   100,    81,    83,   109,   103,   105,    59,
      60,    41,    62,    83,    76,   111,    40,     7,    75,     0,
      82,    21,   131,    72,    74,    74,    83,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,     3,     4,     5,     6,     7,    79,
      36,    37,     7,     0,     0,   151,    37,    38,     7,   240,
      79,   111,   129,    76,    83,   161,    25,    80,     3,     4,
       5,     6,     7,    59,    21,    21,   172,   173,   174,   175,
     176,   177,    41,   179,    76,   178,    44,    45,    80,   226,
      25,   187,     8,    41,    75,    11,   192,    41,   219,   220,
     221,   222,   277,   278,    85,    40,    41,    66,   346,    44,
      45,     7,    83,    81,    72,    86,    74,   355,   356,   357,
      79,    81,   218,    75,    76,   175,    41,    42,    43,     7,
      65,    66,    29,    30,    69,   231,   232,   233,   234,   235,
      81,     7,     7,     7,    79,   238,    83,     7,     7,    84,
      79,    46,    79,    79,    79,    79,    75,   296,    75,     7,
      81,    75,   301,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      83,    75,     7,    75,    75,    75,    32,   296,     7,   328,
      83,    80,   301,   296,     7,     7,   292,     7,   301,   296,
      83,     3,   298,   299,   301,    80,   302,    46,   304,   305,
     306,   307,   308,    75,     7,   335,    79,    46,    27,   328,
     359,    75,    77,    81,   320,   328,     8,     9,    10,    11,
      12,   328,    14,    15,    16,    17,    77,    82,    82,   335,
      22,    23,    24,    75,    77,    80,    77,    21,   159,   358,
     359,   360,   361,   362,   335,   358,   359,   360,   361,   362,
      67,   358,   359,   360,   361,   362,     3,     4,     5,     6,
       7,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,    25,    26,
     332,    28,   332,   238,    31,    32,    33,    34,    35,    36,
      36,    -1,    -1,    40,    41,    -1,    -1,    44,    45,    -1,
      -1,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,    65,    66,
      -1,    -1,    69,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    79,    -1,    81,    82,     3,     4,     5,     6,
       7,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,    25,    26,
      69,   100,    82,   138,   139,    32,    69,   104,    46,   106,
     107,   152,    69,    66,    67,   156,    46,     7,     3,     3,
       5,    77,     7,    79,    75,    78,    36,    37,    38,   110,
      83,   100,    83,    86,     8,    44,    45,   100,    75,   108,
       0,    79,   105,   100,    81,    83,   109,   103,   105,    59,
      60,    41,    62,    83,    76,   111,    40,     7,    75,     0,
      82,    21,   131,    72,    74,    74,    83,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,     3,     4,     5,     6,     7,    79,
      36,    37,     7,     0,     0,   151,    37,    38,     7,   240,
      79,   111,   129,    76,    83,   161,    25,    80,     3,     4,
       5,     6,     7,    59,    21,    21,   172,   173,   174,   175,
     176,   177,    41,   179,    76,   178,    44,    45,    80,   226,
      25,   187,     8,    41,    75,    11,   192,    41,   219,   220,
     221,   222,   277,   278,    85,    40,    41,    66,   346,    44,
      45,     7,    83,    81,    72,    86,    74,   355,   356,   357,
      79,    81,   218,    75,    76,   175,    41,    42,    43,     7,
      65,    66,    29,    30,    69,   231,   232,   233,   234,   235,
      81,     7,     7,     7,    79,   238,    83,     7,     7,    84,
      79,    46,    79,    79,    79,    79,    75,   296,    75,     7,
      81,    75,   301,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      83,    75,     7,    75,    75,    75,    32,   296,     7,   328,
      83,    80,   301,   296,     7,     7,   292,     7,   301,   296,
      83,     3,   298,   299,   301,    80,   302,    46,   304,   305,
     306,   307,   308,    75,     7,   335,    79,    46,    27,   328,
     359,    75,    77,    81,   320,   328,     8,     9,    10,    11,
      12,   328,    14,    15,    16,    17,    77,    82,    82,   335,
      22,    23,    24,    75,    77,    80,    77,    21,   159,   358,
     359,   360,   361,   362,   335,   358,   359,   360,   361,   362,
      67,   358,   359,   360,   361,   362,     3,     4,     5,     6,
       7,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,    25,    26,
     332,    28,   332,   238,    31,    32,    33,    34,    35,    36,
      36,    -1,    -1,    40,    41,    -1,    -1,    44,    45,    -1,
      -1,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,    65,    66,
      -1,    -1,    69,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    79,    -1,    81,    82,     3,     4,     5,     6,
       7,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,    25,    26,
      -1,    28,    -1,    -1,    31,    32,    33,    34,    35,    36,
      -1,    -1,    -1,    40,    41,    82,    -1,    44,    45,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,     3,     4,     5,
       6,     7,     8,     9,    10,    11,    12,    -1,    65,    66,
      16,    17,    69,    -1,    -1,    -1,    22,    23,    24,    25,
      -1,    -1,    79,    -1,    81,    -1,    -1,     3,     4,     5,
       6,     7,    -1,    -1,    40,    41,    -1,    -1,    44,    45,
      -1,    -1,    -1,    -1,     3,     4,     5,     6,     7,    25,
       3,     4,     5,     6,     7,    -1,    -1,    -1,    -1,    65,
      66,    -1,    -1,    69,    40,    41,    25,    -1,    44,    45,
      -1,    -1,    25,    79,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    40,    41,    -1,    -1,    44,    45,    40,    41,    65,
      66,    44,    45,    69,    -1,    -1,    -1,    -1,    -1,    75,
      -1,    -1,    -1,    79,    -1,    -1,    65,    66,    -1,    -1,
      69,    -1,    65,    66,    -1,    -1,    69,    -1,    -1,    -1,
      79,    -1,    -1,    -1,    -1,    -1,    79,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,    46,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    -1,    37,    38,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,    -1,    -1,    39,    40,    -1,
      46,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      56,    -1,    -1,    -1,    75,    57,    58,    59,    60,    61,
      62,    63,    64,    -1,    66,    67,    68,    -1,    70,    71,
      39,    40,    -1,    79,    -1,    -1,    78,    83,    -1,    -1,
      -1,    -1,    84,    73,    -1,    -1,    -1,    -1,    57,    58,
      59,    60,    61,    62,    63,    64,    -1,    66,    67,    68,
      -1,    70,    71,    39,    40,    -1,    -1,    -1,    -1,    78,
      -1,    -1,    -1,    -1,    -1,    84,    -1,    -1,    -1,    -1,
      -1,    57,    58,    59,    60,    61,    62,    63,    64,    -1,
      66,    67,    68,    -1,    70,    71,    39,    40,    -1,    -1,
      -1,    -1,    78,    -1,    -1,    -1,    -1,    -1,    84,    -1,
      -1,    -1,    -1,    -1,    57,    58,    59,    60,    61,    62,
      63,    64,    -1,    66,    67,    68,    -1,    70,    71,    39,
      40,    -1,    -1,    -1,    -1,    78,    -1,    -1,    -1,    -1,
      -1,    84,    -1,    -1,    -1,    -1,    -1,    57,    58,    59,
      -1,    -1,    -1,    40,    41,    82,    -1,    44,    45,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,     3,     4,     5,
       6,     7,     8,     9,    10,    11,    12,    -1,    65,    66,
      16,    17,    69,    -1,    -1,    -1,    22,    23,    24,    25,
      -1,    -1,    79,    -1,    81,    -1,    -1,     3,     4,     5,
       6,     7,    -1,    -1,    40,    41,    -1,    -1,    44,    45,
      -1,    -1,    -1,    -1,     3,     4,     5,     6,     7,    25,
       3,     4,     5,     6,     7,    -1,    -1,    -1,    -1,    65,
      66,    -1,    -1,    69,    40,    41,    25,    -1,    44,    45,
      -1,    -1,    25,    79,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    40,    41,    -1,    -1,    44,    45,    40,    41,    65,
      66,    44,    45,    69,    -1,    -1,    -1,    -1,    -1,    75,
      -1,    -1,    -1,    79,    -1,    -1,    65,    66,    -1,    -1,
      69,    -1,    65,    66,    -1,    -1,    69,    -1,    -1,    -1,
      79,    -1,    -1,    -1,    -1,    -1,    79,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,    46,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    -1,    37,    38,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,    -1,    -1,    39,    40,    -1,
      46,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      56,    -1,    -1,    -1,    75,    57,    58,    59,    60,    61,
      62,    63,    64,    -1,    66,    67,    68,    -1,    70,    71,
      39,    40,    -1,    79,    -1,    -1,    78,    83,    -1,    -1,
      -1,    -1,    84,    73,    -1,    -1,    -1,    -1,    57,    58,
      59,    60,    61,    62,    63,    64,    -1,    66,    67,    68,
      -1,    70,    71,    39,    40,    -1,    -1,    -1,    -1,    78,
      -1,    -1,    -1,    -1,    -1,    84,    -1,    -1,    -1,    -1,
      -1,    57,    58,    59,    60,    61,    62,    63,    64,    -1,
      66,    67,    68,    -1,    70,    71,    39,    40,    -1,    -1,
      -1,    -1,    78,    -1,    -1,    -1,    -1,    -1,    84,    -1,
      -1,    -1,    -1,    -1,    57,    58,    59,    60,    61,    62,
      63,    64,    -1,    66,    67,    68,    -1,    70,    71,    39,
      40,    -1,    -1,    -1,    -1,    78,    -1,    -1,    -1,    -1,
      -1,    84,    -1,    -1,    -1,    -1,    -1,    57,    58,    59,
      60,    61,    62,    63,    64,    -1,    66,    67,    68,    -1,
      70,    71,    39,    40,    -1,    -1,    -1,    -1,    78,    -1,
      80,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      80,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      57,    58,    59,    60,    61,    62,    63,    64,    -1,    66,
      67,    68,    -1,    70,    71,    39,    40,    -1,    -1,    -1,
      -1,    78,    -1,    80,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    78,    -1,    80,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    57,    58,    59,    60,    61,    62,    63,
      64,    -1,    66,    67,    68,    -1,    70,    71,    39,    40,
      -1,    -1,    -1,    -1,    78,    -1,    80,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    57,    58,    59,    60,
      -1,    -1,    -1,    -1,    78,    -1,    80,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    57,    58,    59,    60,
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
      39,    40,    -1,    75,    -1,    -1,    78,    -1,    -1,    -1,
      39,    40,    -1,    75,    -1,    -1,    78,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    57,    58,
      59,    60,    61,    62,    63,    64,    -1,    66,    67,    68,
      -1,    70,    71,    39,    40,    -1,    75,    -1,    -1,    78,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    70,    71,    39,    40,    -1,    75,    -1,    -1,    78,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    57,    58,    59,    60,    61,    62,    63,    64,    -1,
      66,    67,    68,    -1,    70,    71,    39,    40,    -1,    -1,
      -1,    77,    78,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    77,    78,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
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
      -1,    70,    71,    -1,    -1,    -1,    -1,    -1,    -1,    78,
      46,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      56,     7,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    83,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,     8,     9,    10,    11,    12,
      -1,    14,    15,    16,    17,    -1,    -1,    20,    21,    22,
      23,    24,     8,     9,    10,    11,    12,    -1,    -1,    -1,
      16,    17,    -1,    -1,    -1,    -1,    22,    23,    24,    46,
      47,    48,    49,    50,    51,    52,    53,    54,    55,    56,
      46,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      56
      -1,    70,    71,    -1,    -1,    -1,    -1,    -1,    -1,    78,
      46,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      56,     7,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    83,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,     8,     9,    10,    11,    12,
      -1,    14,    15,    16,    17,    -1,    -1,    20,    21,    22,
      23,    24,     8,     9,    10,    11,    12,    -1,    -1,    -1,
      16,    17,    -1,    -1,    -1,    -1,    22,    23,    24,    46,
      47,    48,    49,    50,    51,    52,    53,    54,    55,    56,
      46,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      56
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,    37,    38,
      75,    90,    91,    94,    95,    96,   100,   102,   105,   106,
     126,   127,   128,   134,   135,   136,   137,   138,   139,   140,
     143,     8,    11,     8,     7,     7,     7,     0,    85,    91,
      75,    81,   101,    41,    41,    22,    23,    24,   134,   138,
     139,   134,   139,   134,     7,   142,    81,    81,    81,    92,
       7,     7,     7,   134,   139,   134,   134,    46,    79,    83,
     141,    75,    76,   107,   108,   143,   107,     7,   103,   104,
       3,     4,     5,     6,     7,    25,    26,    28,    31,    32,
      33,    34,    35,    36,    40,    41,    44,    45,    65,    66,
      69,    79,    82,    93,    97,    98,    99,   101,   109,   110,
     115,   116,   117,   118,   119,   120,   124,   125,   127,   128,
     131,   133,   140,   144,   145,   146,   147,   148,   150,   151,
     134,     7,   145,   148,   150,   151,   129,   130,   143,    84,
     145,    83,     7,   124,    82,   108,     7,    82,    46,    76,
      82,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    79,    83,   157,    79,    79,    79,    79,    79,
      93,    75,    75,    75,   145,   147,     7,    79,   150,   151,
     147,   147,    79,   148,     7,   150,   146,   134,   145,    75,
      75,   148,    39,    40,    57,    58,    59,    60,    61,    62,
      63,    64,    66,    67,    68,    70,    71,    75,    78,   153,
     154,   155,   156,    41,    42,    43,   152,    44,    45,    72,
      74,    46,    83,   157,    46,   157,    72,    74,    76,    80,
       7,    84,   145,   141,    75,    75,   141,    75,     3,    40,
     104,    75,   145,   132,   145,   145,   145,   134,   145,   149,
     145,   145,     7,   121,   143,   145,    32,    75,   145,    80,
      80,   145,   146,   146,   146,   146,   147,     7,     7,   145,
     145,   145,   145,   145,     7,     7,    73,   130,   141,    84,
      75,     3,    76,    80,    84,    80,    80,    80,    46,    75,
       7,    80,    79,    80,    77,    46,   157,    46,   157,    75,
      84,    75,    75,    75,   145,    93,    81,   145,   122,   145,
      46,    93,   145,   145,   145,   145,   145,   145,    27,    29,
      30,   111,   112,   113,   114,    75,   145,    80,    75,    75,
      75,    75,    93,     3,     5,     7,    77,    82,   113,   114,
     123,   124,   125,   145,    75,    77,    77,    77,    92,    80,
      92,    92,    92,    93
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,    37,    38,
      75,    90,    91,    94,    95,    96,   100,   102,   105,   106,
     126,   127,   128,   134,   135,   136,   137,   138,   139,   140,
     143,     8,    11,     8,     7,     7,     7,     0,    85,    91,
      75,    81,   101,    41,    41,    22,    23,    24,   134,   138,
     139,   134,   139,   134,     7,   142,    81,    81,    81,    92,
       7,     7,     7,   134,   139,   134,   134,    46,    79,    83,
     141,    75,    76,   107,   108,   143,   107,     7,   103,   104,
       3,     4,     5,     6,     7,    25,    26,    28,    31,    32,
      33,    34,    35,    36,    40,    41,    44,    45,    65,    66,
      69,    79,    82,    93,    97,    98,    99,   101,   109,   110,
     115,   116,   117,   118,   119,   120,   124,   125,   127,   128,
     131,   133,   140,   144,   145,   146,   147,   148,   150,   151,
     134,     7,   145,   148,   150,   151,   129,   130,   143,    84,
     145,    83,     7,   124,    82,   108,     7,    82,    46,    76,
      82,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    79,    83,   157,    79,    79,    79,    79,    79,
      93,    75,    75,    75,   145,   147,     7,    79,   150,   151,
     147,   147,    79,   148,     7,   150,   146,   134,   145,    75,
      75,   148,    39,    40,    57,    58,    59,    60,    61,    62,
      63,    64,    66,    67,    68,    70,    71,    75,    78,   153,
     154,   155,   156,    41,    42,    43,   152,    44,    45,    72,
      74,    46,    83,   157,    46,   157,    72,    74,    76,    80,
       7,    84,   145,   141,    75,    75,   141,    75,     3,    40,
     104,    75,   145,   132,   145,   145,   145,   134,   145,   149,
     145,   145,     7,   121,   143,   145,    32,    75,   145,    80,
      80,   145,   146,   146,   146,   146,   147,     7,     7,   145,
     145,   145,   145,   145,     7,     7,    73,   130,   141,    84,
      75,     3,    76,    80,    84,    80,    80,    80,    46,    75,
       7,    80,    79,    80,    77,    46,   157,    46,   157,    75,
      84,    75,    75,    75,   145,    93,    81,   145,   122,   145,
      46,    93,   145,   145,   145,   145,   145,   145,    27,    29,
      30,   111,   112,   113,   114,    75,   145,    80,    75,    75,
      75,    75,    93,     3,     5,     7,    77,    82,   113,   114,
     123,   124,   125,   145,    75,    77,    77,    77,    92,    80,
      92,    92,    92,    93
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_uint8 yyr1[] =
{
       0,    89,    90,    90,    90,    91,    91,    91,    91,    91,
      91,    92,    92,    93,    93,    93,    93,    93,    93,    93,
      93,    94,    94,    95,    96,    97,    97,    98,    98,    98,
      99,    99,    99,   100,   100,   100,   101,   102,   103,   103,
     103,   104,   104,   104,   105,   106,   107,   107,   108,   108,
     109,   109,   110,   111,   111,   111,   112,   112,   113,   113,
     113,   114,   115,   116,   117,   117,   118,   119,   120,   121,
     121,   121,   121,   122,   122,   123,   123,   123,   123,   124,
     125,   126,   127,   128,   129,   129,   129,   129,   130,   130,
     130,   131,   132,   132,   132,   133,   134,   134,   135,   135,
     136,   136,   136,   136,   136,   136,   136,   136,   136,   136,
     136,   136,   136,   137,   137,   137,   138,   138,   139,   139,
     140,   141,   141,   141,   142,   142,   142,   142,   142,   142,
     143,   143,   143,   143,   143,   143,   143,   143,   144,   144,
     144,   144,   144,   144,   144,   144,   144,   144,   145,   145,
     145,   145,   145,   145,   146,   146,   147,   147,   147,   147,
     147,   147,   147,   148,   148,   148,   148,   148,   148,   148,
     148,   148,   148,   148,   148,   148,   148,   148,   148,   149,
     149,   150,   150,   151,   151,   151,   151,   152,   152,   152,
     153,   153,   153,   153,   154,   154,   154,   154,   154,   154,
     155,   155,   155,   156,   156,   157,   157,   157,   157,   157,
     157,   157,   157,   157,   157
      91,    92,    92,    93,    93,    93,    93,    93,    93,    93,
      93,    94,    94,    95,    96,    97,    97,    98,    98,    98,
      99,    99,    99,   100,   100,   100,   101,   102,   103,   103,
     103,   104,   104,   104,   105,   106,   107,   107,   108,   108,
     109,   109,   110,   111,   111,   111,   112,   112,   113,   113,
     113,   114,   115,   116,   117,   117,   118,   119,   120,   121,
     121,   121,   121,   122,   122,   123,   123,   123,   123,   124,
     125,   126,   127,   128,   129,   129,   129,   129,   130,   130,
     130,   131,   132,   132,   132,   133,   134,   134,   135,   135,
     136,   136,   136,   136,   136,   136,   136,   136,   136,   136,
     136,   136,   136,   137,   137,   137,   138,   138,   139,   139,
     140,   141,   141,   141,   142,   142,   142,   142,   142,   142,
     143,   143,   143,   143,   143,   143,   143,   143,   144,   144,
     144,   144,   144,   144,   144,   144,   144,   144,   145,   145,
     145,   145,   145,   145,   146,   146,   147,   147,   147,   147,
     147,   147,   147,   148,   148,   148,   148,   148,   148,   148,
     148,   148,   148,   148,   148,   148,   148,   148,   148,   149,
     149,   150,   150,   151,   151,   151,   151,   152,   152,   152,
     153,   153,   153,   153,   154,   154,   154,   154,   154,   154,
     155,   155,   155,   156,   156,   157,   157,   157,   157,   157,
     157,   157,   157,   157,   157
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     2,     2,     1,     1,     1,     1,     1,     1,
       1,     0,     2,     1,     1,     1,     1,     1,     1,     1,
       1,     0,     2,     1,     1,     1,     1,     1,     1,     1,
       2,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     3,     6,     1,     3,
       2,     1,     3,     4,     6,     6,     1,     2,     3,     4,
       5,     7,     7,     2,     1,     1,     1,     2,     4,     4,
       4,     3,     2,     2,     2,     3,     5,     7,     9,     0,
       3,     4,     2,     0,     1,     0,     1,     1,     1,     3,
       3,     2,     2,     5,     0,     3,     3,     1,     2,     3,
       1,     4,     0,     3,     1,     3,     1,     1,     2,     2,
       1,     1,     1,     1,     2,     2,     1,     1,     2,     1,
       2,     2,     2,     1,     1,     1,     1,     1,     1,     1,
       3,     3,     2,     4,     1,     3,     2,     3,     4,     3,
       1,     2,     2,     2,     3,     3,     3,     4,     2,     2,
       4,     4,     4,     6,     6,     4,     6,     6,     3,     3,
       3,     3,     5,     1,     3,     1,     2,     2,     2,     2,
       2,     2,     1,     3,     1,     1,     1,     1,     1,     1,
       1,     2,     2,     4,     1,     2,     2,     3,     3,     1,
       1,     4,     4,     2,     2,     2,     4,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     3,     6,     1,     3,
       2,     1,     3,     4,     6,     6,     1,     2,     3,     4,
       5,     7,     7,     2,     1,     1,     1,     2,     4,     4,
       4,     3,     2,     2,     2,     3,     5,     7,     9,     0,
       3,     4,     2,     0,     1,     0,     1,     1,     1,     3,
       3,     2,     2,     5,     0,     3,     3,     1,     2,     3,
       1,     4,     0,     3,     1,     3,     1,     1,     2,     2,
       1,     1,     1,     1,     2,     2,     1,     1,     2,     1,
       2,     2,     2,     1,     1,     1,     1,     1,     1,     1,
       3,     3,     2,     4,     1,     3,     2,     3,     4,     3,
       1,     2,     2,     2,     3,     3,     3,     4,     2,     2,
       4,     4,     4,     6,     6,     4,     6,     6,     3,     3,
       3,     3,     5,     1,     3,     1,     2,     2,     2,     2,
       2,     2,     1,     3,     1,     1,     1,     1,     1,     1,
       1,     2,     2,     4,     1,     2,     2,     3,     3,     1,
       1,     4,     4,     2,     2,     2,     4,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1
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
#line 125 "Parser/parser.y"
#line 125 "Parser/parser.y"
                    {
                        p_treeRoot = yyvsp[-1].treeNode;
                        LOG_DEBUG("Reached end of file!\n");
                        return 0;
                    }
#line 1751 "Parser/parser.tab.c"
#line 1751 "Parser/parser.tab.c"
    break;

  case 3: /* program: program global_statement  */
#line 131 "Parser/parser.y"
#line 131 "Parser/parser.y"
                    {
                        TreeNode_t* p_Head = yyvsp[-1].treeNode;
                        if (yyvsp[0].treeNode != NULL) {
                            if (NodeAppendSibling(&p_Head, yyvsp[0].treeNode)) { YYERROR; }
                        }
                        yyval.treeNode = p_Head;
                    }
#line 1763 "Parser/parser.tab.c"
#line 1763 "Parser/parser.tab.c"
    break;

  case 4: /* program: global_statement  */
#line 139 "Parser/parser.y"
#line 139 "Parser/parser.y"
                    {
                        yyval.treeNode = yyvsp[0].treeNode;
                    }
#line 1771 "Parser/parser.tab.c"
#line 1771 "Parser/parser.tab.c"
    break;

  case 5: /* global_statement: type_declaration  */
#line 145 "Parser/parser.y"
#line 145 "Parser/parser.y"
                                         { yyval.treeNode = yyvsp[0].treeNode; }
#line 1777 "Parser/parser.tab.c"
#line 1777 "Parser/parser.tab.c"
    break;

  case 6: /* global_statement: var_declaration  */
#line 146 "Parser/parser.y"
                                                { yyval.treeNode = yyvsp[0].treeNode; }
#line 1783 "Parser/parser.tab.c"
#line 146 "Parser/parser.y"
                                                { yyval.treeNode = yyvsp[0].treeNode; }
#line 1783 "Parser/parser.tab.c"
    break;

  case 7: /* global_statement: function_prototype  */
#line 147 "Parser/parser.y"
#line 147 "Parser/parser.y"
                                           { yyval.treeNode = yyvsp[0].treeNode; }
#line 1789 "Parser/parser.tab.c"
#line 1789 "Parser/parser.tab.c"
    break;

  case 8: /* global_statement: function_definition  */
#line 148 "Parser/parser.y"
#line 148 "Parser/parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 1795 "Parser/parser.tab.c"
#line 1795 "Parser/parser.tab.c"
    break;

  case 9: /* global_statement: def_undef_definition  */
#line 149 "Parser/parser.y"
                                             { yyval.treeNode = yyvsp[0].treeNode; }
#line 1801 "Parser/parser.tab.c"
  case 9: /* global_statement: def_undef_definition  */
#line 149 "Parser/parser.y"
                                             { yyval.treeNode = yyvsp[0].treeNode; }
#line 1801 "Parser/parser.tab.c"
    break;

  case 10: /* global_statement: TOKEN_SEMI  */
  case 10: /* global_statement: TOKEN_SEMI  */
#line 150 "Parser/parser.y"
                                   { yyval.treeNode = NULL; }
#line 1807 "Parser/parser.tab.c"
                                   { yyval.treeNode = NULL; }
#line 1807 "Parser/parser.tab.c"
    break;

  case 11: /* statement_sequence: %empty  */
#line 154 "Parser/parser.y"
                                     { yyval.treeNode = NULL; }
#line 1813 "Parser/parser.tab.c"
    break;

  case 12: /* statement_sequence: statement_sequence statement  */
#line 156 "Parser/parser.y"
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
#line 1829 "Parser/parser.tab.c"
#line 1829 "Parser/parser.tab.c"
    break;

  case 13: /* statement: selection_statement  */
#line 169 "Parser/parser.y"
                                      { yyval.treeNode = yyvsp[0].treeNode; }
#line 1835 "Parser/parser.tab.c"
    break;

  case 14: /* statement: iteration_statement  */
#line 170 "Parser/parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 1841 "Parser/parser.tab.c"
#line 1841 "Parser/parser.tab.c"
    break;

  case 15: /* statement: jump_statement  */
#line 171 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[0].treeNode; }
#line 1847 "Parser/parser.tab.c"
#line 1847 "Parser/parser.tab.c"
    break;

  case 16: /* statement: compound_statement  */
#line 172 "Parser/parser.y"
                                           { yyval.treeNode = yyvsp[0].treeNode; }
#line 1853 "Parser/parser.tab.c"
#line 1853 "Parser/parser.tab.c"
    break;

  case 17: /* statement: var_declaration  */
#line 173 "Parser/parser.y"
                                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 1859 "Parser/parser.tab.c"
#line 1859 "Parser/parser.tab.c"
    break;

  case 18: /* statement: var_assignment  */
#line 174 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[0].treeNode; }
#line 1865 "Parser/parser.tab.c"
    break;

  case 19: /* statement: function_definition  */
#line 175 "Parser/parser.y"
                                            { yyval.treeNode = yyvsp[0].treeNode; }
#line 1871 "Parser/parser.tab.c"
    break;

  case 20: /* statement: exp TOKEN_SEMI  */
#line 176 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[-1].treeNode; }
#line 1877 "Parser/parser.tab.c"
    break;

  case 21: /* def_undef_definition: define  */
#line 183 "Parser/parser.y"
                                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 1883 "Parser/parser.tab.c"
    break;

  case 22: /* def_undef_definition: undef  */
#line 184 "Parser/parser.y"
                                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 1889 "Parser/parser.tab.c"
    break;

  case 23: /* define: TOKEN_PP_DEFINE  */
#line 188 "Parser/parser.y"
            {
                NodeCreate(&(yyval.treeNode), NODE_PP_DEFINE);
                yyval.treeNode->nodeData.sVal = strdup(pp_name);  //MAX

                if (pp_value[0] != '\0') {
                    TreeNode_t* pVal;
                    NodeCreate(&pVal, NODE_STRING);
                    pVal->nodeData.sVal = strdup(pp_value);  //10
                    NodeAddChild(yyval.treeNode, pVal);
                }
            }
#line 1905 "Parser/parser.tab.c"
    break;

  case 24: /* undef: TOKEN_PP_UNDEF  */
#line 202 "Parser/parser.y"
            {
                NodeCreate(&(yyval.treeNode), NODE_PP_UNDEF);
                yyval.treeNode->nodeData.sVal = strdup(pp_name);
            }
#line 1914 "Parser/parser.tab.c"
    break;

  case 25: /* selection_statement: if_statement  */
#line 214 "Parser/parser.y"
                                   { yyval.treeNode = yyvsp[0].treeNode; }
#line 1920 "Parser/parser.tab.c"
    break;

  case 26: /* selection_statement: switch_statement  */
#line 215 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[0].treeNode; }
#line 1926 "Parser/parser.tab.c"
    break;

  case 27: /* jump_statement: break_statement  */
#line 218 "Parser/parser.y"
                                      { yyval.treeNode = yyvsp[0].treeNode; }
#line 1932 "Parser/parser.tab.c"
    break;

  case 28: /* jump_statement: return_statement  */
#line 219 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[0].treeNode; }
#line 1938 "Parser/parser.tab.c"
    break;

  case 29: /* jump_statement: continue_statement  */
#line 220 "Parser/parser.y"
                                         { yyval.treeNode = yyvsp[0].treeNode; }
#line 1944 "Parser/parser.tab.c"
    break;

  case 30: /* iteration_statement: do_while_loop  */
#line 223 "Parser/parser.y"
                                      { yyval.treeNode = yyvsp[0].treeNode; }
#line 1950 "Parser/parser.tab.c"
    break;

  case 31: /* iteration_statement: while_loop  */
#line 224 "Parser/parser.y"
                                   { yyval.treeNode = yyvsp[0].treeNode; }
#line 1956 "Parser/parser.tab.c"
    break;

  case 32: /* iteration_statement: for_loop  */
#line 225 "Parser/parser.y"
                                 { yyval.treeNode = yyvsp[0].treeNode; }
#line 1962 "Parser/parser.tab.c"
    break;

  case 33: /* type_declaration: enum_declaration  */
#line 228 "Parser/parser.y"
                                        { yyval.treeNode = yyvsp[0].treeNode; }
#line 1968 "Parser/parser.tab.c"
    break;

  case 34: /* type_declaration: struct_declaration  */
#line 229 "Parser/parser.y"
                                          { yyval.treeNode = yyvsp[0].treeNode; }
#line 1974 "Parser/parser.tab.c"
    break;

  case 35: /* type_declaration: union_declaration  */
#line 230 "Parser/parser.y"
                                         { yyval.treeNode = yyvsp[0].treeNode; }
#line 1980 "Parser/parser.tab.c"
    break;

  case 36: /* compound_statement: TOKEN_LEFT_BRACE statement_sequence TOKEN_RIGHT_BRACE  */
#line 234 "Parser/parser.y"
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
#line 2002 "Parser/parser.tab.c"
#line 2002 "Parser/parser.tab.c"
    break;

  case 37: /* enum_declaration: TOKEN_ENUM TOKEN_ID TOKEN_LEFT_BRACE enum_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI  */
#line 259 "Parser/parser.y"
  case 37: /* enum_declaration: TOKEN_ENUM TOKEN_ID TOKEN_LEFT_BRACE enum_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI  */
#line 259 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_ENUM_DECLARATION);
                            yyval.treeNode->nodeData.sVal = yyvsp[-4].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                        }
#line 2012 "Parser/parser.tab.c"
#line 2012 "Parser/parser.tab.c"
    break;

  case 38: /* enum_member_list: enum_member  */
#line 266 "Parser/parser.y"
                                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 2018 "Parser/parser.tab.c"
  case 38: /* enum_member_list: enum_member  */
#line 266 "Parser/parser.y"
                                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 2018 "Parser/parser.tab.c"
    break;

  case 39: /* enum_member_list: enum_member_list TOKEN_COMMA enum_member  */
#line 268 "Parser/parser.y"
  case 39: /* enum_member_list: enum_member_list TOKEN_COMMA enum_member  */
#line 268 "Parser/parser.y"
                        {
                            TreeNode_t* pHead = yyvsp[-2].treeNode;
                            if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                            yyval.treeNode = pHead;
                        }
#line 2028 "Parser/parser.tab.c"
#line 2028 "Parser/parser.tab.c"
    break;

  case 40: /* enum_member_list: enum_member_list TOKEN_COMMA  */
#line 274 "Parser/parser.y"
  case 40: /* enum_member_list: enum_member_list TOKEN_COMMA  */
#line 274 "Parser/parser.y"
                        { yyval.treeNode = yyvsp[-1].treeNode; }
#line 2034 "Parser/parser.tab.c"
#line 2034 "Parser/parser.tab.c"
    break;

  case 41: /* enum_member: TOKEN_ID  */
#line 278 "Parser/parser.y"
  case 41: /* enum_member: TOKEN_ID  */
#line 278 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_ENUM_MEMBER);
                            yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                        }
#line 2043 "Parser/parser.tab.c"
#line 2043 "Parser/parser.tab.c"
    break;

  case 42: /* enum_member: TOKEN_ID TOKEN_ASSIGN TOKEN_NUM  */
#line 283 "Parser/parser.y"
  case 42: /* enum_member: TOKEN_ID TOKEN_ASSIGN TOKEN_NUM  */
#line 283 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_ENUM_MEMBER);
                            yyval.treeNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                            TreeNode_t* pVal;
                            NodeCreate(&pVal, NODE_INTEGER);
                            pVal->nodeData.dVal = yyvsp[0].nodeData.dVal;  // guarda o valor!
                            NodeAddChild(yyval.treeNode, pVal);
                        }
#line 2056 "Parser/parser.tab.c"
#line 2056 "Parser/parser.tab.c"
    break;

  case 43: /* enum_member: TOKEN_ID TOKEN_ASSIGN TOKEN_MINUS TOKEN_NUM  */
#line 292 "Parser/parser.y"
  case 43: /* enum_member: TOKEN_ID TOKEN_ASSIGN TOKEN_MINUS TOKEN_NUM  */
#line 292 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_ENUM_MEMBER);
                            yyval.treeNode->nodeData.sVal = yyvsp[-3].nodeData.sVal;
                            TreeNode_t* pVal;
                            NodeCreate(&pVal, NODE_INTEGER);
                            pVal->nodeData.dVal = -yyvsp[0].nodeData.dVal;
                            NodeAddChild(yyval.treeNode, pVal);
                        }
#line 2069 "Parser/parser.tab.c"
#line 2069 "Parser/parser.tab.c"
    break;

  case 44: /* struct_declaration: TOKEN_STRUCT TOKEN_ID TOKEN_LEFT_BRACE struct_union_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI  */
#line 304 "Parser/parser.y"
  case 44: /* struct_declaration: TOKEN_STRUCT TOKEN_ID TOKEN_LEFT_BRACE struct_union_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI  */
#line 304 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_STRUCT_DECLARATION);
                            yyval.treeNode->nodeData.sVal = yyvsp[-4].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                        }
#line 2079 "Parser/parser.tab.c"
#line 2079 "Parser/parser.tab.c"
    break;

  case 45: /* union_declaration: TOKEN_UNION TOKEN_ID TOKEN_LEFT_BRACE struct_union_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI  */
#line 313 "Parser/parser.y"
  case 45: /* union_declaration: TOKEN_UNION TOKEN_ID TOKEN_LEFT_BRACE struct_union_member_list TOKEN_RIGHT_BRACE TOKEN_SEMI  */
#line 313 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_UNION_DECLARATION);
                            yyval.treeNode->nodeData.sVal = yyvsp[-4].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                        }
#line 2089 "Parser/parser.tab.c"
#line 2089 "Parser/parser.tab.c"
    break;

  case 46: /* struct_union_member_list: struct_member  */
#line 322 "Parser/parser.y"
                                             { yyval.treeNode = yyvsp[0].treeNode; }
#line 2095 "Parser/parser.tab.c"
  case 46: /* struct_union_member_list: struct_member  */
#line 322 "Parser/parser.y"
                                             { yyval.treeNode = yyvsp[0].treeNode; }
#line 2095 "Parser/parser.tab.c"
    break;

  case 47: /* struct_union_member_list: struct_union_member_list struct_member  */
#line 324 "Parser/parser.y"
                              {
                                  TreeNode_t* pHead = yyvsp[-1].treeNode;
                                  if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                                  yyval.treeNode = pHead;
                              }
#line 2105 "Parser/parser.tab.c"
  case 47: /* struct_union_member_list: struct_union_member_list struct_member  */
#line 324 "Parser/parser.y"
                              {
                                  TreeNode_t* pHead = yyvsp[-1].treeNode;
                                  if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                                  yyval.treeNode = pHead;
                              }
#line 2105 "Parser/parser.tab.c"
    break;

  case 48: /* struct_member: var_preamble TOKEN_ID TOKEN_SEMI  */
#line 333 "Parser/parser.y"
  case 48: /* struct_member: var_preamble TOKEN_ID TOKEN_SEMI  */
#line 333 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_STRUCT_MEMBER);
                            yyval.treeNode->nodeData.sVal = yyvsp[-1].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                        }
#line 2115 "Parser/parser.tab.c"
#line 2115 "Parser/parser.tab.c"
    break;

  case 49: /* struct_member: var_preamble TOKEN_ID arr_size TOKEN_SEMI  */
#line 339 "Parser/parser.y"
  case 49: /* struct_member: var_preamble TOKEN_ID arr_size TOKEN_SEMI  */
#line 339 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_ARRAY_DECLARATION);
                            yyval.treeNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-3].treeNode);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2126 "Parser/parser.tab.c"
#line 2126 "Parser/parser.tab.c"
    break;

  case 50: /* if_statement: TOKEN_IF TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES statement  */
#line 352 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_IF);
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);    //condition
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);    //if true
                    }
#line 2136 "Parser/parser.tab.c"
#line 2136 "Parser/parser.tab.c"
    break;

  case 51: /* if_statement: TOKEN_IF TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES statement TOKEN_ELSE statement  */
#line 358 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_IF);
                        NodeAddChild(yyval.treeNode, yyvsp[-4].treeNode);   //condition
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);   //if true
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);   //else
                    }
#line 2147 "Parser/parser.tab.c"
#line 2147 "Parser/parser.tab.c"
    break;

  case 52: /* switch_statement: TOKEN_SWITCH TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES TOKEN_LEFT_BRACE switch_body TOKEN_RIGHT_BRACE  */
#line 367 "Parser/parser.y"
  case 52: /* switch_statement: TOKEN_SWITCH TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES TOKEN_LEFT_BRACE switch_body TOKEN_RIGHT_BRACE  */
#line 367 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_SWITCH);
                            NodeAddChild(yyval.treeNode, yyvsp[-4].treeNode);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2157 "Parser/parser.tab.c"
#line 2157 "Parser/parser.tab.c"
    break;

  case 53: /* switch_body: case_list default_clause  */
#line 375 "Parser/parser.y"
  case 53: /* switch_body: case_list default_clause  */
#line 375 "Parser/parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[-1].treeNode;
                        if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                        yyval.treeNode = pHead;
                    }
#line 2167 "Parser/parser.tab.c"
#line 2167 "Parser/parser.tab.c"
    break;

  case 54: /* switch_body: case_list  */
#line 381 "Parser/parser.y"
  case 54: /* switch_body: case_list  */
#line 381 "Parser/parser.y"
                    {
                        yyval.treeNode = yyvsp[0].treeNode;
                    }
#line 2175 "Parser/parser.tab.c"
#line 2175 "Parser/parser.tab.c"
    break;

  case 55: /* switch_body: default_clause  */
#line 385 "Parser/parser.y"
  case 55: /* switch_body: default_clause  */
#line 385 "Parser/parser.y"
                    {
                        yyval.treeNode = yyvsp[0].treeNode;
                    }
#line 2183 "Parser/parser.tab.c"
#line 2183 "Parser/parser.tab.c"
    break;

  case 56: /* case_list: case_clause  */
#line 391 "Parser/parser.y"
  case 56: /* case_list: case_clause  */
#line 391 "Parser/parser.y"
                    {
                        yyval.treeNode = yyvsp[0].treeNode;
                    }
#line 2191 "Parser/parser.tab.c"
#line 2191 "Parser/parser.tab.c"
    break;

  case 57: /* case_list: case_list case_clause  */
#line 395 "Parser/parser.y"
  case 57: /* case_list: case_list case_clause  */
#line 395 "Parser/parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[-1].treeNode;
                        if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                        yyval.treeNode = pHead;
                    }
#line 2201 "Parser/parser.tab.c"
#line 2201 "Parser/parser.tab.c"
    break;

  case 58: /* case_clause: TOKEN_CASE TOKEN_NUM TOKEN_COLON statement_sequence  */
#line 403 "Parser/parser.y"
                    {
                          NodeCreate(&(yyval.treeNode), NODE_CASE);
                          yyval.treeNode->nodeData.sVal = NULL;
                          yyval.treeNode->nodeData.dVal = yyvsp[-2].nodeData.dVal;
                          NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                          NodeCreate(&(yyval.treeNode), NODE_CASE);
                          yyval.treeNode->nodeData.sVal = NULL;
                          yyval.treeNode->nodeData.dVal = yyvsp[-2].nodeData.dVal;
                          NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2212 "Parser/parser.tab.c"
#line 2212 "Parser/parser.tab.c"
    break;

  case 59: /* case_clause: TOKEN_CASE TOKEN_CNUM TOKEN_COLON statement_sequence  */
#line 410 "Parser/parser.y"
                    {
                          NodeCreate(&(yyval.treeNode), NODE_CASE);
                          yyval.treeNode->nodeData.dVal = yyvsp[-2].nodeData.dVal;
                          NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                          NodeCreate(&(yyval.treeNode), NODE_CASE);
                          yyval.treeNode->nodeData.dVal = yyvsp[-2].nodeData.dVal;
                          NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2222 "Parser/parser.tab.c"
#line 2222 "Parser/parser.tab.c"
    break;

  case 60: /* case_clause: TOKEN_CASE TOKEN_ID TOKEN_COLON statement_sequence  */
#line 416 "Parser/parser.y"
                    {
                          NodeCreate(&(yyval.treeNode), NODE_CASE);
                          yyval.treeNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;  /* guarda o nome */
                          NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                          NodeCreate(&(yyval.treeNode), NODE_CASE);
                          yyval.treeNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;  /* guarda o nome */
                          NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2232 "Parser/parser.tab.c"
#line 2232 "Parser/parser.tab.c"
    break;

  case 61: /* default_clause: TOKEN_DEFAULT TOKEN_COLON statement_sequence  */
#line 424 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_DEFAULT);
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2241 "Parser/parser.tab.c"
#line 2241 "Parser/parser.tab.c"
    break;

  case 62: /* continue_statement: TOKEN_CONTINUE TOKEN_SEMI  */
#line 435 "Parser/parser.y"
  case 62: /* continue_statement: TOKEN_CONTINUE TOKEN_SEMI  */
#line 435 "Parser/parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_CONTINUE); }
#line 2247 "Parser/parser.tab.c"
#line 2247 "Parser/parser.tab.c"
    break;

  case 63: /* break_statement: TOKEN_BREAK TOKEN_SEMI  */
#line 439 "Parser/parser.y"
  case 63: /* break_statement: TOKEN_BREAK TOKEN_SEMI  */
#line 439 "Parser/parser.y"
                        { NodeCreate(&(yyval.treeNode), NODE_BREAK); }
#line 2253 "Parser/parser.tab.c"
#line 2253 "Parser/parser.tab.c"
    break;

  case 64: /* return_statement: TOKEN_RETURN TOKEN_SEMI  */
#line 443 "Parser/parser.y"
  case 64: /* return_statement: TOKEN_RETURN TOKEN_SEMI  */
#line 443 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_RETURN);
                            yyval.treeNode->nodeData.sVal = currentFunction;
                        }
#line 2262 "Parser/parser.tab.c"
#line 2262 "Parser/parser.tab.c"
    break;

  case 65: /* return_statement: TOKEN_RETURN exp TOKEN_SEMI  */
#line 448 "Parser/parser.y"
  case 65: /* return_statement: TOKEN_RETURN exp TOKEN_SEMI  */
#line 448 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_RETURN);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                            yyval.treeNode->nodeData.sVal = currentFunction;
                        }
#line 2272 "Parser/parser.tab.c"
#line 2272 "Parser/parser.tab.c"
    break;

  case 66: /* while_loop: TOKEN_WHILE TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES statement  */
#line 460 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_WHILE);
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);    // Condition
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);    // if true
                    }
#line 2282 "Parser/parser.tab.c"
#line 2282 "Parser/parser.tab.c"
    break;

  case 67: /* do_while_loop: TOKEN_DO statement TOKEN_WHILE TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES TOKEN_SEMI  */
#line 469 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_DO_WHILE);
                        NodeAddChild(yyval.treeNode, yyvsp[-5].treeNode);
                        NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                    }
#line 2292 "Parser/parser.tab.c"
#line 2292 "Parser/parser.tab.c"
    break;

  case 68: /* for_loop: TOKEN_FOR TOKEN_LEFT_PARENTHESES for_init_field TOKEN_SEMI for_condition TOKEN_SEMI for_assignment_field TOKEN_RIGHT_PARENTHESES statement  */
#line 477 "Parser/parser.y"
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
#line 2324 "Parser/parser.tab.c"
#line 2324 "Parser/parser.tab.c"
    break;

  case 69: /* for_init_field: %empty  */
#line 506 "Parser/parser.y"
  case 69: /* for_init_field: %empty  */
#line 506 "Parser/parser.y"
                           { yyval.treeNode = NULL; }
#line 2330 "Parser/parser.tab.c"
#line 2330 "Parser/parser.tab.c"
    break;

  case 70: /* for_init_field: TOKEN_ID TOKEN_ASSIGN exp  */
#line 508 "Parser/parser.y"
  case 70: /* for_init_field: TOKEN_ID TOKEN_ASSIGN exp  */
#line 508 "Parser/parser.y"
                    {
                        TreeNode_t* pNode;
                        NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                        yyval.treeNode->nodeData.dVal = OP_ASSIGN;
                        NodeAddNewChild(yyval.treeNode, &pNode, NODE_IDENTIFIER);
                        pNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 2343 "Parser/parser.tab.c"
#line 2343 "Parser/parser.tab.c"
    break;

  case 71: /* for_init_field: var_preamble TOKEN_ID TOKEN_ASSIGN exp  */
#line 517 "Parser/parser.y"
  case 71: /* for_init_field: var_preamble TOKEN_ID TOKEN_ASSIGN exp  */
#line 517 "Parser/parser.y"
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
#line 2361 "Parser/parser.tab.c"
#line 2361 "Parser/parser.tab.c"
    break;

  case 72: /* for_init_field: var_preamble TOKEN_ID  */
#line 531 "Parser/parser.y"
  case 72: /* for_init_field: var_preamble TOKEN_ID  */
#line 531 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
                        yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                        NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                    }
#line 2371 "Parser/parser.tab.c"
#line 2371 "Parser/parser.tab.c"
    break;

  case 73: /* for_condition: %empty  */
#line 537 "Parser/parser.y"
  case 73: /* for_condition: %empty  */
#line 537 "Parser/parser.y"
                             { yyval.treeNode = NULL; }
#line 2377 "Parser/parser.tab.c"
#line 2377 "Parser/parser.tab.c"
    break;

  case 74: /* for_condition: exp  */
#line 538 "Parser/parser.y"
                          { yyval.treeNode = yyvsp[0].treeNode; }
#line 2383 "Parser/parser.tab.c"
  case 74: /* for_condition: exp  */
#line 538 "Parser/parser.y"
                          { yyval.treeNode = yyvsp[0].treeNode; }
#line 2383 "Parser/parser.tab.c"
    break;

  case 75: /* for_assignment_field: %empty  */
#line 541 "Parser/parser.y"
                                   { yyval.treeNode = NULL; }
#line 2389 "Parser/parser.tab.c"
  case 75: /* for_assignment_field: %empty  */
#line 541 "Parser/parser.y"
                                   { yyval.treeNode = NULL; }
#line 2389 "Parser/parser.tab.c"
    break;

  case 76: /* for_assignment_field: simple_var_assign  */
#line 542 "Parser/parser.y"
  case 76: /* for_assignment_field: simple_var_assign  */
#line 542 "Parser/parser.y"
                                                { yyval.treeNode = yyvsp[0].treeNode; }
#line 2395 "Parser/parser.tab.c"
#line 2395 "Parser/parser.tab.c"
    break;

  case 77: /* for_assignment_field: compound_var_assign  */
#line 543 "Parser/parser.y"
  case 77: /* for_assignment_field: compound_var_assign  */
#line 543 "Parser/parser.y"
                                                { yyval.treeNode = yyvsp[0].treeNode; }
#line 2401 "Parser/parser.tab.c"
#line 2401 "Parser/parser.tab.c"
    break;

  case 78: /* for_assignment_field: exp  */
#line 544 "Parser/parser.y"
  case 78: /* for_assignment_field: exp  */
#line 544 "Parser/parser.y"
                                { yyval.treeNode = yyvsp[0].treeNode; }
#line 2407 "Parser/parser.tab.c"
#line 2407 "Parser/parser.tab.c"
    break;

  case 79: /* simple_var_assign: TOKEN_ID TOKEN_ASSIGN exp  */
#line 548 "Parser/parser.y"
  case 79: /* simple_var_assign: TOKEN_ID TOKEN_ASSIGN exp  */
#line 548 "Parser/parser.y"
                        {
                            TreeNode_t* pNode;
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_ASSIGN;
                            NodeAddNewChild(yyval.treeNode, &pNode, NODE_IDENTIFIER);
                            pNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                        }
#line 2420 "Parser/parser.tab.c"
#line 2420 "Parser/parser.tab.c"
    break;

  case 80: /* compound_var_assign: TOKEN_ID compound_assign_operator exp  */
#line 559 "Parser/parser.y"
  case 80: /* compound_var_assign: TOKEN_ID compound_assign_operator exp  */
#line 559 "Parser/parser.y"
                        {
                            TreeNode_t* pNode;
                            NodeAddNewChild(yyvsp[-1].treeNode, &pNode, NODE_IDENTIFIER);
                            pNode->nodeData.sVal = yyvsp[-2].nodeData.sVal;
                            NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                            yyval.treeNode = yyvsp[-1].treeNode;
                        }
#line 2432 "Parser/parser.tab.c"
#line 2432 "Parser/parser.tab.c"
    break;

  case 81: /* function_prototype: function_signature TOKEN_SEMI  */
#line 573 "Parser/parser.y"
  case 81: /* function_prototype: function_signature TOKEN_SEMI  */
#line 573 "Parser/parser.y"
                        {
                            yyval.treeNode = yyvsp[-1].treeNode;
                        }
#line 2440 "Parser/parser.tab.c"
#line 2440 "Parser/parser.tab.c"
    break;

  case 82: /* function_definition: function_signature compound_statement  */
#line 579 "Parser/parser.y"
  case 82: /* function_definition: function_signature compound_statement  */
#line 579 "Parser/parser.y"
                        {
                            yyval.treeNode = yyvsp[-1].treeNode;
                            NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                        }
#line 2449 "Parser/parser.tab.c"
#line 2449 "Parser/parser.tab.c"
    break;

  case 83: /* function_signature: var_preamble TOKEN_ID TOKEN_LEFT_PARENTHESES arg_list TOKEN_RIGHT_PARENTHESES  */
#line 587 "Parser/parser.y"
  case 83: /* function_signature: var_preamble TOKEN_ID TOKEN_LEFT_PARENTHESES arg_list TOKEN_RIGHT_PARENTHESES  */
#line 587 "Parser/parser.y"
                        {
                            NodeCreate(&yyval.treeNode, NODE_FUNCTION);
                            yyval.treeNode->nodeData.sVal = yyvsp[-3].nodeData.sVal;
                            currentFunction = yyvsp[-3].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-4].treeNode);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2461 "Parser/parser.tab.c"
#line 2461 "Parser/parser.tab.c"
    break;

  case 84: /* arg_list: %empty  */
#line 597 "Parser/parser.y"
                            { yyval.treeNode = NULL; }
#line 2467 "Parser/parser.tab.c"
#line 597 "Parser/parser.y"
                            { yyval.treeNode = NULL; }
#line 2467 "Parser/parser.tab.c"
    break;

  case 85: /* arg_list: arg_list TOKEN_COMMA TOKEN_ELLIPSIS  */
#line 600 "Parser/parser.y"
#line 600 "Parser/parser.y"
                    {
                        TreeNode_t* pNode;
                        TreeNode_t* p_Head = yyvsp[-2].treeNode;
                        NodeCreate(&pNode, NODE_PARAMETER);
                        pNode->nodeData.sVal = "...";
                        if (NodeAppendSibling(&p_Head, pNode)) { YYERROR; }
                        yyval.treeNode = p_Head;
                    }
#line 2480 "Parser/parser.tab.c"
#line 2480 "Parser/parser.tab.c"
    break;

  case 86: /* arg_list: arg_list TOKEN_COMMA param_declaration  */
#line 609 "Parser/parser.y"
#line 609 "Parser/parser.y"
                    {
                        TreeNode_t* p_Head = yyvsp[-2].treeNode;
                        if (NodeAppendSibling(&p_Head, yyvsp[0].treeNode)) { YYERROR; }
                        yyval.treeNode = p_Head;
                    }
#line 2490 "Parser/parser.tab.c"
#line 2490 "Parser/parser.tab.c"
    break;

  case 87: /* arg_list: param_declaration  */
#line 614 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[0].treeNode; }
#line 2496 "Parser/parser.tab.c"
#line 614 "Parser/parser.y"
                                       { yyval.treeNode = yyvsp[0].treeNode; }
#line 2496 "Parser/parser.tab.c"
    break;

  case 88: /* param_declaration: var_preamble TOKEN_ID  */
#line 619 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
                            yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                            NodeAddChildCopy(yyval.treeNode, yyvsp[-1].treeNode);
                            free(yyvsp[-1].treeNode);
                        }
#line 2507 "Parser/parser.tab.c"
    break;

  case 89: /* param_declaration: var_preamble TOKEN_ID arr_size  */
#line 627 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_ARRAY_DECLARATION);
                            yyval.treeNode->nodeData.sVal = yyvsp[-1].nodeData.sVal;
                            NodeAddChildCopy(yyval.treeNode, yyvsp[-2].treeNode);
                            free(yyvsp[-2].treeNode);
                            NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                        }
#line 2519 "Parser/parser.tab.c"
    break;

  case 90: /* param_declaration: var_preamble  */
#line 635 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
                            NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                        }
#line 2528 "Parser/parser.tab.c"
    break;

  case 91: /* func_call: TOKEN_ID TOKEN_LEFT_PARENTHESES exp_list TOKEN_RIGHT_PARENTHESES  */
#line 644 "Parser/parser.y"
  case 88: /* param_declaration: var_preamble TOKEN_ID  */
#line 619 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
                            yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                            NodeAddChildCopy(yyval.treeNode, yyvsp[-1].treeNode);
                            free(yyvsp[-1].treeNode);
                        }
#line 2507 "Parser/parser.tab.c"
    break;

  case 89: /* param_declaration: var_preamble TOKEN_ID arr_size  */
#line 627 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_ARRAY_DECLARATION);
                            yyval.treeNode->nodeData.sVal = yyvsp[-1].nodeData.sVal;
                            NodeAddChildCopy(yyval.treeNode, yyvsp[-2].treeNode);
                            free(yyvsp[-2].treeNode);
                            NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                        }
#line 2519 "Parser/parser.tab.c"
    break;

  case 90: /* param_declaration: var_preamble  */
#line 635 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
                            NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                        }
#line 2528 "Parser/parser.tab.c"
    break;

  case 91: /* func_call: TOKEN_ID TOKEN_LEFT_PARENTHESES exp_list TOKEN_RIGHT_PARENTHESES  */
#line 644 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_FUNCTION_CALL);
                            yyval.treeNode->nodeData.sVal = yyvsp[-3].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2538 "Parser/parser.tab.c"
#line 2538 "Parser/parser.tab.c"
    break;

  case 92: /* exp_list: %empty  */
#line 653 "Parser/parser.y"
  case 92: /* exp_list: %empty  */
#line 653 "Parser/parser.y"
                        {
                            yyval.treeNode = NULL;
                        }
#line 2546 "Parser/parser.tab.c"
#line 2546 "Parser/parser.tab.c"
    break;

  case 93: /* exp_list: exp_list TOKEN_COMMA exp  */
#line 657 "Parser/parser.y"
  case 93: /* exp_list: exp_list TOKEN_COMMA exp  */
#line 657 "Parser/parser.y"
                        {
                            TreeNode_t* pHead = yyvsp[-2].treeNode;
                            if (NodeAppendSibling(&pHead, yyvsp[0].treeNode)) { YYERROR; }
                            yyval.treeNode = pHead;
                        }
#line 2556 "Parser/parser.tab.c"
#line 2556 "Parser/parser.tab.c"
    break;

  case 94: /* exp_list: exp  */
#line 663 "Parser/parser.y"
  case 94: /* exp_list: exp  */
#line 663 "Parser/parser.y"
                        {
                            yyval.treeNode = yyvsp[0].treeNode;
                        }
#line 2564 "Parser/parser.tab.c"
#line 2564 "Parser/parser.tab.c"
    break;

  case 95: /* type_cast_specifier: TOKEN_LEFT_PARENTHESES all_type_specifiers TOKEN_RIGHT_PARENTHESES  */
#line 675 "Parser/parser.y"
  case 95: /* type_cast_specifier: TOKEN_LEFT_PARENTHESES all_type_specifiers TOKEN_RIGHT_PARENTHESES  */
#line 675 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE_CAST);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2573 "Parser/parser.tab.c"
#line 2573 "Parser/parser.tab.c"
    break;

  case 96: /* all_type_specifiers: data_type_specifier  */
#line 682 "Parser/parser.y"
  case 96: /* all_type_specifiers: data_type_specifier  */
#line 682 "Parser/parser.y"
                                             { yyval.treeNode = yyvsp[0].treeNode; }
#line 2579 "Parser/parser.tab.c"
#line 2579 "Parser/parser.tab.c"
    break;

  case 97: /* all_type_specifiers: type_pointer  */
#line 683 "Parser/parser.y"
  case 97: /* all_type_specifiers: type_pointer  */
#line 683 "Parser/parser.y"
                                      { yyval.treeNode = yyvsp[0].treeNode; }
#line 2585 "Parser/parser.tab.c"
#line 2585 "Parser/parser.tab.c"
    break;

  case 98: /* type_pointer: data_type_specifier TOKEN_ASTERISK  */
#line 687 "Parser/parser.y"
  case 98: /* type_pointer: data_type_specifier TOKEN_ASTERISK  */
#line 687 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_POINTER);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2594 "Parser/parser.tab.c"
#line 2594 "Parser/parser.tab.c"
    break;

  case 99: /* type_pointer: type_pointer TOKEN_ASTERISK  */
#line 692 "Parser/parser.y"
  case 99: /* type_pointer: type_pointer TOKEN_ASTERISK  */
#line 692 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_POINTER);
                            NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                        }
#line 2603 "Parser/parser.tab.c"
#line 2603 "Parser/parser.tab.c"
    break;

  case 100: /* data_type_specifier: TOKEN_CHAR  */
#line 700 "Parser/parser.y"
  case 100: /* data_type_specifier: TOKEN_CHAR  */
#line 700 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_CHAR;
                        }
#line 2612 "Parser/parser.tab.c"
#line 2612 "Parser/parser.tab.c"
    break;

  case 101: /* data_type_specifier: TOKEN_SHORT  */
#line 705 "Parser/parser.y"
  case 101: /* data_type_specifier: TOKEN_SHORT  */
#line 705 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_SHORT;
                        }
#line 2621 "Parser/parser.tab.c"
#line 2621 "Parser/parser.tab.c"
    break;

  case 102: /* data_type_specifier: TOKEN_INT  */
#line 710 "Parser/parser.y"
  case 102: /* data_type_specifier: TOKEN_INT  */
#line 710 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_INT;
                        }
#line 2630 "Parser/parser.tab.c"
#line 2630 "Parser/parser.tab.c"
    break;

  case 103: /* data_type_specifier: TOKEN_LONG  */
#line 715 "Parser/parser.y"
  case 103: /* data_type_specifier: TOKEN_LONG  */
#line 715 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_LONG;
                        }
#line 2639 "Parser/parser.tab.c"
#line 2639 "Parser/parser.tab.c"
    break;

  case 104: /* data_type_specifier: TOKEN_LONG TOKEN_INT  */
#line 720 "Parser/parser.y"
  case 104: /* data_type_specifier: TOKEN_LONG TOKEN_INT  */
#line 720 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_LONG;
                        }
#line 2648 "Parser/parser.tab.c"
#line 2648 "Parser/parser.tab.c"
    break;

  case 105: /* data_type_specifier: TOKEN_SHORT TOKEN_INT  */
#line 725 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_SHORT;
                        }
#line 2657 "Parser/parser.tab.c"
  case 105: /* data_type_specifier: TOKEN_SHORT TOKEN_INT  */
#line 725 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_SHORT;
                        }
#line 2657 "Parser/parser.tab.c"
    break;

  case 106: /* data_type_specifier: TOKEN_FLOAT  */
#line 730 "Parser/parser.y"
  case 106: /* data_type_specifier: TOKEN_FLOAT  */
#line 730 "Parser/parser.y"
                            { NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_FLOAT;
                        }
#line 2665 "Parser/parser.tab.c"
#line 2665 "Parser/parser.tab.c"
    break;

  case 107: /* data_type_specifier: TOKEN_DOUBLE  */
#line 734 "Parser/parser.y"
  case 107: /* data_type_specifier: TOKEN_DOUBLE  */
#line 734 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_DOUBLE;
                        }
#line 2674 "Parser/parser.tab.c"
#line 2674 "Parser/parser.tab.c"
    break;

  case 108: /* data_type_specifier: TOKEN_LONG TOKEN_DOUBLE  */
#line 739 "Parser/parser.y"
  case 108: /* data_type_specifier: TOKEN_LONG TOKEN_DOUBLE  */
#line 739 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_LONG_DOUBLE;
                        }
#line 2683 "Parser/parser.tab.c"
#line 2683 "Parser/parser.tab.c"
    break;

  case 109: /* data_type_specifier: TOKEN_VOID  */
#line 744 "Parser/parser.y"
  case 109: /* data_type_specifier: TOKEN_VOID  */
#line 744 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_VOID;
                        }
#line 2692 "Parser/parser.tab.c"
#line 2692 "Parser/parser.tab.c"
    break;

  case 110: /* data_type_specifier: TOKEN_STRUCT TOKEN_ID  */
#line 749 "Parser/parser.y"
  case 110: /* data_type_specifier: TOKEN_STRUCT TOKEN_ID  */
#line 749 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_STRUCT;
                            TreeNode_t* pName;
                            NodeCreate(&pName, NODE_IDENTIFIER);
                            pName->nodeData.sVal = yyvsp[0].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, pName);
                        }
#line 2705 "Parser/parser.tab.c"
#line 2705 "Parser/parser.tab.c"
    break;

  case 111: /* data_type_specifier: TOKEN_UNION TOKEN_ID  */
#line 758 "Parser/parser.y"
  case 111: /* data_type_specifier: TOKEN_UNION TOKEN_ID  */
#line 758 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_UNION;
                            TreeNode_t* pName;
                            NodeCreate(&pName, NODE_IDENTIFIER);
                            pName->nodeData.sVal = yyvsp[0].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, pName);
                        }
#line 2718 "Parser/parser.tab.c"
#line 2718 "Parser/parser.tab.c"
    break;

  case 112: /* data_type_specifier: TOKEN_ENUM TOKEN_ID  */
#line 767 "Parser/parser.y"
  case 112: /* data_type_specifier: TOKEN_ENUM TOKEN_ID  */
#line 767 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_TYPE);
                            yyval.treeNode->nodeData.dVal = TYPE_ENUM;
                            TreeNode_t* pName;
                            NodeCreate(&pName, NODE_IDENTIFIER);
                            pName->nodeData.sVal = yyvsp[0].nodeData.sVal;
                            NodeAddChild(yyval.treeNode, pName);
                        }
#line 2731 "Parser/parser.tab.c"
#line 2731 "Parser/parser.tab.c"
    break;

  case 113: /* visibility_qualifier: TOKEN_STATIC  */
#line 778 "Parser/parser.y"
                             {
                                 NodeCreate(&(yyval.treeNode), NODE_VISIBILITY);
                                 yyval.treeNode->nodeData.dVal = VIS_STATIC;
                             }
#line 2740 "Parser/parser.tab.c"
  case 113: /* visibility_qualifier: TOKEN_STATIC  */
#line 778 "Parser/parser.y"
                             {
                                 NodeCreate(&(yyval.treeNode), NODE_VISIBILITY);
                                 yyval.treeNode->nodeData.dVal = VIS_STATIC;
                             }
#line 2740 "Parser/parser.tab.c"
    break;

  case 114: /* visibility_qualifier: TOKEN_EXTERN  */
#line 783 "Parser/parser.y"
                             {
                                 NodeCreate(&(yyval.treeNode), NODE_VISIBILITY);
                                 yyval.treeNode->nodeData.dVal = VIS_EXTERN;
                             }
#line 2749 "Parser/parser.tab.c"
  case 114: /* visibility_qualifier: TOKEN_EXTERN  */
#line 783 "Parser/parser.y"
                             {
                                 NodeCreate(&(yyval.treeNode), NODE_VISIBILITY);
                                 yyval.treeNode->nodeData.dVal = VIS_EXTERN;
                             }
#line 2749 "Parser/parser.tab.c"
    break;

  case 115: /* visibility_qualifier: TOKEN_INLINE  */
#line 788 "Parser/parser.y"
                             {
                                 NodeCreate(&(yyval.treeNode), NODE_VISIBILITY);
                                 yyval.treeNode->nodeData.dVal = VIS_INLINE;
                             }
#line 2758 "Parser/parser.tab.c"
  case 115: /* visibility_qualifier: TOKEN_INLINE  */
#line 788 "Parser/parser.y"
                             {
                                 NodeCreate(&(yyval.treeNode), NODE_VISIBILITY);
                                 yyval.treeNode->nodeData.dVal = VIS_INLINE;
                             }
#line 2758 "Parser/parser.tab.c"
    break;

  case 116: /* mod_qualifier: TOKEN_CONST  */
#line 795 "Parser/parser.y"
#line 795 "Parser/parser.y"
                        {
                        NodeCreate(&(yyval.treeNode), NODE_MODIFIER);
                        yyval.treeNode->nodeData.dVal = (long int) MOD_CONST;
                        NodeCreate(&(yyval.treeNode), NODE_MODIFIER);
                        yyval.treeNode->nodeData.dVal = (long int) MOD_CONST;
                        }
#line 2767 "Parser/parser.tab.c"
#line 2767 "Parser/parser.tab.c"
    break;

  case 117: /* mod_qualifier: TOKEN_VOLATILE  */
#line 800 "Parser/parser.y"
#line 800 "Parser/parser.y"
                        {
                        NodeCreate(&(yyval.treeNode), NODE_MODIFIER);
                        yyval.treeNode->nodeData.dVal = (long int) MOD_VOLATILE;
                        NodeCreate(&(yyval.treeNode), NODE_MODIFIER);
                        yyval.treeNode->nodeData.dVal = (long int) MOD_VOLATILE;
                        }
#line 2776 "Parser/parser.tab.c"
#line 2776 "Parser/parser.tab.c"
    break;

  case 118: /* sign_qualifier: TOKEN_SIGNED  */
#line 807 "Parser/parser.y"
  case 118: /* sign_qualifier: TOKEN_SIGNED  */
#line 807 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_SIGN);
                            yyval.treeNode->nodeData.dVal = (long int) SIGN_SIGNED;
                        }
#line 2785 "Parser/parser.tab.c"
#line 2785 "Parser/parser.tab.c"
    break;

  case 119: /* sign_qualifier: TOKEN_UNSIGNED  */
#line 812 "Parser/parser.y"
  case 119: /* sign_qualifier: TOKEN_UNSIGNED  */
#line 812 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_SIGN);
                            yyval.treeNode->nodeData.dVal = (long int) SIGN_UNSIGNED;
                        }
#line 2794 "Parser/parser.tab.c"
#line 2794 "Parser/parser.tab.c"
    break;

  case 120: /* var_declaration: var_preamble id_list TOKEN_SEMI  */
#line 824 "Parser/parser.y"
  case 120: /* var_declaration: var_preamble id_list TOKEN_SEMI  */
#line 824 "Parser/parser.y"
                    {
                        /* existing action — keep unchanged */
                        /* existing action — keep unchanged */
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
#line 2812 "Parser/parser.tab.c"
#line 2812 "Parser/parser.tab.c"
    break;

  case 121: /* arr_size: TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET  */
#line 841 "Parser/parser.y"
  case 121: /* arr_size: TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET  */
#line 841 "Parser/parser.y"
                { yyval.treeNode = yyvsp[-1].treeNode; }
#line 2818 "Parser/parser.tab.c"
#line 2818 "Parser/parser.tab.c"
    break;

  case 122: /* arr_size: TOKEN_LEFT_BRACKET TOKEN_RIGHT_BRACKET  */
#line 843 "Parser/parser.y"
  case 122: /* arr_size: TOKEN_LEFT_BRACKET TOKEN_RIGHT_BRACKET  */
#line 843 "Parser/parser.y"
                { NodeCreate(&(yyval.treeNode), NODE_NULL); }
#line 2824 "Parser/parser.tab.c"
#line 2824 "Parser/parser.tab.c"
    break;

  case 123: /* arr_size: arr_size TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET  */
#line 845 "Parser/parser.y"
  case 123: /* arr_size: arr_size TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET  */
#line 845 "Parser/parser.y"
                {
                    TreeNode_t* pHead = yyvsp[-3].treeNode;
                    if (NodeAppendSibling(&pHead, yyvsp[-1].treeNode)) { YYERROR; }
                    yyval.treeNode = pHead;
                }
#line 2834 "Parser/parser.tab.c"
#line 2834 "Parser/parser.tab.c"
    break;

  case 124: /* id_list: TOKEN_ID  */
#line 853 "Parser/parser.y"
              {
                  NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
                  yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
              }
#line 2843 "Parser/parser.tab.c"
  case 124: /* id_list: TOKEN_ID  */
#line 853 "Parser/parser.y"
              {
                  NodeCreate(&(yyval.treeNode), NODE_VAR_DECLARATION);
                  yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
              }
#line 2843 "Parser/parser.tab.c"
    break;

  case 125: /* id_list: TOKEN_ID TOKEN_ASSIGN exp  */
#line 858 "Parser/parser.y"
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
#line 2860 "Parser/parser.tab.c"
  case 125: /* id_list: TOKEN_ID TOKEN_ASSIGN exp  */
#line 858 "Parser/parser.y"
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
#line 2860 "Parser/parser.tab.c"
    break;

  case 126: /* id_list: TOKEN_ID arr_size  */
#line 871 "Parser/parser.y"
              {
                  NodeCreate(&(yyval.treeNode), NODE_ARRAY_DECLARATION);
                  yyval.treeNode->nodeData.sVal = yyvsp[-1].nodeData.sVal;
                  NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
              }
#line 2870 "Parser/parser.tab.c"
  case 126: /* id_list: TOKEN_ID arr_size  */
#line 871 "Parser/parser.y"
              {
                  NodeCreate(&(yyval.treeNode), NODE_ARRAY_DECLARATION);
                  yyval.treeNode->nodeData.sVal = yyvsp[-1].nodeData.sVal;
                  NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
              }
#line 2870 "Parser/parser.tab.c"
    break;

  case 127: /* id_list: id_list TOKEN_COMMA TOKEN_ID  */
#line 877 "Parser/parser.y"
              {
                   TreeNode_t* pHead = yyvsp[-2].treeNode;
                   TreeNode_t* pNewNode;
                   NodeCreate(&pNewNode, NODE_VAR_DECLARATION);
                   pNewNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                   if (NodeAppendSibling(&pHead, pNewNode)) { YYERROR; }
                   yyval.treeNode = pHead;
              }
#line 2883 "Parser/parser.tab.c"
  case 127: /* id_list: id_list TOKEN_COMMA TOKEN_ID  */
#line 877 "Parser/parser.y"
              {
                   TreeNode_t* pHead = yyvsp[-2].treeNode;
                   TreeNode_t* pNewNode;
                   NodeCreate(&pNewNode, NODE_VAR_DECLARATION);
                   pNewNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                   if (NodeAppendSibling(&pHead, pNewNode)) { YYERROR; }
                   yyval.treeNode = pHead;
              }
#line 2883 "Parser/parser.tab.c"
    break;

  case 128: /* id_list: id_list TOKEN_COMMA TOKEN_ID arr_size  */
#line 886 "Parser/parser.y"
              {
                    TreeNode_t* pHead = yyvsp[-3].treeNode;
                    TreeNode_t* pNewNode;
                    NodeCreate(&pNewNode, NODE_ARRAY_DECLARATION);
                    pNewNode->nodeData.sVal = yyvsp[-1].nodeData.sVal;
                    NodeAddChild(pNewNode, yyvsp[0].treeNode);
                    if (NodeAppendSibling(&pHead, pNewNode)) { YYERROR; }
                    yyval.treeNode = pHead;
              }
#line 2897 "Parser/parser.tab.c"
  case 128: /* id_list: id_list TOKEN_COMMA TOKEN_ID arr_size  */
#line 886 "Parser/parser.y"
              {
                    TreeNode_t* pHead = yyvsp[-3].treeNode;
                    TreeNode_t* pNewNode;
                    NodeCreate(&pNewNode, NODE_ARRAY_DECLARATION);
                    pNewNode->nodeData.sVal = yyvsp[-1].nodeData.sVal;
                    NodeAddChild(pNewNode, yyvsp[0].treeNode);
                    if (NodeAppendSibling(&pHead, pNewNode)) { YYERROR; }
                    yyval.treeNode = pHead;
              }
#line 2897 "Parser/parser.tab.c"
    break;

  case 129: /* id_list: id_list TOKEN_COMMA simple_var_assign  */
#line 897 "Parser/parser.y"
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
#line 2912 "Parser/parser.tab.c"
  case 129: /* id_list: id_list TOKEN_COMMA simple_var_assign  */
#line 897 "Parser/parser.y"
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
#line 2912 "Parser/parser.tab.c"
    break;

  case 130: /* var_preamble: all_type_specifiers  */
#line 912 "Parser/parser.y"
                    {
                        yyval.treeNode = yyvsp[0].treeNode;
                    }
#line 2920 "Parser/parser.tab.c"
    break;

  case 131: /* var_preamble: visibility_qualifier all_type_specifiers  */
#line 916 "Parser/parser.y"
  case 130: /* var_preamble: all_type_specifiers  */
#line 912 "Parser/parser.y"
                    {
                        yyval.treeNode = yyvsp[0].treeNode;
                    }
#line 2920 "Parser/parser.tab.c"
    break;

  case 131: /* var_preamble: visibility_qualifier all_type_specifiers  */
#line 916 "Parser/parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[0].treeNode;
                        if (yyvsp[-1].treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, yyvsp[-1].treeNode);
                        else
                            free(yyvsp[-1].treeNode);
                        yyval.treeNode = pHead;
                    }
#line 2933 "Parser/parser.tab.c"
    break;

  case 132: /* var_preamble: mod_qualifier all_type_specifiers  */
#line 925 "Parser/parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[0].treeNode;
                        if (yyvsp[-1].treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, yyvsp[-1].treeNode);
                        else
                            free(yyvsp[-1].treeNode);
                        yyval.treeNode = pHead;
                    }
#line 2933 "Parser/parser.tab.c"
    break;

  case 132: /* var_preamble: mod_qualifier all_type_specifiers  */
#line 925 "Parser/parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[0].treeNode;
                        if (yyvsp[-1].treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, yyvsp[-1].treeNode);
                        else
                            free(yyvsp[-1].treeNode);
                        yyval.treeNode = pHead;
                    }
#line 2946 "Parser/parser.tab.c"
    break;

  case 133: /* var_preamble: sign_qualifier all_type_specifiers  */
#line 934 "Parser/parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[0].treeNode;
                        if (yyvsp[-1].treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, yyvsp[-1].treeNode);
                        else
                            free(yyvsp[-1].treeNode);
                        yyval.treeNode = pHead;
                    }
#line 2959 "Parser/parser.tab.c"
    break;

  case 134: /* var_preamble: visibility_qualifier mod_qualifier all_type_specifiers  */
#line 943 "Parser/parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[0].treeNode;
                        if (yyvsp[-1].treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, yyvsp[-1].treeNode);
                        else
                            free(yyvsp[-1].treeNode);
                        yyval.treeNode = pHead;
                    }
#line 2946 "Parser/parser.tab.c"
    break;

  case 133: /* var_preamble: sign_qualifier all_type_specifiers  */
#line 934 "Parser/parser.y"
                    {
                        TreeNode_t* pHead = yyvsp[0].treeNode;
                        if (yyvsp[-1].treeNode->nodeType != NODE_NULL)
                            NodeAppendSibling(&pHead, yyvsp[-1].treeNode);
                        else
                            free(yyvsp[-1].treeNode);
                        yyval.treeNode = pHead;
                    }
#line 2959 "Parser/parser.tab.c"
    break;

  case 134: /* var_preamble: visibility_qualifier mod_qualifier all_type_specifiers  */
#line 943 "Parser/parser.y"
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
                        yyval.treeNode = pHead;
                    }
#line 2976 "Parser/parser.tab.c"
    break;

  case 135: /* var_preamble: visibility_qualifier sign_qualifier all_type_specifiers  */
#line 956 "Parser/parser.y"
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
                        yyval.treeNode = pHead;
                    }
#line 2993 "Parser/parser.tab.c"
    break;

  case 136: /* var_preamble: mod_qualifier sign_qualifier all_type_specifiers  */
#line 969 "Parser/parser.y"
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
                        yyval.treeNode = pHead;
                    }
#line 3010 "Parser/parser.tab.c"
    break;

  case 137: /* var_preamble: visibility_qualifier mod_qualifier sign_qualifier all_type_specifiers  */
#line 982 "Parser/parser.y"
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
                        yyval.treeNode = pHead;
                    }
#line 2976 "Parser/parser.tab.c"
    break;

  case 135: /* var_preamble: visibility_qualifier sign_qualifier all_type_specifiers  */
#line 956 "Parser/parser.y"
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
                        yyval.treeNode = pHead;
                    }
#line 2993 "Parser/parser.tab.c"
    break;

  case 136: /* var_preamble: mod_qualifier sign_qualifier all_type_specifiers  */
#line 969 "Parser/parser.y"
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
                        yyval.treeNode = pHead;
                    }
#line 3010 "Parser/parser.tab.c"
    break;

  case 137: /* var_preamble: visibility_qualifier mod_qualifier sign_qualifier all_type_specifiers  */
#line 982 "Parser/parser.y"
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
#line 3031 "Parser/parser.tab.c"
#line 3031 "Parser/parser.tab.c"
    break;

  case 138: /* var_assignment: simple_var_assign TOKEN_SEMI  */
#line 1001 "Parser/parser.y"
                                                  { yyval.treeNode = yyvsp[-1].treeNode; }
#line 3037 "Parser/parser.tab.c"
  case 138: /* var_assignment: simple_var_assign TOKEN_SEMI  */
#line 1001 "Parser/parser.y"
                                                  { yyval.treeNode = yyvsp[-1].treeNode; }
#line 3037 "Parser/parser.tab.c"
    break;

  case 139: /* var_assignment: compound_var_assign TOKEN_SEMI  */
#line 1002 "Parser/parser.y"
                                                    { yyval.treeNode = yyvsp[-1].treeNode; }
#line 3043 "Parser/parser.tab.c"
  case 139: /* var_assignment: compound_var_assign TOKEN_SEMI  */
#line 1002 "Parser/parser.y"
                                                    { yyval.treeNode = yyvsp[-1].treeNode; }
#line 3043 "Parser/parser.tab.c"
    break;

  case 140: /* var_assignment: array_access TOKEN_ASSIGN exp TOKEN_SEMI  */
#line 1004 "Parser/parser.y"
  case 140: /* var_assignment: array_access TOKEN_ASSIGN exp TOKEN_SEMI  */
#line 1004 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                        yyval.treeNode->nodeData.dVal = OP_ASSIGN;
                        NodeAddChild(yyval.treeNode, yyvsp[-3].treeNode);
                        NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                    }
#line 3054 "Parser/parser.tab.c"
#line 3054 "Parser/parser.tab.c"
    break;

  case 141: /* var_assignment: pointer_content TOKEN_ASSIGN exp TOKEN_SEMI  */
#line 1011 "Parser/parser.y"
  case 141: /* var_assignment: pointer_content TOKEN_ASSIGN exp TOKEN_SEMI  */
#line 1011 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                        yyval.treeNode->nodeData.dVal = OP_ASSIGN;
                        NodeAddChild(yyval.treeNode, yyvsp[-3].treeNode);
                        NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                    }
#line 3065 "Parser/parser.tab.c"
#line 3065 "Parser/parser.tab.c"
    break;

  case 142: /* var_assignment: array_access compound_assign_operator exp TOKEN_SEMI  */
#line 1018 "Parser/parser.y"
  case 142: /* var_assignment: array_access compound_assign_operator exp TOKEN_SEMI  */
#line 1018 "Parser/parser.y"
                    {
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-3].treeNode);
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-1].treeNode);
                        yyval.treeNode = yyvsp[-2].treeNode;
                    }
#line 3075 "Parser/parser.tab.c"
#line 3075 "Parser/parser.tab.c"
    break;

  case 143: /* var_assignment: factor TOKEN_DOT TOKEN_ID TOKEN_ASSIGN exp TOKEN_SEMI  */
#line 1024 "Parser/parser.y"
  case 143: /* var_assignment: factor TOKEN_DOT TOKEN_ID TOKEN_ASSIGN exp TOKEN_SEMI  */
#line 1024 "Parser/parser.y"
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
#line 3090 "Parser/parser.tab.c"
#line 3090 "Parser/parser.tab.c"
    break;

  case 144: /* var_assignment: factor TOKEN_ARROW TOKEN_ID TOKEN_ASSIGN exp TOKEN_SEMI  */
#line 1035 "Parser/parser.y"
  case 144: /* var_assignment: factor TOKEN_ARROW TOKEN_ID TOKEN_ASSIGN exp TOKEN_SEMI  */
#line 1035 "Parser/parser.y"
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
#line 3105 "Parser/parser.tab.c"
#line 3105 "Parser/parser.tab.c"
    break;

  case 145: /* var_assignment: pointer_content compound_assign_operator exp TOKEN_SEMI  */
#line 1046 "Parser/parser.y"
  case 145: /* var_assignment: pointer_content compound_assign_operator exp TOKEN_SEMI  */
#line 1046 "Parser/parser.y"
                    {
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-3].treeNode);
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-1].treeNode);
                        yyval.treeNode = yyvsp[-2].treeNode;
                    }
#line 3115 "Parser/parser.tab.c"
#line 3115 "Parser/parser.tab.c"
    break;

  case 146: /* var_assignment: factor TOKEN_DOT TOKEN_ID compound_assign_operator exp TOKEN_SEMI  */
#line 1052 "Parser/parser.y"
  case 146: /* var_assignment: factor TOKEN_DOT TOKEN_ID compound_assign_operator exp TOKEN_SEMI  */
#line 1052 "Parser/parser.y"
                    {
                        TreeNode_t* pMember;
                        NodeCreate(&pMember, NODE_IDENTIFIER);
                        pMember->nodeData.sVal = yyvsp[-3].nodeData.sVal;
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-5].treeNode);
                        NodeAddChild(yyvsp[-2].treeNode, pMember);
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-1].treeNode);
                        yyval.treeNode = yyvsp[-2].treeNode;
                    }
#line 3129 "Parser/parser.tab.c"
#line 3129 "Parser/parser.tab.c"
    break;

  case 147: /* var_assignment: factor TOKEN_ARROW TOKEN_ID compound_assign_operator exp TOKEN_SEMI  */
#line 1062 "Parser/parser.y"
  case 147: /* var_assignment: factor TOKEN_ARROW TOKEN_ID compound_assign_operator exp TOKEN_SEMI  */
#line 1062 "Parser/parser.y"
                    {
                        TreeNode_t* pMember;
                        NodeCreate(&pMember, NODE_IDENTIFIER);
                        pMember->nodeData.sVal = yyvsp[-3].nodeData.sVal;
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-5].treeNode);
                        NodeAddChild(yyvsp[-2].treeNode, pMember);
                        NodeAddChild(yyvsp[-2].treeNode, yyvsp[-1].treeNode);
                        yyval.treeNode = yyvsp[-2].treeNode;
                    }
#line 3143 "Parser/parser.tab.c"
#line 3143 "Parser/parser.tab.c"
    break;

  case 148: /* exp: exp arithmetic_operator term  */
#line 1079 "Parser/parser.y"
  case 148: /* exp: exp arithmetic_operator term  */
#line 1079 "Parser/parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode; //sets the operator as the root
                }
#line 3153 "Parser/parser.tab.c"
#line 3153 "Parser/parser.tab.c"
    break;

  case 149: /* exp: exp comparison_operator term  */
#line 1085 "Parser/parser.y"
  case 149: /* exp: exp comparison_operator term  */
#line 1085 "Parser/parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 3163 "Parser/parser.tab.c"
#line 3163 "Parser/parser.tab.c"
    break;

  case 150: /* exp: exp bitwise_operator term  */
#line 1091 "Parser/parser.y"
  case 150: /* exp: exp bitwise_operator term  */
#line 1091 "Parser/parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 3173 "Parser/parser.tab.c"
#line 3173 "Parser/parser.tab.c"
    break;

  case 151: /* exp: exp logic_operator term  */
#line 1097 "Parser/parser.y"
  case 151: /* exp: exp logic_operator term  */
#line 1097 "Parser/parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 3183 "Parser/parser.tab.c"
#line 3183 "Parser/parser.tab.c"
    break;

  case 152: /* exp: exp TOKEN_TERNARY exp TOKEN_COLON exp  */
#line 1103 "Parser/parser.y"
  case 152: /* exp: exp TOKEN_TERNARY exp TOKEN_COLON exp  */
#line 1103 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_TERNARY);
                    NodeAddChild(yyval.treeNode, yyvsp[-4].treeNode);
                    NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 3194 "Parser/parser.tab.c"
#line 3194 "Parser/parser.tab.c"
    break;

  case 153: /* exp: term  */
#line 1110 "Parser/parser.y"
  case 153: /* exp: term  */
#line 1110 "Parser/parser.y"
                {
                    yyval.treeNode = yyvsp[0].treeNode;
                }
#line 3202 "Parser/parser.tab.c"
#line 3202 "Parser/parser.tab.c"
    break;

  case 154: /* term: term priority_operator operand  */
#line 1117 "Parser/parser.y"
  case 154: /* term: term priority_operator operand  */
#line 1117 "Parser/parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[-2].treeNode);
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 3212 "Parser/parser.tab.c"
#line 3212 "Parser/parser.tab.c"
    break;

  case 155: /* term: operand  */
#line 1122 "Parser/parser.y"
                         { yyval.treeNode = yyvsp[0].treeNode; }
#line 3218 "Parser/parser.tab.c"
  case 155: /* term: operand  */
#line 1122 "Parser/parser.y"
                         { yyval.treeNode = yyvsp[0].treeNode; }
#line 3218 "Parser/parser.tab.c"
    break;

  case 156: /* operand: TOKEN_MINUS operand  */
#line 1127 "Parser/parser.y"
  case 156: /* operand: TOKEN_MINUS operand  */
#line 1127 "Parser/parser.y"
                {
                      NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                      yyval.treeNode->nodeData.dVal = OP_UNARY_MINUS;
                      NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 3228 "Parser/parser.tab.c"
                      NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                      yyval.treeNode->nodeData.dVal = OP_UNARY_MINUS;
                      NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 3228 "Parser/parser.tab.c"
    break;

  case 157: /* operand: TOKEN_INCREMENT operand  */
#line 1133 "Parser/parser.y"
  case 157: /* operand: TOKEN_INCREMENT operand  */
#line 1133 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_PRE_INC);
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 3237 "Parser/parser.tab.c"
                    NodeCreate(&(yyval.treeNode), NODE_PRE_INC);
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 3237 "Parser/parser.tab.c"
    break;

  case 158: /* operand: TOKEN_DECREMENT operand  */
#line 1138 "Parser/parser.y"
  case 158: /* operand: TOKEN_DECREMENT operand  */
#line 1138 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_PRE_DEC);
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 3246 "Parser/parser.tab.c"
                    NodeCreate(&(yyval.treeNode), NODE_PRE_DEC);
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 3246 "Parser/parser.tab.c"
    break;

  case 159: /* operand: TOKEN_LOGICAL_NOT factor  */
#line 1143 "Parser/parser.y"
  case 159: /* operand: TOKEN_LOGICAL_NOT factor  */
#line 1143 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                    yyval.treeNode->nodeData.dVal = OP_LOGICAL_NOT;
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 3256 "Parser/parser.tab.c"
#line 3256 "Parser/parser.tab.c"
    break;

  case 160: /* operand: TOKEN_BITWISE_NOT term  */
#line 1149 "Parser/parser.y"
  case 160: /* operand: TOKEN_BITWISE_NOT term  */
#line 1149 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                    yyval.treeNode->nodeData.dVal = OP_BITWISE_NOT;
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 3266 "Parser/parser.tab.c"
#line 3266 "Parser/parser.tab.c"
    break;

  case 161: /* operand: type_cast_specifier factor  */
#line 1155 "Parser/parser.y"
  case 161: /* operand: type_cast_specifier factor  */
#line 1155 "Parser/parser.y"
                {
                    NodeAddChild(yyvsp[-1].treeNode, yyvsp[0].treeNode);
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 3275 "Parser/parser.tab.c"
#line 3275 "Parser/parser.tab.c"
    break;

  case 162: /* operand: factor  */
#line 1160 "Parser/parser.y"
  case 162: /* operand: factor  */
#line 1160 "Parser/parser.y"
                {
                    yyval.treeNode = yyvsp[0].treeNode;
                }
#line 3283 "Parser/parser.tab.c"
#line 3283 "Parser/parser.tab.c"
    break;

  case 163: /* factor: TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES  */
#line 1167 "Parser/parser.y"
  case 163: /* factor: TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES  */
#line 1167 "Parser/parser.y"
                {
                    yyval.treeNode = yyvsp[-1].treeNode;
                }
#line 3291 "Parser/parser.tab.c"
#line 3291 "Parser/parser.tab.c"
    break;

  case 164: /* factor: array_access  */
#line 1171 "Parser/parser.y"
  case 164: /* factor: array_access  */
#line 1171 "Parser/parser.y"
                {
                    yyval.treeNode = yyvsp[0].treeNode;
                }
#line 3299 "Parser/parser.tab.c"
#line 3299 "Parser/parser.tab.c"
    break;

  case 165: /* factor: TOKEN_NUM  */
#line 1175 "Parser/parser.y"
  case 165: /* factor: TOKEN_NUM  */
#line 1175 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_INTEGER);
                    yyval.treeNode->nodeData.dVal = yyvsp[0].nodeData.dVal;
                }
#line 3308 "Parser/parser.tab.c"
#line 3308 "Parser/parser.tab.c"
    break;

  case 166: /* factor: TOKEN_ID  */
#line 1180 "Parser/parser.y"
  case 166: /* factor: TOKEN_ID  */
#line 1180 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_IDENTIFIER);
                    yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                }
#line 3317 "Parser/parser.tab.c"
#line 3317 "Parser/parser.tab.c"
    break;

  case 167: /* factor: pointer_content  */
#line 1185 "Parser/parser.y"
  case 167: /* factor: pointer_content  */
#line 1185 "Parser/parser.y"
                { yyval.treeNode = yyvsp[0].treeNode; }
#line 3323 "Parser/parser.tab.c"
#line 3323 "Parser/parser.tab.c"
    break;

  case 168: /* factor: TOKEN_FNUM  */
#line 1187 "Parser/parser.y"
  case 168: /* factor: TOKEN_FNUM  */
#line 1187 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_FLOAT);
                    yyval.treeNode->nodeData.fVal = yyvsp[0].nodeData.fVal;
                }
#line 3332 "Parser/parser.tab.c"
#line 3332 "Parser/parser.tab.c"
    break;

  case 169: /* factor: TOKEN_CNUM  */
#line 1192 "Parser/parser.y"
  case 169: /* factor: TOKEN_CNUM  */
#line 1192 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_CHAR);
                    yyval.treeNode->nodeData.dVal = yyvsp[0].nodeData.dVal;
                }
#line 3341 "Parser/parser.tab.c"
#line 3341 "Parser/parser.tab.c"
    break;

  case 170: /* factor: TOKEN_STR  */
#line 1197 "Parser/parser.y"
  case 170: /* factor: TOKEN_STR  */
#line 1197 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_STRING);
                    yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                }
#line 3350 "Parser/parser.tab.c"
#line 3350 "Parser/parser.tab.c"
    break;

  case 171: /* factor: TOKEN_BITWISE_AND array_access  */
#line 1202 "Parser/parser.y"
  case 171: /* factor: TOKEN_BITWISE_AND array_access  */
#line 1202 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_REFERENCE);
                    NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                }
#line 3359 "Parser/parser.tab.c"
#line 3359 "Parser/parser.tab.c"
    break;

  case 172: /* factor: TOKEN_BITWISE_AND TOKEN_ID  */
#line 1207 "Parser/parser.y"
  case 172: /* factor: TOKEN_BITWISE_AND TOKEN_ID  */
#line 1207 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_REFERENCE);
                    yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                }
#line 3368 "Parser/parser.tab.c"
#line 3368 "Parser/parser.tab.c"
    break;

  case 173: /* factor: TOKEN_SIZEOF TOKEN_LEFT_PARENTHESES sizeof_operand TOKEN_RIGHT_PARENTHESES  */
#line 1212 "Parser/parser.y"
  case 173: /* factor: TOKEN_SIZEOF TOKEN_LEFT_PARENTHESES sizeof_operand TOKEN_RIGHT_PARENTHESES  */
#line 1212 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                    yyval.treeNode->nodeData.dVal = OP_SIZEOF;
                    NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                }
#line 3378 "Parser/parser.tab.c"
#line 3378 "Parser/parser.tab.c"
    break;

  case 174: /* factor: func_call  */
#line 1217 "Parser/parser.y"
                           { yyval.treeNode = yyvsp[0].treeNode; }
#line 3384 "Parser/parser.tab.c"
  case 174: /* factor: func_call  */
#line 1217 "Parser/parser.y"
                           { yyval.treeNode = yyvsp[0].treeNode; }
#line 3384 "Parser/parser.tab.c"
    break;

  case 175: /* factor: factor TOKEN_INCREMENT  */
#line 1219 "Parser/parser.y"
  case 175: /* factor: factor TOKEN_INCREMENT  */
#line 1219 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_POST_INC);
                    NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                }
#line 3393 "Parser/parser.tab.c"
                    NodeCreate(&(yyval.treeNode), NODE_POST_INC);
                    NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                }
#line 3393 "Parser/parser.tab.c"
    break;

  case 176: /* factor: factor TOKEN_DECREMENT  */
#line 1224 "Parser/parser.y"
  case 176: /* factor: factor TOKEN_DECREMENT  */
#line 1224 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_POST_DEC);
                    NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                }
#line 3402 "Parser/parser.tab.c"
                    NodeCreate(&(yyval.treeNode), NODE_POST_DEC);
                    NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                }
#line 3402 "Parser/parser.tab.c"
    break;

  case 177: /* factor: factor TOKEN_DOT TOKEN_ID  */
#line 1229 "Parser/parser.y"
  case 177: /* factor: factor TOKEN_DOT TOKEN_ID  */
#line 1229 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_IDENTIFIER);
                    yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                    NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                }
#line 3412 "Parser/parser.tab.c"
#line 3412 "Parser/parser.tab.c"
    break;

  case 178: /* factor: factor TOKEN_ARROW TOKEN_ID  */
#line 1235 "Parser/parser.y"
  case 178: /* factor: factor TOKEN_ARROW TOKEN_ID  */
#line 1235 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_IDENTIFIER);
                    yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                    NodeAddChild(yyval.treeNode, yyvsp[-2].treeNode);
                }
#line 3422 "Parser/parser.tab.c"
#line 3422 "Parser/parser.tab.c"
    break;

  case 179: /* sizeof_operand: all_type_specifiers  */
#line 1244 "Parser/parser.y"
  case 179: /* sizeof_operand: all_type_specifiers  */
#line 1244 "Parser/parser.y"
                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 3428 "Parser/parser.tab.c"
#line 3428 "Parser/parser.tab.c"
    break;

  case 180: /* sizeof_operand: exp  */
#line 1246 "Parser/parser.y"
  case 180: /* sizeof_operand: exp  */
#line 1246 "Parser/parser.y"
                    { yyval.treeNode = yyvsp[0].treeNode; }
#line 3434 "Parser/parser.tab.c"
#line 3434 "Parser/parser.tab.c"
    break;

  case 181: /* array_access: TOKEN_ID TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET  */
#line 1251 "Parser/parser.y"
  case 181: /* array_access: TOKEN_ID TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET  */
#line 1251 "Parser/parser.y"
                {
                    NodeCreate(&(yyval.treeNode), NODE_ARRAY_ACCESS);
                    yyval.treeNode->nodeData.sVal = yyvsp[-3].nodeData.sVal;
                    NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                }
#line 3444 "Parser/parser.tab.c"
#line 3444 "Parser/parser.tab.c"
    break;

  case 182: /* array_access: array_access TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET  */
#line 1257 "Parser/parser.y"
  case 182: /* array_access: array_access TOKEN_LEFT_BRACKET exp TOKEN_RIGHT_BRACKET  */
#line 1257 "Parser/parser.y"
                {
                    NodeAddChild(yyvsp[-3].treeNode, yyvsp[-1].treeNode);
                    yyval.treeNode = yyvsp[-3].treeNode;
                }
#line 3453 "Parser/parser.tab.c"
#line 3453 "Parser/parser.tab.c"
    break;

  case 183: /* pointer_content: TOKEN_ASTERISK pointer_content  */
#line 1264 "Parser/parser.y"
  case 183: /* pointer_content: TOKEN_ASTERISK pointer_content  */
#line 1264 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_POINTER_CONTENT);
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 3462 "Parser/parser.tab.c"
#line 3462 "Parser/parser.tab.c"
    break;

  case 184: /* pointer_content: TOKEN_ASTERISK TOKEN_ID  */
#line 1269 "Parser/parser.y"
  case 184: /* pointer_content: TOKEN_ASTERISK TOKEN_ID  */
#line 1269 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_POINTER_CONTENT);
                        yyval.treeNode->nodeData.sVal = yyvsp[0].nodeData.sVal;
                    }
#line 3471 "Parser/parser.tab.c"
#line 3471 "Parser/parser.tab.c"
    break;

  case 185: /* pointer_content: TOKEN_ASTERISK array_access  */
#line 1274 "Parser/parser.y"
  case 185: /* pointer_content: TOKEN_ASTERISK array_access  */
#line 1274 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_POINTER_CONTENT);
                        NodeAddChild(yyval.treeNode, yyvsp[0].treeNode);
                    }
#line 3480 "Parser/parser.tab.c"
#line 3480 "Parser/parser.tab.c"
    break;

  case 186: /* pointer_content: TOKEN_ASTERISK TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES  */
#line 1279 "Parser/parser.y"
  case 186: /* pointer_content: TOKEN_ASTERISK TOKEN_LEFT_PARENTHESES exp TOKEN_RIGHT_PARENTHESES  */
#line 1279 "Parser/parser.y"
                    {
                        NodeCreate(&(yyval.treeNode), NODE_POINTER_CONTENT);
                        NodeAddChild(yyval.treeNode, yyvsp[-1].treeNode);
                    }
#line 3489 "Parser/parser.tab.c"
#line 3489 "Parser/parser.tab.c"
    break;

  case 187: /* priority_operator: TOKEN_ASTERISK  */
#line 1290 "Parser/parser.y"
  case 187: /* priority_operator: TOKEN_ASTERISK  */
#line 1290 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_MULTIPLY;
                        }
#line 3498 "Parser/parser.tab.c"
#line 3498 "Parser/parser.tab.c"
    break;

  case 188: /* priority_operator: TOKEN_DIVIDE  */
#line 1295 "Parser/parser.y"
  case 188: /* priority_operator: TOKEN_DIVIDE  */
#line 1295 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_DIVIDE;
                        }
#line 3507 "Parser/parser.tab.c"
#line 3507 "Parser/parser.tab.c"
    break;

  case 189: /* priority_operator: TOKEN_MOD  */
#line 1300 "Parser/parser.y"
  case 189: /* priority_operator: TOKEN_MOD  */
#line 1300 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_MODULE;
                        }
#line 3516 "Parser/parser.tab.c"
#line 3516 "Parser/parser.tab.c"
    break;

  case 190: /* arithmetic_operator: TOKEN_PLUS  */
#line 1307 "Parser/parser.y"
  case 190: /* arithmetic_operator: TOKEN_PLUS  */
#line 1307 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_PLUS;
                        }
#line 3525 "Parser/parser.tab.c"
#line 3525 "Parser/parser.tab.c"
    break;

  case 191: /* arithmetic_operator: TOKEN_MINUS  */
#line 1312 "Parser/parser.y"
  case 191: /* arithmetic_operator: TOKEN_MINUS  */
#line 1312 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_MINUS;
                        }
#line 3534 "Parser/parser.tab.c"
#line 3534 "Parser/parser.tab.c"
    break;

  case 192: /* arithmetic_operator: TOKEN_RIGHT_SHIFT  */
#line 1317 "Parser/parser.y"
  case 192: /* arithmetic_operator: TOKEN_RIGHT_SHIFT  */
#line 1317 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_RIGHT_SHIFT;
                        }
#line 3543 "Parser/parser.tab.c"
#line 3543 "Parser/parser.tab.c"
    break;

  case 193: /* arithmetic_operator: TOKEN_LEFT_SHIFT  */
#line 1322 "Parser/parser.y"
  case 193: /* arithmetic_operator: TOKEN_LEFT_SHIFT  */
#line 1322 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_LEFT_SHIFT;
                        }
#line 3552 "Parser/parser.tab.c"
#line 3552 "Parser/parser.tab.c"
    break;

  case 194: /* comparison_operator: TOKEN_EQUAL  */
#line 1329 "Parser/parser.y"
  case 194: /* comparison_operator: TOKEN_EQUAL  */
#line 1329 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_EQUAL;
                        }
#line 3561 "Parser/parser.tab.c"
#line 3561 "Parser/parser.tab.c"
    break;

  case 195: /* comparison_operator: TOKEN_NOT_EQUAL  */
#line 1334 "Parser/parser.y"
  case 195: /* comparison_operator: TOKEN_NOT_EQUAL  */
#line 1334 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_NOT_EQUAL;
                        }
#line 3570 "Parser/parser.tab.c"
#line 3570 "Parser/parser.tab.c"
    break;

  case 196: /* comparison_operator: TOKEN_GREATER_THAN  */
#line 1339 "Parser/parser.y"
  case 196: /* comparison_operator: TOKEN_GREATER_THAN  */
#line 1339 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_GREATER_THAN;
                        }
#line 3579 "Parser/parser.tab.c"
#line 3579 "Parser/parser.tab.c"
    break;

  case 197: /* comparison_operator: TOKEN_LESS_THAN_OR_EQUAL  */
#line 1344 "Parser/parser.y"
  case 197: /* comparison_operator: TOKEN_LESS_THAN_OR_EQUAL  */
#line 1344 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_LESS_THAN_OR_EQUAL;
                        }
#line 3588 "Parser/parser.tab.c"
#line 3588 "Parser/parser.tab.c"
    break;

  case 198: /* comparison_operator: TOKEN_GREATER_THAN_OR_EQUAL  */
#line 1349 "Parser/parser.y"
  case 198: /* comparison_operator: TOKEN_GREATER_THAN_OR_EQUAL  */
#line 1349 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_GREATER_THAN_OR_EQUAL;
                        }
#line 3597 "Parser/parser.tab.c"
#line 3597 "Parser/parser.tab.c"
    break;

  case 199: /* comparison_operator: TOKEN_LESS_THAN  */
#line 1354 "Parser/parser.y"
  case 199: /* comparison_operator: TOKEN_LESS_THAN  */
#line 1354 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_LESS_THAN;
                        }
#line 3606 "Parser/parser.tab.c"
#line 3606 "Parser/parser.tab.c"
    break;

  case 200: /* bitwise_operator: TOKEN_BITWISE_AND  */
#line 1361 "Parser/parser.y"
  case 200: /* bitwise_operator: TOKEN_BITWISE_AND  */
#line 1361 "Parser/parser.y"
                        {
                             NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                             yyval.treeNode->nodeData.dVal = OP_BITWISE_AND;
                         }
#line 3615 "Parser/parser.tab.c"
#line 3615 "Parser/parser.tab.c"
    break;

  case 201: /* bitwise_operator: TOKEN_BITWISE_OR  */
#line 1366 "Parser/parser.y"
  case 201: /* bitwise_operator: TOKEN_BITWISE_OR  */
#line 1366 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_BITWISE_OR;
                        }
#line 3624 "Parser/parser.tab.c"
#line 3624 "Parser/parser.tab.c"
    break;

  case 202: /* bitwise_operator: TOKEN_BITWISE_XOR  */
#line 1371 "Parser/parser.y"
  case 202: /* bitwise_operator: TOKEN_BITWISE_XOR  */
#line 1371 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_BITWISE_XOR;
                        }
#line 3633 "Parser/parser.tab.c"
#line 3633 "Parser/parser.tab.c"
    break;

  case 203: /* logic_operator: TOKEN_LOGICAL_AND  */
#line 1378 "Parser/parser.y"
  case 203: /* logic_operator: TOKEN_LOGICAL_AND  */
#line 1378 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_LOGICAL_AND;
                        }
#line 3642 "Parser/parser.tab.c"
#line 3642 "Parser/parser.tab.c"
    break;

  case 204: /* logic_operator: TOKEN_LOGICAL_OR  */
#line 1383 "Parser/parser.y"
  case 204: /* logic_operator: TOKEN_LOGICAL_OR  */
#line 1383 "Parser/parser.y"
                        {
                            NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                            yyval.treeNode->nodeData.dVal = OP_LOGICAL_OR;
                        }
#line 3651 "Parser/parser.tab.c"
#line 3651 "Parser/parser.tab.c"
    break;

  case 205: /* compound_assign_operator: TOKEN_PLUS_ASSIGN  */
#line 1390 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_PLUS_ASSIGN;
                            }
#line 3660 "Parser/parser.tab.c"
  case 205: /* compound_assign_operator: TOKEN_PLUS_ASSIGN  */
#line 1390 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_PLUS_ASSIGN;
                            }
#line 3660 "Parser/parser.tab.c"
    break;

  case 206: /* compound_assign_operator: TOKEN_MINUS_ASSIGN  */
#line 1395 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_MINUS_ASSIGN;
                            }
#line 3669 "Parser/parser.tab.c"
  case 206: /* compound_assign_operator: TOKEN_MINUS_ASSIGN  */
#line 1395 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_MINUS_ASSIGN;
                            }
#line 3669 "Parser/parser.tab.c"
    break;

  case 207: /* compound_assign_operator: TOKEN_MODULUS_ASSIGN  */
#line 1400 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_MODULUS_ASSIGN;
                            }
#line 3678 "Parser/parser.tab.c"
  case 207: /* compound_assign_operator: TOKEN_MODULUS_ASSIGN  */
#line 1400 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_MODULUS_ASSIGN;
                            }
#line 3678 "Parser/parser.tab.c"
    break;

  case 208: /* compound_assign_operator: TOKEN_LEFT_SHIFT_ASSIGN  */
#line 1405 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_LEFT_SHIFT_ASSIGN;
                            }
#line 3687 "Parser/parser.tab.c"
  case 208: /* compound_assign_operator: TOKEN_LEFT_SHIFT_ASSIGN  */
#line 1405 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_LEFT_SHIFT_ASSIGN;
                            }
#line 3687 "Parser/parser.tab.c"
    break;

  case 209: /* compound_assign_operator: TOKEN_RIGHT_SHIFT_ASSIGN  */
#line 1410 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_RIGHT_SHIFT_ASSIGN;
                            }
#line 3696 "Parser/parser.tab.c"
  case 209: /* compound_assign_operator: TOKEN_RIGHT_SHIFT_ASSIGN  */
#line 1410 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_RIGHT_SHIFT_ASSIGN;
                            }
#line 3696 "Parser/parser.tab.c"
    break;

  case 210: /* compound_assign_operator: TOKEN_AND_ASSIGN  */
#line 1415 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_BITWISE_AND_ASSIGN;
                            }
#line 3705 "Parser/parser.tab.c"
  case 210: /* compound_assign_operator: TOKEN_AND_ASSIGN  */
#line 1415 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_BITWISE_AND_ASSIGN;
                            }
#line 3705 "Parser/parser.tab.c"
    break;

  case 211: /* compound_assign_operator: TOKEN_OR_ASSIGN  */
#line 1420 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_BITWISE_OR_ASSIGN;
                            }
#line 3714 "Parser/parser.tab.c"
  case 211: /* compound_assign_operator: TOKEN_OR_ASSIGN  */
#line 1420 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_BITWISE_OR_ASSIGN;
                            }
#line 3714 "Parser/parser.tab.c"
    break;

  case 212: /* compound_assign_operator: TOKEN_XOR_ASSIGN  */
#line 1425 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_BITWISE_XOR_ASSIGN;
                            }
#line 3723 "Parser/parser.tab.c"
  case 212: /* compound_assign_operator: TOKEN_XOR_ASSIGN  */
#line 1425 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_BITWISE_XOR_ASSIGN;
                            }
#line 3723 "Parser/parser.tab.c"
    break;

  case 213: /* compound_assign_operator: TOKEN_MULTIPLY_ASSIGN  */
#line 1430 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_MULTIPLY_ASSIGN;
                            }
#line 3732 "Parser/parser.tab.c"
  case 213: /* compound_assign_operator: TOKEN_MULTIPLY_ASSIGN  */
#line 1430 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_MULTIPLY_ASSIGN;
                            }
#line 3732 "Parser/parser.tab.c"
    break;

  case 214: /* compound_assign_operator: TOKEN_DIVIDE_ASSIGN  */
#line 1435 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_DIVIDE_ASSIGN;
                            }
#line 3741 "Parser/parser.tab.c"
  case 214: /* compound_assign_operator: TOKEN_DIVIDE_ASSIGN  */
#line 1435 "Parser/parser.y"
                            {
                                NodeCreate(&(yyval.treeNode), NODE_OPERATOR);
                                yyval.treeNode->nodeData.dVal = OP_DIVIDE_ASSIGN;
                            }
#line 3741 "Parser/parser.tab.c"
    break;


#line 3745 "Parser/parser.tab.c"
#line 3745 "Parser/parser.tab.c"

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

#line 1444 "Parser/parser.y"
#line 1444 "Parser/parser.y"


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
