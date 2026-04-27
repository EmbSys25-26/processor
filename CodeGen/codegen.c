/*
 * codegen.c — Stage 6: Assembly Code Generation
 *
 * Walks the post-regalloc IR and emits assembly for the custom 16-bit RISC.
 * All virtual registers have already been assigned to physical registers by
 * regalloc.c; every IR_VAL_VREG is translated by looking up ra->color[vreg].
 *
 * ISA:
 *
 *   RR  format  op(4) rd(4) rs(4) fn(4)    — ADD, SUB, AND, XOR, SRL, SRA, CMP …
 *   RI  format  op(4) rd(4) fn(4) imm(4)   — RSUBI, ANDI, XORI …
 *   RRI format  op(4) rd(4) rs(4) imm(4)   — ADDI, LW, LB, SW, SB, JAL
 *   I12 format  op(4) imm(12)               — IMM (upper-12 prefix for next instr)
 *   BR  format  op(4) cond(4) disp(8)       — BEQ, BLT, BLE, BLEU, BLETU, BR …
 *
 *   Key macros (expanded by m4/abi.m4):
 *     MOV(rd, rs)  →  ADDI rd, rs, #0
 *     PUSH(r)      →  ADDI sp, sp, #-1 ; SW r, sp, #0
 *     POP(r)       →  LW r, sp, #0 ; ADDI sp, sp, #1
 *     NEG(rd)      →  RSUBI rd, #0
 *     COM(rd)      →  IMM #0xFFF ; XORI rd, #0xF   (bitwise NOT)
 *     OR(rd,rs)    →  MOV(t0,rd); AND t0,rs; XOR rd,rs; XOR rd,t0
 *     SLL(rd)      →  ADD rd, rd               (left-shift by 1)
 *     LI(rd,imm)   →  IMM #(imm>>4) ; ADDI rd, r0, #(imm&0xF)
 *     CALL(addr)   →  IMM+JAL lr,r0,#0
 *     RET          →  JAL r0, lr, #0
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "codegen.h"

/* ═══════════════════════════════════════════════════════════════════════════
 * §1  Physical register helpers
 * ═══════════════════════════════════════════════════════════════════════════ */

static const char *phys_name(phys_reg_t r)
{
    static const char *tbl[] = {
        "r0","a0","a1","a2","t0","t1","t2","t3",
        "s0","s1","s2","s3","fp","sp","lr", "gp"
    };
    if ((unsigned)r < sizeof(tbl)/sizeof(*tbl))
        return tbl[(unsigned)r];
    return "??";
}

/* Physical register for a virtual register (after regalloc). */
static const char *vreg2phys(const regalloc_t *ra, unsigned vreg)
{
    if (vreg >= ra->n_vregs) return "??";
    if (ra->color[vreg] == REGALLOC_SPILL)
        return "SPILL"; /* should not happen in final IR */
    return phys_name(ra->color[vreg]);
}


/* Helpers to dereference ir_value_t operands to their physical register name.
 * Only safe to call when kind == IR_VAL_VREG. */
#define PREG(val)  vreg2phys(ra, (val).as.vreg)

/* ═══════════════════════════════════════════════════════════════════════════
 * §2  Frame layout helpers
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Count local stack slots declared in the function. */
static unsigned count_slots(const ir_function_t *func)
{
    unsigned n = 0;
    for (const ir_slot_entry_t *s = func->slots; s; s = s->next) n++;
    return n;
}

/* Frame-pointer offset for slot_id N:  fp + offset_of(N) = address of slot N.
 * Slot 0 is directly below the saved fp → offset = -1. */
static int slot_fp_offset(unsigned slot_id)
{
    return -((int)slot_id + 1);
}

/* ─── detect which callee-saved registers (r8–r11) are used by the function */
static uint16_t callee_used_mask(const regalloc_t *ra)
{
    uint16_t mask = 0;
    for (unsigned v = 0; v < ra->n_vregs; v++) {
        phys_reg_t c = ra->color[v];
        if (c != PHYS_NONE && c != REGALLOC_SPILL &&
            c >= PHYS_R8 && c <= PHYS_R11)
            mask |= (uint16_t)(1u << (c - PHYS_R8)); /* bit i → r(8+i) */
    }
    return mask;
}

/* ═══════════════════════════════════════════════════════════════════════════
 * §3  Low-level emitters
 * ═══════════════════════════════════════════════════════════════════════════ */

