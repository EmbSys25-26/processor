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
#line 1 "parser.y"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "../Util/asm_operations.h"    
#include "../Util/statements_list.h"  
#include "../Util/symbol_table.h"     

extern int yylex();
void yyerror(const char *s);

#line 84 "parser.tab.c"

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
  YYSYMBOL_TOKEN_NUMBER = 3,               /* TOKEN_NUMBER  */
  YYSYMBOL_TOKEN_REG = 4,                  /* TOKEN_REG  */
  YYSYMBOL_TOKEN_DOLLAR = 5,               /* TOKEN_DOLLAR  */
  YYSYMBOL_TOKEN_IDENTIFIER = 6,           /* TOKEN_IDENTIFIER  */
  YYSYMBOL_TOKEN_BR = 7,                   /* TOKEN_BR  */
  YYSYMBOL_TOKEN_BEQ = 8,                  /* TOKEN_BEQ  */
  YYSYMBOL_TOKEN_BC = 9,                   /* TOKEN_BC  */
  YYSYMBOL_TOKEN_BV = 10,                  /* TOKEN_BV  */
  YYSYMBOL_TOKEN_BLT = 11,                 /* TOKEN_BLT  */
  YYSYMBOL_TOKEN_BLE = 12,                 /* TOKEN_BLE  */
  YYSYMBOL_TOKEN_BLETU = 13,               /* TOKEN_BLETU  */
  YYSYMBOL_TOKEN_BLEU = 14,                /* TOKEN_BLEU  */
  YYSYMBOL_TOKEN_ADD = 15,                 /* TOKEN_ADD  */
  YYSYMBOL_TOKEN_SUB = 16,                 /* TOKEN_SUB  */
  YYSYMBOL_TOKEN_AND = 17,                 /* TOKEN_AND  */
  YYSYMBOL_TOKEN_XOR = 18,                 /* TOKEN_XOR  */
  YYSYMBOL_TOKEN_ADC = 19,                 /* TOKEN_ADC  */
  YYSYMBOL_TOKEN_SBC = 20,                 /* TOKEN_SBC  */
  YYSYMBOL_TOKEN_CMP = 21,                 /* TOKEN_CMP  */
  YYSYMBOL_TOKEN_SRL = 22,                 /* TOKEN_SRL  */
  YYSYMBOL_TOKEN_SRA = 23,                 /* TOKEN_SRA  */
  YYSYMBOL_TOKEN_RSUBI = 24,               /* TOKEN_RSUBI  */
  YYSYMBOL_TOKEN_ANDI = 25,                /* TOKEN_ANDI  */
  YYSYMBOL_TOKEN_XORI = 26,                /* TOKEN_XORI  */
  YYSYMBOL_TOKEN_ADCI = 27,                /* TOKEN_ADCI  */
  YYSYMBOL_TOKEN_RSBCI = 28,               /* TOKEN_RSBCI  */
  YYSYMBOL_TOKEN_RCMPI = 29,               /* TOKEN_RCMPI  */
  YYSYMBOL_TOKEN_JAL = 30,                 /* TOKEN_JAL  */
  YYSYMBOL_TOKEN_ADDI = 31,                /* TOKEN_ADDI  */
  YYSYMBOL_TOKEN_LW = 32,                  /* TOKEN_LW  */
  YYSYMBOL_TOKEN_LB = 33,                  /* TOKEN_LB  */
  YYSYMBOL_TOKEN_SW = 34,                  /* TOKEN_SW  */
  YYSYMBOL_TOKEN_SB = 35,                  /* TOKEN_SB  */
  YYSYMBOL_TOKEN_IMM_TOK = 36,             /* TOKEN_IMM_TOK  */
  YYSYMBOL_TOKEN_BYTE = 37,                /* TOKEN_BYTE  */
  YYSYMBOL_TOKEN_WORD = 38,                /* TOKEN_WORD  */
  YYSYMBOL_TOKEN_ORG = 39,                 /* TOKEN_ORG  */
  YYSYMBOL_TOKEN_EQU = 40,                 /* TOKEN_EQU  */
  YYSYMBOL_TOKEN_GETCC = 41,               /* TOKEN_GETCC  */
  YYSYMBOL_TOKEN_SETCC = 42,               /* TOKEN_SETCC  */
  YYSYMBOL_TOKEN_CLI = 43,                 /* TOKEN_CLI  */
  YYSYMBOL_TOKEN_STI = 44,                 /* TOKEN_STI  */
  YYSYMBOL_TOKEN_NOP = 45,                 /* TOKEN_NOP  */
  YYSYMBOL_TOKEN_ENDFILE = 46,             /* TOKEN_ENDFILE  */
  YYSYMBOL_TOKEN_COMMA = 47,               /* TOKEN_COMMA  */
  YYSYMBOL_TOKEN_COLON = 48,               /* TOKEN_COLON  */
  YYSYMBOL_TOKEN_CARDINAL = 49,            /* TOKEN_CARDINAL  */
  YYSYMBOL_TOKEN_PLUS = 50,                /* TOKEN_PLUS  */
  YYSYMBOL_TOKEN_MINUS = 51,               /* TOKEN_MINUS  */
  YYSYMBOL_TOKEN_LEFT_PAREN = 52,          /* TOKEN_LEFT_PAREN  */
  YYSYMBOL_TOKEN_RIGHT_PAREN = 53,         /* TOKEN_RIGHT_PAREN  */
  YYSYMBOL_YYACCEPT = 54,                  /* $accept  */
  YYSYMBOL_program = 55,                   /* program  */
  YYSYMBOL_lines = 56,                     /* lines  */
  YYSYMBOL_line = 57,                      /* line  */
  YYSYMBOL_label_decl = 58,                /* label_decl  */
  YYSYMBOL_stmt = 59,                      /* stmt  */
  YYSYMBOL_add_stmt = 60,                  /* add_stmt  */
  YYSYMBOL_sub_stmt = 61,                  /* sub_stmt  */
  YYSYMBOL_and_stmt = 62,                  /* and_stmt  */
  YYSYMBOL_xor_stmt = 63,                  /* xor_stmt  */
  YYSYMBOL_adc_stmt = 64,                  /* adc_stmt  */
  YYSYMBOL_sbc_stmt = 65,                  /* sbc_stmt  */
  YYSYMBOL_cmp_stmt = 66,                  /* cmp_stmt  */
  YYSYMBOL_srl_stmt = 67,                  /* srl_stmt  */
  YYSYMBOL_sra_stmt = 68,                  /* sra_stmt  */
  YYSYMBOL_getcc_stmt = 69,                /* getcc_stmt  */
  YYSYMBOL_setcc_stmt = 70,                /* setcc_stmt  */
  YYSYMBOL_rsubi_stmt = 71,                /* rsubi_stmt  */
  YYSYMBOL_andi_stmt = 72,                 /* andi_stmt  */
  YYSYMBOL_xori_stmt = 73,                 /* xori_stmt  */
  YYSYMBOL_adci_stmt = 74,                 /* adci_stmt  */
  YYSYMBOL_rsbci_stmt = 75,                /* rsbci_stmt  */
  YYSYMBOL_rcmpi_stmt = 76,                /* rcmpi_stmt  */
  YYSYMBOL_addi_stmt = 77,                 /* addi_stmt  */
  YYSYMBOL_jal_stmt = 78,                  /* jal_stmt  */
  YYSYMBOL_lw_stmt = 79,                   /* lw_stmt  */
  YYSYMBOL_lb_stmt = 80,                   /* lb_stmt  */
  YYSYMBOL_sw_stmt = 81,                   /* sw_stmt  */
  YYSYMBOL_sb_stmt = 82,                   /* sb_stmt  */
  YYSYMBOL_imm_stmt = 83,                  /* imm_stmt  */
  YYSYMBOL_branch_stmt = 84,               /* branch_stmt  */
  YYSYMBOL_cli_stmt = 85,                  /* cli_stmt  */
  YYSYMBOL_sti_stmt = 86,                  /* sti_stmt  */
  YYSYMBOL_nop_stmt = 87,                  /* nop_stmt  */
  YYSYMBOL_directive = 88,                 /* directive  */
  YYSYMBOL_branch_op = 89,                 /* branch_op  */
  YYSYMBOL_expression = 90,                /* expression  */
  YYSYMBOL_immediate_val = 91              /* immediate_val  */
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
typedef yytype_uint8 yy_state_t;

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
#define YYFINAL  3
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   222

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  54
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  38
/* YYNRULES -- Number of rules.  */
#define YYNRULES  99
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  190

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   308


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
      45,    46,    47,    48,    49,    50,    51,    52,    53
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,    56,    56,    61,    62,    65,    66,    67,    70,    78,
      78,    78,    78,    78,    78,    78,    78,    78,    79,    79,
      80,    80,    80,    80,    80,    80,    81,    81,    81,    81,
      81,    81,    82,    83,    84,    84,    84,    88,    93,    98,
     103,   108,   113,   118,   123,   128,   133,   138,   144,   148,
     153,   157,   162,   166,   171,   175,   180,   184,   189,   193,
     199,   204,   210,   214,   219,   223,   228,   232,   237,   241,
     246,   250,   256,   260,   267,   271,   277,   282,   287,   293,
     297,   301,   305,   309,   313,   320,   321,   322,   323,   324,
     325,   326,   327,   331,   335,   339,   343,   347,   353,   357
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
  "\"end of file\"", "error", "\"invalid token\"", "TOKEN_NUMBER",
  "TOKEN_REG", "TOKEN_DOLLAR", "TOKEN_IDENTIFIER", "TOKEN_BR", "TOKEN_BEQ",
  "TOKEN_BC", "TOKEN_BV", "TOKEN_BLT", "TOKEN_BLE", "TOKEN_BLETU",
  "TOKEN_BLEU", "TOKEN_ADD", "TOKEN_SUB", "TOKEN_AND", "TOKEN_XOR",
  "TOKEN_ADC", "TOKEN_SBC", "TOKEN_CMP", "TOKEN_SRL", "TOKEN_SRA",
  "TOKEN_RSUBI", "TOKEN_ANDI", "TOKEN_XORI", "TOKEN_ADCI", "TOKEN_RSBCI",
  "TOKEN_RCMPI", "TOKEN_JAL", "TOKEN_ADDI", "TOKEN_LW", "TOKEN_LB",
  "TOKEN_SW", "TOKEN_SB", "TOKEN_IMM_TOK", "TOKEN_BYTE", "TOKEN_WORD",
  "TOKEN_ORG", "TOKEN_EQU", "TOKEN_GETCC", "TOKEN_SETCC", "TOKEN_CLI",
  "TOKEN_STI", "TOKEN_NOP", "TOKEN_ENDFILE", "TOKEN_COMMA", "TOKEN_COLON",
  "TOKEN_CARDINAL", "TOKEN_PLUS", "TOKEN_MINUS", "TOKEN_LEFT_PAREN",
  "TOKEN_RIGHT_PAREN", "$accept", "program", "lines", "line", "label_decl",
  "stmt", "add_stmt", "sub_stmt", "and_stmt", "xor_stmt", "adc_stmt",
  "sbc_stmt", "cmp_stmt", "srl_stmt", "sra_stmt", "getcc_stmt",
  "setcc_stmt", "rsubi_stmt", "andi_stmt", "xori_stmt", "adci_stmt",
  "rsbci_stmt", "rcmpi_stmt", "addi_stmt", "jal_stmt", "lw_stmt",
  "lb_stmt", "sw_stmt", "sb_stmt", "imm_stmt", "branch_stmt", "cli_stmt",
  "sti_stmt", "nop_stmt", "directive", "branch_op", "expression",
  "immediate_val", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-74)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-1)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
     -74,     6,   171,   -74,   -30,   -74,   -74,   -74,   -74,   -74,
     -74,   -74,   -74,     7,    56,    60,    61,    68,    69,    72,
      73,    76,    77,    80,    81,    84,    85,    88,    89,    92,
      93,   127,   128,   129,    10,   120,   124,     9,   130,   131,
     -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,
     -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,
     -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,
     -74,   -74,   -74,   -74,   -74,   -74,    14,     9,   -74,   -25,
     -21,   -17,   -13,    -9,    -1,     3,    65,    90,    91,    94,
      95,    96,    97,    98,    99,   100,   101,   102,   103,   105,
     -74,   -74,   -74,     9,     9,   -42,   -74,   -74,   -42,   -74,
     -42,   -42,   -74,   -74,   -74,   -74,   -42,   132,   135,   136,
     147,   150,   151,   154,   155,   158,    18,    22,    26,    30,
      34,    38,   159,   162,   163,   165,   166,   167,   -42,   -46,
       9,     9,   -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,
     -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,
     -74,   -74,   -74,   126,   164,   172,   173,   174,   175,   -74,
     -74,   -74,    42,    46,   104,   108,   112,   116,   -74,   -74,
     -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int8 yydefact[] =
{
       4,     0,     0,     1,     0,    85,    86,    87,    88,    89,
      90,    91,    92,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      76,    77,    78,     2,     3,     5,     6,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,     7,     0,     0,     8,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      93,    94,    73,     0,     0,    99,    72,    83,    82,    81,
      80,    79,    46,    47,    75,    74,    84,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    98,     0,
       0,     0,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    49,    48,    51,    50,    53,    52,    55,    54,    57,
      56,    59,    58,     0,     0,     0,     0,     0,     0,    97,
      95,    96,     0,     0,     0,     0,     0,     0,    63,    62,
      61,    60,    65,    64,    67,    66,    69,    68,    71,    70
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
     -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,
     -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,
     -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,   -74,
     -74,   -74,   -74,   -74,   -74,   -74,   -35,   -73
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
       0,     1,     2,    44,    45,    46,    47,    48,    49,    50,
      51,    52,    53,    54,    55,    56,    57,    58,    59,    60,
      61,    62,    63,    64,    65,    66,    67,    68,    69,    70,
      71,    72,    73,    74,    75,    76,   105,   106
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_uint8 yytable[] =
{
     108,   110,   111,   115,   140,   141,     3,   169,   140,   141,
      77,    79,   100,   100,   101,   101,   102,   100,    78,   101,
     114,   100,   117,   101,   151,   100,   118,   101,   153,   100,
     119,   101,   155,   100,   120,   101,   157,   100,   121,   101,
     159,   100,   116,   101,   161,   100,   122,   101,   178,   100,
     123,   101,   180,   152,   154,   156,   158,   160,   162,   103,
      80,   104,   104,   103,    81,    82,   104,   103,   138,   139,
     104,   103,    83,    84,   104,   103,    85,    86,   104,   103,
      87,    88,   104,   103,    89,    90,   104,   103,    91,    92,
     104,   103,    93,    94,   104,   103,    95,    96,   104,   179,
     181,   183,   185,   187,   189,   170,   171,   100,     0,   101,
     182,   100,   124,   101,   184,   100,     0,   101,   186,   100,
       0,   101,   188,   100,     0,   101,   107,   100,     0,   101,
     109,    97,    98,    99,   112,   113,   142,   125,   126,   143,
     144,   127,   128,   129,   130,   131,   132,   133,   134,   135,
     136,   145,   137,   103,   146,   147,   104,   103,   148,   149,
     104,   103,   150,   163,   104,   103,   164,   165,   104,   166,
     167,   168,   104,   172,     0,     0,   104,     4,     5,     6,
       7,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,   173,    38,    39,    40,    41,    42,    43,     0,   174,
     175,   176,   177
};

static const yytype_int16 yycheck[] =
{
      35,    36,    37,    76,    50,    51,     0,    53,    50,    51,
      40,     4,     3,     3,     5,     5,     6,     3,    48,     5,
       6,     3,    47,     5,     6,     3,    47,     5,     6,     3,
      47,     5,     6,     3,    47,     5,     6,     3,    47,     5,
       6,     3,    77,     5,     6,     3,    47,     5,     6,     3,
      47,     5,     6,   126,   127,   128,   129,   130,   131,    49,
       4,    52,    52,    49,     4,     4,    52,    49,   103,   104,
      52,    49,     4,     4,    52,    49,     4,     4,    52,    49,
       4,     4,    52,    49,     4,     4,    52,    49,     4,     4,
      52,    49,     4,     4,    52,    49,     4,     4,    52,   172,
     173,   174,   175,   176,   177,   140,   141,     3,    -1,     5,
       6,     3,    47,     5,     6,     3,    -1,     5,     6,     3,
      -1,     5,     6,     3,    -1,     5,     6,     3,    -1,     5,
       6,     4,     4,     4,     4,     4,     4,    47,    47,     4,
       4,    47,    47,    47,    47,    47,    47,    47,    47,    47,
      47,     4,    47,    49,     4,     4,    52,    49,     4,     4,
      52,    49,     4,     4,    52,    49,     4,     4,    52,     4,
       4,     4,    52,    47,    -1,    -1,    52,     6,     7,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    47,    41,    42,    43,    44,    45,    46,    -1,    47,
      47,    47,    47
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int8 yystos[] =
{
       0,    55,    56,     0,     6,     7,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    41,    42,
      43,    44,    45,    46,    57,    58,    59,    60,    61,    62,
      63,    64,    65,    66,    67,    68,    69,    70,    71,    72,
      73,    74,    75,    76,    77,    78,    79,    80,    81,    82,
      83,    84,    85,    86,    87,    88,    89,    40,    48,     4,
       4,     4,     4,     4,     4,     4,     4,     4,     4,     4,
       4,     4,     4,     4,     4,     4,     4,     4,     4,     4,
       3,     5,     6,    49,    52,    90,    91,     6,    90,     6,
      90,    90,     4,     4,     6,    91,    90,    47,    47,    47,
      47,    47,    47,    47,    47,    47,    47,    47,    47,    47,
      47,    47,    47,    47,    47,    47,    47,    47,    90,    90,
      50,    51,     4,     4,     4,     4,     4,     4,     4,     4,
       4,     6,    91,     6,    91,     6,    91,     6,    91,     6,
      91,     6,    91,     4,     4,     4,     4,     4,     4,    53,
      90,    90,    47,    47,    47,    47,    47,    47,     6,    91,
       6,    91,     6,    91,     6,    91,     6,    91,     6,    91
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr1[] =
{
       0,    54,    55,    56,    56,    57,    57,    57,    58,    59,
      59,    59,    59,    59,    59,    59,    59,    59,    59,    59,
      59,    59,    59,    59,    59,    59,    59,    59,    59,    59,
      59,    59,    59,    59,    59,    59,    59,    60,    61,    62,
      63,    64,    65,    66,    67,    68,    69,    70,    71,    71,
      72,    72,    73,    73,    74,    74,    75,    75,    76,    76,
      77,    77,    78,    78,    79,    79,    80,    80,    81,    81,
      82,    82,    83,    83,    84,    84,    85,    86,    87,    88,
      88,    88,    88,    88,    88,    89,    89,    89,    89,    89,
      89,    89,    89,    90,    90,    90,    90,    90,    91,    91
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     2,     2,     0,     1,     1,     1,     2,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     4,     4,     4,
       4,     4,     4,     4,     4,     4,     2,     2,     4,     4,
       4,     4,     4,     4,     4,     4,     4,     4,     4,     4,
       6,     6,     6,     6,     6,     6,     6,     6,     6,     6,
       6,     6,     2,     2,     2,     2,     1,     1,     1,     2,
       2,     2,     2,     2,     3,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     3,     3,     3,     2,     1
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
  case 2: /* program: lines TOKEN_ENDFILE  */
#line 57 "parser.y"
                {
                    return 0;
                }
#line 1303 "parser.tab.c"
    break;

  case 8: /* label_decl: TOKEN_IDENTIFIER TOKEN_COLON  */
#line 71 "parser.y"
                {
                    /* gets the current LC and associates it to the declared label */
                    uint32_t current_lc = get_location_counter();
                    set_symbol_value((yyvsp[-1].num), (int16_t)current_lc);    
                }
#line 1313 "parser.tab.c"
    break;

  case 37: /* add_stmt: TOKEN_ADD TOKEN_REG TOKEN_COMMA TOKEN_REG  */
#line 89 "parser.y"
                { 
                    add_statement_rr(RR_OPCODE, ADD_FN, (yyvsp[-2].num), (yyvsp[0].num));
                }
#line 1321 "parser.tab.c"
    break;

  case 38: /* sub_stmt: TOKEN_SUB TOKEN_REG TOKEN_COMMA TOKEN_REG  */
#line 94 "parser.y"
                { 
                    add_statement_rr(RR_OPCODE, SUB_FN, (yyvsp[-2].num), (yyvsp[0].num));
                }
#line 1329 "parser.tab.c"
    break;

  case 39: /* and_stmt: TOKEN_AND TOKEN_REG TOKEN_COMMA TOKEN_REG  */
#line 99 "parser.y"
                { 
                    add_statement_rr(RR_OPCODE, AND_FN, (yyvsp[-2].num), (yyvsp[0].num));
                }
#line 1337 "parser.tab.c"
    break;

  case 40: /* xor_stmt: TOKEN_XOR TOKEN_REG TOKEN_COMMA TOKEN_REG  */
#line 104 "parser.y"
                { 
                    add_statement_rr(RR_OPCODE, XOR_FN, (yyvsp[-2].num), (yyvsp[0].num));
                }
#line 1345 "parser.tab.c"
    break;

  case 41: /* adc_stmt: TOKEN_ADC TOKEN_REG TOKEN_COMMA TOKEN_REG  */
#line 109 "parser.y"
                { 
                    add_statement_rr(RR_OPCODE, ADC_FN, (yyvsp[-2].num), (yyvsp[0].num));
                }
#line 1353 "parser.tab.c"
    break;

  case 42: /* sbc_stmt: TOKEN_SBC TOKEN_REG TOKEN_COMMA TOKEN_REG  */
#line 114 "parser.y"
                { 
                    add_statement_rr(RR_OPCODE, SBC_FN, (yyvsp[-2].num), (yyvsp[0].num));
                }
#line 1361 "parser.tab.c"
    break;

  case 43: /* cmp_stmt: TOKEN_CMP TOKEN_REG TOKEN_COMMA TOKEN_REG  */
#line 119 "parser.y"
                { 
                    add_statement_rr(RR_OPCODE, CMP_FN, (yyvsp[-2].num), (yyvsp[0].num));
                }
#line 1369 "parser.tab.c"
    break;

  case 44: /* srl_stmt: TOKEN_SRL TOKEN_REG TOKEN_COMMA TOKEN_REG  */
#line 124 "parser.y"
                { 
                    add_statement_rr(RR_OPCODE, SRL_FN, (yyvsp[-2].num), (yyvsp[0].num));
                }
#line 1377 "parser.tab.c"
    break;

  case 45: /* sra_stmt: TOKEN_SRA TOKEN_REG TOKEN_COMMA TOKEN_REG  */
#line 129 "parser.y"
                { 
                    add_statement_rr(RR_OPCODE, SRA_FN, (yyvsp[-2].num), (yyvsp[0].num));
                }
#line 1385 "parser.tab.c"
    break;

  case 46: /* getcc_stmt: TOKEN_GETCC TOKEN_REG  */
#line 134 "parser.y"
                { 
                    add_statement_rr(CC_OPCODE, GETCC_FN, (yyvsp[0].num), 0);
                }
#line 1393 "parser.tab.c"
    break;

  case 47: /* setcc_stmt: TOKEN_SETCC TOKEN_REG  */
#line 139 "parser.y"
                { 
                    add_statement_rr(CC_OPCODE, SETCC_FN, 0, (yyvsp[0].num));
                }
#line 1401 "parser.tab.c"
    break;

  case 48: /* rsubi_stmt: TOKEN_RSUBI TOKEN_REG TOKEN_COMMA immediate_val  */
#line 145 "parser.y"
                { 
                    add_statement_ri(RI_OPCODE, RSUBI_FN, (yyvsp[-2].num), (yyvsp[0].num));
                }
#line 1409 "parser.tab.c"
    break;

  case 49: /* rsubi_stmt: TOKEN_RSUBI TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER  */
#line 149 "parser.y"
                { 
                    add_statement_ri(RI_OPCODE, RSUBI_FN, (yyvsp[-2].num), get_symbol_value((yyvsp[0].num)));
                }
#line 1417 "parser.tab.c"
    break;

  case 50: /* andi_stmt: TOKEN_ANDI TOKEN_REG TOKEN_COMMA immediate_val  */
#line 154 "parser.y"
                { 
                    add_statement_ri(RI_OPCODE, ANDI_FN, (yyvsp[-2].num), (yyvsp[0].num));
                }
#line 1425 "parser.tab.c"
    break;

  case 51: /* andi_stmt: TOKEN_ANDI TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER  */
#line 158 "parser.y"
                { 
                    add_statement_ri(RI_OPCODE, ANDI_FN, (yyvsp[-2].num), get_symbol_value((yyvsp[0].num)));
                }
#line 1433 "parser.tab.c"
    break;

  case 52: /* xori_stmt: TOKEN_XORI TOKEN_REG TOKEN_COMMA immediate_val  */
#line 163 "parser.y"
                { 
                    add_statement_ri(RI_OPCODE, XORI_FN, (yyvsp[-2].num), (yyvsp[0].num));
                }
#line 1441 "parser.tab.c"
    break;

  case 53: /* xori_stmt: TOKEN_XORI TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER  */
#line 167 "parser.y"
                { 
                    add_statement_ri(RI_OPCODE, XORI_FN, (yyvsp[-2].num), get_symbol_value((yyvsp[0].num)));
                }
#line 1449 "parser.tab.c"
    break;

  case 54: /* adci_stmt: TOKEN_ADCI TOKEN_REG TOKEN_COMMA immediate_val  */
#line 172 "parser.y"
                { 
                    add_statement_ri(RI_OPCODE, ADCI_FN, (yyvsp[-2].num), (yyvsp[0].num));
                }
#line 1457 "parser.tab.c"
    break;

  case 55: /* adci_stmt: TOKEN_ADCI TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER  */
#line 176 "parser.y"
                { 
                    add_statement_ri(RI_OPCODE, ADCI_FN, (yyvsp[-2].num), get_symbol_value((yyvsp[0].num)));
                }
#line 1465 "parser.tab.c"
    break;

  case 56: /* rsbci_stmt: TOKEN_RSBCI TOKEN_REG TOKEN_COMMA immediate_val  */
#line 181 "parser.y"
                { 
                    add_statement_ri(RI_OPCODE, RSBCI_FN, (yyvsp[-2].num), (yyvsp[0].num));
                }
#line 1473 "parser.tab.c"
    break;

  case 57: /* rsbci_stmt: TOKEN_RSBCI TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER  */
#line 185 "parser.y"
                { 
                    add_statement_ri(RI_OPCODE, RSBCI_FN, (yyvsp[-2].num), get_symbol_value((yyvsp[0].num)));
                }
#line 1481 "parser.tab.c"
    break;

  case 58: /* rcmpi_stmt: TOKEN_RCMPI TOKEN_REG TOKEN_COMMA immediate_val  */
#line 190 "parser.y"
                { 
                    add_statement_ri(RI_OPCODE, RCMPI_FN, (yyvsp[-2].num), (yyvsp[0].num));
                }
#line 1489 "parser.tab.c"
    break;

  case 59: /* rcmpi_stmt: TOKEN_RCMPI TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER  */
#line 194 "parser.y"
                { 
                    add_statement_ri(RI_OPCODE, RCMPI_FN, (yyvsp[-2].num), get_symbol_value((yyvsp[0].num)));
                }
#line 1497 "parser.tab.c"
    break;

  case 60: /* addi_stmt: TOKEN_ADDI TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA immediate_val  */
#line 200 "parser.y"
                { 
                    /* the value is a number saved as IMMEDIATE, no Step 2 needed */
                    add_statement_rri(ADDI_OPCODE, (yyvsp[-4].num), (yyvsp[-2].num), (yyvsp[0].num), IMMEDIATE);
                }
#line 1506 "parser.tab.c"
    break;

  case 61: /* addi_stmt: TOKEN_ADDI TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER  */
#line 205 "parser.y"
                { 
                    /* the value is a Label. forwarding the symbol table index ($6) to the IR, to be resolved in Step 2. */
                    add_statement_rri(ADDI_OPCODE, (yyvsp[-4].num), (yyvsp[-2].num), (yyvsp[0].num), LABEL);
                }
#line 1515 "parser.tab.c"
    break;

  case 62: /* jal_stmt: TOKEN_JAL TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA immediate_val  */
#line 211 "parser.y"
                { 
                    add_statement_rri(JAL_OPCODE, (yyvsp[-4].num), (yyvsp[-2].num), (yyvsp[0].num), IMMEDIATE);
                }
#line 1523 "parser.tab.c"
    break;

  case 63: /* jal_stmt: TOKEN_JAL TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER  */
#line 215 "parser.y"
                { 
                    add_statement_rri(JAL_OPCODE, (yyvsp[-4].num), (yyvsp[-2].num), (yyvsp[0].num), LABEL);
                }
#line 1531 "parser.tab.c"
    break;

  case 64: /* lw_stmt: TOKEN_LW TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA immediate_val  */
#line 220 "parser.y"
                { 
                    add_statement_rri(LW_OPCODE, (yyvsp[-4].num), (yyvsp[-2].num), (yyvsp[0].num), IMMEDIATE);
                }
#line 1539 "parser.tab.c"
    break;

  case 65: /* lw_stmt: TOKEN_LW TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER  */
#line 224 "parser.y"
                { 
                    add_statement_rri(LW_OPCODE, (yyvsp[-4].num), (yyvsp[-2].num), (yyvsp[0].num), LABEL);
                }
#line 1547 "parser.tab.c"
    break;

  case 66: /* lb_stmt: TOKEN_LB TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA immediate_val  */
#line 229 "parser.y"
                { 
                    add_statement_rri(LB_OPCODE, (yyvsp[-4].num), (yyvsp[-2].num), (yyvsp[0].num), IMMEDIATE);
                }
#line 1555 "parser.tab.c"
    break;

  case 67: /* lb_stmt: TOKEN_LB TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER  */
#line 233 "parser.y"
                { 
                    add_statement_rri(LB_OPCODE, (yyvsp[-4].num), (yyvsp[-2].num), (yyvsp[0].num), LABEL);
                }
#line 1563 "parser.tab.c"
    break;

  case 68: /* sw_stmt: TOKEN_SW TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA immediate_val  */
#line 238 "parser.y"
                { 
                    add_statement_rri(SW_OPCODE, (yyvsp[-4].num), (yyvsp[-2].num), (yyvsp[0].num), IMMEDIATE);
                }
#line 1571 "parser.tab.c"
    break;

  case 69: /* sw_stmt: TOKEN_SW TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER  */
#line 242 "parser.y"
                { 
                    add_statement_rri(SW_OPCODE, (yyvsp[-4].num), (yyvsp[-2].num), (yyvsp[0].num), LABEL);
                }
#line 1579 "parser.tab.c"
    break;

  case 70: /* sb_stmt: TOKEN_SB TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA immediate_val  */
#line 247 "parser.y"
                { 
                    add_statement_rri(SB_OPCODE, (yyvsp[-4].num), (yyvsp[-2].num), (yyvsp[0].num), IMMEDIATE);
                }
#line 1587 "parser.tab.c"
    break;

  case 71: /* sb_stmt: TOKEN_SB TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER  */
#line 251 "parser.y"
                { 
                    add_statement_rri(SB_OPCODE, (yyvsp[-4].num), (yyvsp[-2].num), (yyvsp[0].num), LABEL);
                }
#line 1595 "parser.tab.c"
    break;

  case 72: /* imm_stmt: TOKEN_IMM_TOK immediate_val  */
#line 257 "parser.y"
                { 
                    add_statement_i12(IMM_OPCODE, (yyvsp[0].num));
                }
#line 1603 "parser.tab.c"
    break;

  case 73: /* imm_stmt: TOKEN_IMM_TOK TOKEN_IDENTIFIER  */
#line 261 "parser.y"
                { 
                    /* immediate resolution for 12-bit prefix */
                    add_statement_i12(IMM_OPCODE, get_symbol_value((yyvsp[0].num)));
                }
#line 1612 "parser.tab.c"
    break;

  case 74: /* branch_stmt: branch_op immediate_val  */
#line 268 "parser.y"
                { 
                    add_statement_br(BR_OPCODE, (yyvsp[-1].num), (yyvsp[0].num), IMMEDIATE);
                }
#line 1620 "parser.tab.c"
    break;

  case 75: /* branch_stmt: branch_op TOKEN_IDENTIFIER  */
#line 272 "parser.y"
                { 
                    /* branch targets are stored as indexes (LABEL flag) for relative displacement calculation in Step 2 */
                    add_statement_br(BR_OPCODE, (yyvsp[-1].num), (yyvsp[0].num), LABEL);
                }
#line 1629 "parser.tab.c"
    break;

  case 76: /* cli_stmt: TOKEN_CLI  */
#line 278 "parser.y"
                { 
                    add_statement_fixed(CLI_OPCODE);
                }
#line 1637 "parser.tab.c"
    break;

  case 77: /* sti_stmt: TOKEN_STI  */
#line 283 "parser.y"
                { 
                    add_statement_fixed(STI_OPCODE);
                }
#line 1645 "parser.tab.c"
    break;

  case 78: /* nop_stmt: TOKEN_NOP  */
#line 288 "parser.y"
                { 
                    add_statement_fixed(NOP_OPCODE);
                }
#line 1653 "parser.tab.c"
    break;

  case 79: /* directive: TOKEN_ORG expression  */
#line 294 "parser.y"
                { 
                    add_statement_directive(DIR_ORG, (yyvsp[0].num));
                }
#line 1661 "parser.tab.c"
    break;

  case 80: /* directive: TOKEN_WORD expression  */
#line 298 "parser.y"
                { 
                    add_statement_directive(DIR_WORD, (yyvsp[0].num));
                }
#line 1669 "parser.tab.c"
    break;

  case 81: /* directive: TOKEN_WORD TOKEN_IDENTIFIER  */
#line 302 "parser.y"
                { 
                    add_statement_directive(DIR_WORD, get_symbol_value((yyvsp[0].num)));
                }
#line 1677 "parser.tab.c"
    break;

  case 82: /* directive: TOKEN_BYTE expression  */
#line 306 "parser.y"
                { 
                    add_statement_directive(DIR_BYTE, (yyvsp[0].num));
                }
#line 1685 "parser.tab.c"
    break;

  case 83: /* directive: TOKEN_BYTE TOKEN_IDENTIFIER  */
#line 310 "parser.y"
                { 
                    add_statement_directive(DIR_BYTE, get_symbol_value((yyvsp[0].num)));
                }
#line 1693 "parser.tab.c"
    break;

  case 84: /* directive: TOKEN_IDENTIFIER TOKEN_EQU expression  */
#line 314 "parser.y"
                {
                    /* assigns a constant value to a symbol explicitly */
                    set_symbol_value((yyvsp[-2].num), (yyvsp[0].num));
                    add_statement_directive(DIR_EQU, (yyvsp[0].num)); 
                }
#line 1703 "parser.tab.c"
    break;

  case 85: /* branch_op: TOKEN_BR  */
#line 320 "parser.y"
                            { (yyval.num) = (yyvsp[0].num); }
#line 1709 "parser.tab.c"
    break;

  case 86: /* branch_op: TOKEN_BEQ  */
#line 321 "parser.y"
                            { (yyval.num) = (yyvsp[0].num); }
#line 1715 "parser.tab.c"
    break;

  case 87: /* branch_op: TOKEN_BC  */
#line 322 "parser.y"
                            { (yyval.num) = (yyvsp[0].num); }
#line 1721 "parser.tab.c"
    break;

  case 88: /* branch_op: TOKEN_BV  */
#line 323 "parser.y"
                            { (yyval.num) = (yyvsp[0].num); }
#line 1727 "parser.tab.c"
    break;

  case 89: /* branch_op: TOKEN_BLT  */
#line 324 "parser.y"
                            { (yyval.num) = (yyvsp[0].num); }
#line 1733 "parser.tab.c"
    break;

  case 90: /* branch_op: TOKEN_BLE  */
#line 325 "parser.y"
                            { (yyval.num) = (yyvsp[0].num); }
#line 1739 "parser.tab.c"
    break;

  case 91: /* branch_op: TOKEN_BLETU  */
#line 326 "parser.y"
                            { (yyval.num) = (yyvsp[0].num); }
#line 1745 "parser.tab.c"
    break;

  case 92: /* branch_op: TOKEN_BLEU  */
#line 327 "parser.y"
                            { (yyval.num) = (yyvsp[0].num); }
#line 1751 "parser.tab.c"
    break;

  case 93: /* expression: TOKEN_NUMBER  */
#line 332 "parser.y"
                { 
                    (yyval.num) = (yyvsp[0].num);
                }
#line 1759 "parser.tab.c"
    break;

  case 94: /* expression: TOKEN_DOLLAR  */
#line 336 "parser.y"
                { 
                    (yyval.num) = (yyvsp[0].num);
                }
#line 1767 "parser.tab.c"
    break;

  case 95: /* expression: expression TOKEN_PLUS expression  */
#line 340 "parser.y"
                { 
                    (yyval.num) = (yyvsp[-2].num) + (yyvsp[0].num);
                }
#line 1775 "parser.tab.c"
    break;

  case 96: /* expression: expression TOKEN_MINUS expression  */
#line 344 "parser.y"
                { 
                    (yyval.num) = (yyvsp[-2].num) - (yyvsp[0].num);
                }
#line 1783 "parser.tab.c"
    break;

  case 97: /* expression: TOKEN_LEFT_PAREN expression TOKEN_RIGHT_PAREN  */
#line 348 "parser.y"
                { 
                    (yyval.num) = (yyvsp[-1].num);
                }
#line 1791 "parser.tab.c"
    break;

  case 98: /* immediate_val: TOKEN_CARDINAL expression  */
#line 354 "parser.y"
                { 
                    (yyval.num) = (yyvsp[0].num);
                }
#line 1799 "parser.tab.c"
    break;

  case 99: /* immediate_val: expression  */
#line 358 "parser.y"
                { 
                    (yyval.num) = (yyvsp[0].num);
                }
#line 1807 "parser.tab.c"
    break;


#line 1811 "parser.tab.c"

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

#line 363 "parser.y"


void yyerror(const char *s) {
    fprintf(stderr, "Parser- Syntax error %s\n", s);
}
