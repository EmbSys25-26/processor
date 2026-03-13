#include <errno.h>
#include <locale.h>
#include <string.h>
#include "ASTree.h"
#include "../Util/logger.h"

extern int line_number;

/*
 * NodeCreate
 * ----------
 * Allocates and initializes a new AST node of the given type.
 * Uses a double pointer so the caller's pointer is updated directly.
 *
 * Returns 0 on success, negative errno on failure.
 */
int NodeCreate(TreeNode_t** pp_NewNode, NodeType_t nodeType){
	TreeNode_t*  pNode;
	
	if (!pp_NewNode)
        	return -EINVAL;

	*pp_NewNode = (TreeNode_t*) calloc(1, sizeof(TreeNode_t)); // allocates memory for only one node, zero-initialized
	if (!(*pp_NewNode)){
		LOG_ERROR("Failed to allocate memory!\n");
		return -ENOMEM;
	}

	pNode = *pp_NewNode;
	pNode->nodeType = nodeType;
	pNode->lineNumber = (line_number > 0) ? (size_t)line_number : 0u;
	//pNode->pSymbol = NULL;
	return 0;
}

/*
 * NodeFree
 * ----------
 * Deallocates a node in the AST, recursively deallocating its children and siblings as well. 
 * Returns 0 on success, negative errno on failure.
 */
int NodeFree(TreeNode_t* src){
	
	if (!src) { 
		return 0; 
	}

	switch (src->nodeType) {
		case NODE_STRING:
		case NODE_IDENTIFIER:
		case NODE_FUNCTION:
		case NODE_FUNCTION_CALL:
		case NODE_VAR_DECLARATION:
		case NODE_ARRAY_DECLARATION:
		case NODE_PARAMETER:
		case NODE_PP_DEFINE:
		case NODE_PP_UNDEF:
		case NODE_STRUCT_DECLARATION:
		case NODE_UNION_DECLARATION:
		case NODE_ENUM_DECLARATION:
		case NODE_ENUM_MEMBER:
		case NODE_STRUCT_MEMBER:
				if (src->nodeData.sVal) {
						free(src->nodeData.sVal); 
				}
				break;
		default: 
			break;
	}

	NodeFree(src->p_firstChild); 
	NodeFree(src->p_sibling); 
	free(src); 
	return 0; 
}

/*
 * NodeAddChild
 * ------------
 * Attaches an existing node as the last child of a parent node.
 * Children are stored as a singly linked list via p_sibling pointers:
 *
 *   Parent
 *     |
 *     p_firstChild
 *     |
 *     v
 *   [child1] --> [child2] --> [child3] --> NULL
 *
 * Insertion order is preserved — the new child is always appended at the end.
 *
 * Returns 0 on success, negative errno on failure.
 */
int NodeAddChild(TreeNode_t* p_Parent, TreeNode_t* p_Child) {
	if (!p_Parent || !p_Child) 
		return -EINVAL;

	if (!p_Parent->p_firstChild) {
		// no children yet, the new node becomes the first child
		p_Parent->p_firstChild = p_Child;
	} else {
		// walk the sibling chain to find the last child
		TreeNode_t* pSibling = p_Parent->p_firstChild;
		while (pSibling->p_sibling)
		    pSibling = pSibling->p_sibling;

		pSibling->p_sibling = p_Child; // append at the end
	}

	p_Parent->childNumber++;
	return 0;
}

/*
 * NodeAddNewChild
 * ---------------
 * Allocates a new node of the given type and immediately attaches it
 * as the last child of the parent. The caller receives a pointer to
 * the new node via pp_NewChild so it can set nodeData or other fields.
 *
 * On allocation failure the parent is left unchanged.
 * On insertion failure the newly allocated node is freed to avoid a memory leak.
 *
 * Returns 0 on success, negative errno on failure.
 */
int NodeAddNewChild(TreeNode_t* p_Parent, TreeNode_t** pp_NewChild, NodeType_t nodeType){
	if (!p_Parent || !pp_NewChild)
		return -EINVAL;

	*pp_NewChild = calloc(1, sizeof(TreeNode_t));
	if (!(*pp_NewChild)) {
		LOG_ERROR("Failed to allocate memory while trying to add a new child!\n");
		return -ENOMEM;
	}

	(*pp_NewChild)->nodeType = nodeType;

	int ret = NodeAddChild(p_Parent, *pp_NewChild);
	if (ret < 0) {
		free(*pp_NewChild);
		*pp_NewChild = NULL;
	}

	return ret;
}

/*
 * NodeAppendSibling
 * -----------------
 * Appends a node to the end of a sibling list.
 *
 * Does the same as NodeAddChild but for sibling instead. Does not assume there is a parent.
 *
 * If *pp_Head is NULL, p_NewSibling becomes the list head.
 * Otherwise, the function traverses p_sibling pointers to the end
 * and links p_NewSibling there.
 *
 * Returns 0 on success, negative errno on failure.
 */
