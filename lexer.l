%option noyywrap
%x INCOMMENT

%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "parser.tab.h"

YYSTYPE yylval;

int line_number = 1;
%}

digit       [0-9]
number      {digit}+
hexNumber   0[xX][0-9a-fA-F]+
floatNumber {digit}*"."{digit}+([eE][-+]?{digit}+)?
identifier  [a-zA-Z_][a-zA-Z0-9_]*
string      \"([^"\\\n]|\\.|\\\n)*\"
charlit     '([^'\\\n]|\\.)'
whitespace  [ \t\r]+
newline     \n

%%

"int"       { return TOKEN_INT;      }
"char"      { return TOKEN_CHAR;     }
"float"     { return TOKEN_FLOAT;    }
"double"    { return TOKEN_DOUBLE;   }
"void"      { return TOKEN_VOID;     }
"inline"    { return TOKEN_INLINE;   }
"signed"    { return TOKEN_SIGNED;   }
"unsigned"  { return TOKEN_UNSIGNED; }
"long"      { return TOKEN_LONG;     }
"short"     { return TOKEN_SHORT;    }
"static"    { return TOKEN_STATIC;   }
"extern"    { return TOKEN_EXTERN;   }
"const"     { return TOKEN_CONST;    }
"volatile"  { return TOKEN_VOLATILE; }
"if"        { return TOKEN_IF;       }
"else"      { return TOKEN_ELSE;     }
"switch"    { return TOKEN_SWITCH;   }
"case"      { return TOKEN_CASE;     }
"default"   { return TOKEN_DEFAULT;  }
"for"       { return TOKEN_FOR;      }
"while"     { return TOKEN_WHILE;    }
"do"        { return TOKEN_DO;       }
"break"     { return TOKEN_BREAK;    }
"continue"  { return TOKEN_CONTINUE; }
"return"    { return TOKEN_RETURN;   }
"goto"      { return TOKEN_GOTO;     }

"<<="   { return TOKEN_LEFT_SHIFT_ASSIGN;     }
">>="   { return TOKEN_RIGHT_SHIFT_ASSIGN;    }
"+="    { return TOKEN_PLUS_ASSIGN;           }
"-="    { return TOKEN_MINUS_ASSIGN;          }
"*="    { return TOKEN_MULTIPLY_ASSIGN;       }
"/="    { return TOKEN_DIVIDE_ASSIGN;         }
"%="    { return TOKEN_MODULUS_ASSIGN;        }
"&="    { return TOKEN_AND_ASSIGN;            }
"|="    { return TOKEN_OR_ASSIGN;             }
"^="    { return TOKEN_XOR_ASSIGN;            }
"++"    { return TOKEN_INCREMENT;             }
"--"    { return TOKEN_DECREMENT;             }
"+"     { return TOKEN_PLUS;                  }
"-"     { return TOKEN_MINUS;                 }
"*"     { return TOKEN_ASTERISK;              }
"/"     { return TOKEN_OVER;                  }
"%"     { return TOKEN_PERCENT;               }
"=="    { return TOKEN_EQUAL;                 }
"!="    { return TOKEN_NOT_EQUAL;             }
"<="    { return TOKEN_LESS_THAN_OR_EQUAL;    }
">="    { return TOKEN_GREATER_THAN_OR_EQUAL; }
"<"     { return TOKEN_LESS_THAN;             }
">"     { return TOKEN_GREATER_THAN;          }
"&&"    { return TOKEN_LOGICAL_AND;           }
"||"    { return TOKEN_LOGICAL_OR;            }
"!"     { return TOKEN_LOGICAL_NOT;           }
"<<"    { return TOKEN_LEFT_SHIFT;            }
">>"    { return TOKEN_RIGHT_SHIFT;           }
"&"     { return TOKEN_BITWISE_AND;           }
"|"     { return TOKEN_BITWISE_OR;            }
"^"     { return TOKEN_BITWISE_XOR;           }
"~"     { return TOKEN_BITWISE_NOT;           }
"="     { return TOKEN_ASSIGN;                }
";"     { return TOKEN_SEMI;                  }
","     { return TOKEN_COMMA;                 }
":"     { return TOKEN_COLON;                 }
"?"     { return TOKEN_TERNARY;               }
"("     { return TOKEN_LEFT_PARENTHESES;      }
")"     { return TOKEN_RIGHT_PARENTHESES;     }
"{"     { return TOKEN_LEFT_BRACE;            }
"}"     { return TOKEN_RIGHT_BRACE;           }
"["     { return TOKEN_LEFT_BRACKET;          }
"]"     { return TOKEN_RIGHT_BRACKET;         }

{charlit} {
    if (yytext[1] == '\\') {
        switch (yytext[2]) {
            case 'n':  yylval.cval = '\n'; break;
            case 't':  yylval.cval = '\t'; break;
            case 'r':  yylval.cval = '\r'; break;
            case '\\': yylval.cval = '\\'; break;
            case '\'': yylval.cval = '\''; break;
            case '0':  yylval.cval = '\0'; break;
            default:   yylval.cval = yytext[2]; break;
        }
    } else {
        yylval.cval = yytext[1];
    }
    return TOKEN_CNUM;
}

{hexNumber}   { yylval.ival = strtol(yytext, NULL, 16); return TOKEN_NUM;  }
{number}      { yylval.ival = strtol(yytext, NULL, 10); return TOKEN_NUM;  }
{floatNumber} { yylval.fval = strtod(yytext, NULL);     return TOKEN_FNUM; }
{string}      { yylval.sval = strdup(yytext);           return TOKEN_STR;  }
{identifier}  { yylval.sval = strdup(yytext);           return TOKEN_ID;   }

{whitespace}  { }
{newline}     { line_number++; }

"//".*        { }

<INITIAL>"/*" { BEGIN(INCOMMENT); }

<INCOMMENT>{
    "*/"    { BEGIN(INITIAL); }
    "\n"    { line_number++;  }
    <<EOF>> { fprintf(stderr, "Line %d: unterminated block comment\n", line_number);
              return TOKEN_ERROR; }
    [^*\n]+ { }
    "*"     { }
}

<<EOF>> { return 0; }

. { fprintf(stderr, "Line %d: unknown token '%s'\n", line_number, yytext);
    return TOKEN_ERROR; }

%%
