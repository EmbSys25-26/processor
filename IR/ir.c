/*
 * ir.c — IR module: lifetime management, builders, and text serialiser.
 *
 * Contract: §6, §7, §12 of IR_GENERATION_CONTRACT.md
 */

#include <assert.h>
#include <errno.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ir.h"

/************************************************************
 * Type helpers
 *************************************************************/

/* Primitive ir_type_t constructors. */
ir_type_t ir_type_void(void)  { ir_type_t t; memset(&t,0,sizeof(t)); t.kind=IR_TYPE_VOID;  return t; }
ir_type_t ir_type_i1(void)   { ir_type_t t; memset(&t,0,sizeof(t)); t.kind=IR_TYPE_I1;    return t; }
ir_type_t ir_type_i8(void)   { ir_type_t t; memset(&t,0,sizeof(t)); t.kind=IR_TYPE_I8;    return t; }
ir_type_t ir_type_i16(void)  { ir_type_t t; memset(&t,0,sizeof(t)); t.kind=IR_TYPE_I16;   return t; }
ir_type_t ir_type_i32(void)  { ir_type_t t; memset(&t,0,sizeof(t)); t.kind=IR_TYPE_I32;   return t; }
ir_type_t ir_type_ptr(void)  { ir_type_t t; memset(&t,0,sizeof(t)); t.kind=IR_TYPE_PTR;   return t; }

/* Builds an ir_type_t array descriptor for `elem[count]`. */
ir_type_t ir_type_array(ir_type_t elem, size_t count)
{
    ir_type_t t;
    memset(&t, 0, sizeof(t));
    t.kind = IR_TYPE_ARRAY;
    /* store element type on heap so derived info is stable */
    t.as.array.elem  = (const ir_type_t *)malloc(sizeof(ir_type_t));
    if (t.as.array.elem) {
        memcpy((void *)t.as.array.elem, &elem, sizeof(elem));
    }
    t.as.array.count = count;
    return t;
}

/* Builds a struct ir_type_t carrying the given tag. */
ir_type_t ir_type_struct(const char *tag)
{
    ir_type_t t;
    memset(&t, 0, sizeof(t));
    t.kind = IR_TYPE_STRUCT;
    if (tag) snprintf(t.as.aggr.tag, sizeof(t.as.aggr.tag), "%s", tag);
    return t;
}

/* Builds a union ir_type_t carrying the given tag. */
ir_type_t ir_type_union(const char *tag)
{
    ir_type_t t;
    memset(&t, 0, sizeof(t));
    t.kind = IR_TYPE_UNION;
    if (tag) snprintf(t.as.aggr.tag, sizeof(t.as.aggr.tag), "%s", tag);
    return t;
}

/* Returns 1 if `t` is one of the integer kinds (i1/i8/i16/i32). */
int ir_type_is_integer(ir_type_t t)
{
    return t.kind == IR_TYPE_I1 || t.kind == IR_TYPE_I8 ||
           t.kind == IR_TYPE_I16 || t.kind == IR_TYPE_I32;
}

/* Returns 1 if `a` and `b` have the same kind (and tag for aggregates). */
int ir_type_equal(ir_type_t a, ir_type_t b)
{
    if (a.kind != b.kind) return 0;
    if (a.kind == IR_TYPE_STRUCT || a.kind == IR_TYPE_UNION) {
        return strncmp(a.as.aggr.tag, b.as.aggr.tag, sizeof(a.as.aggr.tag)) == 0;
    }
    return 1;
}

/* Storage size of a type, in 16-bit words (the addressing unit of this
 * ISA: ADDI offsets, slot ids, and LW/SW addresses are all word-indexed).
 *
 *   i1 / i8 / i16 / ptr → 1 word
 *   i32                 → 2 words
 *   array<T, N>         → N * sizeof(T) words (recursive)
 *   struct / union      → not implemented yet; conservative 1 word.
 *   void                → 0 (caller should not invoke for void types). */
