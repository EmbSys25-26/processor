#include <stdlib.h>
#include <string.h>
#include "precolor.h"
#include "liveness.h"

/* Indexed by physical register number (0–12). r0 entry present for safety. */
static const char *phys_name[] = {
    "r0",  /* 0 — zero, not allocatable */
    "r1",  /* 1 — a0/v0 */
    "r2",  /* 2 — a1    */
    "r3",  /* 3 — a2    */
    "r4",  /* 4 — t0    */
    "r5",  /* 5 — t1    */
    "r6",  /* 6 — t2    */
    "r7",  /* 7 — t3    */
    "r8",  /* 8 — s0    */
    "r9",  /* 9 — s1    */
    "r10", /* 10 — s2   */
    "r11", /* 11 — s3   */
};

precolor_t *precolor_build(const ir_function_t *func, const ir_liveness_t *liv)
{
    precolor_t *p = malloc(sizeof(*p));
    if (!p) return NULL;

    p->n_vregs = func->next_vreg;
    p->color   = NULL;
    vreg_set_init(&p->call_live, p->n_vregs);

    if (p->n_vregs == 0)
        return p;

    p->color = malloc(p->n_vregs * sizeof(phys_reg_t));
    if (!p->color) { free(p); return NULL; }

    for (unsigned i = 0; i < p->n_vregs; i++)
        p->color[i] = PHYS_NONE;

    /* Pattern 1: function parameters → r1, r2, r3
     * Only the first PHYS_ARG_REGS params are passed in registers (ABI).
     * Further params are passed on the stack — no precolor assigned. */
    unsigned nparams = func->param_count < PHYS_ARG_REGS
                       ? func->param_count : PHYS_ARG_REGS;
    for (unsigned i = 0; i < nparams; i++)
        p->color[i] = (phys_reg_t)(PHYS_R1 + i);  /* r1, r2, r3 */

    /* ── Pass 1: Scout — build call_live completely before any precoloring.
     *
     * A call result that is also call-live cannot be pinned to r1: r1 is
     * caller-saved and would be clobbered by the very next call.  We must
     * know the full call_live set before deciding which results to pin.
     * Walking in the same instruction order as liveness.c keeps instr_idx
     * aligned with liv->instr[]. */
    unsigned instr_idx = 0;
    for (const ir_block_t *b = func->entry; b; b = b->next) {
        for (const ir_instr_t *ins = b->head; ins; ins = ins->next) {
            if (ins->op == IR_OP_CALL && liv && instr_idx < liv->n_instrs) {
                vreg_set_union_into(&p->call_live,
                                    &liv->instr[instr_idx].live_after);
                /* The call's own result is born here, not live across it. */
                if (ins->dst.kind == IR_VAL_VREG)
                    vreg_set_remove(&p->call_live, ins->dst.as.vreg);
            }
            instr_idx++;
        }
    }

    /* ── Pass 2: Painter — apply precolor rules now that call_live is complete.
     *
     * Pattern 3 (call result) is the only rule that changes: a result vreg
     * that is in call_live is NOT pinned to r1 — the allocator will assign
     * it to a callee-saved register (r8–r11) through the call_live mechanism.
     * A result vreg that is NOT in call_live dies before any subsequent call,
     * so r1 is safe and the pin is applied as before.
     *
     * Pattern 4 cross-vreg conflict: before pinning a call-argument vreg to
     * r1/r2/r3, verify that no other vreg simultaneously live at this call
     * site is already pinned to the same register.  Two interfering vregs
     * with the same precolor would produce an incorrect coloring that neither
     * Stage 4 (which treats precolors as final) nor Stage 5 would catch.
     * live_before(call) = live_after(call) ∪ {call arguments}. */
    instr_idx = 0;
    for (const ir_block_t *b = func->entry; b; b = b->next) {
        for (const ir_instr_t *ins = b->head; ins; ins = ins->next) {

            /* Pattern 2: ret %vX  →  %vX must leave in r1 (a0) */
            if (ins->op == IR_OP_RET && ins->src[0].kind == IR_VAL_VREG)
                p->color[ins->src[0].as.vreg] = PHYS_R1;

            if (ins->op == IR_OP_CALL) {
                /* Pattern 3: %vd = call @f(...)  →  return value lands in r1.
                 * Only pin if the vreg is NOT call-live: if it must survive
                 * a subsequent call it cannot stay in r1 (caller-saved). */
                if (ins->dst.kind == IR_VAL_VREG) {
                    unsigned vr = ins->dst.as.vreg;
                    if (!vreg_set_has(&p->call_live, vr))
                        p->color[vr] = PHYS_R1;
                }

                /* Pattern 4 (Caller ABI): first PHYS_ARG_REGS arguments
                 * must be in r1/r2/r3 at the call site.
                 * Skip call-live vregs: they must survive subsequent calls in
                 * callee-saved registers; the code generator inserts the copy
                 * to r1/r2/r3 at the call boundary. */
                unsigned nargs = ins->as.call.arg_count < PHYS_ARG_REGS
                                 ? ins->as.call.arg_count : PHYS_ARG_REGS;
                for (unsigned i = 0; i < nargs; i++) {
                    const ir_value_t *arg = &ins->as.call.args[i];
                    if (arg->kind != IR_VAL_VREG) continue;
                    unsigned vr      = arg->as.vreg;
                    if (vreg_set_has(&p->call_live, vr)) continue;
                    phys_reg_t want  = (phys_reg_t)(PHYS_R1 + i);
                    phys_reg_t exist = p->color[vr];
                    if (exist == PHYS_NONE) {
                        /* Cross-vreg conflict check: is `want` already held by
                         * any vreg that is live just before this call?
                         * live_before = live_after(call) ∪ call arguments. */
                        int conflict = 0;
                        for (unsigned ov = 0; ov < p->n_vregs && !conflict; ov++) {
                            if (ov == vr || p->color[ov] != want) continue;
                            /* Check live_after of this call instruction. */
                            int live = (liv && instr_idx < liv->n_instrs) &&
                                       vreg_set_has(&liv->instr[instr_idx].live_after, ov);
                            /* Also check the call's own argument list (uses). */
                            for (unsigned j = 0; j < ins->as.call.arg_count && !live; j++) {
                                if (ins->as.call.args[j].kind == IR_VAL_VREG &&
                                    ins->as.call.args[j].as.vreg == ov)
                                    live = 1;
                            }
                            if (live) conflict = 1;
                        }
                        if (!conflict)
                            p->color[vr] = want;
                    }
                    /* exist == want: consistent.
                     * exist != want: conflict — Stage 4 resolves with a copy. */
                }
            }
            instr_idx++;
        }
    }

    return p;
}

