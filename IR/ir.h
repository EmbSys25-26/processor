#ifndef IR_IR_H
#define IR_IR_H

/*
 * ir.h — Low-GIMPLE-style typed three-address CFG IR
 *
 * Contract: §4–§7 of docs/semantic-analysis/IR_GENERATION_CONTRACT.md
 *
 * Organisation
 * ────────────
 *   ir_module_t          top-level container (§6.1)
 *   ir_function_t        one function (§6.2)
 *   ir_block_t           one basic block (§6.3)
 *   ir_instr_t           one instruction or terminator (§7)
 *   ir_value_t           reference to a virtual register, slot, global, or immediate
 *   ir_type_t            IR primitive / derived type (§5)
 */

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

/* ────────────────────────────────────────────────────────────
 * §5  IR type system
 * ──────────────────────────────────────────────────────────── */

typedef enum {
    IR_TYPE_VOID = 0,
    IR_TYPE_I1,          /* predicate / boolean                  */
    IR_TYPE_I8,          /* byte                                  */
    IR_TYPE_I16,         /* native scalar (target is 16-bit word) */
    IR_TYPE_I32,         /* widened constant or intermediate      */
    IR_TYPE_PTR,         /* 16-bit address-space pointer          */
    IR_TYPE_ARRAY,       /* arr<T, N>                             */
    IR_TYPE_STRUCT,      /* struct<tag>                           */
    IR_TYPE_UNION        /* union<tag>                            */
} ir_type_kind_t;

typedef struct ir_type_s ir_type_t;

struct ir_type_s {
    ir_type_kind_t kind;
    union {
        struct { const ir_type_t *elem; size_t count; } array;  /* IR_TYPE_ARRAY  */
        struct { char tag[64]; }                        aggr;   /* STRUCT / UNION */
        struct { const ir_type_t *pointee; }            ptr;    /* IR_TYPE_PTR    */
    } as;
};

/* ───────────────────────────────────────────────────────────
 * §4.2  Naming / value references
 * ──────────────────────────────────────────────────────────── */

typedef enum {
    IR_VAL_VREG,        /* %vN           — virtual register          */
    IR_VAL_SLOT,        /* %slotN        — stack slot (address ref)  */
    IR_VAL_GLOBAL,      /* @name         — global symbol             */
    IR_VAL_IMM_INT,     /* inline integer constant                   */
    IR_VAL_LABEL,       /* bbN           — block label reference      */
    IR_VAL_NONE         /* unused / void operand                     */
} ir_value_kind_t;

typedef struct {
    ir_value_kind_t kind;
    ir_type_t       type;
    union {
        unsigned    vreg;       /* IR_VAL_VREG  */
        unsigned    slot;       /* IR_VAL_SLOT  */
        char        name[128];  /* IR_VAL_GLOBAL */
        long        imm;        /* IR_VAL_IMM_INT */
        unsigned    block_id;   /* IR_VAL_LABEL  */
    } as;
} ir_value_t;

/* ────────────────────────────────────────────────────────────
 * §7  Instruction opcodes
 * ──────────────────────────────────────────────────────────── */