size_t ir_type_size_words(ir_type_t t)
{
    switch (t.kind) {
    case IR_TYPE_VOID:   return 0;
    case IR_TYPE_I1:     return 1;
    case IR_TYPE_I8:     return 1;
    case IR_TYPE_I16:    return 1;
    case IR_TYPE_I32:    return 2;
    case IR_TYPE_PTR:    return 1;
    case IR_TYPE_ARRAY:
        if (t.as.array.elem)
            return t.as.array.count * ir_type_size_words(*t.as.array.elem);
        return t.as.array.count; /* unknown elem: assume word-sized */
    case IR_TYPE_STRUCT:
    case IR_TYPE_UNION:
        return 1; /* aggregates not yet supported in storage layout */
    }
    return 1;
}

/************************************************************
 * Value constructors
 *************************************************************/

/* ir_value_t constructors for each value kind. */
ir_value_t ir_val_vreg(unsigned id, ir_type_t type)
{
    ir_value_t v; memset(&v,0,sizeof(v));
    v.kind = IR_VAL_VREG; v.type = type; v.as.vreg = id;
    return v;
}

ir_value_t ir_val_slot(unsigned id, ir_type_t type)
{
    ir_value_t v; memset(&v,0,sizeof(v));
    v.kind = IR_VAL_SLOT; v.type = type; v.as.slot = id;
    return v;
}

ir_value_t ir_val_global(const char *name, ir_type_t type)
{
    ir_value_t v; memset(&v,0,sizeof(v));
    v.kind = IR_VAL_GLOBAL; v.type = type;
    if (name) snprintf(v.as.name, sizeof(v.as.name), "%s", name);
    return v;
}

ir_value_t ir_val_imm(long imm, ir_type_t type)
{
    ir_value_t v; memset(&v,0,sizeof(v));
    v.kind = IR_VAL_IMM_INT; v.type = type; v.as.imm = imm;
    return v;
}

ir_value_t ir_val_label(unsigned block_id)
{
    ir_value_t v; memset(&v,0,sizeof(v));
    v.kind = IR_VAL_LABEL; v.as.block_id = block_id;
    return v;
}

ir_value_t ir_val_none(void)
{
    ir_value_t v; memset(&v,0,sizeof(v));
    v.kind = IR_VAL_NONE;
    return v;
}

/************************************************************
 * Module lifetime
 *************************************************************/

/* Allocates a zero-initialised module tagged with the given arch name. */
ir_module_t *ir_module_new(const char *arch)
{
    ir_module_t *mod = (ir_module_t *)calloc(1, sizeof(*mod));
    if (!mod) return NULL;
    if (arch) snprintf(mod->arch, sizeof(mod->arch), "%s", arch);
    return mod;
}

/* Releases an instruction chain starting at `head`. */
static void ir_instr_free_chain(ir_instr_t *head)
{
    while (head) {
        ir_instr_t *next = head->next;
        free(head);
        head = next;
    }
}

/* Releases a block chain along with each block's instructions. */
static void ir_block_free_chain(ir_block_t *head)
{
    while (head) {
        ir_block_t *next = head->next;
        ir_instr_free_chain(head->head);
        free(head);
        head = next;
    }
}

/* Releases a slot-entry chain. */
static void ir_slot_free_chain(ir_slot_entry_t *head)
{
    while (head) {
        ir_slot_entry_t *next = head->next;
        free(head);
        head = next;
    }
}

/* Frees a function and all of its blocks, instructions, and slots. */
void ir_function_free(ir_function_t *func)
{
    if (!func) return;
    ir_block_free_chain(func->entry);
    ir_slot_free_chain(func->slots);
    free(func);
}

/* Frees a module along with every function and global it owns. */
void ir_module_free(ir_module_t *mod)
{
    if (!mod) return;

    ir_function_list_t *fl = mod->functions;
    while (fl) {
        ir_function_list_t *next = fl->next;
        ir_function_free(fl->func);
        free(fl);
        fl = next;
    }

    ir_global_t *gl = mod->globals;
    while (gl) {
        ir_global_t *next = gl->next;
        free(gl);
        gl = next;
    }

    free(mod);
}

