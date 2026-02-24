%option noyywrap
%x INCOMMENT

%{
/*======================================================
    INCLUDES & HEADERS
======================================================*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../Util/asm_operations.h"
#include "../Util/statements_list.h"
#include "../Util/symbol_table.h"
#include "parser.tab.h"

%}

/*======================================================
    DEFINICOES DE PADROES
======================================================*/

digit           [0-9]
hex             [a-fA-F]

dec_number      {digit}+
hex_number_x    0x({digit}|{hex})+

/* Registos R0-R31, aceita maiusculas e minusculas */
register        [Rr]({digit}|[12]{digit}|3[01])

identifier      [a-zA-Z_][a-zA-Z0-9_]*

newline         \n
carriage        \r
whitespace      [ \t]+


%%

"BR"     { yylval.num = BR_COND;    return TOKEN_BR;    }
"BEQ"    { yylval.num = BEQ_COND;   return TOKEN_BEQ;   }
"BC"     { yylval.num = BC_COND;    return TOKEN_BC;    }
"BV"     { yylval.num = BV_COND;    return TOKEN_BV;    }
"BLT"    { yylval.num = BLT_COND;   return TOKEN_BLT;   }
"BLE"    { yylval.num = BLE_COND;   return TOKEN_BLE;   }
"BLETU"  { yylval.num = BLETU_COND; return TOKEN_BLETU; }
"BLEU"   { yylval.num = BLEU_COND;  return TOKEN_BLEU;  }

"ADD"    { return TOKEN_ADD; }
"SUB"    { return TOKEN_SUB; }
"AND"    { return TOKEN_AND; }
"XOR"    { return TOKEN_XOR; }
"ADC"    { return TOKEN_ADC; }
"SBC"    { return TOKEN_SBC; }
"CMP"    { return TOKEN_CMP; }
"SRL"    { return TOKEN_SRL; }
"SRA"    { return TOKEN_SRA; }

"RSUBI"  { return TOKEN_RSUBI; }
"ANDI"   { return TOKEN_ANDI;  }
"XORI"   { return TOKEN_XORI;  }
"ADCI"   { return TOKEN_ADCI;  }
"RSBCI"  { return TOKEN_RSBCI; }
"RCMPI"  { return TOKEN_RCMPI; }

"JAL"    { return TOKEN_JAL;  }
"ADDI"   { return TOKEN_ADDI; }
"LW"     { return TOKEN_LW;   }
"LB"     { return TOKEN_LB;   }
"SW"     { return TOKEN_SW;   }
"SB"     { return TOKEN_SB;   }

"IMM"    { return TOKEN_IMM_TOK; }
"GETCC"  { return TOKEN_GETCC;   }
"SETCC"  { return TOKEN_SETCC;   }
"CLI"    { return TOKEN_CLI;     }
"STI"    { return TOKEN_STI;     }
"NOP"    { return TOKEN_NOP;     }

".byte"  { return TOKEN_BYTE; }
".word"  { return TOKEN_WORD; }
".org"   { return TOKEN_ORG;  }
".equ"   { return TOKEN_EQU;  }

","      { return TOKEN_COMMA;       }
"#"      { return TOKEN_CARDINAL;    }
":"      { return TOKEN_COLON;       }
"+"      { return TOKEN_PLUS;        }
"-"      { return TOKEN_MINUS;       }
"("      { return TOKEN_LEFT_PAREN;  }
")"      { return TOKEN_RIGHT_PAREN; }

"$"            { yylval.num = get_location_counter(); return TOKEN_DOLLAR;     }
{dec_number}   { yylval.num = strtol(yytext, NULL, 10); return TOKEN_NUMBER;   }
{hex_number_x} { yylval.num = strtol(yytext, NULL, 16); return TOKEN_NUMBER;   }
{register}     { yylval.num = atoi(yytext + 1);          return TOKEN_REG;     }
{identifier}   { yylval.num = add_symbol(yytext);         return TOKEN_IDENTIFIER; }

{newline}    { increment_line_number(1); }
{whitespace} { /* ignorar espacos e tabs */ }
{carriage}   { /* ignorar carriage return (Windows) */ }

"//".*  { /* comentario de linha */ }
";".*   { /* comentario de linha */ }

<INITIAL>{
    "/*" { BEGIN(INCOMMENT); }
}

<INCOMMENT>{
    <<EOF>>  { fprintf(stderr, "[ASSEMBLER] Erro: comentario nao terminado\n");
               return -1; }
    "*/"     { BEGIN(INITIAL); }
    "\n"     { increment_line_number(1); }
    [^*\n]+  ;
}

<<EOF>> { return TOKEN_ENDFILE; }

. { fprintf(stderr, "[ASSEMBLER] Erro: token invalido '%s'\n", yytext);
    return -1; }

%%

/*======================================================
    FUNCOES DE SUPORTE
======================================================*/

//Abre o ficheiro fonte e atribui a yyin.
void init_lexer(const char *filename)
{
    yyin = fopen(filename, "r");
    if (!yyin) {
        perror(filename);
        exit(1);
    }
}


