#ifndef CODEGEN_H
#define CODEGEN_H

/*
 * codegen.h — Stage 6: Assembly Code Generation
 *
 * Translates the post-regalloc IR (with physical registers assigned) into
 * assembly for the custom 16-bit RISC ISA.
 *
 *
 * Frame layout (fp = r12, grows downward by word):
 *
 *   ┌─────────────────┐  ← sp on entry
 *   │   saved lr      │  ← after PUSH(lr)
 *   │   saved fp      │  ← after PUSH(fp)   ← fp after MOV(fp,sp)
 *   │   slot 0        │  ← fp − 1
 *   │   slot 1        │  ← fp − 2
 *   │      …          │
 *   │   slot n−1      │  ← fp − n           ← sp after allocation
 *   └─────────────────┘
 *
 */

#include <stdio.h>
#include "../IR/ir.h"       /* ir_module_t, ir_function_t, ir_instr_t … */
#include "RegAlloc/regalloc.h"       /* regalloc_t, phys_reg_t, PHYS_*, REGALLOC_SPILL */
#include "RegAlloc/precolor.h"       /* precolor_t (needed only if passed to helpers) */

/* ─── module-level entry point ───────────────────────────────────────────── */

/*
 * Emit assembly for every function in the module.
 *
 * @param out     Output file (e.g. fopen("out.asm", "w")).
 * @param module  Fully-lowered IR module.
 * @param allocs  Array of regalloc_t*, one per function in module->functions
 *                (same order, NULL-terminated sentinel not needed — the
 *                 function list length determines how many are consumed).
 */
void codegen_emit_module(FILE               *out,
                         const ir_module_t  *module,
                         const regalloc_t  **allocs);

/* ─── per-function entry point ───────────────────────────────────────────── */

/*
 * Emit assembly for a single function.
 * Includes prologue, all basic blocks, and epilogue-on-ret.
 */
void codegen_emit_function(FILE                *out,
                            const ir_function_t *func,
                            const regalloc_t    *ra);

#endif /* CODEGEN_H */
