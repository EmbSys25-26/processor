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
    TOKEN_IDENTIFIER = 260,        /* TOKEN_IDENTIFIER  */
    TOKEN_BR = 261,                /* TOKEN_BR  */
    TOKEN_BEQ = 262,               /* TOKEN_BEQ  */
    TOKEN_BC = 263,                /* TOKEN_BC  */
    TOKEN_BV = 264,                /* TOKEN_BV  */
    TOKEN_BLT = 265,               /* TOKEN_BLT  */
    TOKEN_BLE = 266,               /* TOKEN_BLE  */
    TOKEN_BLETU = 267,             /* TOKEN_BLETU  */
    TOKEN_BLEU = 268,              /* TOKEN_BLEU  */
    TOKEN_ADD = 269,               /* TOKEN_ADD  */
    TOKEN_SUB = 270,               /* TOKEN_SUB  */
    TOKEN_AND = 271,               /* TOKEN_AND  */
    TOKEN_XOR = 272,               /* TOKEN_XOR  */
    TOKEN_ADC = 273,               /* TOKEN_ADC  */
    TOKEN_SBC = 274,               /* TOKEN_SBC  */
    TOKEN_CMP = 275,               /* TOKEN_CMP  */
    TOKEN_SRL = 276,               /* TOKEN_SRL  */
    TOKEN_SRA = 277,               /* TOKEN_SRA  */
    TOKEN_RSUBI = 278,             /* TOKEN_RSUBI  */
    TOKEN_ANDI = 279,              /* TOKEN_ANDI  */
    TOKEN_XORI = 280,              /* TOKEN_XORI  */
    TOKEN_ADCI = 281,              /* TOKEN_ADCI  */
    TOKEN_RSBCI = 282,             /* TOKEN_RSBCI  */
    TOKEN_RCMPI = 283,             /* TOKEN_RCMPI  */
    TOKEN_JAL = 284,               /* TOKEN_JAL  */
    TOKEN_ADDI = 285,              /* TOKEN_ADDI  */
    TOKEN_LW = 286,                /* TOKEN_LW  */
    TOKEN_LB = 287,                /* TOKEN_LB  */
    TOKEN_SW = 288,                /* TOKEN_SW  */
    TOKEN_SB = 289,                /* TOKEN_SB  */
    TOKEN_IMM_TOK = 290,           /* TOKEN_IMM_TOK  */
    TOKEN_BYTE = 291,              /* TOKEN_BYTE  */
    TOKEN_WORD = 292,              /* TOKEN_WORD  */
    TOKEN_ORG = 293,               /* TOKEN_ORG  */
    TOKEN_EQU = 294,               /* TOKEN_EQU  */
    TOKEN_GETCC = 295,             /* TOKEN_GETCC  */
    TOKEN_SETCC = 296,             /* TOKEN_SETCC  */
    TOKEN_CLI = 297,               /* TOKEN_CLI  */
    TOKEN_STI = 298,               /* TOKEN_STI  */
    TOKEN_NOP = 299,               /* TOKEN_NOP  */
    TOKEN_ENDFILE = 300,           /* TOKEN_ENDFILE  */
    TOKEN_COMMA = 301,             /* TOKEN_COMMA  */
    TOKEN_COLON = 302,             /* TOKEN_COLON  */
    TOKEN_CARDINAL = 303           /* TOKEN_CARDINAL  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 14 "parser.y"

    int num;

#line 116 "parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
