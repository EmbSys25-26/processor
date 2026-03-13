#include "check_stmt.h"
#include "diagnostics.h"



int check_stmt(TreeNode_t *node, semantic_context_t *ctx) {
    if (!node) return 0;

    switch (node->nodeType) {
        
        case NODE_IF:
        case NODE_WHILE: 
        case NODE_DO_WHILE: {
            //TreeNode_t *cond_node = node->p_firstChild; 
            
            /* * CHECK SEM052
             * ask "check_expr" the type of 'cond_node'.
             * if not scalar, error SEM052 with diag_emit.
             */
            
            break;
        }
        case NODE_RETURN: {
            /* SEM046: return inside a function?
             * If current_fn_ret is NULL, it means the return is floating in the global scope.

               later is needed a case for NODE_FUNCTION 
             */
            if (ctx->current_fn_ret == NULL) {
                diag_emit(&ctx->diagnostics, 
                          "SEM046", 
                          DIAG_ERROR, 
                          node->lineNumber, 
                          0, 
                          "return statement outside function scope");
                break; 
            }

            // in 'return x;', 'x' is the first child
            TreeNode_t *ret_expr = node->p_firstChild;

            /* CHECK SEM044: if void function is trying to return a value
             * check if the expected return type is BUILTIN_VOID.
             */
            
             if (ctx->current_fn_ret->kind == TYPE_BUILTIN && 
                ctx->current_fn_ret->as.builtin == BUILTIN_VOID) {
                
                /* If it's a void function, but there is an expression being returned... ERROR! */
                if (ret_expr != NULL) {
                    diag_emit(&ctx->diagnostics, 
                              "SEM044", 
                              DIAG_ERROR, 
                              node->lineNumber, 
                              0, 
                              "return with a value in a function returning void");
                }
            }
            
            /* (Future space for SEM043 and SEM045) */
            
            break;
        }
        case NODE_FUNCTION: {
            // save the previous return type 
            type_t *old_ret = ctx->current_fn_ret;

            /*  TODO: Pass 1 (Symbol Resolution) is not yet fully linked
             * I dont have the real function return type from the symbol table yet
             * for now I used the a placeholder type (int) so that valid returns 
             * (like 'return 0;' in minimal_ok.c) dont trigger SEM044 or SEM046
             * 
             * after Pass 1 is done, replace this placeholder with the actual symbol type
             * ctx->current_fn_ret = sym->type->as.function.return_type;
             */

            type_t *placeholder_ret = type_new_builtin(BUILTIN_INT, 0);
            ctx->current_fn_ret = placeholder_ret;

            // visit the function body 
            if (node->p_firstChild) {
                check_stmt(node->p_firstChild, ctx);
            }

            // restore the previous return type and free the placeholder to prevent memory leaks
            ctx->current_fn_ret = old_ret;
            type_free(placeholder_ret);

            // continue to the next sibling
            return check_stmt(node->p_sibling, ctx);
        }
        
        default:
            break;
    }

    // check statements inside the current block (e.g., the body of the if/while loop) 
    if (node->p_firstChild) {
        check_stmt(node->p_firstChild, ctx);
    }

    // check the next statement in the sequence 
    return check_stmt(node->p_sibling, ctx);
}