/************************************************************
 * Module / function builders
 *************************************************************/

/* Allocates a fresh function with the given name and return type. */
ir_function_t *ir_function_new(const char *name, ir_type_t ret_type)
{
    ir_function_t *func = (ir_function_t *)calloc(1, sizeof(*func));
    if (!func) return NULL;
    if (name) snprintf(func->name, sizeof(func->name), "%s", name);
    func->ret_type = ret_type;
    func->next_vreg     = 0u;
    func->next_block_id = 0u;
    func->next_slot_id  = 0u;
    return func;
}

/* Appends `func` to the module's function list, preserving insertion order. */
void ir_module_add_function(ir_module_t *mod, ir_function_t *func)
{
    if (!mod || !func) return;
    ir_function_list_t *entry = (ir_function_list_t *)calloc(1, sizeof(*entry));
    if (!entry) return;
    entry->func = func;
    /* append for stable ordering */
    if (!mod->functions) {
        mod->functions = entry;
    } else {
        ir_function_list_t *cur = mod->functions;
        while (cur->next) cur = cur->next;
        cur->next = entry;
    }
}

/* Appends a new global symbol to the module and returns it. */
ir_global_t *ir_module_add_global(ir_module_t *mod, const char *name,
                                   ir_type_t type, int is_extern)
{
    if (!mod || !name) return NULL;
    ir_global_t *g = (ir_global_t *)calloc(1, sizeof(*g));
    if (!g) return NULL;
    snprintf(g->name, sizeof(g->name), "%s", name);
    g->type       = type;
    g->is_extern  = is_extern;
    g->init_kind  = IR_GINIT_NONE;   /* caller may overwrite */
    g->size_words = ir_type_size_words(type);   /* default; lowering may
                                                 * overwrite for structs */
    if (g->size_words == 0) g->size_words = 1;
    /* append */
    if (!mod->globals) {
        mod->globals = g;
    } else {
        ir_global_t *cur = mod->globals;
        while (cur->next) cur = cur->next;
        cur->next = g;
    }
    return g;
}

/************************************************************
 * Block / instruction builders
 *************************************************************/

/* Allocates a fresh basic block with the next id from `func`. */
ir_block_t *ir_block_new(ir_function_t *func)
{
    ir_block_t *b = (ir_block_t *)calloc(1, sizeof(*b));
    if (!b) return NULL;
    b->id = func->next_block_id++;
    return b;
}

/* Appends `block` to the function's block list. */
void ir_block_append(ir_function_t *func, ir_block_t *block)
{
    if (!func || !block) return;
    if (!func->entry) {
        func->entry = block;
        func->block_tail = block;
    } else {
        func->block_tail->next = block;
        func->block_tail = block;
    }
}

/* Allocates a zero-initialised instruction of opcode `op`. */
ir_instr_t *ir_instr_new(ir_opcode_t op)
{
    ir_instr_t *i = (ir_instr_t *)calloc(1, sizeof(*i));
    if (!i) return NULL;
    i->op  = op;
    i->dst = ir_val_none();
    i->src[0] = ir_val_none();
    i->src[1] = ir_val_none();
    return i;
}

/* Appends `instr` to the end of `block`'s instruction list. */
void ir_instr_push(ir_block_t *block, ir_instr_t *instr)
{
    if (!block || !instr) return;
    if (!block->head) {
        block->head = instr;
        block->tail = instr;
    } else {
        block->tail->next = instr;
        block->tail = instr;
    }
}

/* Returns a fresh virtual register id for `func`. */
unsigned ir_new_vreg(ir_function_t *func)
{
    return func->next_vreg++;
}