/*
 * Emit:  rd = rs + offset
 * Uses the IMM prefix for offsets outside the 4-bit signed range [−8, 7].
 * The full 16-bit immediate is encoded as: (IMM_val << 4) | low4.
 */
static void emit_addi_imm(FILE *out, const char *rd, const char *rs, int offset)
{
    if (offset >= -8 && offset <= 7) {
        fprintf(out, "    ADDI %s, %s, #%d\n", rd, rs, offset);
    } else {
    	/* 
    	   IMM #upper
	   ADDI rd, rs, #lower
	*/
        uint16_t u16   = (uint16_t)(int16_t)offset;
        unsigned upper = u16 >> 4;
        unsigned lower = u16 & 0xFu;
        fprintf(out, "    IMM #0x%03X\n", upper);
        fprintf(out, "    ADDI %s, %s, #%u\n", rd, rs, lower);
    }
}

/*
 * Emit a sequence of ADDI sp, sp, #step to ADJUST THE STACK POINTER by
 * `delta` words (negative = allocate, positive = free).
 * Each step is clamped to [−8, 7] to fit in the 4-bit immediate field.
 */
static void emit_sp_adj(FILE *out, int delta)
{
    while (delta != 0) {
        int step = delta;
        if (step < -8) step = -8;
        if (step >  7) step =  7;
        fprintf(out, "    ADDI sp, sp, #%d\n", step);
        delta -= step;
    }
}

/*
 * Emit a 16-bit immediate value into rd.
 *   • 0       → MOV(rd, r0)
 *   • 1–15    → ADDI rd, r0, #imm
 *   • anything else → LI(rd, imm)  [expands to IMM+ADDI via m4]
 */
static void emit_load_imm(FILE *out, const char *rd, long imm)
{
    if (imm == 0) {
        fprintf(out, "    MOV(%s, r0)\n", rd);
    } else if (imm >= 1 && imm <= 15) {
        fprintf(out, "    ADDI %s, r0, #%ld\n", rd, imm);
    } else {
        uint16_t u16 = (uint16_t)(int16_t)imm;
        fprintf(out, "    LI(%s, 0x%04X)", rd, u16);
        if (imm != (long)u16)
            fprintf(out, "    ; (%ld)", imm);
        fprintf(out, "\n");
    }
}

/* ═══════════════════════════════════════════════════════════════════════════
 * §4  Prologue / Epilogue for functions
 * ═══════════════════════════════════════════════════════════════════════════ */
/*
*   save caller frame pointer
*   establish frame pointer
*   save return address
*   save callee-saved
*   allocate local slots
*/

static void emit_prologue(FILE *out,
                           const ir_function_t *func,
                           const regalloc_t    *ra)
{
    unsigned n_slots = count_slots(func);
    uint16_t callee  = callee_used_mask(ra);

    fprintf(out, "    ; --- Prologue ---\n");
    fprintf(out, "    PUSH(fp) \n");
    fprintf(out, "    MOV(fp, sp) \n");
    fprintf(out, "    PUSH(lr) \n");
    

    /* Save any callee-saved registers the function uses */
    for (int i = 0; i <= 3; i++) {
        if (callee & (1u << i))
            fprintf(out, "    PUSH(r%d)\n", 8 + i);
    }

    /* Reserve stack space for all local slots */
    if (n_slots > 0) {
        fprintf(out, "    ; Allocate %u local slot(s)\n", n_slots);
        emit_sp_adj(out, -(int)n_slots);
    }
    fprintf(out, "\n");
}


/*
*    restore stack pointer
*    restore callee-saved
*    restore link register
*    restore frame pointer
*
*/
static void emit_epilogue(FILE *out,
                           const ir_function_t *func __attribute__((unused)),
                           const regalloc_t    *ra)
{
    uint16_t callee = callee_used_mask(ra);

    fprintf(out, "    ; --- Epilogue ---\n");
    fprintf(out, "    MOV(sp, fp)  \n");

    /* Restore callee-saved in reverse order */
    for (int i = 3; i >= 0; i--) {
        if (callee & (1u << i))
            fprintf(out, "    POP(r%d)\n", 8 + i);
    }

    fprintf(out, "    POP(lr) \n");
    fprintf(out, "    POP(fp) \n");
    fprintf(out, "    RET\n");
}

