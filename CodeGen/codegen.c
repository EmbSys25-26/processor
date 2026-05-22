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

/* Format a block label scoped by function name. Block ids restart at 0 per
 * function; the assembler's symbol table is global, so plain "bb1" would
 * collide across functions. The ".L" prefix keeps it a dot-label. */
static void fmt_block_label(char *buf, size_t cap,
                            const ir_function_t *func, unsigned id)
{
    snprintf(buf, cap, ".L%s_bb%u", func->name, id);
}

/* ═══════════════════════════════════════════════════════════════════════════
 * §1  Physical register helpers
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Returns the ABI mnemonic for a physical register id. */
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

/* Forward declarations so the materialize helper below can call into the
 * low-level emitters defined further down in §3. */
static void emit_load_imm(FILE *out, const char *rd, long imm);

/* Pick a scratch register for codegen-introduced temps.
 *
 * The register allocator excludes r7 (t3) from its preference list, so t3
 * is guaranteed never to be the home of a live vreg.  We try t3 first as
 * the always-safe choice, and fall back to t0..t2 only if a caller forbids
 * t3 explicitly (no current call site does).  The `avoid*` parameters are
 * still honoured for clarity at call sites.
 *
 * The returned name is safe to write to without consulting liveness. */
/* Returns a safe scratch register name avoiding up to three given names. */
static const char *pick_scratch3(const char *avoid1,
                                  const char *avoid2,
                                  const char *avoid3)
{
    static const char *cands[] = {"t3", "t2", "t1", "t0"};
    for (unsigned i = 0; i < 4; i++) {
        if (avoid1 && strcmp(cands[i], avoid1) == 0) continue;
        if (avoid2 && strcmp(cands[i], avoid2) == 0) continue;
        if (avoid3 && strcmp(cands[i], avoid3) == 0) continue;
        return cands[i];
    }
    return "t3";
}

/* If `v` is a virtual register, return the physical name it was allocated to
 * (no instruction emitted).  Otherwise emit code to load the value into
 * `scratch` and return the scratch register name.
 *
 * Supports immediates and global symbols.  Slot/label/none operands are
 * not handled — they are addressed via dedicated opcodes (ADDR_OF, GOTO …). */
static const char *materialize_operand(FILE                *out,
                                        const ir_value_t    *v,
                                        const regalloc_t    *ra,
                                        const char          *scratch)
{
    switch (v->kind) {
    case IR_VAL_VREG:
        return vreg2phys(ra, v->as.vreg);
    case IR_VAL_IMM_INT:
        /* r0 is hardwired to zero on this ISA, so an immediate zero needs
         * no materialisation — use r0 directly and save an instruction. */
        if (v->as.imm == 0)
            return "r0";
        emit_load_imm(out, scratch, v->as.imm);
        return scratch;
    case IR_VAL_GLOBAL:
        fprintf(out, "    LI(%s, %s)              ; @%s\n",
                scratch, v->as.name, v->as.name);
        return scratch;
    default:
        fprintf(out, "    ; [CODEGEN] cannot materialize operand kind %d\n",
                (int)v->kind);
        return scratch;
    }
}

/* ═══════════════════════════════════════════════════════════════════════════
 * §2  Frame layout helpers
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Total stack space used by local slots, in 16-bit words.
 *
 * Each named slot may occupy more than one word (arrays).  ir_new_slot()
 * reserves consecutive slot ids by bumping `next_slot_id` by the type's
 * word size, so the high-water mark is the right total. */
