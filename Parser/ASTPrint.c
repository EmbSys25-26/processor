#include <stdio.h>
#include <string.h>
#include "ASTPrint.h"
#include "../Util/NodeTypes.h"

/* ════════════════════════════════════════════════════════════
 *  AST Pretty-Print
 * ════════════════════════════════════════════════════════════ */

static const char* NodeTypeToStr(NodeType_t t)
{
    switch (t) {
        case NODE_SIGN:              return "SIGN";
        case NODE_VISIBILITY:        return "VISIBILITY";
        case NODE_MODIFIER:          return "MODIFIER";
        case NODE_TYPE:              return "TYPE";
        case NODE_OPERATOR:          return "OPERATOR";
        case NODE_TERNARY:           return "TERNARY";
        case NODE_IDENTIFIER:        return "IDENTIFIER";
        case NODE_STRING:            return "STRING";
        case NODE_INTEGER:           return "INTEGER";
        case NODE_FLOAT:             return "FLOAT";
        case NODE_CHAR:              return "CHAR";
        case NODE_IF:                return "IF";
        case NODE_WHILE:             return "WHILE";
        case NODE_DO_WHILE:          return "DO_WHILE";
        case NODE_RETURN:            return "RETURN";
        case NODE_CONTINUE:          return "CONTINUE";
        case NODE_BREAK:             return "BREAK";
        case NODE_SWITCH:            return "SWITCH";
        case NODE_CASE:              return "CASE";
        case NODE_DEFAULT:           return "DEFAULT";
        case NODE_REFERENCE:         return "REFERENCE";
        case NODE_POINTER:           return "POINTER";
        case NODE_POINTER_CONTENT:   return "POINTER_CONTENT";
        case NODE_TYPE_CAST:         return "TYPE_CAST";
        case NODE_POST_DEC:          return "POST_DEC";
        case NODE_PRE_DEC:           return "PRE_DEC";
        case NODE_POST_INC:          return "POST_INC";
        case NODE_PRE_INC:           return "PRE_INC";
        case NODE_VAR_DECLARATION:   return "VAR_DECL";
        case NODE_ARRAY_DECLARATION: return "ARRAY_DECL";
        case NODE_ARRAY_ACCESS:      return "ARRAY_ACCESS";
        case NODE_STRUCT_DECLARATION:return "STRUCT_DECL";
        case NODE_STRUCT_MEMBER:     return "STRUCT_MEMBER";
        case NODE_ENUM_DECLARATION:  return "ENUM_DECL";
        case NODE_ENUM_MEMBER:       return "ENUM_MEMBER";
        case NODE_UNION_DECLARATION: return "UNION_DECL";
        case NODE_FUNCTION:          return "FUNCTION";
        case NODE_FUNCTION_CALL:     return "FUNC_CALL";
        case NODE_PARAMETER:         return "PARAMETER";
        case NODE_NULL:              return "NULL";
        case NODE_START_SCOPE:       return "{";
        case NODE_END_SCOPE:         return "}";
        default:                     return "???";
    }
}