/* Allocates a named stack slot, reserving enough word ids to cover the type. */
unsigned ir_new_slot(ir_function_t *func, const char *name, ir_type_t type)
{
    ir_slot_entry_t *e = (ir_slot_entry_t *)calloc(1, sizeof(*e));
    if (!e) return (unsigned)-1;
    if (name) snprintf(e->name, sizeof(e->name), "%s", name);
    e->type    = type;
    e->slot_id = func->next_slot_id;
    /* Reserve enough consecutive slot ids to hold the whole object.
     * For arrays this means N words for `T[N]`, so the next slot starts
     * at e->slot_id + N.  Scalars take one slot. */
    size_t sz = ir_type_size_words(type);
    if (sz == 0) sz = 1;
    func->next_slot_id += (unsigned)sz;
    /* prepend (lookup is by name, order doesn't matter) */
    e->next    = func->slots;
    func->slots = e;
    return e->slot_id;
}

/* Looks up a slot by name and returns its id, or (unsigned)-1 if absent. */
unsigned ir_find_slot(const ir_function_t *func, const char *name)
{
    if (!func || !name) return (unsigned)-1;
    for (const ir_slot_entry_t *e = func->slots; e; e = e->next) {
        if (strncmp(e->name, name, sizeof(e->name)) == 0) {
            return e->slot_id;
        }
    }
    return (unsigned)-1;
}

/************************************************************
 * §12  Text serialiser - Based on IR Contract notation
 *************************************************************/

/* Writes a type's textual form (per IR contract §12) to `out`. */
void ir_type_print(FILE *out, const ir_type_t *t)
{
    if (!t) { fprintf(out, "?"); return; }
    switch (t->kind) {
    case IR_TYPE_VOID:   fprintf(out, "void");  break;
    case IR_TYPE_I1:     fprintf(out, "i1");    break;
    case IR_TYPE_I8:     fprintf(out, "i8");    break;
    case IR_TYPE_I16:    fprintf(out, "i16");   break;
    case IR_TYPE_I32:    fprintf(out, "i32");   break;
    case IR_TYPE_PTR:    fprintf(out, "ptr");   break;
    case IR_TYPE_ARRAY:
        fprintf(out, "arr<");
        if (t->as.array.elem) ir_type_print(out, t->as.array.elem);
        fprintf(out, ", %zu>", t->as.array.count);
        break;
    case IR_TYPE_STRUCT: fprintf(out, "struct<%s>", t->as.aggr.tag); break;
    case IR_TYPE_UNION:  fprintf(out, "union<%s>",  t->as.aggr.tag); break;
    default:             fprintf(out, "?type");  break;
    }
}

/* Writes a value's textual form (vreg/slot/global/imm/label) to `out`. */
void ir_value_print(FILE *out, const ir_value_t *v)
{
    if (!v || v->kind == IR_VAL_NONE) { fprintf(out, "-"); return; }
    switch (v->kind) {
    case IR_VAL_VREG:    fprintf(out, "%%v%u", v->as.vreg);     break;
    case IR_VAL_SLOT:    fprintf(out, "%%slot%u", v->as.slot);  break;
    case IR_VAL_GLOBAL:  fprintf(out, "@%s", v->as.name);       break;
    case IR_VAL_IMM_INT: fprintf(out, "%ld", v->as.imm);        break;
    case IR_VAL_LABEL:   fprintf(out, "bb%u", v->as.block_id);  break;
    default:             fprintf(out, "?val");                   break;
    }
}

