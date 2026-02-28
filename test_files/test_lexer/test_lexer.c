#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

/* ── Nomes dos tokens para imprimir ── */
static const char* token_name(int tok) {
    switch (tok) {
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
        case TOKEN_INLINE:   return "inline";
        case TOKEN_SIGNED:   return "signed";
        case TOKEN_UNSIGNED: return "unsigned";
        case TOKEN_LONG:     return "long";
        case TOKEN_SHORT:    return "short";
        case TOKEN_STATIC:   return "static";
        case TOKEN_EXTERN:   return "extern";
        case TOKEN_CONST:    return "const";
        case TOKEN_VOLATILE: return "volatile";
        case TOKEN_IF:       return "if";
        case TOKEN_ELSE:     return "else";
        case TOKEN_SWITCH:   return "switch";
        case TOKEN_CASE:     return "case";
        case TOKEN_DEFAULT:  return "default";
        case TOKEN_FOR:      return "for";
        case TOKEN_WHILE:    return "while";
        case TOKEN_DO:       return "do";
        case TOKEN_BREAK:    return "break";
        case TOKEN_CONTINUE: return "continue";
        case TOKEN_RETURN:   return "return";
        case TOKEN_GOTO:     return "goto";
        case TOKEN_PLUS:     return "+";
        case TOKEN_MINUS:    return "-";
        case TOKEN_ASTERISK: return "*";
        case TOKEN_OVER:     return "/";
        case TOKEN_PERCENT:  return "%";
        case TOKEN_ASSIGN:   return "=";
        case TOKEN_EQUAL:    return "==";
        case TOKEN_NOT_EQUAL: return "!=";
        case TOKEN_LESS_THAN: return "<";
        case TOKEN_GREATER_THAN: return ">";
        case TOKEN_LESS_THAN_OR_EQUAL:    return "<=";
        case TOKEN_GREATER_THAN_OR_EQUAL: return ">=";
        case TOKEN_LOGICAL_AND: return "&&";
        case TOKEN_LOGICAL_OR:  return "||";
        case TOKEN_LOGICAL_NOT: return "!";
        case TOKEN_INCREMENT:   return "++";
        case TOKEN_DECREMENT:   return "--";
        case TOKEN_SEMI:   return ";";
        case TOKEN_COMMA:  return ",";
        case TOKEN_COLON:  return ":";
        case TOKEN_TERNARY: return "?";
        case TOKEN_LEFT_PARENTHESES:  return "(";
        case TOKEN_RIGHT_PARENTHESES: return ")";
        case TOKEN_LEFT_BRACE:        return "{";
        case TOKEN_RIGHT_BRACE:       return "}";
        case TOKEN_LEFT_BRACKET:      return "[";
        case TOKEN_RIGHT_BRACKET:     return "]";
        case TOKEN_PLUS_ASSIGN:           return "+=";
	case TOKEN_MINUS_ASSIGN:          return "-=";
	case TOKEN_MULTIPLY_ASSIGN:       return "*=";
	case TOKEN_DIVIDE_ASSIGN:         return "/=";
	case TOKEN_MODULUS_ASSIGN:        return "%=";
	case TOKEN_AND_ASSIGN:            return "&=";
	case TOKEN_OR_ASSIGN:             return "|=";
	case TOKEN_XOR_ASSIGN:            return "^=";
	case TOKEN_LEFT_SHIFT_ASSIGN:     return "<<=";
	case TOKEN_RIGHT_SHIFT_ASSIGN:    return ">>=";
	case TOKEN_BITWISE_AND:           return "&";
	case TOKEN_BITWISE_OR:            return "|";
	case TOKEN_BITWISE_XOR:           return "^";
	case TOKEN_BITWISE_NOT:           return "~";
	case TOKEN_LEFT_SHIFT:            return "<<";
	case TOKEN_RIGHT_SHIFT:           return ">>";
        case TOKEN_ERROR:  return "ERROR";
        default:           return "UNKNOWN";
    }
}

extern int   line_number;
extern FILE* yyin;
extern char* yytext;
extern int   yylex(void);

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <ficheiro.c>\n", argv[0]);
        return 1;
    }
    yyin = fopen(argv[1], "r");
    if (!yyin) { perror(argv[1]); return 1; }

    printf("%-6s  %-25s  %s\n", "LINE", "TOKEN", "LEXEME");
    printf("%-6s  %-25s  %s\n", "----", "-----", "------");

    int tok;
    while ((tok = yylex()) != 0 && tok != TOKEN_ERROR) {
        printf("%-6d  %-25s  %s\n", line_number, token_name(tok), yytext);
    }
    if (tok == TOKEN_ERROR)
        fprintf(stderr, "Erro no lexer na linha %d\n", line_number);

    printf("%-6d  EOF\n", line_number);
    fclose(yyin);
    return 0;
}