static void NodeValueSuffix(const TreeNode_t* p, char* buf, size_t buflen)
{
    buf[0] = '\0';
    switch (p->nodeType) {
        case NODE_IDENTIFIER:
        case NODE_STRING:
        case NODE_FUNCTION:
        case NODE_FUNCTION_CALL:
        case NODE_ARRAY_ACCESS:
        case NODE_POINTER_CONTENT:
        case NODE_REFERENCE:
        case NODE_POST_INC: case NODE_PRE_INC:
        case NODE_POST_DEC: case NODE_PRE_DEC:
        case NODE_VAR_DECLARATION:
        case NODE_ARRAY_DECLARATION:
        case NODE_PARAMETER:
        case NODE_STRUCT_DECLARATION:
        case NODE_UNION_DECLARATION:
        case NODE_ENUM_DECLARATION:
        case NODE_STRUCT_MEMBER:
        case NODE_ENUM_MEMBER:
            if (p->nodeData.sVal)
                snprintf(buf, buflen, " (%s)", p->nodeData.sVal);
            break;
        case NODE_INTEGER:
            snprintf(buf, buflen, " (%ld)", p->nodeData.dVal);
            break;
        case NODE_CASE:
            /* case can be int (dVal) or enum identifier (sVal) */
            if (p->nodeData.sVal && p->nodeData.dVal == 0 && p->nodeData.sVal != (char*)0);
            else
                snprintf(buf, buflen, " (%ld)", p->nodeData.dVal);
            break;
        case NODE_FLOAT:
            snprintf(buf, buflen, " (%g)", p->nodeData.fVal);
            break;
        case NODE_CHAR:
            snprintf(buf, buflen, " ('%c')", (char)p->nodeData.dVal);
            break;
        case NODE_TYPE:
            switch ((VarType_t)p->nodeData.dVal) {
                case TYPE_CHAR:        snprintf(buf, buflen, " (char)");        break;
                case TYPE_SHORT:       snprintf(buf, buflen, " (short)");       break;
                case TYPE_INT:         snprintf(buf, buflen, " (int)");         break;
                case TYPE_LONG:        snprintf(buf, buflen, " (long)");        break;
                case TYPE_FLOAT:       snprintf(buf, buflen, " (float)");       break;
                case TYPE_DOUBLE:      snprintf(buf, buflen, " (double)");      break;
                case TYPE_LONG_DOUBLE: snprintf(buf, buflen, " (long double)"); break;
                case TYPE_STRING:      snprintf(buf, buflen, " (string)");      break;
                case TYPE_VOID:        snprintf(buf, buflen, " (void)");        break;
                case TYPE_STRUCT:      snprintf(buf, buflen, " (struct)");      break;
                case TYPE_UNION:       snprintf(buf, buflen, " (union)");       break;
                case TYPE_ENUM:        snprintf(buf, buflen, " (enum)");        break;
            }
            break;
        case NODE_OPERATOR:
            switch ((OperatorType_t)p->nodeData.dVal) {
                case OP_PLUS:                  snprintf(buf, buflen, " (+)");      break;
                case OP_MINUS:                 snprintf(buf, buflen, " (-)");      break;
                case OP_MULTIPLY:              snprintf(buf, buflen, " (*)");      break;
                case OP_DIVIDE:                snprintf(buf, buflen, " (/)");      break;
                case OP_MODULE:                snprintf(buf, buflen, " (%%)");     break;
                case OP_ASSIGN:                snprintf(buf, buflen, " (=)");      break;
                case OP_EQUAL:                 snprintf(buf, buflen, " (==)");     break;
                case OP_NOT_EQUAL:             snprintf(buf, buflen, " (!=)");     break;
                case OP_LESS_THAN:             snprintf(buf, buflen, " (<)");      break;
                case OP_GREATER_THAN:          snprintf(buf, buflen, " (>)");      break;
                case OP_LESS_THAN_OR_EQUAL:    snprintf(buf, buflen, " (<=)");     break;
                case OP_GREATER_THAN_OR_EQUAL: snprintf(buf, buflen, " (>=)");     break;
                case OP_LOGICAL_AND:           snprintf(buf, buflen, " (&&)");     break;
                case OP_LOGICAL_OR:            snprintf(buf, buflen, " (||)");     break;
                case OP_LOGICAL_NOT:           snprintf(buf, buflen, " (!)");      break;
                case OP_BITWISE_AND:           snprintf(buf, buflen, " (&)");      break;
                case OP_BITWISE_OR:            snprintf(buf, buflen, " (|)");      break;
                case OP_BITWISE_XOR:           snprintf(buf, buflen, " (^)");      break;
                case OP_BITWISE_NOT:           snprintf(buf, buflen, " (~)");      break;
                case OP_LEFT_SHIFT:            snprintf(buf, buflen, " (<<)");     break;
                case OP_RIGHT_SHIFT:           snprintf(buf, buflen, " (>>)");     break;
                case OP_PLUS_ASSIGN:           snprintf(buf, buflen, " (+=)");     break;
                case OP_MINUS_ASSIGN:          snprintf(buf, buflen, " (-=)");     break;
                case OP_MULTIPLY_ASSIGN:       snprintf(buf, buflen, " (*=)");     break;
                case OP_DIVIDE_ASSIGN:         snprintf(buf, buflen, " (/=)");     break;
                case OP_MODULUS_ASSIGN:        snprintf(buf, buflen, " (%%=)");    break;
                case OP_LEFT_SHIFT_ASSIGN:     snprintf(buf, buflen, " (<<=)");    break;
                case OP_RIGHT_SHIFT_ASSIGN:    snprintf(buf, buflen, " (>>=)");    break;
                case OP_BITWISE_AND_ASSIGN:    snprintf(buf, buflen, " (&=)");     break;
                case OP_BITWISE_OR_ASSIGN:     snprintf(buf, buflen, " (|=)");     break;
                case OP_BITWISE_XOR_ASSIGN:    snprintf(buf, buflen, " (^=)");     break;
                case OP_SIZEOF:                snprintf(buf, buflen, " (sizeof)"); break;
                case OP_NEGATIVE:              snprintf(buf, buflen, " (neg)");    break;
                case OP_UNARY_MINUS:            snprintf(buf, buflen, " (-)");    break;
                case OP_NOT_DEFINED: snprintf(buf, buflen, " (undefined)");    break;
            }
            break;
        case NODE_VISIBILITY:
	    switch ((VisQualifier_t)p->nodeData.dVal) {
		case VIS_STATIC: snprintf(buf, buflen, " (static)"); break;
		case VIS_EXTERN: snprintf(buf, buflen, " (extern)"); break;
		case VIS_INLINE: snprintf(buf, buflen, " (inline)"); break;
		default: break;
	    }
	    break;
	case NODE_MODIFIER:
	    switch ((ModQualifier_t)p->nodeData.dVal) {
		case MOD_CONST:    snprintf(buf, buflen, " (const)");    break;
		case MOD_VOLATILE: snprintf(buf, buflen, " (volatile)"); break;
		default: break;
	    }
	    break;
        case NODE_SIGN:
            switch ((SignQualifier_t)p->nodeData.dVal) {
                case SIGN_SIGNED:   snprintf(buf, buflen, " (signed)");   break;
                case SIGN_UNSIGNED: snprintf(buf, buflen, " (unsigned)"); break;
            }
            break;
        default:
            break;
    }
}

