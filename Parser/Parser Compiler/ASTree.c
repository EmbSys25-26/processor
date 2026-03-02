#include <errno.h>
#include <locale.h>
#include "ASTree.h"
#include "logger.h"

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
	//pNode->lineNumber = getLineNumber();
	//pNode->pSymbol = NULL;
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

	if (!p_Parent->p_firstChild) { // returns true if there are no children yet
		// no children yet, the new node becomes the first child
		p_Parent->p_firstChild = p_Child;
	} else {
		// walk the sibling chain to find the last child
		TreeNode_t* pSibling = p_Parent->p_firstChild;	//
		while (pSibling->p_sibling)	// while there's a next sibling
		    pSibling = pSibling->p_sibling;	// move the pointer to the next sibling, linked list traversal

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
	//(*pp_NewChild)->lineNumber = getLineNumber();

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



//ADICIONEI (PEDRO)----------------------------------------------
int NodeAddChildCopy(TreeNode_t* p_Parent, const TreeNode_t* p_Source) {
    TreeNode_t* pCopy;

    if (!p_Parent || !p_Source)
        return -EINVAL;

    pCopy = (TreeNode_t*) malloc(sizeof(TreeNode_t));
    if (!pCopy) {
        LOG_ERROR("Failed to allocate memory in NodeAddChildCopy!\n");
        return -ENOMEM;
    }

    /* Copy all fields, then reset the link fields so the clone is a leaf */
    *pCopy = *p_Source;
    pCopy->p_firstChild = NULL;
    pCopy->p_sibling    = NULL;
    pCopy->childNumber  = 0;

    int ret = NodeAddChild(p_Parent, pCopy);
    if (ret < 0) {
        free(pCopy);
    }
    return ret;
}