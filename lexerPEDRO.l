%option noyywrap
%x INCOMMENT

%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int line_number = 1;

char pp_name[256];
char pp_value[512];

static void read_pp_define(void);
static void read_pp_undef(void);
static void read_pp_include_sys(void);
static void read_pp_include_usr(void);

typedef enum {
    TOKEN_NUM,  TOKEN_FNUM, TOKEN_CNUM, TOKEN_STR, TOKEN_ID,
    TOKEN_INT,    TOKEN_CHAR,    TOKEN_FLOAT,  TOKEN_DOUBLE, TOKEN_VOID,
    TOKEN_BOOL,   TOKEN_INLINE,
    TOKEN_SIGNED, TOKEN_UNSIGNED, TOKEN_LONG,  TOKEN_SHORT,
    TOKEN_STATIC, TOKEN_EXTERN,   TOKEN_CONST, TOKEN_VOLATILE,
    TOKEN_STRUCT, TOKEN_UNION,  TOKEN_ENUM, TOKEN_TYPEDEF, TOKEN_SIZEOF,
    TOKEN_IF,  TOKEN_ELSE,  TOKEN_SWITCH, TOKEN_CASE,  TOKEN_DEFAULT,
    TOKEN_FOR, TOKEN_WHILE, TOKEN_DO,     TOKEN_BREAK, TOKEN_RETURN,
    TOKEN_PP_DEFINE, TOKEN_PP_UNDEF, TOKEN_PP_INCLUDE_SYS, TOKEN_PP_INCLUDE_USR,
    TOKEN_PLUS, TOKEN_MINUS, TOKEN_ASTERISK, TOKEN_OVER, TOKEN_PERCENT,
    TOKEN_INCREMENT, TOKEN_DECREMENT,
    TOKEN_ASSIGN,
    TOKEN_PLUS_ASSIGN, TOKEN_MINUS_ASSIGN, TOKEN_MULTIPLY_ASSIGN,
    TOKEN_DIVIDE_ASSIGN, TOKEN_MODULUS_ASSIGN,
    TOKEN_AND_ASSIGN, TOKEN_OR_ASSIGN, TOKEN_XOR_ASSIGN,
    TOKEN_LEFT_SHIFT_ASSIGN, TOKEN_RIGHT_SHIFT_ASSIGN,
    TOKEN_EQUAL, TOKEN_NOT_EQUAL,
    TOKEN_LESS_THAN, TOKEN_GREATER_THAN,
    TOKEN_LESS_THAN_OR_EQUAL, TOKEN_GREATER_THAN_OR_EQUAL,
    TOKEN_LOGICAL_AND, TOKEN_LOGICAL_OR, TOKEN_LOGICAL_NOT,
    TOKEN_BITWISE_AND, TOKEN_BITWISE_OR, TOKEN_BITWISE_XOR, TOKEN_BITWISE_NOT,
    TOKEN_LEFT_SHIFT, TOKEN_RIGHT_SHIFT,
    TOKEN_ARROW, TOKEN_DOT,
    TOKEN_SEMI, TOKEN_COMMA, TOKEN_COLON, TOKEN_TERNARY,
    TOKEN_LEFT_PARENTHESES, TOKEN_RIGHT_PARENTHESES,
    TOKEN_LEFT_BRACE, TOKEN_RIGHT_BRACE,
    TOKEN_LEFT_BRACKET, TOKEN_RIGHT_BRACKET,
    TOKEN_EOF, TOKEN_ERROR
} TokenType;

static const char *token_name(TokenType t);
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
"bool"      { return TOKEN_BOOL;     }
"inline"    { return TOKEN_INLINE;   }
"signed"    { return TOKEN_SIGNED;   }
"unsigned"  { return TOKEN_UNSIGNED; }
"long"      { return TOKEN_LONG;     }
"short"     { return TOKEN_SHORT;    }
"static"    { return TOKEN_STATIC;   }
"extern"    { return TOKEN_EXTERN;   }
"const"     { return TOKEN_CONST;    }
"volatile"  { return TOKEN_VOLATILE; }
"struct"    { return TOKEN_STRUCT;   }
"union"     { return TOKEN_UNION;    }
"enum"      { return TOKEN_ENUM;     }
"typedef"   { return TOKEN_TYPEDEF;  }
"sizeof"    { return TOKEN_SIZEOF;   }
"if"        { return TOKEN_IF;       }
"else"      { return TOKEN_ELSE;     }
"switch"    { return TOKEN_SWITCH;   }
"case"      { return TOKEN_CASE;     }
"default"   { return TOKEN_DEFAULT;  }
"for"       { return TOKEN_FOR;      }
"while"     { return TOKEN_WHILE;    }
"do"        { return TOKEN_DO;       }
"break"     { return TOKEN_BREAK;    }
"return"    { return TOKEN_RETURN;   }