static void ASTPrintRecursive(const TreeNode_t* p_Node,
                               const char* prefix,
                               int is_last)
{
    if (!p_Node) return;

    const char* connector = is_last
        ? "\xE2\x94\x94\xE2\x94\x80\xE2\x94\x80 "   /* └── */
        : "\xE2\x94\x9C\xE2\x94\x80\xE2\x94\x80 ";  /* ├── */

    char suffix[128] = "";
    NodeValueSuffix(p_Node, suffix, sizeof(suffix));
    printf("%s%s%s%s\n", prefix, connector, NodeTypeToStr(p_Node->nodeType), suffix);

    char child_prefix[1024];
    snprintf(child_prefix, sizeof(child_prefix), "%s%s", prefix,
             is_last ? "    " : "\xE2\x94\x82   ");  /* │ */

    const TreeNode_t* child = p_Node->p_firstChild;
    while (child) {
        ASTPrintRecursive(child, child_prefix, child->p_sibling == NULL);
        child = child->p_sibling;
    }
}

void ASTPrint(const TreeNode_t* p_Root)
{
    if (!p_Root) {
        printf("(arvore vazia)\n");
        return;
    }

    const TreeNode_t* node = p_Root;
    while (node) {
        char suffix[128] = "";
        NodeValueSuffix(node, suffix, sizeof(suffix));
        printf("%s%s\n", NodeTypeToStr(node->nodeType), suffix);

        const TreeNode_t* child = node->p_firstChild;
        while (child) {
            ASTPrintRecursive(child, "", child->p_sibling == NULL);
            child = child->p_sibling;
        }

        node = node->p_sibling;
        if (node) printf("\n");
    }
}