int NodeAppendSibling(TreeNode_t** pp_Head, TreeNode_t* p_NewSibling){
	TreeNode_t* pNode;

	if (!pp_Head || !p_NewSibling) 	// invalid arguments
		return -EINVAL;

	if (!(*pp_Head)) {	// if there no parent node, the new sibling becomes the head of the list
		*pp_Head = p_NewSibling;	// equivalent to  $$.treeNode = $2.treeNode; 
		return 0;
	}

	pNode = *pp_Head;
	while (pNode->p_sibling)
		pNode = pNode->p_sibling;

	pNode->p_sibling = p_NewSibling;
	return 0;
}


int NodeCloneSubtree(const TreeNode_t *src, TreeNode_t **out_clone)
{
    TreeNode_t *copy = NULL;
    const TreeNode_t *child = NULL;

    if (!src || !out_clone) {
        return -EINVAL;
    }

    *out_clone = NULL;

    copy = calloc(1, sizeof(*copy));
    if (!copy) {
        return -ENOMEM;
    }

    copy->lineNumber = src->lineNumber;
    copy->nodeType = src->nodeType;
    copy->nodeVarType = src->nodeVarType;
    copy->childNumber = 0;
    copy->p_firstChild = NULL;
    copy->p_sibling = NULL;

    switch (src->nodeType) {
			case NODE_STRING:
			case NODE_IDENTIFIER:
			case NODE_FUNCTION:
			case NODE_FUNCTION_CALL:
			case NODE_VAR_DECLARATION:
			case NODE_ARRAY_DECLARATION:
			case NODE_PARAMETER:
			case NODE_PP_DEFINE:
			case NODE_PP_UNDEF:
			case NODE_STRUCT_DECLARATION:
			case NODE_UNION_DECLARATION:
			case NODE_ENUM_DECLARATION:
			case NODE_ENUM_MEMBER:
			case NODE_STRUCT_MEMBER:
					if (src->nodeData.sVal) {
							copy->nodeData.sVal = strdup(src->nodeData.sVal);
							if (!copy->nodeData.sVal) {
									free(copy);
									return -ENOMEM;
							}
					}
					break;
			default:
					copy->nodeData = src->nodeData;
					break;
    }

    child = src->p_firstChild;
    while (child) {
        TreeNode_t *child_copy = NULL;
        int rc = NodeCloneSubtree(child, &child_copy);
        if (rc < 0) {
            NodeFree(copy);
            return rc;
        }
        NodeAddChild(copy, child_copy);
        child = child->p_sibling;
    }

    *out_clone = copy;
    return 0;
}

int NodeAddChildCloneChain(TreeNode_t *parent, const TreeNode_t *head)
{
    const TreeNode_t *it = head;

    if (!parent || !head) {
        return -EINVAL;
    }

    while (it) {
        TreeNode_t *copy = NULL;
        int rc = NodeCloneSubtree(it, &copy);
        if (rc < 0) {
            return rc;
        }

        rc = NodeAddChild(parent, copy);
        if (rc < 0) {
            NodeFree(copy);
            return rc;
        }

        it = it->p_sibling;
    }

    return 0;
}

int NodeAttachDeclSpecifiers(TreeNode_t *decl, const TreeNode_t *specs)
{
    TreeNode_t *it;
    TreeNode_t *pointer_node = NULL;
    TreeNode_t *clone_head = NULL;
    TreeNode_t *clone_tail = NULL;
    const TreeNode_t *spec_it;
    size_t clone_count = 0u;

    if (!decl || !specs) {
        return -EINVAL;
    }

    if (decl->nodeType == NODE_FUNCTION) {
        if (decl->p_firstChild && decl->p_firstChild->nodeType == NODE_POINTER) {
            pointer_node = decl->p_firstChild;
            while (pointer_node->p_firstChild && pointer_node->p_firstChild->nodeType == NODE_POINTER) {
                pointer_node = pointer_node->p_firstChild;
            }
            return NodeAddChildCloneChain(pointer_node, specs);
        }

        spec_it = specs;
        while (spec_it) {
            TreeNode_t *clone = NULL;
            int rc = NodeCloneSubtree(spec_it, &clone);
            if (rc < 0) {
                NodeFree(clone_head);
                return rc;
            }

            if (!clone_head) {
                clone_head = clone;
                clone_tail = clone;
            } else {
                clone_tail->p_sibling = clone;
                clone_tail = clone;
            }

            clone_count++;
            spec_it = spec_it->p_sibling;
        }

        clone_tail->p_sibling = decl->p_firstChild;
        decl->p_firstChild = clone_head;
        decl->childNumber += clone_count;
        return 0;
    }

    it = decl->p_firstChild;
    while (it) {
        if (it->nodeType == NODE_POINTER) {
            pointer_node = it;
            break;
        }
        it = it->p_sibling;
    }

    if (!pointer_node) {
        return NodeAddChildCloneChain(decl, specs);
    }

    while (pointer_node->p_firstChild && pointer_node->p_firstChild->nodeType == NODE_POINTER) {
        pointer_node = pointer_node->p_firstChild;
    }

    return NodeAddChildCloneChain(pointer_node, specs);
}