"#define"[ \t]+      { read_pp_define();      return TOKEN_PP_DEFINE;      }
"#undef"[ \t]+       { read_pp_undef();       return TOKEN_PP_UNDEF;        }
"#include"[ \t]*"<"  { read_pp_include_sys(); return TOKEN_PP_INCLUDE_SYS; }
"#include"[ \t]*"\"" { read_pp_include_usr(); return TOKEN_PP_INCLUDE_USR; }

"<<="   { return TOKEN_LEFT_SHIFT_ASSIGN;  }
">>="   { return TOKEN_RIGHT_SHIFT_ASSIGN; }
"+="    { return TOKEN_PLUS_ASSIGN;        }
"-="    { return TOKEN_MINUS_ASSIGN;       }
"*="    { return TOKEN_MULTIPLY_ASSIGN;    }
"/="    { return TOKEN_DIVIDE_ASSIGN;      }
"%="    { return TOKEN_MODULUS_ASSIGN;     }
"&="    { return TOKEN_AND_ASSIGN;         }
"|="    { return TOKEN_OR_ASSIGN;          }
"^="    { return TOKEN_XOR_ASSIGN;         }

"++"    { return TOKEN_INCREMENT;  }
"--"    { return TOKEN_DECREMENT;  }
"+"     { return TOKEN_PLUS;       }
"-"     { return TOKEN_MINUS;      }
"*"     { return TOKEN_ASTERISK;   }
"/"     { return TOKEN_OVER;       }
"%"     { return TOKEN_PERCENT;    }

"=="    { return TOKEN_EQUAL;                 }
"!="    { return TOKEN_NOT_EQUAL;             }
"<="    { return TOKEN_LESS_THAN_OR_EQUAL;    }
">="    { return TOKEN_GREATER_THAN_OR_EQUAL; }
"<"     { return TOKEN_LESS_THAN;             }
">"     { return TOKEN_GREATER_THAN;          }

"&&"    { return TOKEN_LOGICAL_AND; }
"||"    { return TOKEN_LOGICAL_OR;  }
"!"     { return TOKEN_LOGICAL_NOT; }

"<<"    { return TOKEN_LEFT_SHIFT;  }
">>"    { return TOKEN_RIGHT_SHIFT; }
"&"     { return TOKEN_BITWISE_AND; }
"|"     { return TOKEN_BITWISE_OR;  }
"^"     { return TOKEN_BITWISE_XOR; }
"~"     { return TOKEN_BITWISE_NOT; }

"->"    { return TOKEN_ARROW;  }
"."     { return TOKEN_DOT;    }
"="     { return TOKEN_ASSIGN; }

";"     { return TOKEN_SEMI;              }
","     { return TOKEN_COMMA;             }
":"     { return TOKEN_COLON;             }
"?"     { return TOKEN_TERNARY;           }
"("     { return TOKEN_LEFT_PARENTHESES;  }
")"     { return TOKEN_RIGHT_PARENTHESES; }
"{"     { return TOKEN_LEFT_BRACE;        }
"}"     { return TOKEN_RIGHT_BRACE;       }
"["     { return TOKEN_LEFT_BRACKET;      }
"]"     { return TOKEN_RIGHT_BRACKET;     }

{charlit}     { return TOKEN_CNUM; }
{hexNumber}   { return TOKEN_NUM;  }
{number}      { return TOKEN_NUM;  }
{floatNumber} { return TOKEN_FNUM; }
{string}      { return TOKEN_STR;  }
{identifier}  { return TOKEN_ID;   }

{whitespace} { }
{newline}    { line_number++; }

"//".*  { }

