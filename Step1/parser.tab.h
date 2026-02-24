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

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    TOKEN_NUMBER = 258,            /* TOKEN_NUMBER  */
    TOKEN_REG = 259,               /* TOKEN_REG  */
    TOKEN_DOLLAR = 260,            /* TOKEN_DOLLAR  */
    TOKEN_IDENTIFIER = 261,        /* TOKEN_IDENTIFIER  */
    TOKEN_BR = 262,                /* TOKEN_BR  */
    TOKEN_BEQ = 263,               /* TOKEN_BEQ  */
    TOKEN_BC = 264,                /* TOKEN_BC  */
    TOKEN_BV = 265,                /* TOKEN_BV  */
    TOKEN_BLT = 266,               /* TOKEN_BLT  */
    TOKEN_BLE = 267,               /* TOKEN_BLE  */
    TOKEN_BLETU = 268,             /* TOKEN_BLETU  */
    TOKEN_BLEU = 269,              /* TOKEN_BLEU  */
    TOKEN_ADD = 270,               /* TOKEN_ADD  */
    TOKEN_SUB = 271,               /* TOKEN_SUB  */
    TOKEN_AND = 272,               /* TOKEN_AND  */
    TOKEN_XOR = 273,               /* TOKEN_XOR  */
    TOKEN_ADC = 274,               /* TOKEN_ADC  */
    TOKEN_SBC = 275,               /* TOKEN_SBC  */
    TOKEN_CMP = 276,               /* TOKEN_CMP  */
    TOKEN_SRL = 277,               /* TOKEN_SRL  */
    TOKEN_SRA = 278,               /* TOKEN_SRA  */
    TOKEN_RSUBI = 279,             /* TOKEN_RSUBI  */
    TOKEN_ANDI = 280,              /* TOKEN_ANDI  */
    TOKEN_XORI = 281,              /* TOKEN_XORI  */
    TOKEN_ADCI = 282,              /* TOKEN_ADCI  */
    TOKEN_RSBCI = 283,             /* TOKEN_RSBCI  */
    TOKEN_RCMPI = 284,             /* TOKEN_RCMPI  */
    TOKEN_JAL = 285,               /* TOKEN_JAL  */
    TOKEN_ADDI = 286,              /* TOKEN_ADDI  */
    TOKEN_LW = 287,                /* TOKEN_LW  */
    TOKEN_LB = 288,                /* TOKEN_LB  */
    TOKEN_SW = 289,                /* TOKEN_SW  */
    TOKEN_SB = 290,                /* TOKEN_SB  */
    TOKEN_IMM_TOK = 291,           /* TOKEN_IMM_TOK  */
    TOKEN_BYTE = 292,              /* TOKEN_BYTE  */
    TOKEN_WORD = 293,              /* TOKEN_WORD  */
    TOKEN_ORG = 294,               /* TOKEN_ORG  */
    TOKEN_EQU = 295,               /* TOKEN_EQU  */
    TOKEN_GETCC = 296,             /* TOKEN_GETCC  */
    TOKEN_SETCC = 297,             /* TOKEN_SETCC  */
    TOKEN_CLI = 298,               /* TOKEN_CLI  */
    TOKEN_STI = 299,               /* TOKEN_STI  */
    TOKEN_NOP = 300,               /* TOKEN_NOP  */
    TOKEN_ENDFILE = 301,           /* TOKEN_ENDFILE  */
    TOKEN_COMMA = 302,             /* TOKEN_COMMA  */
    TOKEN_COLON = 303,             /* TOKEN_COLON  */
    TOKEN_CARDINAL = 304,          /* TOKEN_CARDINAL  */
    TOKEN_PLUS = 305,              /* TOKEN_PLUS  */
    TOKEN_MINUS = 306,             /* TOKEN_MINUS  */
    TOKEN_LEFT_PAREN = 307,        /* TOKEN_LEFT_PAREN  */
    TOKEN_RIGHT_PAREN = 308        /* TOKEN_RIGHT_PAREN  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 14 "parser.y"

    int num;

#line 121 "parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