/* Maps an opcode enum to its printable mnemonic. */
static const char *opname(ir_opcode_t op)
{
    switch (op) {
    case IR_OP_CONST:   return "const";
    case IR_OP_COPY:    return "copy";
    case IR_OP_ADD:     return "add";
    case IR_OP_SUB:     return "sub";
    case IR_OP_MUL:     return "mul";
    case IR_OP_DIVS:    return "divs";
    case IR_OP_DIVU:    return "divu";
    case IR_OP_MODS:    return "mods";
    case IR_OP_MODU:    return "modu";
    case IR_OP_AND:     return "and";
    case IR_OP_OR:      return "or";
    case IR_OP_XOR:     return "xor";
    case IR_OP_SHL:     return "shl";
    case IR_OP_SHRU:    return "shru";
    case IR_OP_SHRS:    return "shrs";
    case IR_OP_NEG:     return "neg";
    case IR_OP_NOT:     return "not";
    case IR_OP_EQ:      return "eq";
    case IR_OP_NEQ:     return "neq";
    case IR_OP_LTS:     return "lts";
    case IR_OP_LES:     return "les";
    case IR_OP_GTS:     return "gts";
    case IR_OP_GES:     return "ges";
    case IR_OP_LTU:     return "ltu";
    case IR_OP_LEU:     return "leu";
    case IR_OP_GTU:     return "gtu";
    case IR_OP_GEU:     return "geu";
    case IR_OP_ADDR_OF: return "addr_of";
    case IR_OP_LOAD:    return "load";
    case IR_OP_STORE:   return "store";
    case IR_OP_GEP:     return "gep";
    case IR_OP_ZEXT:    return "zext";
    case IR_OP_SEXT:    return "sext";
    case IR_OP_TRUNC:   return "trunc";
    case IR_OP_BITCAST: return "bitcast";
    case IR_OP_GOTO:    return "goto";
    case IR_OP_BRANCH:  return "branch";
    case IR_OP_SWITCH:  return "switch";
    case IR_OP_RET:     return "ret";
    case IR_OP_CALL:    return "call";
    default:            return "?op";
    }
}

/* Prints a single instruction, dispatching on opcode for special-case formats. */
void ir_instr_print(FILE *out, const ir_instr_t *i)
{
    if (!i) return;

    switch (i->op) {
    /* terminators */
    case IR_OP_GOTO:
        fprintf(out, "    goto bb%u\n", IR_BRANCH_TRUE(i));
        break;
    case IR_OP_BRANCH:
        fprintf(out, "    if ");
        ir_value_print(out, &i->src[0]);
        fprintf(out, " goto bb%u else bb%u\n", IR_BRANCH_TRUE(i), IR_BRANCH_FALSE(i));
        break;
    case IR_OP_SWITCH:
        fprintf(out, "    switch ");
        ir_value_print(out, &i->src[0]);
        fprintf(out, " default bb%u", IR_SWITCH_DEFAULT(i));
        for (unsigned k = 0; k < IR_SWITCH_CASE_COUNT(i); ++k) {
            fprintf(out, " [");
            /* direct union access needed for array indexing; opcode asserted via IR_SWITCH_CASE_COUNT above */
            fprintf(out, "%ld:bb%u", i->as.sw.case_values[k], i->as.sw.case_blocks[k]);
            fprintf(out, "]");
        }
        fprintf(out, "\n");
        break;
    case IR_OP_RET:
        if (i->src[0].kind == IR_VAL_NONE) {
            fprintf(out, "    ret void\n");
        } else {
            fprintf(out, "    ret ");
            ir_value_print(out, &i->src[0]);
            fprintf(out, "\n");
        }
        break;

    /* store: *ptr = src */
    case IR_OP_STORE:
        fprintf(out, "    *");
        ir_value_print(out, &i->src[0]);
        fprintf(out, " = ");
        ir_value_print(out, &i->src[1]);
        fprintf(out, "\n");
        break;

    /* call (void or value) */
    case IR_OP_CALL:
        fprintf(out, "    ");
        if (!IR_CALL_IS_VOID(i)) {
            ir_value_print(out, &i->dst);
            fprintf(out, " = ");
        }
        fprintf(out, "@%s(", IR_CALL_CALLEE(i));
        for (unsigned k = 0; k < IR_CALL_ARG_COUNT(i); k++) {
            if (k) fprintf(out, ", ");
            /* direct union access needed for address-of array element; opcode asserted via IR_CALL_ARG_COUNT above */
            ir_value_print(out, &i->as.call.args[k]);
        }
        fprintf(out, ")\n");
        break;

    /* GEP */
    case IR_OP_GEP:
        fprintf(out, "    ");
        ir_value_print(out, &i->dst);
        fprintf(out, " = gep ");
        ir_value_print(out, &i->src[0]);
        fprintf(out, " + ");
        ir_value_print(out, &i->src[1]);
        fprintf(out, " * %ld\n", IR_GEP_WIDTH(i));
        break;

    /* cast ops */
    case IR_OP_ZEXT:
    case IR_OP_SEXT:
    case IR_OP_TRUNC:
    case IR_OP_BITCAST:
        fprintf(out, "    ");
        ir_value_print(out, &i->dst);
        fprintf(out, " = (%s ", opname(i->op));
        ir_type_print(out, &i->dst.type);
        fprintf(out, ") ");
        ir_value_print(out, &i->src[0]);
        fprintf(out, "\n");
        break;

    /* addr_of */
    case IR_OP_ADDR_OF:
        fprintf(out, "    ");
        ir_value_print(out, &i->dst);
        fprintf(out, " = addr_of ");
        ir_value_print(out, &i->src[0]);
        fprintf(out, "\n");
        break;

    /* load */
    case IR_OP_LOAD:
        fprintf(out, "    ");
        ir_value_print(out, &i->dst);
        fprintf(out, " = *");
        ir_value_print(out, &i->src[0]);
        fprintf(out, "\n");
        break;

    /* unary ops */
    case IR_OP_NEG:
    case IR_OP_NOT:
    case IR_OP_CONST:
    case IR_OP_COPY:
        fprintf(out, "    ");
        ir_value_print(out, &i->dst);
        fprintf(out, " = ");
        if (i->op == IR_OP_NEG) fprintf(out, "-");
        if (i->op == IR_OP_NOT) fprintf(out, "~");
        ir_value_print(out, &i->src[0]);
        fprintf(out, "\n");
        break;

    /* binary ops */
    default: {
        fprintf(out, "    ");
        ir_value_print(out, &i->dst);
        fprintf(out, " = ");
        ir_value_print(out, &i->src[0]);
        fprintf(out, " %s ", opname(i->op));
        ir_value_print(out, &i->src[1]);
        fprintf(out, "\n");
        break;
    }
    }
}