typedef enum {
    IR_OP_INVALID = 0,
    /* §7.1 Constants / moves */
    IR_OP_CONST,        /* %dst = <imm>                  */
    IR_OP_COPY,         /* %dst = %src                   */

    /* §7.2 Arithmetic */
    IR_OP_ADD,
    IR_OP_SUB,
    IR_OP_MUL,
    IR_OP_DIVS,         /* signed divide                 */
    IR_OP_DIVU,         /* unsigned divide               */
    /* modulo: remainder of integer division */
    IR_OP_MODS,         /* signed modulo                 */
    IR_OP_MODU,         /* unsigned modulo               */
    IR_OP_AND,
    IR_OP_OR,
    IR_OP_XOR,
    IR_OP_SHL,
    IR_OP_SHRU,         /* logical shift right           */
    IR_OP_SHRS,         /* arithmetic shift right        */
    IR_OP_NEG,          /* unary –                       */
    IR_OP_NOT,          /* unary ~                       */

    /* §7.3 Comparisons — result type is always i1 */
    IR_OP_EQ,
    IR_OP_NEQ,
    /* Signed Operations */
    IR_OP_LTS,          /*  <                            */
    IR_OP_LES,          /*  <=                           */
    IR_OP_GTS,          /*  >                            */
    IR_OP_GES,          /*  >=                           */
    /* Unsigned Operations */
    IR_OP_LTU,         
    IR_OP_LEU,
    IR_OP_GTU,
    IR_OP_GEU,

    /* §7.4 Memory */
    IR_OP_ADDR_OF,      /* %ptr = addr_of <symbol>       */
    IR_OP_LOAD,         /* %dst = *%ptr                  */
    IR_OP_STORE,        /* *%ptr = %src  (dst unused)    */
    IR_OP_GEP,          /* %ptr2 = %base + %idx * <width> */

    /* §7.5 Casts */
    IR_OP_ZEXT,         /* Zero extension */
    IR_OP_SEXT,         /* Signal extension */
    IR_OP_TRUNC,
    IR_OP_BITCAST,

    /* §7.6 Terminators */
    IR_OP_GOTO,         /* goto bbX                      */
    IR_OP_BRANCH,       /* if %pred goto bbT else bbF    */
    IR_OP_SWITCH,       /* NEW -> switch %v default bbD [k->bbX] */
    IR_OP_RET,          /* ret void | ret %v             */

    /* §7.7 Calls */
    IR_OP_CALL,         /* %dst = @func(args...)  or void call */

    IR_OP_COUNT         /* Used for total number of opcode in IR */
} ir_opcode_t;

/* ────────────────────────────────────────────────────────────
 * Instruction node
 * ──────────────────────────────────────────────────────────── */

/* Caller side 
    This is on the caller side — the maximum number of arguments 
    that can be passed in a single function call instruction
    This is imposed for simpliciy, instead of having dynamic arrays.
*/
#define IR_MAX_ARGS 16    /* (>3 go to stack per ABI) -- irrelevant for now */
#define IR_MAX_SWITCH_CASES 64

typedef struct ir_instr_s ir_instr_t;

struct ir_instr_s { // quadruple representation: op dst src1 src2
    ir_opcode_t  op;
    ir_value_t   dst;        /* Destination virtual register: IR_VAL_NONE for stores/void calls/ret */
    ir_value_t   src[2];     /* up to two operands for most instructions */

    union {
        struct {
            /* For GEP (Get Element Pointer): width */
            long width;    /* <=> sizeof(array_data_type) (compile time element size)*/
        } gep;
        struct {
            char       callee[128];
            ir_value_t args[IR_MAX_ARGS];
            unsigned   arg_count;
            int        is_void_call;  /* 1 -> no dst assigned                   */
        } call;
        struct {
            unsigned true_block;
            unsigned false_block;
        } branch;
        struct {
            unsigned default_block;                     // default target bb id
            long     case_values[IR_MAX_SWITCH_CASES];  // case values (sorted ascending)
            unsigned case_blocks[IR_MAX_SWITCH_CASES];  // target bb id for each case value
            unsigned case_count;                        // number of cases
        } sw;
    } as;

    ir_instr_t *next;
};

/* ────────────────────────────────────────────────────────────
 * §6.3  Basic block (bb) - any structure without an indirection
 * ──────────────────────────────────────────────────────────── */

typedef struct ir_block_s ir_block_t;

struct ir_block_s {
    unsigned     id;            /* bb<id>                         */
    ir_instr_t  *head;          /* first instruction              */
    ir_instr_t  *tail;          /* last instruction (terminator)  */
    ir_block_t  *next;          /* next block in function order   */
};

/* ────────────────────────────────────────────────────────────
 * Slot-to-symbol map (stack allocation metadata)
 * ──────────────────────────────────────────────────────────── */

typedef struct ir_slot_entry_s ir_slot_entry_t;

struct ir_slot_entry_s {
    char             name[128];  /* symbol name                    */
    unsigned         slot_id;    /* %slotN                         */
    ir_type_t        type;
    ir_slot_entry_t *next;
};

/* ────────────────────────────────────────────────────────────
 * §6.2  Function
 * ──────────────────────────────────────────────────────────── */

 /* Callee side
     The maximum number of parameters a function definition can
     declare in its signature. It limits the fixed arrays inside ir_function_t.
     This is imposed for simpliciy, instead of having dynamic arrays.
 */
#define IR_MAX_PARAMS IR_MAX_ARGS // must be the same for coherency