/* ═══════════════════════════════════════════════════════════════════════════
 * §5  Two-address arithmetic helpers
 *
 * The ISA has 2-address form: RR op rd, rs → rd = rd op rs.
 * IR has 3-address form: dst = src0 op src1.
 * We bridge this by emitting a MOV when dst ≠ src0 (or ≠ src1 for
 * commutative ops).
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Commutative: dst = a op b  (ADD, AND, XOR) */
static void emit_binop_rr(FILE *out, const char *mnem,
                            const char *dst,
                            const char *a, const char *b)
{
    if (strcmp(dst, a) == 0) {  //eg. r1=r1+r2
        fprintf(out, "    %s %s, %s\n", mnem, dst, b);
    } else if (strcmp(dst, b) == 0) {  //eg. r1=r2+r1
        /* commutative: swap operands */
        fprintf(out, "    %s %s, %s\n", mnem, dst, a);
    } else {	//eg. r1 = r2+r3
        fprintf(out, "    MOV(%s, %s)\n", dst, a);
        fprintf(out, "    %s %s, %s\n", mnem, dst, b);
    }
}

/* Non-commutative: dst = a op b  (SUB, SRL, SRA) — order matters */
static void emit_binop_rr_nc(FILE *out, const char *mnem,
                               const char *dst,
                               const char *a, const char *b)
{
    if (strcmp(dst, a) != 0)
        fprintf(out, "    MOV(%s, %s)\n", dst, a);
    fprintf(out, "    %s %s, %s\n", mnem, dst, b);
}

/*
 * OR(rd, rs) is an m4 macro that clobbers t0 (r4).
 * Constraint: rs must NOT be r4 (it would be overwritten by MOV(t0,rd)) (get/set CC).
 * We handle this by swapping if rs==r4 (OR is commutative).
 */
static void emit_or_rr(FILE *out,
                         const char *dst, const char *a, const char *b)
{
    const char *lhs = a, *rhs = b;

    /* Ensure rhs != r4 (t0 used internally by OR macro) */
    if (strcmp(rhs, "r4") == 0) {
        const char *tmp = lhs; lhs = rhs; rhs = tmp;
    }

    if (strcmp(dst, lhs) != 0)
        fprintf(out, "    MOV(%s, %s)\n", dst, lhs);
    fprintf(out, "    OR(%s, %s)\n", dst, rhs);
}

/* ═══════════════════════════════════════════════════════════════════════════
 * §6  Comparison / branch helpers
 *
 * IR comparisons produce an i1 vreg (0 or 1).  The ISA has no compare-and-
 * set instruction, so we materialise the result with a branch ladder:
 *
 *   CMP rA, rB
 *   ADDI rD, r0, #0       ; assume false
 *   <Bcond> .true         ; if condition holds, skip to true
 *   BR .done
 * .true:
 *   ADDI rD, r0, #1
 * .done:
 *
 * Branch displacement for each BR is computed by the assembler from labels,
 * so we emit local per-comparison labels using a running counter.
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Global label counter (reset per function for readability). */
static unsigned g_cmp_label = 0;

/* Map IR comparison opcode → branch mnemonic + whether operands are swapped. */
static void cmp_to_branch(ir_opcode_t op,
                            const char **bmnem_out,
                            int         *swap_out)
{
    *swap_out = 0;
    switch (op) {
    case IR_OP_EQ:   *bmnem_out = "BEQ";  break;
    /*There is no different operator*/
    case IR_OP_NEQ:  *bmnem_out = "BEQ";  *swap_out = 1; break; /* inverted */
    case IR_OP_LTS:  *bmnem_out = "BLT";  break;
    case IR_OP_LES:  *bmnem_out = "BLE";  break;
    /*There is no instruction for greater than, so swap operands*/
    case IR_OP_GTS:  *bmnem_out = "BLT";  *swap_out = 1; break; /* a>b ≡ b<a */
    case IR_OP_GES:  *bmnem_out = "BLE";  *swap_out = 1; break; /* a≥b ≡ b≤a */
    case IR_OP_LTU:  *bmnem_out = "BLEU"; break;
    case IR_OP_LEU:  *bmnem_out = "BLETU";break;
    /*There is no instruction for greater than, so swap operands*/
    case IR_OP_GTU:  *bmnem_out = "BLEU"; *swap_out = 1; break;
    case IR_OP_GEU:  *bmnem_out = "BLETU";*swap_out = 1; break;
    default:         *bmnem_out = "BEQ";  break;
    }
}