<INITIAL>"/*" { BEGIN(INCOMMENT); }

<INCOMMENT>{
    "*/"    { BEGIN(INITIAL); }
    "\n"    { line_number++;  }
    <<EOF>> { fprintf(stderr, "Line %d: unterminated block comment\n", line_number);
              return TOKEN_ERROR; }
    [^*\n]+ { }
    "*"     { }
}

<<EOF>> { return TOKEN_EOF; }

. { fprintf(stderr, "Line %d: unknown token '%s'\n", line_number, yytext);
    return TOKEN_ERROR; }

%%

static void read_pp_define(void) {
    int ni = 0, vi = 0; char c;
    memset(pp_name, 0, sizeof(pp_name));
    memset(pp_value, 0, sizeof(pp_value));
    while ((c = (char)input()) != (char)EOF && c != ' ' && c != '\t' && c != '\n')
        if (ni < (int)sizeof(pp_name)-1) pp_name[ni++] = c;
    if (c == ' ' || c == '\t')
        while ((c = (char)input()) != (char)EOF && (c == ' ' || c == '\t'));
    if (c != '\n' && c != (char)EOF) {
        if (vi < (int)sizeof(pp_value)-1) pp_value[vi++] = c;
        while ((c = (char)input()) != (char)EOF && c != '\n')
            if (vi < (int)sizeof(pp_value)-1) pp_value[vi++] = c;
    }
    if (c == '\n') line_number++;
}

static void read_pp_undef(void) {
    int ni = 0; char c;
    memset(pp_name, 0, sizeof(pp_name));
    while ((c = (char)input()) != (char)EOF && c != ' ' && c != '\t' && c != '\n')
        if (ni < (int)sizeof(pp_name)-1) pp_name[ni++] = c;
    if (c == '\n') line_number++;
}

static void read_pp_include_sys(void) {
    int ni = 0; char c;
    memset(pp_name, 0, sizeof(pp_name));
    while ((c = (char)input()) != (char)EOF && c != '>' && c != '\n')
        if (ni < (int)sizeof(pp_name)-1) pp_name[ni++] = c;
    if (c == '\n') line_number++;
}

static void read_pp_include_usr(void) {
    int ni = 0; char c;
    memset(pp_name, 0, sizeof(pp_name));
    while ((c = (char)input()) != (char)EOF && c != '"' && c != '\n')
        if (ni < (int)sizeof(pp_name)-1) pp_name[ni++] = c;
    if (c == '\n') line_number++;
}