/* Returns the total number of local-slot words to reserve. */
static unsigned count_slots(const ir_function_t *func)
{
    return func->next_slot_id;
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

/* ─── leaf-function detection ──────────────────────────────────────────────
 *
 * A function is `leaf` iff its IR body contains no IR_OP_CALL.  Leaf
 * functions need not save lr in the prologue, because lr is preserved
 * across a leaf body (no callee can clobber it) and the closing RET
 * (= JAL r0, lr, #0) reads back the original lr that the caller still
 * holds.  Skipping PUSH(lr)/POP(lr) saves two instructions per leaf
 * function but shifts every slot one word toward fp -- see
 * slot_fp_offset() below.
 */
/* Returns 1 if the function contains no IR_OP_CALL instruction. */
static int function_is_leaf(const ir_function_t *func)
{
    for (const ir_block_t *b = func->entry; b; b = b->next)
        for (const ir_instr_t *i = b->head; i; i = i->next)
            if (i->op == IR_OP_CALL) return 0;
    return 1;
}

/* Frame-pointer offset for slot_id N:  fp + offset_of(N) = address of slot N.
 *
 *  Non-leaf frame layout after prologue:
 *    fp-0: saved fp
 *    fp-1: saved lr               <-- absent for leaf functions
 *    fp-2 .. fp-(1+cc): saved callee-saved
 *    slot 0 lives at fp-(2+cc).
 *
 *  Leaf frame layout (no PUSH(lr)):
 *    fp-0: saved fp
 *    fp-1 .. fp-(cc): saved callee-saved
 *    slot 0 lives at fp-(1+cc).
 */
static int slot_fp_offset(unsigned slot_id,
                          const ir_function_t *func,
                          const regalloc_t *ra)
{
    int lr_word = function_is_leaf(func) ? 0 : 1;
    int header  = lr_word + __builtin_popcount(callee_used_mask(ra));
    return -((int)slot_id + 1 + header);
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

/* Emits the function prologue: saves fp/lr/callee-saveds and allocates the frame. */
static void emit_prologue(FILE *out,
                           const ir_function_t *func,
                           const regalloc_t    *ra)
{
    unsigned n_slots = count_slots(func);
    uint16_t callee  = callee_used_mask(ra);
    int      leaf    = function_is_leaf(func);
    int      ultra   = leaf && n_slots == 0 && callee == 0
                            && func->param_count <= PHYS_ARG_REGS;

    /* Ultra-leaf fast path: no frame at all -- the body uses no
     * fp-relative addressing and the caller's lr is preserved. */
    if (ultra) {
        fprintf(out, "    ; --- Prologue (ultra-leaf: no frame) ---\n");
        return;
    }

    fprintf(out, "    ; --- Prologue%s ---\n",
            leaf ? " (leaf: skip lr save)" : "");
    fprintf(out, "    PUSH(fp) \n");
    fprintf(out, "    MOV(fp, sp) \n");
    if (!leaf)
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

    /* Load stack-passed parameters straight from the caller's frame into
     * their assigned local slots, going through t3 (regalloc-reserved).
     *
     * ABI recap: caller pushes args[N-1] .. args[3] before the CALL, so
     * after our PUSH(fp) they sit at:
     *     fp+1  → args[3]   (the first stack arg)
     *     fp+2  → args[4]
     *     ...
     * Each stack-param's local slot is allocated by ir_lower_function. */
    if (func->param_count > PHYS_ARG_REGS) {
        for (unsigned i = PHYS_ARG_REGS; i < func->param_count; i++) {
            int caller_off = (int)(i - PHYS_ARG_REGS) + 1;
            unsigned slot = ir_find_slot(func, func->param_names[i]);
            if (slot == (unsigned)-1) continue;
            int slot_off = slot_fp_offset(slot, func, ra);
            /* LW t3, fp, #caller_off */
            if (caller_off >= -8 && caller_off <= 7) {
                fprintf(out, "    LW t3, fp, #%d         ; load stack param %s\n",
                        caller_off, func->param_names[i]);
            } else {
                uint16_t u16 = (uint16_t)(int16_t)caller_off;
                fprintf(out, "    IMM #0x%03X\n", u16 >> 4);
                fprintf(out, "    LW t3, fp, #%u         ; load stack param %s\n",
                        u16 & 0xFu, func->param_names[i]);
            }
            /* SW t3, fp, #slot_off  — but SW's imm is also 4-bit signed. */
            if (slot_off >= -8 && slot_off <= 7) {
                fprintf(out, "    SW t3, fp, #%d         ; store to slot %s\n",
                        slot_off, func->param_names[i]);
            } else {
                uint16_t u16 = (uint16_t)(int16_t)slot_off;
                fprintf(out, "    IMM #0x%03X\n", u16 >> 4);
                fprintf(out, "    SW t3, fp, #%u         ; store to slot %s\n",
                        u16 & 0xFu, func->param_names[i]);
            }
        }
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
/* Emits the function epilogue: frees the frame, restores saved regs, and returns. */
static void emit_epilogue(FILE *out,
                           const ir_function_t *func,
                           const regalloc_t    *ra)
{
    uint16_t callee  = callee_used_mask(ra);
    unsigned n_slots = count_slots(func);
    int      leaf    = function_is_leaf(func);
    int      ultra   = leaf && n_slots == 0 && callee == 0
                            && func->param_count <= PHYS_ARG_REGS;

    /* Ultra-leaf fast path: no frame was set up, so the epilogue is
     * literally just RET. */
    if (ultra) {
        fprintf(out, "    ; --- Epilogue (ultra-leaf: bare RET) ---\n");
        fprintf(out, "    RET\n");
        return;
    }

    fprintf(out, "    ; --- Epilogue%s ---\n",
            leaf ? " (leaf: skip lr restore)" : "");

    /* Free local slots: walk sp up past the slot region, leaving it at
     * the lowest saved callee-saved word (or saved lr if none used). */
    if (n_slots > 0) {
        fprintf(out, "    ; Free %u local slot(s)\n", n_slots);
        emit_sp_adj(out, n_slots);
    }

    /* Restore callee-saved in reverse push order (push order is r8..r11) */
    for (int i = 3; i >= 0; i--) {
        if (callee & (1u << i))
            fprintf(out, "    POP(r%d)\n", 8 + i);
    }

    if (!leaf)
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
/* Emits a commutative two-address RR op, inserting a MOV when dst aliases neither source. */
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

/* Non-commutative: dst = a op b  (SUB, SRL, SRA) — order matters.
 *
 * When dst == b (a separate register from a), the obvious sequence
 *     MOV(dst, a) ; OP dst, b
 * clobbers b's value before the OP reads it.  Regalloc legitimately
 * recycles dst from a dead source — `r = a - b` with %v_r and %v_b in the
 * same physical register is reachable in practice.
 *
 * For SUB we rewrite via NEG (no scratch needed):
 *     dst = a − b   when dst == b   →   NEG(dst); ADD dst, a
 *
 * For SRL / SRA we save b in t3 (regalloc-reserved, never holds a live
 * vreg) before overwriting dst with a. */
/* Emits a non-commutative RR op, handling the dst==b aliasing hazard for SUB/SRL/SRA. */
static void emit_binop_rr_nc(FILE *out, const char *mnem,
                               const char *dst,
                               const char *a, const char *b)
{
    if (strcmp(dst, a) == 0) {
        fprintf(out, "    %s %s, %s\n", mnem, dst, b);
        return;
    }
    if (strcmp(dst, b) == 0) {
        if (strcmp(mnem, "SUB") == 0) {
            fprintf(out, "    NEG(%s)\n", dst);
            fprintf(out, "    ADD %s, %s\n", dst, a);
            return;
        }
        /* SRL / SRA: stash b in the regalloc-reserved scratch t3. */
        fprintf(out, "    MOV(t3, %s)\n", b);
        fprintf(out, "    MOV(%s, %s)\n", dst, a);
        fprintf(out, "    %s %s, t3\n", mnem, dst);
        return;
    }
    fprintf(out, "    MOV(%s, %s)\n", dst, a);
    fprintf(out, "    %s %s, %s\n", mnem, dst, b);
}

/*
 * OR(rd, rs) is an m4 macro that clobbers t0 (r4).
 * Constraint: rs must NOT be r4 (it would be overwritten by MOV(t0,rd)) (get/set CC).
 * We handle this by swapping if rs==r4 (OR is commutative).
 */
/* Emits a bitwise OR, working around the OR macro's t0 clobber. */
static void emit_or_rr(FILE *out,
                         const char *dst, const char *a, const char *b)
{
    const char *lhs = a, *rhs = b;

    /* (1) Commutative swap to maximise dst == lhs.
     * Without this, MOV(dst, lhs) clobbers rhs whenever dst == rhs
     * (regalloc legitimately recycles dst's register from a dead source).
     * OR is commutative, so swapping is safe. */
    if (strcmp(dst, rhs) == 0 && strcmp(dst, lhs) != 0) {
        const char *t = lhs; lhs = rhs; rhs = t;
    }

    /* (2) Special case: dst == t0.
     * The OR(rd, rs) macro expands to
     *     MOV(t0, rd); AND t0, rs; XOR rd, rs; XOR rd, t0
     * When rd IS t0 the saved copy and the working copy alias each other;
     * the final XOR rd, t0 collapses to XOR t0, t0 = 0.
     *
     * Manually expand:  dst | rhs  ≡  (dst ^ rhs) ^ (dst & rhs).
     * The scratch must differ from both dst (= t0) and rhs.  We use t3,
     * which the register allocator reserves, so it never holds a live
     * vreg's value. */
    if (strcmp(dst, "t0") == 0) {
        /* t3 is regalloc-reserved, so it never collides with a vreg color.
         * The only way rhs could already be t3 is if the caller materialised
         * an imm/global into our reserved scratch.  In that case use t1
         * with a stack save so we don't lose the materialised rhs value. */
        if (strcmp(rhs, "t3") == 0) {
            const char *scratch = "t1";
            fprintf(out, "    PUSH(%s)\n", scratch);
            if (strcmp(dst, lhs) != 0)
                fprintf(out, "    MOV(%s, %s)\n", dst, lhs);
            fprintf(out, "    MOV(%s, %s)\n",  scratch, dst);
            fprintf(out, "    AND %s, %s\n",   scratch, rhs);
            fprintf(out, "    XOR %s, %s\n",   dst,     rhs);
            fprintf(out, "    XOR %s, %s\n",   dst,     scratch);
            fprintf(out, "    POP(%s)\n", scratch);
            return;
        }
        const char *scratch = "t3";
        if (strcmp(dst, lhs) != 0)
            fprintf(out, "    MOV(%s, %s)\n", dst, lhs);
        fprintf(out, "    MOV(%s, %s)\n",  scratch, dst);
        fprintf(out, "    AND %s, %s\n",   scratch, rhs);
        fprintf(out, "    XOR %s, %s\n",   dst,     rhs);
        fprintf(out, "    XOR %s, %s\n",   dst,     scratch);
        return;
    }

    /* (3) Normal path.  OR macro's internal t0 is fine, but rhs must
     * not be t0 (the macro's MOV(t0, rd) would clobber rhs). */
    if (strcmp(rhs, "t0") == 0 && strcmp(lhs, "t0") != 0) {
        const char *t = lhs; lhs = rhs; rhs = t;
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
/* Maps an IR comparison opcode to its branch mnemonic and operand-swap flag. */
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

/* CMP + branch ladder that lands a 0/1 boolean in rd. Local labels are
 * scoped per-function to dodge collisions in the assembler's global
 * symbol table. */
static void emit_comparison(FILE *out, ir_opcode_t op,
                              const char *rd,
                              const char *ra_r, const char *rb_r,
                              const ir_function_t *func)
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
        fprintf(out, "    BEQ .cmp_false_%s_%u\n", func->name, lbl);
        fprintf(out, "    BR .cmp_done_%s_%u\n",  func->name, lbl);
        fprintf(out, ".cmp_false_%s_%u:\n",       func->name, lbl);
        fprintf(out, "    ADDI %s, r0, #0      ; equal → false\n", rd);
        fprintf(out, ".cmp_done_%s_%u:\n",        func->name, lbl);
    } else {
        fprintf(out, "    CMP %s, %s\n", cmp_a, cmp_b);
        fprintf(out, "    ADDI %s, r0, #0      ; assume false\n", rd);
        fprintf(out, "    %s .cmp_true_%s_%u\n", bmnem, func->name, lbl);
        fprintf(out, "    BR .cmp_done_%s_%u\n",        func->name, lbl);
        fprintf(out, ".cmp_true_%s_%u:\n",              func->name, lbl);
        fprintf(out, "    ADDI %s, r0, #1      ; condition true\n", rd);
        fprintf(out, ".cmp_done_%s_%u:\n",              func->name, lbl);
    }
}

/* ═══════════════════════════════════════════════════════════════════════════
 * §7  Per-instruction emitter
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Emits assembly for a single IR instruction by dispatching on its opcode. */
static void emit_instr(FILE                *out,
                        const ir_instr_t    *ins,
                        const ir_function_t *func,
                        const regalloc_t    *ra)
{
    /* Shorthand: physical name of destination vreg.
     * Source operands are no longer materialised eagerly here — each case
     * calls materialize_operand() so that immediates and global labels are
     * loaded into a chosen scratch register on demand.  The previous shorthand
     * `rs0 / rs1` produced NULL strings for non-VREG sources and led to the
     * "ADD t0, (null)" / "SW (null), t0, #0" miscompilations. */
    const char *rd = (ins->dst.kind == IR_VAL_VREG)
                     ? PREG(ins->dst) : NULL;

    switch (ins->op) {

    /* ── §7.1  Constants ─────────────────────────────────────────────── */

    case IR_OP_CONST:
        emit_load_imm(out, rd, ins->src[0].as.imm);
        break;

    /* ── §7.2  Copy / move ───────────────────────────────────────────── */

    case IR_OP_COPY: {
        /* Source may be a vreg, an immediate, or a global label.  Materialise
         * directly into rd when possible so we don't burn a separate temp. */
        const char *src = materialize_operand(out, &ins->src[0], ra, rd);
        if (strcmp(rd, src) != 0)
            fprintf(out, "    MOV(%s, %s)\n", rd, src);
        break;
    }

    /* ── §7.3  Arithmetic ────────────────────────────────────────────── */

    case IR_OP_ADD: {
        /* Imm + vreg → ADDI rd, vreg, #imm (commutative).  The IMM-prefix
         * encoding inside emit_addi_imm covers any 16-bit value. */
        if (ins->src[0].kind == IR_VAL_VREG &&
            ins->src[1].kind == IR_VAL_IMM_INT) {
            emit_addi_imm(out, rd, PREG(ins->src[0]),
                          (int)ins->src[1].as.imm);
            break;
        }
        if (ins->src[1].kind == IR_VAL_VREG &&
            ins->src[0].kind == IR_VAL_IMM_INT) {
            emit_addi_imm(out, rd, PREG(ins->src[1]),
                          (int)ins->src[0].as.imm);
            break;
        }
        const char *a = materialize_operand(out, &ins->src[0], ra,
                            pick_scratch3(rd, NULL, NULL));
        const char *b = materialize_operand(out, &ins->src[1], ra,
                            pick_scratch3(rd, a, NULL));
        emit_binop_rr(out, "ADD", rd, a, b);
        break;
    }

    case IR_OP_SUB: {
        /* vreg − imm → ADDI rd, vreg, #-imm (when the negation fits 16 bits). */
        if (ins->src[0].kind == IR_VAL_VREG &&
            ins->src[1].kind == IR_VAL_IMM_INT) {
            emit_addi_imm(out, rd, PREG(ins->src[0]),
                          -(int)ins->src[1].as.imm);
            break;
        }
        const char *a = materialize_operand(out, &ins->src[0], ra,
                            pick_scratch3(rd, NULL, NULL));
        const char *b = materialize_operand(out, &ins->src[1], ra,
                            pick_scratch3(rd, a, NULL));
        emit_binop_rr_nc(out, "SUB", rd, a, b);
        break;
    }

    case IR_OP_AND: {
        const char *a = materialize_operand(out, &ins->src[0], ra,
                            pick_scratch3(rd, NULL, NULL));
        const char *b = materialize_operand(out, &ins->src[1], ra,
                            pick_scratch3(rd, a, NULL));
        emit_binop_rr(out, "AND", rd, a, b);
        break;
    }

    case IR_OP_OR: {
        /* The OR(rd,rs) macro expands using t0 internally, so neither input
         * may live in t0 (emit_or_rr handles vreg-vs-vreg conflicts via swap;
         * here we just keep our materialised scratches off t0). */
        const char *a = materialize_operand(out, &ins->src[0], ra,
                            pick_scratch3(rd, "t0", NULL));
        const char *b = materialize_operand(out, &ins->src[1], ra,
                            pick_scratch3(rd, "t0", a));
        emit_or_rr(out, rd, a, b);
        break;
    }

    case IR_OP_XOR: {
        const char *a = materialize_operand(out, &ins->src[0], ra,
                            pick_scratch3(rd, NULL, NULL));
        const char *b = materialize_operand(out, &ins->src[1], ra,
                            pick_scratch3(rd, a, NULL));
        emit_binop_rr(out, "XOR", rd, a, b);
        break;
    }

    case IR_OP_NEG:
        /* Constant-fold immediate operands at codegen time. */
        if (ins->src[0].kind == IR_VAL_IMM_INT) {
            emit_load_imm(out, rd, -ins->src[0].as.imm);
        } else {
            const char *src = materialize_operand(out, &ins->src[0], ra,
                                  pick_scratch3(rd, NULL, NULL));
            if (strcmp(rd, src) != 0)
                fprintf(out, "    MOV(%s, %s)\n", rd, src);
            fprintf(out, "    NEG(%s)\n", rd);
        }
        break;

    case IR_OP_NOT:
        if (ins->src[0].kind == IR_VAL_IMM_INT) {
            emit_load_imm(out, rd, ~ins->src[0].as.imm);
        } else {
            const char *src = materialize_operand(out, &ins->src[0], ra,
                                  pick_scratch3(rd, NULL, NULL));
            if (strcmp(rd, src) != 0)
                fprintf(out, "    MOV(%s, %s)\n", rd, src);
            fprintf(out, "    COM(%s)\n", rd);
        }
        break;

    case IR_OP_SHL: {
        /* SLL(rd) shifts rd left by 1.  For a constant shift count N, emit N
         * SLL instructions.  For a variable shift count, emit a software loop.
         */
        const char *src0 = materialize_operand(out, &ins->src[0], ra,
                              pick_scratch3(rd, NULL, NULL));
        if (ins->src[1].kind == IR_VAL_IMM_INT) {
            long n = ins->src[1].as.imm;
            if (strcmp(rd, src0) != 0)
                fprintf(out, "    MOV(%s, %s)\n", rd, src0);
            for (long i = 0; i < n && i < 16; i++)
                fprintf(out, "    SLL(%s)\n", rd);
        } else {
            unsigned lbl = g_cmp_label++;
            if (strcmp(rd, src0) != 0)
                fprintf(out, "    MOV(%s, %s)\n", rd, src0);
            const char *src1 = materialize_operand(out, &ins->src[1], ra,
                                  pick_scratch3(rd, src0, NULL));
            const char *cnt = pick_scratch3(rd, src0, src1);
            fprintf(out, "    MOV(%s, %s)\n", cnt, src1);
            fprintf(out, "    CMP %s, r0\n", cnt);
            fprintf(out, "    BEQ .shl_done_%s_%u\n", func->name, lbl);
            fprintf(out, ".shl_loop_%s_%u:\n",        func->name, lbl);
            fprintf(out, "    SLL(%s)\n", rd);
            fprintf(out, "    ADDI %s, %s, #-1\n", cnt, cnt);
            fprintf(out, "    CMP %s, r0\n", cnt);
            fprintf(out, "    BEQ .shl_done_%s_%u\n", func->name, lbl);
            fprintf(out, "    BR .shl_loop_%s_%u\n",  func->name, lbl);
            fprintf(out, ".shl_done_%s_%u:\n",        func->name, lbl);
        }
        break;
    }

    case IR_OP_SHRU: {
        const char *a = materialize_operand(out, &ins->src[0], ra,
                            pick_scratch3(rd, NULL, NULL));
        const char *b = materialize_operand(out, &ins->src[1], ra,
                            pick_scratch3(rd, a, NULL));
        emit_binop_rr_nc(out, "SRL", rd, a, b);
        break;
    }

    case IR_OP_SHRS: {
        const char *a = materialize_operand(out, &ins->src[0], ra,
                            pick_scratch3(rd, NULL, NULL));
        const char *b = materialize_operand(out, &ins->src[1], ra,
                            pick_scratch3(rd, a, NULL));
        emit_binop_rr_nc(out, "SRA", rd, a, b);
        break;
    }

    /* ── §7.4  Memory ────────────────────────────────────────────────── */

    /*
     * ADDR_OF %slotN → ADDI rd, fp, #-(N+1)
     * ADDR_OF @global → LI(rd, global_label)  [resolved by linker / assembler]
     */
    case IR_OP_ADDR_OF:
        if (ins->src[0].kind == IR_VAL_SLOT) {
            int off = slot_fp_offset(ins->src[0].as.slot, func, ra);
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
        const char *ptr = materialize_operand(out, &ins->src[0], ra,
                             pick_scratch3(rd, NULL, NULL));
        const char *op = (ins->dst.type.kind == IR_TYPE_I8) ? "LB" : "LW";
        fprintf(out, "    %s %s, %s, #0\n", op, rd, ptr);
        break;
    }

    /*
     * STORE *%ptr = %val
     * src[0] = ptr register, src[1] = value register.
     * Use SW (word) or SB (byte).
     */
    case IR_OP_STORE: {
        const char *ptr = materialize_operand(out, &ins->src[0], ra,
                             pick_scratch3(NULL, NULL, NULL));
        const char *val = materialize_operand(out, &ins->src[1], ra,
                             pick_scratch3(ptr, NULL, NULL));
        const char *op  = (ins->src[1].type.kind == IR_TYPE_I8) ? "SB" : "SW";
        fprintf(out, "    %s %s, %s, #0\n", op, val, ptr);
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
        long width = IR_GEP_WIDTH(ins);
        const char *base = materialize_operand(out, &ins->src[0], ra,
                              pick_scratch3(rd, NULL, NULL));
        const char *idx  = materialize_operand(out, &ins->src[1], ra,
                              pick_scratch3(rd, base, NULL));
        if (width == 1) {
            emit_binop_rr(out, "ADD", rd, base, idx);
        } else if (width == 2 || width == 4) {
            int shifts = (width == 2) ? 1 : 2;
            /* Compute idx * width in rd (may clobber rd if rd ≠ idx). */
            if (strcmp(rd, idx) != 0)
                fprintf(out, "    MOV(%s, %s)\n", rd, idx);
            for (int i = 0; i < shifts; i++)
                fprintf(out, "    SLL(%s)\n", rd);
            fprintf(out, "    ADD %s, %s\n", rd, base);
        } else {
            /* General case: rd = base + idx * width via __mul helper.
             *
             * The CALL clobbers all caller-saved registers, so `base` (which
             * we must add after the multiply) cannot stay in t0..t3 / a0..a2
             * across the call.  Spill it to the stack, do the call, reload
             * into a scratch, and add. */
            fprintf(out, "    PUSH(%s)                ; save base across __mul\n",
                    base);
            /* Load width into a1 directly (avoids needing a separate scratch). */
            if (strcmp(idx, "a1") == 0) {
                /* idx and width target collide: stage idx into a0 first. */
                fprintf(out, "    MOV(a0, a1)\n");
                emit_load_imm(out, "a1", width);
            } else {
                if (strcmp(idx, "a0") != 0)
                    fprintf(out, "    MOV(a0, %s)\n", idx);
                emit_load_imm(out, "a1", width);
            }
            fprintf(out, "    CALL(__mul)             ; a0 = idx * width\n");
            /* Reload base into a free temp.  a0 now holds the product, so
             * pick anything else; t0 is fine after the call (it was
             * caller-saved). */
            fprintf(out, "    POP(t0)                 ; reload base\n");
            fprintf(out, "    ADD a0, t0\n");
            if (strcmp(rd, "a0") != 0)
                fprintf(out, "    MOV(%s, a0)\n", rd);
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
        /* Constant-fold immediate sources: just load the masked value. */
        if (ins->src[0].kind == IR_VAL_IMM_INT) {
            long v = ins->src[0].as.imm;
            if (ins->src[0].type.kind == IR_TYPE_I1)      v &= 0x1;
            else if (ins->src[0].type.kind == IR_TYPE_I8) v &= 0xFF;
            emit_load_imm(out, rd, v);
            break;
        }
        {
            const char *src = materialize_operand(out, &ins->src[0], ra,
                                  pick_scratch3(rd, NULL, NULL));
            if (strcmp(rd, src) != 0)
                fprintf(out, "    MOV(%s, %s)\n", rd, src);
        }
        if (ins->src[0].type.kind == IR_TYPE_I1) {
            fprintf(out, "    ANDI %s, #1\n", rd);
        } else if (ins->src[0].type.kind == IR_TYPE_I8) {
            /* Zero-extend byte: AND with 0x00FF.  Pick a scratch that is
             * not the destination so the mask load doesn't clobber rd. */
            const char *scratch = pick_scratch3(rd, NULL, NULL);
            fprintf(out, "    IMM #0x00F\n");
            fprintf(out, "    ADDI %s, r0, #0xF       ; %s = 0x00FF (byte mask)\n",
                    scratch, scratch);
            fprintf(out, "    AND %s, %s              ; zero-extend byte\n",
                    rd, scratch);
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
        /* Constant-fold immediate sources by sign-extending at codegen time. */
        if (ins->src[0].kind == IR_VAL_IMM_INT) {
            long v = ins->src[0].as.imm;
            if (ins->src[0].type.kind == IR_TYPE_I1) {
                v = (v & 1) ? -1L : 0L;
            } else if (ins->src[0].type.kind == IR_TYPE_I8) {
                v &= 0xFF;
                if (v & 0x80) v |= ~0xFFL;
            }
            emit_load_imm(out, rd, v);
            break;
        }
        {
            const char *src = materialize_operand(out, &ins->src[0], ra,
                                  pick_scratch3(rd, NULL, NULL));
            if (strcmp(rd, src) != 0)
                fprintf(out, "    MOV(%s, %s)\n", rd, src);
        }
        if (ins->src[0].type.kind == IR_TYPE_I8) {
            /* Shift left 8 then arithmetic-right 8 to sign-extend.
             * Pick a shift-count register that is NOT the destination —
             * otherwise the ADDI overwrites the byte-to-extend before the
             * SLL loop has a chance to shift it. */
            const char *cnt = pick_scratch3(rd, NULL, NULL);
            fprintf(out, "    ADDI %s, r0, #8         ; shift count = 8\n", cnt);
            for (int i = 0; i < 8; i++) fprintf(out, "    SLL(%s)\n", rd);
            fprintf(out, "    SRA %s, %s              ; sign-extend (SRA by 8)\n",
                    rd, cnt);
        } else if (ins->src[0].type.kind == IR_TYPE_I1) {
            /* i1 sign-extend: 0→0, 1→-1 (0xFFFF). */
            fprintf(out, "    NEG(%s)                 ; i1 sign-extend: 1→-1\n", rd);
        }
        break;

    case IR_OP_TRUNC:
    case IR_OP_BITCAST: {
        /* Truncation / reinterpretation: the physical register already holds
         * the value, so for VREG sources we only need a MOV when rd ≠ src.
         * Immediate / global sources materialise straight into rd. */
        const char *src = materialize_operand(out, &ins->src[0], ra, rd);
        if (strcmp(rd, src) != 0)
            fprintf(out, "    MOV(%s, %s)\n", rd, src);
        break;
    }

    /* ── §7.6  Comparisons ────────────────────────────────────────────── */

    case IR_OP_EQ: case IR_OP_NEQ:
    case IR_OP_LTS: case IR_OP_LES: case IR_OP_GTS: case IR_OP_GES:
    case IR_OP_LTU: case IR_OP_LEU: case IR_OP_GTU: case IR_OP_GEU: {
        const char *a = materialize_operand(out, &ins->src[0], ra,
                            pick_scratch3(rd, NULL, NULL));
        const char *b = materialize_operand(out, &ins->src[1], ra,
                            pick_scratch3(rd, a, NULL));
        emit_comparison(out, ins->op, rd, a, b, func);
        break;
    }

    /* ── §7.7  Terminators ────────────────────────────────────────────── */

    /*
     * GOTO bbN → unconditional branch.
     * The assembler resolves the label; displacement computed as
     *   (label_addr − branch_addr) / 2.
     */
    case IR_OP_GOTO: {
        unsigned tgt = (ins->src[0].kind == IR_VAL_LABEL)
                       ? ins->src[0].as.block_id
                       : IR_BRANCH_TRUE(ins);
        char lbl[128];
        fmt_block_label(lbl, sizeof lbl, func, tgt);
        fprintf(out, "    BR %s\n", lbl);
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
    case IR_OP_BRANCH: {
        const char *pred = materialize_operand(out, &ins->src[0], ra,
                              pick_scratch3(NULL, NULL, NULL));
        char lblF[128], lblT[128];
        fmt_block_label(lblF, sizeof lblF, func, IR_BRANCH_FALSE(ins));
        fmt_block_label(lblT, sizeof lblT, func, IR_BRANCH_TRUE(ins));
        fprintf(out, "    CMP %s, r0\n", pred);
        fprintf(out, "    BEQ %s\n", lblF);
        fprintf(out, "    BR  %s\n", lblT);
        break;
    }

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
        const char *val = materialize_operand(out, &ins->src[0], ra,
                             pick_scratch3(NULL, NULL, NULL));
        const char *scratch = pick_scratch3(val, NULL, NULL);
        for (unsigned k = 0; k < IR_SWITCH_CASE_COUNT(ins); k++) {
            long cv = ins->as.sw.case_values[k]; /* direct: address-of array; opcode asserted above */
            /* Compare val against the case constant. */
            if (cv >= 0 && cv <= 15) {
                /* RCMPI computes imm − rd; Z is set iff rd == imm. */
                fprintf(out, "    RCMPI %s, #%ld\n", val, cv);
            } else {
                emit_load_imm(out, scratch, cv);
                fprintf(out, "    CMP %s, %s\n", val, scratch);
            }
            char lblK[128];
            fmt_block_label(lblK, sizeof lblK, func, ins->as.sw.case_blocks[k]);
            fprintf(out, "    BEQ %s\n", lblK);
        }
        char lblD[128];
        fmt_block_label(lblD, sizeof lblD, func, IR_SWITCH_DEFAULT(ins));
        fprintf(out, "    BR  %s             ; default\n", lblD);
        break;
    }

    /*
     * RET void  → epilogue (no value move needed)
     * RET %v    → ensure return value is in a0 (= r1), then epilogue.
     *
     * The strcmp uses the ABI mnemonic "a0" because phys_name() emits
     * mnemonics; comparing against the canonical "r1" would always differ
     * and produce a self-MOV.
     */
    case IR_OP_RET:
        switch (ins->src[0].kind) {
        case IR_VAL_VREG: {
            const char *rv = PREG(ins->src[0]);
            if (strcmp(rv, "a0") != 0)
                fprintf(out, "    MOV(a0, %s)\n", rv);
            break;
        }
        case IR_VAL_IMM_INT:
            emit_load_imm(out, "a0", ins->src[0].as.imm);
            break;
        case IR_VAL_GLOBAL:
            fprintf(out, "    LI(a0, %s)\n", ins->src[0].as.name);
            break;
        default:
            /* void return: no value to place in a0 */
            break;
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
	    unsigned nargs  = IR_CALL_ARG_COUNT(ins);
	    unsigned nreg   = (nargs < PHYS_ARG_REGS) ? nargs : PHYS_ARG_REGS;
	    unsigned nstack = nargs - nreg;

	    /* Argument-register names use ABI mnemonics so the strcmps below
	     * match phys_name() output (otherwise every MOV looks redundant
	     * but still gets emitted as a no-op self-move). */
	    static const char *arg_regs[] = {"a0", "a1", "a2"};

	    /* Pick a scratch register for materialising imm / global stack
	     * args.  It must not be the home of any VREG argument (register
	     * or stack), otherwise materialising one arg would clobber the
	     * source of another.  Without this, calls like
	     *     f5(1, 2, 3, p, 5)
	     * where p lives in t0 misbehave: emitting "LI t0, #5" overwrites
	     * p before the PUSH that is supposed to read it. */
	    uint16_t arg_homes_mask = 0;
	    for (unsigned i = 0; i < nargs; i++) {
		const ir_value_t *a = &ins->as.call.args[i]; /* direct: address-of array element; opcode asserted via IR_CALL_ARG_COUNT above */
		if (a->kind == IR_VAL_VREG) {
		    phys_reg_t c = ra->color[a->as.vreg];
		    if (c < 16) arg_homes_mask |= (uint16_t)(1u << c);
		}
	    }
	    static const struct { phys_reg_t p; const char *n; } t_pool[] = {
		{ PHYS_R4, "t0" }, { PHYS_R5, "t1" },
		{ PHYS_R6, "t2" }, { PHYS_R7, "t3" }
	    };
	    const char *stack_scratch = "t0";
	    for (unsigned i = 0; i < 4; i++) {
		if (!(arg_homes_mask & (1u << t_pool[i].p))) {
		    stack_scratch = t_pool[i].n;
		    break;
		}
	    }

	    /* ── 1. stack arguments (write FIRST so register loads can't
	     *      clobber a stack-arg vreg's source) ─────── */
	    if (nstack > 0) {
		/* Allocate the stack-arg slots in one shot. */
		emit_sp_adj(out, -(int)nstack);

		/* Per ABI: leftmost stack arg at lowest address.
		 *   args[PHYS_ARG_REGS + i]  →  sp + i */
		for (unsigned i = 0; i < nstack; i++) {
		    const ir_value_t *a = &ins->as.call.args[PHYS_ARG_REGS + i];
		    switch (a->kind) {
		    case IR_VAL_VREG:
			fprintf(out, "    SW %s, sp, #%u\n", PREG(*a), i);
			break;
		    case IR_VAL_IMM_INT:
			emit_load_imm(out, stack_scratch, a->as.imm);
			fprintf(out, "    SW %s, sp, #%u\n", stack_scratch, i);
			break;
		    case IR_VAL_GLOBAL:
			fprintf(out, "    LI(%s, %s)\n",
				stack_scratch, a->as.name);
			fprintf(out, "    SW %s, sp, #%u\n", stack_scratch, i);
			break;
		    default:
			fprintf(out,
				"    ; [CALL] unsupported stack arg %d\n",
				a->kind);
			break;
		    }
		}
	    }

	    /* ── 2. register arguments (a0..a2) ───────────
	     *
	     * Naive sequential MOVs are unsafe when arg sources form a cycle
	     * across the destination registers — e.g. `g(b, a)` with `a` in
	     * a0 and `b` in a1 needs to swap the two registers, not just
	     * "MOV a0, a1; MOV a1, a0" (which leaves both holding a1's value).
	     *
	     * We solve it as a parallel-copy:
	     *   1. Emit any VREG copy whose dst is not the SRC of another
	     *      pending VREG copy (Kahn-style topological order).
	     *   2. Repeat until either nothing pending or only cycles remain.
	     *   3. Break each remaining cycle by spilling one source into t3
	     *      (regalloc-reserved scratch), redirecting the cycle's reads
	     *      to t3, and re-running phase 1.
	     *   4. Imm/global args run last so they don't clobber any vreg
	     *      source register before it is read. */
	    typedef struct {
		const char *dst;
		const char *src;          /* VREG home; updated to "t3" if cycle */
		int         kind;         /* mirrors ir_value_kind_t */
		long        imm;
		const char *gname;
		int         done;
	    } arg_copy_t;

	    arg_copy_t cps[3];
	    unsigned cn = 0;
	    for (unsigned i = 0; i < nreg; i++) {
		const ir_value_t *a = &ins->as.call.args[i]; /* direct: address-of array element; opcode asserted via IR_CALL_ARG_COUNT above */
		arg_copy_t *c = &cps[cn++];
		c->dst   = arg_regs[i];
		c->kind  = (int)a->kind;
		c->done  = 0;
		c->src   = NULL;
		c->gname = NULL;
		c->imm   = 0;
		switch (a->kind) {
		case IR_VAL_VREG:
		    c->src = PREG(*a);
		    if (strcmp(c->dst, c->src) == 0) c->done = 1; /* no-op */
		    break;
		case IR_VAL_IMM_INT:
		    c->imm = a->as.imm;
		    break;
		case IR_VAL_GLOBAL:
		    c->gname = a->as.name;
		    break;
		default:
		    fprintf(out, "    ; [CALL] unsupported arg kind %d\n",
			    a->kind);
		    c->done = 1;
		    break;
		}
	    }

	    /* Phase 1+2: VREG copies in topological order, breaking cycles
	     * via t3 (regalloc-reserved). */
	    int progress = 1;
	    while (progress) {
		progress = 0;
		/* Drain everything that can be safely emitted right now. */
		int drained = 1;
		while (drained) {
		    drained = 0;
		    for (unsigned i = 0; i < cn; i++) {
			arg_copy_t *c = &cps[i];
			if (c->done || c->kind != IR_VAL_VREG) continue;
			int blocked = 0;
			for (unsigned j = 0; j < cn && !blocked; j++) {
			    if (i == j) continue;
			    arg_copy_t *o = &cps[j];
			    if (o->done || o->kind != IR_VAL_VREG) continue;
			    if (strcmp(o->src, c->dst) == 0) blocked = 1;
			}
			if (!blocked) {
			    fprintf(out, "    MOV(%s, %s)\n", c->dst, c->src);
			    c->done = 1;
			    drained = 1;
			    progress = 1;
			}
		    }
		}
		/* If anything remains, the survivors form one or more cycles.
		 * Break the next cycle by spilling its current src into t3. */
		for (unsigned i = 0; i < cn; i++) {
		    arg_copy_t *c = &cps[i];
		    if (c->done || c->kind != IR_VAL_VREG) continue;
		    fprintf(out, "    MOV(t3, %s)        ; break cycle\n",
			    c->src);
		    /* Any other pending copy reading c->src must now read t3. */
		    const char *old_src = c->src;
		    for (unsigned j = 0; j < cn; j++) {
			arg_copy_t *o = &cps[j];
			if (o->done || o->kind != IR_VAL_VREG) continue;
			if (strcmp(o->src, old_src) == 0) o->src = "t3";
		    }
		    progress = 1;
		    break; /* re-run phase 1 */
		}
	    }

	    /* Phase 3: imm / global. */
	    for (unsigned i = 0; i < cn; i++) {
		arg_copy_t *c = &cps[i];
		if (c->done) continue;
		if (c->kind == IR_VAL_IMM_INT)
		    emit_load_imm(out, c->dst, c->imm);
		else if (c->kind == IR_VAL_GLOBAL)
		    fprintf(out, "    LI(%s, %s)\n", c->dst, c->gname);
	    }

	    /* ── 3. call ──────────────────────────────── */
	    fprintf(out, "    CALL(%s)\n", IR_CALL_CALLEE(ins));

	    /* ── 4. stack cleanup ─────────────────────── */
	    if (nstack > 0)
		emit_sp_adj(out, (int)nstack);

	    /* ── 5. return value ───────────────────────── */
	    if (!IR_CALL_IS_VOID(ins) &&
		ins->dst.kind == IR_VAL_VREG) {

		const char *dst = PREG(ins->dst);
		if (strcmp(dst, "a0") != 0)
		    fprintf(out, "    MOV(%s, a0)\n", dst);
	    }

	    break;
	}

	    default:
		fprintf(out, "    ; [CODEGEN] unhandled IR opcode %d "
		             "(arithmetic helpers MUL/DIVS/DIVU/MODS/MODU are rewritten "
		             "to IR_OP_CALL at lowering — see ir_lower_expr.c)\n",
		             (int)ins->op);
		break;
    }
}

/* ═══════════════════════════════════════════════════════════════════════════
 * §8  Block and function emitters
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Emits a comment listing each frame slot's fp-relative offset. */
static void emit_slot_comment(FILE *out, const ir_function_t *func, const regalloc_t *ra)
{
    fprintf(out, "    ; Frame slots (fp-based):\n");
    for (const ir_slot_entry_t *s = func->slots; s; s = s->next) {
        int off = slot_fp_offset(s->slot_id, func, ra);
        fprintf(out, "    ;   %%slot%u (%s) @ fp%+d\n",
                s->slot_id, s->name, off);
    }
}

/* Emits a labelled basic block and its instruction stream. */
static void emit_block(FILE                *out,
                        const ir_block_t    *block,
                        const ir_function_t *func,
                        const regalloc_t    *ra)
{
    char lbl[128];
    fmt_block_label(lbl, sizeof lbl, func, block->id);
    fprintf(out, "%s:\n", lbl);
    for (const ir_instr_t *ins = block->head; ins; ins = ins->next)
        emit_instr(out, ins, func, ra);
    fprintf(out, "\n");
}

/* ═══════════════════════════════════════════════════════════════════════════
 * §8.5  Branch relaxation
 *
 * B* displacements encode a signed 8-bit instruction count (±127). Long
 * functions can produce branches that overflow it. We emit the function
 * with short branches, scan the buffer, and rewrite any branch beyond
 * threshold into a J(label) trampoline. Iterate until stable.
 *
 *   unconditional   BR target  ->  J(target)
 *   conditional     Bcc target ->  Bcc .Lrelax_take_<func>_K
 *                                  BR  .Lrelax_skip_<func>_K
 *                                  .Lrelax_take_<func>_K:
 *                                  J(target)
 *                                  .Lrelax_skip_<func>_K:
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Below the hard ±127 limit; leaves margin for shifts from other relaxations
 * in the same iteration. */
#define BRANCH_RELAX_THRESHOLD 120

/* Expansion size, in physical instructions, of every macro the codegen
 * actually emits. Kept aligned with abi.m4. */
static unsigned macro_size_instr(const char *name, size_t len)
{
    if (len == 3 && memcmp(name, "MOV", 3) == 0) return 1;
    if (len == 3 && memcmp(name, "NEG", 3) == 0) return 1;
    if (len == 3 && memcmp(name, "SLL", 3) == 0) return 1;
    if (len == 3 && memcmp(name, "RET", 3) == 0) return 1;
    if (len == 3 && memcmp(name, "LEA", 3) == 0) return 1;
    if (len == 4 && memcmp(name, "SUBI", 4) == 0) return 1;
    if (len == 4 && memcmp(name, "PUSH", 4) == 0) return 2;
    if (len == 3 && memcmp(name, "POP",  3) == 0) return 2;
    if (len == 2 && memcmp(name, "LI",   2) == 0) return 2;
    if (len == 4 && memcmp(name, "CALL", 4) == 0) return 2;
    if (len == 1 && name[0] == 'J')               return 2;
    if (len == 3 && memcmp(name, "COM",  3) == 0) return 2;
    if (len == 2 && memcmp(name, "OR",   2) == 0) return 4;
    if (len == 3 && memcmp(name, "LBS",  3) == 0) return 5;
    if (len == 7 && memcmp(name, "PUSH_CC", 7) == 0) return 3;
    if (len == 6 && memcmp(name, "POP_CC",  6) == 0) return 3;
    return 1;  /* unknown macro: treat as 1 instruction */
}

static const char *skip_ws(const char *s)
{
    while (*s == ' ' || *s == '\t') s++;
    return s;
}

/* How many physical instructions one buffer line produces (0 for blank,
 * comment, label, or .word/.byte/.org/.equ directives). */
static unsigned line_instr_count(const char *line, size_t len)
{
    const char *p = skip_ws(line);
    if (p >= line + len) return 0;
    if (*p == '\0' || *p == '\n' || *p == '\r' || *p == ';') return 0;

    /* Labels end with ':'. */
    const char *end = line + len;
    while (end > p && (end[-1] == '\n' || end[-1] == '\r' ||
                       end[-1] == ' ' || end[-1] == '\t')) end--;
    if (end > p && end[-1] == ':') return 0;

    if (*p == '.') {
        if ((len > 5 && memcmp(p, ".word", 5) == 0) ||
            (len > 5 && memcmp(p, ".byte", 5) == 0) ||
            (len > 4 && memcmp(p, ".org",  4) == 0) ||
            (len > 4 && memcmp(p, ".equ",  4) == 0))
            return 0;
    }

    /* MACRO(...) form: consume the identifier and check for '('. */
    const char *name = p;
    while ((*p >= 'A' && *p <= 'Z') || *p == '_' ||
           (*p >= '0' && *p <= '9')) p++;
    size_t name_len = (size_t)(p - name);
    p = skip_ws(p);
    if (*p == '(') return macro_size_instr(name, name_len);

    return 1;
}

/* Recognise "<ws>MNEM<ws>TARGET" branch lines. Returns 1 on match and
 * writes mnem / target slices through the out params. */
static int parse_branch_line(const char *line, size_t len,
                             const char **mnem_start, size_t *mnem_len,
                             const char **target_start, size_t *target_len)
{
    const char *p = skip_ws(line);
    const char *mnem = p;

    static const char * const branches[] = {
        "BR", "BEQ", "BC", "BV", "BLT", "BLE",
        "BLEU", "BLETU", "BLTU", NULL
    };
    size_t mnlen = 0;
    for (int i = 0; branches[i]; i++) {
        size_t bl = strlen(branches[i]);
        /* Strict `>`: mnem[bl] is the separator we test below. */
        if (len > (size_t)(mnem - line) + bl &&
            memcmp(mnem, branches[i], bl) == 0 &&
            (mnem[bl] == ' ' || mnem[bl] == '\t')) {
            mnlen = bl;
            break;
        }
    }
    if (mnlen == 0) return 0;

    const char *t = skip_ws(mnem + mnlen);
    const char *tstart = t;
    if (*t == '#') return 0;   /* numeric displacement, not a label */
    while (*t && *t != ' ' && *t != '\t' && *t != '\n' &&
           *t != '\r' && *t != ';') t++;
    size_t tlen = (size_t)(t - tstart);
    if (tlen == 0) return 0;

    *mnem_start   = mnem;
    *mnem_len     = mnlen;
    *target_start = tstart;
    *target_len   = tlen;
    return 1;
}

/* Recognise a "NAME:" label-definition line; writes name slice on match. */
static int parse_label_line(const char *line, size_t len,
                            const char **name_start, size_t *name_len)
{
    const char *p = skip_ws(line);
    if (p >= line + len) return 0;
    if (*p == ';' || *p == '\n' || *p == '\r') return 0;

    const char *end = line + len;
    while (end > p && (end[-1] == '\n' || end[-1] == '\r' ||
                       end[-1] == ' ' || end[-1] == '\t')) end--;
    if (end <= p || end[-1] != ':') return 0;

    *name_start = p;
    *name_len   = (size_t)((end - 1) - p);
    return 1;
}

/* One relaxation iteration. Returns 1 if any branch was rewritten (caller
 * loops until 0). On rewrite, *bufp is replaced with a fresh allocation;
 * the old buffer is freed. *next_relax_id supplies unique trampoline-label
 * counters across iterations; func_name scopes them across functions. */
static int relax_branches_once(char **bufp, unsigned *next_relax_id,
                               const char *func_name)
{
    char *buf = *bufp;
    if (!buf) return 0;
    size_t buflen = strlen(buf);

    /* --- Pass 1: catalogue labels and branch sites. ----------------------- */
    typedef struct { size_t name_off, name_len; unsigned instr_idx; } label_t;
    typedef struct {
        size_t mnem_off, mnem_len;
        size_t target_off, target_len;
        size_t line_start, line_end;
        unsigned instr_idx;
    } branch_t;

    /* Cap = newlines + 1; at most one label OR one branch per line. */
    size_t max_lines = 1;
    for (size_t i = 0; i < buflen; i++) if (buf[i] == '\n') max_lines++;

    label_t  *labels   = malloc(sizeof(*labels)   * max_lines);
    branch_t *branches = malloc(sizeof(*branches) * max_lines);
    if (!labels || !branches) {
        free(labels); free(branches);
        return 0;
    }
    size_t n_labels = 0, n_branches = 0;

    unsigned instr_idx = 0;
    size_t line_start = 0;
    for (size_t i = 0; i <= buflen; i++) {
        if (i != buflen && buf[i] != '\n') continue;
        size_t line_end = (i < buflen) ? i + 1 : i;
        size_t llen = line_end - line_start;
        const char *line = buf + line_start;

        const char *lname; size_t lname_len;
        if (parse_label_line(line, llen, &lname, &lname_len)) {
            labels[n_labels].name_off  = (size_t)(lname - buf);
            labels[n_labels].name_len  = lname_len;
            labels[n_labels].instr_idx = instr_idx;
            n_labels++;
        }

        const char *mn; size_t mnlen;
        const char *tg; size_t tglen;
        if (parse_branch_line(line, llen, &mn, &mnlen, &tg, &tglen)) {
            branches[n_branches].mnem_off   = (size_t)(mn - buf);
            branches[n_branches].mnem_len   = mnlen;
            branches[n_branches].target_off = (size_t)(tg - buf);
            branches[n_branches].target_len = tglen;
            branches[n_branches].line_start = line_start;
            branches[n_branches].line_end   = line_end;
            branches[n_branches].instr_idx  = instr_idx;
            n_branches++;
        }

        instr_idx += line_instr_count(line, llen);
        line_start = line_end;
    }

    /* --- Pass 2: mark branches whose target is out of short-form range. -- */
    char *flags = calloc(n_branches, 1);
    if (!flags) { free(labels); free(branches); return 0; }

    int any_relax = 0;
    for (size_t b = 0; b < n_branches; b++) {
        const char *t = buf + branches[b].target_off;
        size_t tl = branches[b].target_len;
        unsigned target_idx = (unsigned)-1;
        for (size_t l = 0; l < n_labels; l++) {
            if (labels[l].name_len == tl &&
                memcmp(buf + labels[l].name_off, t, tl) == 0) {
                target_idx = labels[l].instr_idx;
                break;
            }
        }
        /* External symbol (resolved by the assembler at link time): skip. */
        if (target_idx == (unsigned)-1) continue;

        long delta = (long)target_idx - (long)branches[b].instr_idx;
        if (delta >  BRANCH_RELAX_THRESHOLD ||
            delta < -BRANCH_RELAX_THRESHOLD) {
            flags[b] = 1;
            any_relax = 1;
        }
    }

    if (!any_relax) {
        free(labels); free(branches); free(flags);
        return 0;
    }

    /* --- Pass 3: emit a new buffer, expanding the marked branches. -------- */
    /* Each relax adds up to ~256 chars (5 lines). Pad by the branch count. */
    size_t new_cap = buflen + n_branches * 256 + 64;
    char *nbuf = malloc(new_cap);
    if (!nbuf) {
        free(labels); free(branches); free(flags);
        return 0;
    }
    size_t nlen = 0;

    size_t cursor = 0;
    for (size_t b = 0; b < n_branches; b++) {
        if (!flags[b]) continue;

        /* Copy the unchanged region up to (but not including) this branch. */
        size_t copy = branches[b].line_start - cursor;
        memcpy(nbuf + nlen, buf + cursor, copy);
        nlen += copy;
        cursor = branches[b].line_end;

        /* Null-terminate mnemonic and target for the printf below. */
        char mnemz[16]  = {0};
        char targz[256] = {0};
        size_t mn = branches[b].mnem_len;
        size_t tn = branches[b].target_len;
        if (mn >= sizeof(mnemz)) mn = sizeof(mnemz) - 1;
        if (tn >= sizeof(targz)) tn = sizeof(targz) - 1;
        memcpy(mnemz, buf + branches[b].mnem_off, mn);
        memcpy(targz, buf + branches[b].target_off, tn);

        int n;
        if (mnemz[0] == 'B' && mnemz[1] == 'R' && mnemz[2] == '\0') {
            n = snprintf(nbuf + nlen, new_cap - nlen,
                         "    J(%s)             ; relaxed long BR\n", targz);
            if (n < 0) goto fail;
            nlen += (size_t)n;
        } else {
            unsigned k = (*next_relax_id)++;
            n = snprintf(nbuf + nlen, new_cap - nlen,
                         "    %s .Lrelax_take_%s_%u   ; relaxed long %s\n"
                         "    BR .Lrelax_skip_%s_%u\n"
                         ".Lrelax_take_%s_%u:\n"
                         "    J(%s)\n"
                         ".Lrelax_skip_%s_%u:\n",
                         mnemz, func_name, k, mnemz,
                         func_name, k,
                         func_name, k, targz,
                         func_name, k);
            if (n < 0) goto fail;
            nlen += (size_t)n;
        }
    }
    memcpy(nbuf + nlen, buf + cursor, buflen - cursor);
    nlen += buflen - cursor;
    nbuf[nlen] = '\0';

    free(*bufp);
    *bufp = nbuf;

    free(labels); free(branches); free(flags);
    return 1;

fail:
    free(nbuf);
    free(labels); free(branches); free(flags);
    return 0;
}

/* ═══════════════════════════════════════════════════════════════════════════
 * §9  Public API
 * ═══════════════════════════════════════════════════════════════════════════ */

/* Emits a complete function: label, prologue, blocks (epilogues are inlined
 * at each RET). Goes through a memstream so the branch-relaxation pass (§8.5)
 * can rewrite out-of-range B* into J(label) trampolines before the text
 * reaches `out`. */
void codegen_emit_function(FILE                *out,
                            const ir_function_t *func,
                            const regalloc_t    *ra)
{
    g_cmp_label = 0;

    char *buf = NULL;
    size_t bufsize = 0;
    FILE *mem = open_memstream(&buf, &bufsize);
    if (!mem) {
        /* No relaxation possible — assembler will flag any overlong branch. */
        fprintf(out, "%s:\n", func->name);
        emit_slot_comment(out, func, ra);
        fprintf(out, "\n");
        emit_prologue(out, func, ra);
        for (const ir_block_t *b = func->entry; b; b = b->next)
            emit_block(out, b, func, ra);
        return;
    }

    fprintf(mem, "%s:\n", func->name);
    emit_slot_comment(mem, func, ra);
    fprintf(mem, "\n");
    emit_prologue(mem, func, ra);
    for (const ir_block_t *b = func->entry; b; b = b->next)
        emit_block(mem, b, func, ra);
    fclose(mem);

    /* Relaxation is monotonic (a branch can only go from short to long), so
     * the loop is bounded by the branch count. 16 caps the worst case. */
    unsigned relax_id = 0;
    for (int iter = 0; iter < 16; iter++) {
        if (!relax_branches_once(&buf, &relax_id, func->name)) break;
    }

    fputs(buf, out);
    free(buf);
}

/* Emits a whole module: header banner, global data section, then function text. */
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
                continue;
            }
            fprintf(out, "%s:\n", g->name);
            /* Storage in 16-bit words.  ir_global_t.size_words is set by
             * lowering to handle structs/unions whose IR type drops layout
             * info; for plain scalars/arrays it equals ir_type_size_words. */
            size_t words = g->size_words;
            if (words == 0) words = 1;
            switch (g->init_kind) {
            case IR_GINIT_INT: {
                /* 16-bit machine — mask to one word, two's-complement. */
                uint16_t w = (uint16_t)(int16_t)g->init_int;
                fprintf(out, "    .word 0x%04X         ; global @%s = %ld\n",
                        w, g->name, g->init_int);
                /* Pad remaining words for arrays. */
                for (size_t i = 1; i < words; i++)
                    fprintf(out, "    .word 0x0000\n");
                break;
            }
            case IR_GINIT_STRING: {
                /* The IR holds the body of the literal exactly as it appeared
                 * in source, minus the surrounding quotes.  Embedded escape
                 * sequences (\n, \t, \\, \", ...) are passed through to the
                 * assembler, which interprets them per .asciz conventions.
                 * The trailing NUL is implicit per .asciz semantics. */
                fprintf(out, "    .asciz \"%s\"          ; global @%s (string literal)\n",
                        g->init_string, g->name);
                break;
            }
            case IR_GINIT_LABEL:
                /* Pointer initialiser: store the address of another global.
                 * Relies on the assembler/linker resolving the label as a
                 * 16-bit word value. */
                fprintf(out, "    .word %s         ; global @%s = &%s\n",
                        g->init_label, g->name, g->init_label);
                break;
            case IR_GINIT_NONE:
            default:
                fprintf(out, "    .word 0x0000         ; global @%s (%zu word%s)\n",
                        g->name, words, words == 1 ? "" : "s");
                for (size_t i = 1; i < words; i++)
                    fprintf(out, "    .word 0x0000\n");
                break;
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