static void emit_comparison(FILE *out, ir_opcode_t op,
                              const char *rd,
                              const char *ra_r, const char *rb_r)
{
    const char *bmnem;
    int         swap;
    cmp_to_branch(op, &bmnem, &swap);

    unsigned lbl = g_cmp_label++;
    const char *cmp_a = swap ? rb_r : ra_r;
    const char *cmp_b = swap ? ra_r : rb_r;

    /* For NEQ we want "branch if NOT equal to true", so invert sense:
     * "CMP; BEQ .false; ADDI rD,#1; BR .done; .false: ADDI rD,#0; .done:" */
    if (op == IR_OP_NEQ) {
        fprintf(out, "    CMP %s, %s\n", cmp_a, cmp_b);
        fprintf(out, "    ADDI %s, r0, #1      ; assume true (!=)\n", rd);
        fprintf(out, "    BEQ .cmp_false_%u\n", lbl);
        fprintf(out, "    BR .cmp_done_%u\n", lbl);
        fprintf(out, ".cmp_false_%u:\n", lbl);
        fprintf(out, "    ADDI %s, r0, #0      ; equal → false\n", rd);
        fprintf(out, ".cmp_done_%u:\n", lbl);
    } else {
        fprintf(out, "    CMP %s, %s\n", cmp_a, cmp_b);
        fprintf(out, "    ADDI %s, r0, #0      ; assume false\n", rd);
        fprintf(out, "    %s .cmp_true_%u\n", bmnem, lbl);
        fprintf(out, "    BR .cmp_done_%u\n", lbl);
        fprintf(out, ".cmp_true_%u:\n", lbl);
        fprintf(out, "    ADDI %s, r0, #1      ; condition true\n", rd);
        fprintf(out, ".cmp_done_%u:\n", lbl);
    }
}

/* ═══════════════════════════════════════════════════════════════════════════
 * §7  Per-instruction emitter
 * ═══════════════════════════════════════════════════════════════════════════ */