/* Prints a block header (`bbN:`) followed by all of its instructions. */
void ir_block_print(FILE *out, const ir_block_t *b)
{
    if (!b) return;
    fprintf(out, "bb%u:\n", b->id);
    for (const ir_instr_t *i = b->head; i; i = i->next) {
        ir_instr_print(out, i);
    }
}

/* Prints a function's signature, slot table, and every block. */
void ir_function_print(FILE *out, const ir_function_t *func)
{
    if (!func) return;
    fprintf(out, "func @%s(", func->name);
    for (unsigned k = 0; k < func->param_count; k++) {
        if (k) fprintf(out, ", ");
        ir_type_print(out, &func->param_types[k]);
        fprintf(out, " %%%s", func->param_names[k]);
    }
    fprintf(out, ") -> ");
    ir_type_print(out, &func->ret_type);
    fprintf(out, " {\n");

    /* slot declarations */
    for (const ir_slot_entry_t *e = func->slots; e; e = e->next) {
        fprintf(out, "  slot %%slot%u : ", e->slot_id);
        ir_type_print(out, &e->type);
        fprintf(out, "  ; %s\n", e->name);
    }
    if (func->slots) fprintf(out, "\n");

    for (const ir_block_t *b = func->entry; b; b = b->next) {
        ir_block_print(out, b);
        if (b->next) fprintf(out, "\n");
    }
    fprintf(out, "}\n");
}

/* Prints a whole module: header line, globals, then each function. */
void ir_module_print(FILE *out, const ir_module_t *mod)
{
    if (!mod) return;
    fprintf(out, "module %s\n\n", mod->arch[0] ? mod->arch : "unnamed");

    for (const ir_global_t *g = mod->globals; g; g = g->next) {
        fprintf(out, "%sglobal @%s : ",
                g->is_extern ? "extern " : "", g->name);
        ir_type_print(out, &g->type);
        fprintf(out, "\n");
    }
    if (mod->globals) fprintf(out, "\n");

    for (const ir_function_list_t *fl = mod->functions; fl; fl = fl->next) {
        ir_function_print(out, fl->func);
        fprintf(out, "\n");
    }
}