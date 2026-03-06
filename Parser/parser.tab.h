/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

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

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 5 "parser.y"

#include "ASTree.h"
#include "../Util/NodeTypes.h"

#line 54 "parser.tab.h"

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    TOKEN_NUM = 258,               /* TOKEN_NUM  */
    TOKEN_FNUM = 259,              /* TOKEN_FNUM  */
    TOKEN_CNUM = 260,              /* TOKEN_CNUM  */
    TOKEN_STR = 261,               /* TOKEN_STR  */
    TOKEN_ID = 262,                /* TOKEN_ID  */
    TOKEN_INT = 263,               /* TOKEN_INT  */
    TOKEN_CHAR = 264,              /* TOKEN_CHAR  */
    TOKEN_FLOAT = 265,             /* TOKEN_FLOAT  */
    TOKEN_DOUBLE = 266,            /* TOKEN_DOUBLE  */
    TOKEN_VOID = 267,              /* TOKEN_VOID  */
    TOKEN_INLINE = 268,            /* TOKEN_INLINE  */
    TOKEN_SIGNED = 269,            /* TOKEN_SIGNED  */
    TOKEN_UNSIGNED = 270,          /* TOKEN_UNSIGNED  */
    TOKEN_LONG = 271,              /* TOKEN_LONG  */
    TOKEN_SHORT = 272,             /* TOKEN_SHORT  */
    TOKEN_STATIC = 273,            /* TOKEN_STATIC  */
    TOKEN_EXTERN = 274,            /* TOKEN_EXTERN  */
    TOKEN_CONST = 275,             /* TOKEN_CONST  */
    TOKEN_VOLATILE = 276,          /* TOKEN_VOLATILE  */
    TOKEN_STRUCT = 277,            /* TOKEN_STRUCT  */
    TOKEN_UNION = 278,             /* TOKEN_UNION  */
    TOKEN_ENUM = 279,              /* TOKEN_ENUM  */
    TOKEN_SIZEOF = 280,            /* TOKEN_SIZEOF  */
    TOKEN_IF = 281,                /* TOKEN_IF  */
    TOKEN_ELSE = 282,              /* TOKEN_ELSE  */
    TOKEN_SWITCH = 283,            /* TOKEN_SWITCH  */
    TOKEN_CASE = 284,              /* TOKEN_CASE  */
    TOKEN_DEFAULT = 285,           /* TOKEN_DEFAULT  */
    TOKEN_FOR = 286,               /* TOKEN_FOR  */
    TOKEN_WHILE = 287,             /* TOKEN_WHILE  */
    TOKEN_DO = 288,                /* TOKEN_DO  */
    TOKEN_BREAK = 289,             /* TOKEN_BREAK  */
    TOKEN_CONTINUE = 290,          /* TOKEN_CONTINUE  */
    TOKEN_RETURN = 291,            /* TOKEN_RETURN  */
    TOKEN_PP_DEFINE = 292,         /* TOKEN_PP_DEFINE  */
    TOKEN_PP_UNDEF = 293,          /* TOKEN_PP_UNDEF  */
    TOKEN_PLUS = 294,              /* TOKEN_PLUS  */
    TOKEN_MINUS = 295,             /* TOKEN_MINUS  */
    TOKEN_ASTERISK = 296,          /* TOKEN_ASTERISK  */
    TOKEN_DIVIDE = 297,            /* TOKEN_DIVIDE  */
    TOKEN_MOD = 298,               /* TOKEN_MOD  */
    TOKEN_INCREMENT = 299,         /* TOKEN_INCREMENT  */
    TOKEN_DECREMENT = 300,         /* TOKEN_DECREMENT  */
    TOKEN_ASSIGN = 301,            /* TOKEN_ASSIGN  */
    TOKEN_PLUS_ASSIGN = 302,       /* TOKEN_PLUS_ASSIGN  */
    TOKEN_MINUS_ASSIGN = 303,      /* TOKEN_MINUS_ASSIGN  */
    TOKEN_MULTIPLY_ASSIGN = 304,   /* TOKEN_MULTIPLY_ASSIGN  */
    TOKEN_DIVIDE_ASSIGN = 305,     /* TOKEN_DIVIDE_ASSIGN  */
    TOKEN_MODULUS_ASSIGN = 306,    /* TOKEN_MODULUS_ASSIGN  */
    TOKEN_AND_ASSIGN = 307,        /* TOKEN_AND_ASSIGN  */
    TOKEN_OR_ASSIGN = 308,         /* TOKEN_OR_ASSIGN  */
    TOKEN_XOR_ASSIGN = 309,        /* TOKEN_XOR_ASSIGN  */
    TOKEN_LEFT_SHIFT_ASSIGN = 310, /* TOKEN_LEFT_SHIFT_ASSIGN  */
    TOKEN_RIGHT_SHIFT_ASSIGN = 311, /* TOKEN_RIGHT_SHIFT_ASSIGN  */
    TOKEN_EQUAL = 312,             /* TOKEN_EQUAL  */
    TOKEN_NOT_EQUAL = 313,         /* TOKEN_NOT_EQUAL  */
    TOKEN_LESS_THAN = 314,         /* TOKEN_LESS_THAN  */
    TOKEN_GREATER_THAN = 315,      /* TOKEN_GREATER_THAN  */
    TOKEN_LESS_THAN_OR_EQUAL = 316, /* TOKEN_LESS_THAN_OR_EQUAL  */
    TOKEN_GREATER_THAN_OR_EQUAL = 317, /* TOKEN_GREATER_THAN_OR_EQUAL  */
    TOKEN_LOGICAL_AND = 318,       /* TOKEN_LOGICAL_AND  */
    TOKEN_LOGICAL_OR = 319,        /* TOKEN_LOGICAL_OR  */
    TOKEN_LOGICAL_NOT = 320,       /* TOKEN_LOGICAL_NOT  */
    TOKEN_BITWISE_AND = 321,       /* TOKEN_BITWISE_AND  */
    TOKEN_BITWISE_OR = 322,        /* TOKEN_BITWISE_OR  */
    TOKEN_BITWISE_XOR = 323,       /* TOKEN_BITWISE_XOR  */
    TOKEN_BITWISE_NOT = 324,       /* TOKEN_BITWISE_NOT  */
    TOKEN_LEFT_SHIFT = 325,        /* TOKEN_LEFT_SHIFT  */
    TOKEN_RIGHT_SHIFT = 326,       /* TOKEN_RIGHT_SHIFT  */
    TOKEN_ARROW = 327,             /* TOKEN_ARROW  */
    TOKEN_ELLIPSIS = 328,          /* TOKEN_ELLIPSIS  */
    TOKEN_DOT = 329,               /* TOKEN_DOT  */
    TOKEN_SEMI = 330,              /* TOKEN_SEMI  */
    TOKEN_COMMA = 331,             /* TOKEN_COMMA  */
    TOKEN_COLON = 332,             /* TOKEN_COLON  */
    TOKEN_TERNARY = 333,           /* TOKEN_TERNARY  */
    TOKEN_LEFT_PARENTHESES = 334,  /* TOKEN_LEFT_PARENTHESES  */
    TOKEN_RIGHT_PARENTHESES = 335, /* TOKEN_RIGHT_PARENTHESES  */
    TOKEN_LEFT_BRACE = 336,        /* TOKEN_LEFT_BRACE  */
    TOKEN_RIGHT_BRACE = 337,       /* TOKEN_RIGHT_BRACE  */
    TOKEN_LEFT_BRACKET = 338,      /* TOKEN_LEFT_BRACKET  */
    TOKEN_RIGHT_BRACKET = 339,     /* TOKEN_RIGHT_BRACKET  */
    TOKEN_EOF = 340,               /* TOKEN_EOF  */
    TOKEN_ERROR = 341,             /* TOKEN_ERROR  */
    LOWER_THAN_ELSE = 342,         /* LOWER_THAN_ELSE  */
    UNARY = 343                    /* UNARY  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef ParserObject_t YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