static void emit_instr(FILE                *out,
                        const ir_instr_t    *ins,
                        const ir_function_t *func,
                        const regalloc_t    *ra)
{
    /* Shorthand: physical name of destination vreg */
    const char *rd = (ins->dst.kind == IR_VAL_VREG)
                     ? PREG(ins->dst) : NULL;

    /* Shorthand: physical names of source vregs */
    const char *rs0 = (ins->src[0].kind == IR_VAL_VREG)
                      ? PREG(ins->src[0]) : NULL;
    const char *rs1 = (ins->src[1].kind == IR_VAL_VREG)
                      ? PREG(ins->src[1]) : NULL;

    switch (ins->op) {

    /* ── §7.1  Constants ─────────────────────────────────────────────── */

    case IR_OP_CONST:
        emit_load_imm(out, rd, ins->src[0].as.imm);
        break;

    /* ── §7.2  Copy / move ───────────────────────────────────────────── */

    case IR_OP_COPY:
        if (strcmp(rd, rs0) != 0)
            fprintf(out, "    MOV(%s, %s)\n", rd, rs0);
        break;

    /* ── §7.3  Arithmetic ────────────────────────────────────────────── */

    case IR_OP_ADD:
        emit_binop_rr(out, "ADD", rd, rs0, rs1);
        break;

    case IR_OP_SUB:
        emit_binop_rr_nc(out, "SUB", rd, rs0, rs1);
        break;

    case IR_OP_AND:
        emit_binop_rr(out, "AND", rd, rs0, rs1);
        break;

    case IR_OP_OR:
        emit_or_rr(out, rd, rs0, rs1);
        break;

    case IR_OP_XOR:
        emit_binop_rr(out, "XOR", rd, rs0, rs1);
        break;

    case IR_OP_NEG:
        if (strcmp(rd, rs0) != 0)
            fprintf(out, "    MOV(%s, %s)\n", rd, rs0);
        fprintf(out, "    NEG(%s)\n", rd);
        break;

    case IR_OP_NOT:
        if (strcmp(rd, rs0) != 0)
            fprintf(out, "    MOV(%s, %s)\n", rd, rs0);
        fprintf(out, "    COM(%s)\n", rd);
        break;

    case IR_OP_SHL:
        /* SLL(rd) shifts rd left by 1.  For a constant shift count N, emit N
         * SLL instructions.  For a variable shift count, emit a software loop.
         */
        if (ins->src[1].kind == IR_VAL_IMM_INT) {
            long n = ins->src[1].as.imm;
            if (strcmp(rd, rs0) != 0)
                fprintf(out, "    MOV(%s, %s)\n", rd, rs0);
            for (long i = 0; i < n && i < 16; i++)
                fprintf(out, "    SLL(%s)\n", rd);
        } else {
            /* Variable-count left shift using a decrement-and-branch loop:
             *
             *   MOV rd, rs0
             *   MOV t0, rs1        ; loop counter
             *   CMP t0, r0
             *   BEQ .shl_done_N
             * .shl_loop_N:
             *   SLL rd
             *   ADDI t0, t0, #-1
             *   CMP t0, r0
             *   BEQ .shl_done_N
             *   BR .shl_loop_N
             * .shl_done_N:
             */
            unsigned lbl = g_cmp_label++;
            if (strcmp(rd, rs0) != 0)
                fprintf(out, "    MOV(%s, %s)\n", rd, rs0);
            fprintf(out, "    MOV(r4, %s)\n", rs1); /* t0 = shift count */
            fprintf(out, "    CMP r4, r0\n");
            fprintf(out, "    BEQ .shl_done_%u\n", lbl);
            fprintf(out, ".shl_loop_%u:\n", lbl);
            fprintf(out, "    SLL(%s)\n", rd);
            fprintf(out, "    ADDI r4, r4, #-1\n");
            fprintf(out, "    CMP r4, r0\n");
            fprintf(out, "    BEQ .shl_done_%u\n", lbl);
            fprintf(out, "    BR .shl_loop_%u\n", lbl);
            fprintf(out, ".shl_done_%u:\n", lbl);
        }
        break;

    case IR_OP_SHRU:
        emit_binop_rr_nc(out, "SRL", rd, rs0, rs1);
        break;

    case IR_OP_SHRS:
        emit_binop_rr_nc(out, "SRA", rd, rs0, rs1);
        break;

    /* ── §7.4  Memory ────────────────────────────────────────────────── */

    /*
     * ADDR_OF %slotN → ADDI rd, fp, #-(N+1)
     * ADDR_OF @global → LI(rd, global_label)  [resolved by linker / assembler]
     */
    case IR_OP_ADDR_OF:
        if (ins->src[0].kind == IR_VAL_SLOT) {
            int off = slot_fp_offset(ins->src[0].as.slot);
            emit_addi_imm(out, rd, "fp", off);
        } else if (ins->src[0].kind == IR_VAL_GLOBAL) {
            /* Global symbol — assembler resolves the label at link time.
             * LI(rd, label) expands to IMM+ADDI using the 16-bit address. */
            fprintf(out, "    LI(%s, %s)              ; &@%s\n",
                    rd, ins->src[0].as.name, ins->src[0].as.name);
        } else {
            fprintf(out, "    ; [CODEGEN] ADDR_OF: unhandled src kind %d\n",
                    (int)ins->src[0].kind);
        }
        break;

    /*
     * LOAD %dst = *%ptr
     * Use LW (word, 16-bit) by default; LB for i8 destination.
     */
    case IR_OP_LOAD: {
        const char *op = (ins->dst.type.kind == IR_TYPE_I8) ? "LB" : "LW";
        fprintf(out, "    %s %s, %s, #0\n", op, rd, rs0);
        break;
    }

    /*
     * STORE *%ptr = %val
     * src[0] = ptr register, src[1] = value register.
     * Use SW (word) or SB (byte).
     */
    case IR_OP_STORE: {
        const char *op = (ins->src[1].type.kind == IR_TYPE_I8) ? "SB" : "SW";
        fprintf(out, "    %s %s, %s, #0\n", op, rs1, rs0);
        break;
    }

    /*
     * GEP  %dst = %base + %idx * width
     *
     * Width 1 → ADD rd, rbase, ridx
     * Width 2 → SLL ridx copy, then ADD base
     * Width 4 → two SLLs then ADD
     * Larger  → emit MUL helper call or repeated SLLs (limited support)
     */
    case IR_OP_GEP: {
        long width = ins->as.gep.width;
        if (width == 1) {
            emit_binop_rr(out, "ADD", rd, rs0, rs1);
        } else if (width == 2 || width == 4) {
            int shifts = (width == 2) ? 1 : 2;
            /* Compute idx * width in rd (may clobber rd if rd ≠ rs1). */
            if (strcmp(rd, rs1) != 0)
                fprintf(out, "    MOV(%s, %s)\n", rd, rs1);
            for (int i = 0; i < shifts; i++)
                fprintf(out, "    SLL(%s)\n", rd);
            fprintf(out, "    ADD %s, %s\n", rd, rs0); /* rd = scaled_idx + base */
        } else {
            /* General case: rd = base + idx * width */
            emit_load_imm(out, "r4", width);            /* r4 = width (scratch) */
            if (strcmp(rs1, "r1") != 0) fprintf(out, "    MOV(r1, %s)\n", rs1);
            fprintf(out, "    MOV(r2, r4)\n");
            fprintf(out, "    CALL(__mul)             ; r1 = idx * width\n");
            fprintf(out, "    ADD r1, %s\n", rs0);     /* r1 = base + offset */
            if (strcmp(rd, "r1") != 0)
                fprintf(out, "    MOV(%s, r1)\n", rd);
        }
        break;
    }

    /* ── §7.5  Casts ──────────────────────────────────────────────────── */

    /*
     * ZEXT: zero-extend a narrower integer.
     * i1 → i16:  ANDI rd, #1
     * i8 → i16:  AND with 0x00FF
     *             IMM #0x00F ; AND rd, r0... actually: need mask in a reg.
     *             Use ANDI rd, #0xF twice or load mask.
     * i16 → i16: just MOV (no-op extension).
     */
    case IR_OP_ZEXT:
        if (strcmp(rd, rs0) != 0)
            fprintf(out, "    MOV(%s, %s)\n", rd, rs0);
        if (ins->src[0].type.kind == IR_TYPE_I1) {
            fprintf(out, "    ANDI %s, #1\n", rd);
        } else if (ins->src[0].type.kind == IR_TYPE_I8) {
            /* Zero-extend byte: mask = 0x00FF.
             * Load mask into a scratch (r4), then AND rd with r4.
             * We use IMM #0x00F ; ADDI r4, r0, #0xF to get 0x00FF. */
            fprintf(out, "    IMM #0x00F\n");
            fprintf(out, "    ADDI r4, r0, #0xF       ; r4 = 0x00FF (byte mask)\n");
            fprintf(out, "    AND %s, r4              ; zero-extend byte\n", rd);
        }
        /* i16/i32 → i16: no masking needed, value already fits. */
        break;

    /*
     * SEXT: sign-extend from a narrower integer.
     * i8  → i16: LBS macro (load-byte-signed) sign-extends an 8-bit value.
     *            Since we already loaded the value into a register, we use
     *            the arithmetic right-shift trick: SLL 8 times then SRA 8 times.
     * i1  → i16: NEG(rd) after isolating the bit (rare, handles booleans).
     * i16 → i16: no-op.
     */
    case IR_OP_SEXT:
        if (strcmp(rd, rs0) != 0)
            fprintf(out, "    MOV(%s, %s)\n", rd, rs0);
        if (ins->src[0].type.kind == IR_TYPE_I8) {
            /* Shift left 8 then arithmetic-right 8 to sign-extend. */
            fprintf(out, "    ADDI r4, r0, #8         ; shift count = 8\n");
            for (int i = 0; i < 8; i++) fprintf(out, "    SLL(%s)\n", rd);
            fprintf(out, "    SRA %s, r4              ; sign-extend (SRA by 8)\n", rd);
        } else if (ins->src[0].type.kind == IR_TYPE_I1) {
            /* i1 sign-extend: 0→0, 1→-1 (0xFFFF). */
            fprintf(out, "    NEG(%s)                 ; i1 sign-extend: 1→-1\n", rd);
        }
        break;

    case IR_OP_TRUNC:
    case IR_OP_BITCAST:
        /* Truncation / reinterpretation: the physical register holds the value;
         * no instruction needed — the low-order bits are already correct.
         * A byte truncation could AND with 0xFF, but since we use 16-bit regs
         * everywhere and the LB/SB instructions handle byte granularity in
         * memory, this is typically a no-op at the register level. */
        if (strcmp(rd, rs0) != 0)
            fprintf(out, "    MOV(%s, %s)\n", rd, rs0);
        break;

    /* ── §7.6  Comparisons ────────────────────────────────────────────── */

    case IR_OP_EQ: case IR_OP_NEQ:
    case IR_OP_LTS: case IR_OP_LES: case IR_OP_GTS: case IR_OP_GES:
    case IR_OP_LTU: case IR_OP_LEU: case IR_OP_GTU: case IR_OP_GEU:
        emit_comparison(out, ins->op, rd, rs0, rs1);
        break;

    /* ── §7.7  Terminators ────────────────────────────────────────────── */

    /*
     * GOTO bbN → unconditional branch.
     * The assembler resolves the label; displacement computed as
     *   (label_addr − branch_addr) / 2.
     */
    case IR_OP_GOTO: {
        unsigned tgt = (ins->src[0].kind == IR_VAL_LABEL)
                       ? ins->src[0].as.block_id
                       : ins->as.branch.true_block;
        fprintf(out, "    BR bb%u\n", tgt);
        break;
    }

    /*
     * BRANCH  if %pred goto bbT else bbF
     *
     * Pattern (pred is already 0/1 from a comparison):
     *   CMP pred, r0    ; test pred ≠ 0
     *   BEQ bbF         ; pred == 0 → false branch
     *   BR  bbT
     */
    case IR_OP_BRANCH:
        fprintf(out, "    CMP %s, r0\n", rs0);
        fprintf(out, "    BEQ bb%u\n", ins->as.branch.false_block);
        fprintf(out, "    BR  bb%u\n", ins->as.branch.true_block);
        break;

    /*
     * SWITCH %val default bbD [c0→bb0, c1→bb1, …]
     *
     * Emit a linear comparison chain (small case counts — typically up to
     * IR_MAX_SWITCH_CASES=64, but the chain is correct regardless of N):
     *
     *   ; for each case k:
     *   CMP val, rTemp  (where rTemp = immediate or LI-loaded constant)
     *   BEQ bbK
     *   BR  bbDefault
     */
    case IR_OP_SWITCH: {
        const char *val = rs0;
        for (unsigned k = 0; k < ins->as.sw.case_count; k++) {
            long cv = ins->as.sw.case_values[k];
            /* Compare val against the case constant. */
            if (cv >= 0 && cv <= 15) {
                /* RCMPI computes imm − rd; Z is set iff rd == imm. */
                fprintf(out, "    RCMPI %s, #%ld\n", val, cv);
            } else {
                /* Load case value into scratch register r4. */
                emit_load_imm(out, "r4", cv);
                fprintf(out, "    CMP %s, r4\n", val);
            }
            fprintf(out, "    BEQ bb%u\n", ins->as.sw.case_blocks[k]);
        }
        fprintf(out, "    BR  bb%u             ; default\n",
                ins->as.sw.default_block);
        break;
    }

    /*
     * RET void  → epilogue (no value move needed)
     * RET %v    → ensure return value is in r1, then epilogue
     */
    case IR_OP_RET:
        if (ins->src[0].kind == IR_VAL_VREG) {
            const char *rv = rs0;
            if (strcmp(rv, "r1") != 0)
                fprintf(out, "    MOV(r1, %s)\n", rv);
        }
        emit_epilogue(out, func, ra);
        break;

    /* ── §7.8  Function calls ─────────────────────────────────────────── */

    /*
     * CALL @f(args…)
     *
     * The regalloc precoloring already constrained the first 3 arguments to
     * r1/r2/r3 and the return value to r1, so no explicit MOVs are needed
     * for those in the common case.  Extra arguments beyond 3 would need to
     * be pushed onto the stack before the call and cleaned up after — emitted
     * here if present.
     */
    case IR_OP_CALL: {
	    unsigned nargs = ins->as.call.arg_count;

	    static const char *arg_regs[] = {"r1", "r2", "r3"};

	    /* ── 1. register arguments ───────────────────── */
	    unsigned nreg = (nargs < PHYS_ARG_REGS) ? nargs : PHYS_ARG_REGS;

	    for (unsigned i = 0; i < nreg; i++) {
		const ir_value_t *a = &ins->as.call.args[i];
		const char *dst = arg_regs[i];

		switch (a->kind) {
		case IR_VAL_VREG:
		    if (strcmp(dst, PREG(*a)) != 0)
		        fprintf(out, "    MOV(%s, %s)\n", dst, PREG(*a));
		    break;

		case IR_VAL_IMM_INT:
		    emit_load_imm(out, dst, a->as.imm);
		    break;

		case IR_VAL_GLOBAL:
		    fprintf(out, "    LI(%s, %s)\n", dst, a->as.name);
		    break;

		default:
		    fprintf(out, "    ; [CALL] unsupported arg kind %d\n", a->kind);
		    break;
		}
	    }

	    /* ── 2. stack arguments ─────────────────────── */
	    for (unsigned i = nargs; i > PHYS_ARG_REGS; i--) {
		const ir_value_t *a = &ins->as.call.args[i - 1];

		switch (a->kind) {
		case IR_VAL_VREG:
		    fprintf(out, "    PUSH(%s)\n", PREG(*a));
		    break;

		case IR_VAL_IMM_INT:
		    emit_load_imm(out, "r4", a->as.imm);
		    fprintf(out, "    PUSH(r4)\n");
		    break;

		case IR_VAL_GLOBAL:
		    fprintf(out, "    LI(r4, %s)\n", a->as.name);
		    fprintf(out, "    PUSH(r4)\n");
		    break;

		default:
		    fprintf(out, "    ; [CALL] unsupported stack arg %d\n", a->kind);
		    break;
		}
	    }

	    /* ── 3. call ──────────────────────────────── */
	    fprintf(out, "    CALL(%s)\n", ins->as.call.callee);

	    /* ── 4. stack cleanup ─────────────────────── */
	    if (nargs > PHYS_ARG_REGS)
		emit_sp_adj(out, (int)(nargs - PHYS_ARG_REGS));

	    /* ── 5. return value ───────────────────────── */
	    if (!ins->as.call.is_void_call &&
		ins->dst.kind == IR_VAL_VREG) {

		const char *dst = PREG(ins->dst);
		if (strcmp(dst, "r1") != 0)
		    fprintf(out, "    MOV(%s, r1)\n", dst);
	    }

	    break;
	}

	    default:
		fprintf(out, "    ; [CODEGEN] unhandled IR opcode %d\n", (int)ins->op);
		break;
    }
}