static const char *token_name(TokenType t) {
    switch (t) {
    case TOKEN_NUM:    return "NUM";
    case TOKEN_FNUM:   return "FNUM";
    case TOKEN_CNUM:   return "CNUM";
    case TOKEN_STR:    return "STR";
    case TOKEN_ID:     return "ID";
    case TOKEN_INT:    return "int";
    case TOKEN_CHAR:   return "char";
    case TOKEN_FLOAT:  return "float";
    case TOKEN_DOUBLE: return "double";
    case TOKEN_VOID:   return "void";
    case TOKEN_BOOL:   return "bool";
    case TOKEN_INLINE: return "inline";
    case TOKEN_SIGNED:   return "signed";
    case TOKEN_UNSIGNED: return "unsigned";
    case TOKEN_LONG:   return "long";
    case TOKEN_SHORT:  return "short";
    case TOKEN_STATIC:   return "static";
    case TOKEN_EXTERN:   return "extern";
    case TOKEN_CONST:    return "const";
    case TOKEN_VOLATILE: return "volatile";
    case TOKEN_STRUCT:  return "struct";
    case TOKEN_UNION:   return "union";
    case TOKEN_ENUM:    return "enum";
    case TOKEN_TYPEDEF: return "typedef";
    case TOKEN_SIZEOF:  return "sizeof";
    case TOKEN_IF:      return "if";
    case TOKEN_ELSE:    return "else";
    case TOKEN_SWITCH:  return "switch";
    case TOKEN_CASE:    return "case";
    case TOKEN_DEFAULT: return "default";
    case TOKEN_FOR:     return "for";
    case TOKEN_WHILE:   return "while";
    case TOKEN_DO:      return "do";
    case TOKEN_BREAK:   return "break";
    case TOKEN_RETURN:  return "return";
    case TOKEN_PP_DEFINE:      return "#define";
    case TOKEN_PP_UNDEF:       return "#undef";
    case TOKEN_PP_INCLUDE_SYS: return "#include<>";
    case TOKEN_PP_INCLUDE_USR: return "#include\"\"";
    case TOKEN_PLUS:       return "+";
    case TOKEN_MINUS:      return "-";
    case TOKEN_ASTERISK:   return "*";
    case TOKEN_OVER:       return "/";
    case TOKEN_PERCENT:    return "%";
    case TOKEN_INCREMENT:  return "++";
    case TOKEN_DECREMENT:  return "--";
    case TOKEN_ASSIGN:             return "=";
    case TOKEN_PLUS_ASSIGN:        return "+=";
    case TOKEN_MINUS_ASSIGN:       return "-=";
    case TOKEN_MULTIPLY_ASSIGN:    return "*=";
    case TOKEN_DIVIDE_ASSIGN:      return "/=";
    case TOKEN_MODULUS_ASSIGN:     return "%=";
    case TOKEN_AND_ASSIGN:         return "&=";
    case TOKEN_OR_ASSIGN:          return "|=";
    case TOKEN_XOR_ASSIGN:         return "^=";
    case TOKEN_LEFT_SHIFT_ASSIGN:  return "<<=";
    case TOKEN_RIGHT_SHIFT_ASSIGN: return ">>=";
    case TOKEN_EQUAL:                 return "==";
    case TOKEN_NOT_EQUAL:             return "!=";
    case TOKEN_LESS_THAN:             return "<";
    case TOKEN_GREATER_THAN:          return ">";
    case TOKEN_LESS_THAN_OR_EQUAL:    return "<=";
    case TOKEN_GREATER_THAN_OR_EQUAL: return ">=";
    case TOKEN_LOGICAL_AND: return "&&";
    case TOKEN_LOGICAL_OR:  return "||";
    case TOKEN_LOGICAL_NOT: return "!";
    case TOKEN_BITWISE_AND: return "&";
    case TOKEN_BITWISE_OR:  return "|";
    case TOKEN_BITWISE_XOR: return "^";
    case TOKEN_BITWISE_NOT: return "~";
    case TOKEN_LEFT_SHIFT:  return "<<";
    case TOKEN_RIGHT_SHIFT: return ">>";
    case TOKEN_ARROW: return "->";
    case TOKEN_DOT:   return ".";
    case TOKEN_SEMI:              return ";";
    case TOKEN_COMMA:             return ",";
    case TOKEN_COLON:             return ":";
    case TOKEN_TERNARY:           return "?";
    case TOKEN_LEFT_PARENTHESES:  return "(";
    case TOKEN_RIGHT_PARENTHESES: return ")";
    case TOKEN_LEFT_BRACE:        return "{";
    case TOKEN_RIGHT_BRACE:       return "}";
    case TOKEN_LEFT_BRACKET:      return "[";
    case TOKEN_RIGHT_BRACKET:     return "]";
    case TOKEN_EOF:   return "EOF";
    case TOKEN_ERROR: return "ERROR";
    default:          return "?";
    }
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) { perror(argv[1]); return 1; }
    }
    TokenType tok;
    printf("%-6s  %-22s  %s\n", "LINE", "TOKEN", "LEXEME");
    printf("%-6s  %-22s  %s\n", "----", "-----", "------");
    while ((tok = (TokenType)yylex()) != TOKEN_EOF && tok != TOKEN_ERROR) {
        if (tok == TOKEN_PP_DEFINE)
            printf("%-6d  %-22s  name=%-20s value=%s\n",
                   line_number, token_name(tok), pp_name, pp_value);
        else if (tok == TOKEN_PP_UNDEF ||
                 tok == TOKEN_PP_INCLUDE_SYS ||
                 tok == TOKEN_PP_INCLUDE_USR)
            printf("%-6d  %-22s  %s\n",
                   line_number, token_name(tok), pp_name);
        else
            printf("%-6d  %-22s  %s\n",
                   line_number, token_name(tok), yytext);
    }
    printf("%-6d  %-22s\n", line_number, "EOF");
    if (argc > 1) fclose(yyin);
    return 0;
}