void precolor_free(precolor_t *p)
{
    if (!p) return;
    free(p->color);
    vreg_set_free(&p->call_live);
    free(p);
}

phys_reg_t precolor_get(const precolor_t *p, unsigned vreg)
{
    if (vreg >= p->n_vregs) return PHYS_NONE;
    return p->color[vreg];
}

int precolor_is_fixed(const precolor_t *p, unsigned vreg)
{
    return precolor_get(p, vreg) != PHYS_NONE;
}

int precolor_is_call_live(const precolor_t *p, unsigned vreg)
{
    if (!p || vreg >= p->n_vregs) return 0;
    return vreg_set_has(&p->call_live, vreg);
}



/*=======================================PRiNT====================================================*/
void precolor_print(FILE *out, const char *func_name, const precolor_t *p)
{
    fprintf(out, "precolor for @%s  (%u vreg%s):\n",
            func_name, p->n_vregs, p->n_vregs == 1 ? "" : "s");
    int any = 0;
    for (unsigned v = 0; v < p->n_vregs; v++) {
        if (p->color[v] != PHYS_NONE) {
            fprintf(out, "  %%v%u → %s\n", v, phys_name[p->color[v]]);
            any = 1;
        }
    }
    if (!any)
        fprintf(out, "  (none)\n");

    fprintf(out, "  call-live vregs (must use callee-saved r8–r12): ");
    vreg_set_print(out, &p->call_live);
    fprintf(out, "\n");
}