/* ═══════════════════════════════════════════════════════════════════════════
 * §8  Block and function emitters
 * ═══════════════════════════════════════════════════════════════════════════ */

static void emit_slot_comment(FILE *out, const ir_function_t *func)
{
    fprintf(out, "    ; Frame slots (fp-based):\n");
    for (const ir_slot_entry_t *s = func->slots; s; s = s->next) {
        int off = slot_fp_offset(s->slot_id);
        fprintf(out, "    ;   %%slot%u (%s) @ fp%+d\n",
                s->slot_id, s->name, off);
    }
}

static void emit_block(FILE                *out,
                        const ir_block_t    *block,
                        const ir_function_t *func,
                        const regalloc_t    *ra)
{
    fprintf(out, "bb%u:\n", block->id);
    for (const ir_instr_t *ins = block->head; ins; ins = ins->next)
        emit_instr(out, ins, func, ra);
    fprintf(out, "\n");
}

/* ═══════════════════════════════════════════════════════════════════════════
 * §9  Public API
 * ═══════════════════════════════════════════════════════════════════════════ */

void codegen_emit_function(FILE                *out,
                            const ir_function_t *func,
                            const regalloc_t    *ra)
{
    g_cmp_label = 0; /* reset per-function label counter */

    fprintf(out, "%s:\n", func->name);
    emit_slot_comment(out, func);
    fprintf(out, "\n");
    emit_prologue(out, func, ra);

    for (const ir_block_t *b = func->entry; b; b = b->next)
        emit_block(out, b, func, ra);
}

void codegen_emit_module(FILE               *out,
                          const ir_module_t  *module,
                          const regalloc_t  **allocs)
{
    /* ── file header ── */
    fprintf(out,
            "; ============================================================\n"
            "; Generated by codegen  —  %s\n"
            "; Custom 16-bit RISC ISA\n"
            "; ============================================================\n\n",
            module->arch);

    /* ── global data section ── */
    if (module->globals) {
        fprintf(out, "; ── Global data ──────────────────────────────────────────\n");
        for (const ir_global_t *g = module->globals; g; g = g->next) {
            if (g->is_extern) {
                fprintf(out, "; extern @%s  (resolved at link time)\n", g->name);
            } else {
                fprintf(out, "%s:\n", g->name);
                fprintf(out, "    .word 0x0000         ; global @%s\n", g->name);
            }
        }
        fprintf(out, "\n");
    }

    /* ── function text section ── */
    unsigned fi = 0;
    for (const ir_function_list_t *fl = module->functions; fl; fl = fl->next, fi++) {
        codegen_emit_function(out, fl->func, allocs[fi]);
        fprintf(out, "\n");
    }
}