typedef struct {
    char       name[128];   /* function name (without @)     */
    ir_type_t  ret_type;

    /* Parameters */
    char       param_names[IR_MAX_PARAMS][128];
    ir_type_t  param_types[IR_MAX_PARAMS];
    unsigned   param_count;

    /* Virtual register counter */
    unsigned   next_vreg;

    /* Basic block counter */
    unsigned   next_block_id;

    /* Slot counter */
    unsigned   next_slot_id;

    /* Slot → symbol map (singly linked) */
    ir_slot_entry_t *slots;

    /* Basic block list (ordered) */
    ir_block_t *entry;      /* first block                   */
    ir_block_t *block_tail; /* tail for O(1) append          */
} ir_function_t;

/* ────────────────────────────────────────────────────────────
 * §6.1  Module
 * ──────────────────────────────────────────────────────────── */

typedef struct ir_global_s ir_global_t;

struct ir_global_s {
    char         name[128];
    ir_type_t    type;
    int          is_extern;
    ir_global_t *next;
};

typedef struct ir_function_list_s ir_function_list_t;

struct ir_function_list_s {
    ir_function_t       *func;
    ir_function_list_t  *next;
};

typedef struct {
    char                 arch[64];   /* processor name :)              */
    ir_global_t         *globals;    /* linked list of globals         */
    ir_function_list_t  *functions;  /* linked list of functions       */
} ir_module_t;

/* ────────────────────────────────────────────────────────────
 * Module / function lifetime
 * ──────────────────────────────────────────────────────────── */

ir_module_t    *ir_module_new(const char *arch);
void            ir_module_free(ir_module_t *mod);

ir_function_t  *ir_function_new(const char *name, ir_type_t ret_type);
void            ir_function_free(ir_function_t *func);
void            ir_module_add_function(ir_module_t *mod, ir_function_t *func);
void            ir_module_add_global(ir_module_t *mod, const char *name,
                                     ir_type_t type, int is_extern);

/* ────────────────────────────────────────────────────────────
 * Block / instruction builders (used by lowering)
 * ──────────────────────────────────────────────────────────── */

ir_block_t *ir_block_new(ir_function_t *func);
void        ir_block_append(ir_function_t *func, ir_block_t *block);
void        ir_instr_push(ir_block_t *block, ir_instr_t *instr);

ir_instr_t *ir_instr_new(ir_opcode_t op);

/* Allocate a fresh virtual register id */
unsigned    ir_new_vreg(ir_function_t *func);

/* Declare a stack slot for a named local */
unsigned    ir_new_slot(ir_function_t *func, const char *name, ir_type_t type);
/* Look up slot id by symbol name; returns (unsigned)-1 if not found */
unsigned    ir_find_slot(const ir_function_t *func, const char *name);

/* ────────────────────────────────────────────────────────────
 * §12  Text serialiser
 * ──────────────────────────────────────────────────────────── */

void ir_module_print(FILE *out, const ir_module_t *mod);
void ir_function_print(FILE *out, const ir_function_t *func);
void ir_block_print(FILE *out, const ir_block_t *block);
void ir_instr_print(FILE *out, const ir_instr_t *instr);
void ir_value_print(FILE *out, const ir_value_t *val);
void ir_type_print(FILE *out, const ir_type_t *type);

/* ────────────────────────────────────────────────────────────
 * Convenience constructors for ir_value_t
 * ──────────────────────────────────────────────────────────── */

ir_value_t ir_val_vreg(unsigned id, ir_type_t type);
ir_value_t ir_val_slot(unsigned id, ir_type_t type);
ir_value_t ir_val_global(const char *name, ir_type_t type);
ir_value_t ir_val_imm(long imm, ir_type_t type);
ir_value_t ir_val_label(unsigned block_id);
ir_value_t ir_val_none(void);

/* ────────────────────────────────────────────────────────────
 * Convenience type constructors
 * ──────────────────────────────────────────────────────────── */

ir_type_t ir_type_void(void);
ir_type_t ir_type_i1(void);
ir_type_t ir_type_i8(void);
ir_type_t ir_type_i16(void);
ir_type_t ir_type_i32(void);
ir_type_t ir_type_ptr(void);
ir_type_t ir_type_array(ir_type_t elem, size_t count);
ir_type_t ir_type_struct(const char *tag);
ir_type_t ir_type_union(const char *tag);

/* Return the "native" scalar for a given IR type width */
int ir_type_is_integer(ir_type_t t);
int ir_type_equal(ir_type_t a, ir_type_t b);

#endif /* IR_IR_H */