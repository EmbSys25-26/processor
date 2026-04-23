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
    "r12", /* 12 — fp   */
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

    /* Patterns 2, 3, 4 + call_live: scan every instruction in every block.
     * We walk in the same block/instruction order as liveness.c so that
     * instr_idx corresponds correctly to liv->instr[instr_idx]. */
    unsigned instr_idx = 0;
    for (const ir_block_t *b = func->entry; b; b = b->next) {
        for (const ir_instr_t *ins = b->head; ins; ins = ins->next) {

            /* Pattern 2: ret %vX  →  %vX must leave in r1 (a0) */
            if (ins->op == IR_OP_RET && ins->src[0].kind == IR_VAL_VREG)
                p->color[ins->src[0].as.vreg] = PHYS_R1;

            if (ins->op == IR_OP_CALL) {
                /* Pattern 3: %vd = call @f(...)  →  return value lands in r1 (a0) */
                if (ins->dst.kind == IR_VAL_VREG)
                    p->color[ins->dst.as.vreg] = PHYS_R1;

                /* Pattern 4 (Caller ABI): arguments → r1, r2, r3
                 * The first PHYS_ARG_REGS arguments must be in r1/r2/r3 at
                 * the call site.  We pre-color the argument vregs now.
                 * A conflict (vreg already bound to a different physical reg)
                 * means Stage 4 must insert a COPY before the call. */
                unsigned nargs = ins->as.call.arg_count < PHYS_ARG_REGS
                                 ? ins->as.call.arg_count : PHYS_ARG_REGS;
                for (unsigned i = 0; i < nargs; i++) {
                    const ir_value_t *arg = &ins->as.call.args[i];
                    if (arg->kind != IR_VAL_VREG) continue;
                    unsigned vr      = arg->as.vreg;
                    phys_reg_t want  = (phys_reg_t)(PHYS_R1 + i);
                    phys_reg_t exist = p->color[vr];
                    if (exist == PHYS_NONE)
                        p->color[vr] = want;
                    /* If exist == want: consistent, nothing to do.
                     * If exist != want: genuine conflict — leave as-is;
                     * Stage 4 will resolve it with a copy. */
                }

                /* Caller-saved clobber: any vreg live AFTER this call
                 * that was NOT defined by the call itself is live across
                 * the call boundary.  It must not be assigned a
                 * caller-saved register (r1–r7) by Stage 4. */
                if (liv && instr_idx < liv->n_instrs) {
                    vreg_set_union_into(&p->call_live,
                                        &liv->instr[instr_idx].live_after);
                    /* Exclude the call's own return-value vreg: it is
                     * produced by the call (in r1) and does not need to
                     * survive across it. */
                    if (ins->dst.kind == IR_VAL_VREG)
                        vreg_set_remove(&p->call_live, ins->dst.as.vreg);
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
