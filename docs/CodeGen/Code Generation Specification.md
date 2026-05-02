## Code Generator

**Input:** post-regalloc IR module + array of `regalloc_t*` (one per function, same order as `module->functions`)
**Output:** assembly text for the custom 16-bit RISC ISA, written to a `FILE*` (driver writes to `output.asm`)
**Purpose:** lower each `ir_instr_t` into ISA mnemonics, with correct frame layout and ABI conformance, after register allocation has assigned a physical register to every virtual register.
**Entry point:** `codegen_emit_module(FILE *out, const ir_module_t *module, const regalloc_t **allocs)`.

The codegen is a single pass — no peephole optimisation, no instruction selection beyond per-opcode handlers, no instruction scheduling. Correctness comes from rigorously conservative emission combined with a few targeted optimisations (`ADDI` immediate-form for ADD/SUB, `RCMPI` for SWITCH, `r0` direct-use for immediate zero).

---

### Pipeline position

```
ir_module_t (post-lowering)
        │
        ▼
register allocation (Liveness + Interference + Precolor + Chaitin-Briggs + Spill)
        │     produces regalloc_t per function
        ▼
codegen_emit_module    ← entry point
        │
        ├── module header                   (file banner)
        ├── globals  (.word / .asciz)       (one per ir_global_t)
        └── for each function:
                codegen_emit_function
                        ├── slot comment table
                        ├── emit_prologue   (frame setup + stack-param load)
                        └── emit_block * N  (label + per-instr emission)
                                  └── emit_instr (per-opcode handler)
                                        └── emit_epilogue on RET
```

---

### ISA cheatsheet

The target is a custom 16-bit RISC. All addressing is **word-indexed** — `LW r, base, #-3` reads the word at `base − 3 words`, not `base − 3 bytes`. Slot ids, frame-pointer offsets, GEP strides, and pointer arithmetic are all in 16-bit words.

| Format | Encoding | Mnemonics |
|---|---|---|
| RR  | op(4) rd(4) rs(4) fn(4) | ADD, SUB, AND, XOR, SRL, SRA, CMP, … |
| RI  | op(4) rd(4) fn(4) imm(4) | RSUBI, ANDI, XORI, … |
| RRI | op(4) rd(4) rs(4) imm(4) | ADDI, LW, LB, SW, SB, JAL |
| I12 | op(4) imm(12) | IMM (upper-12 prefix for next instruction) |
| BR  | op(4) cond(4) disp(8) | BEQ, BLT, BLE, BLEU, BLETU, BR |

Immediates in RI/RRI/BR are **4-bit** (or 8-bit for branch displacements). Wider values require an `IMM #upper12` prefix on the line before, which is OR'd into the next instruction's immediate field by the assembler.

Convenience macros (defined in the m4 ABI include and used directly by codegen output):

| Macro | Expansion | Purpose |
|---|---|---|
| `MOV(rd, rs)` | `ADDI rd, rs, #0` | Register copy |
| `PUSH(r)` | `ADDI sp, sp, #-1; SW r, sp, #0` | Push 1 word |
| `POP(r)` | `LW r, sp, #0; ADDI sp, sp, #1` | Pop 1 word |
| `NEG(rd)` | `RSUBI rd, #0` | Two's-complement negate |
| `COM(rd)` | `IMM #0xFFF; XORI rd, #0xF` | Bitwise NOT (flip all 16 bits) |
| `OR(rd, rs)` | `MOV(t0,rd); AND t0,rs; XOR rd,rs; XOR rd,t0` | Logical OR via XOR/AND identity (clobbers `t0`) |
| `SLL(rd)` | `ADD rd, rd` | Left shift by 1 |
| `LI(rd, imm)` | `IMM #(imm>>4); ADDI rd, r0, #(imm&0xF)` | 16-bit immediate load |
| `CALL(addr)` | `IMM (addr>>4); JAL lr, r0, #(addr&0xF)` | Call function |
| `RET` | `JAL r0, lr, #0` | Return via lr |

> **Branch convention footgun:** on this ISA `BLEU` is **strictly less-than unsigned**, and `BLETU` is **less-or-equal unsigned** — despite the suffix letters. This is project convention; the runtime helpers and codegen comparison ladder both rely on it. Same goes for `BLT` (strict <, signed) vs `BLE` (≤, signed). Don't change either side without updating the other.

---

### Register conventions (used in emitted text)

`phys_name()` always emits ABI mnemonics, never the canonical `rN`. All `strcmp` checks in codegen compare against the mnemonics.

| Mnemonic | Canonical | Role | Allocatable by regalloc |
|---|---|---|---|
| `r0` | `r0` | Hardwired zero | no |
| `a0` | `r1` | Arg 0 / return value | yes (caller-saved) |
| `a1` | `r2` | Arg 1 | yes (caller-saved) |
| `a2` | `r3` | Arg 2 | yes (caller-saved) |
| `t0` | `r4` | Temp | yes (caller-saved) |
| `t1` | `r5` | Temp | yes (caller-saved) |
| `t2` | `r6` | Temp | yes (caller-saved) |
| `t3` | `r7` | **Codegen scratch — reserved** | **no** |
| `s0`–`s3` | `r8`–`r11` | Saved | yes (callee-saved) |
| `fp` | `r12` | Frame pointer | no |
| `sp` | `r13` | Stack pointer | no |
| `lr` | `r14` | Link register | no |
| `gp` | `r15` | Global pointer / reserved | no |

`t3` is not in the allocator's preference list, so it is guaranteed never to hold a live virtual register. Codegen uses it as a safe scratch in four places:
1. `materialize_operand()` default — load immediates / globals into `t3` without consulting per-instruction liveness.
2. `emit_binop_rr_nc()` SRL / SRA in-place spill (when `dst == b ≠ a`, save `b` in `t3` before overwriting `dst` with `a`).
3. `emit_or_rr()` `dst == t0` special path scratch (the OR macro internally uses `t0`, so when `dst` IS `t0` the macro corrupts itself; we manually expand `dst | rhs ≡ (dst ^ rhs) ^ (dst & rhs)` using `t3` as scratch).
4. CALL register-arg parallel-copy cycle breaking (e.g. `(a0 ← a1, a1 ← a0)` is broken by `MOV(t3, a0); MOV(a0, a1); MOV(a1, t3)`).
5. Stack-passed parameter loading in the prologue: `LW t3, fp, #+i; SW t3, fp, #-slot`.

---

### Frame layout

```
                                                  ┌──────────────────┐  ← caller's sp (before CALL)
                                                  │   stack arg N-1  │
                                                  │   …              │
                                                  │   stack arg 3    │
                                                  ├──────────────────┤  ← sp at function entry
       (PUSH(fp) → MOV(fp, sp))                   │   saved fp       │  ← fp after MOV(fp, sp)
                                                  ├──────────────────┤
       (PUSH(lr))                                 │   saved lr       │  fp − 1
                                                  ├──────────────────┤
       (PUSH(s0..s3) for each callee-saved used)  │   saved s0       │  fp − 2
                                                  │   saved s1       │  fp − 3
                                                  │   …              │
                                                  ├──────────────────┤  ← sp before slot allocation
       (ADDI sp, sp, #-N for n_slots)             │   slot 0         │  fp − (2 + cc)
                                                  │   slot 1         │  fp − (3 + cc)
                                                  │   …              │
                                                  │   slot n−1       │  fp − (1 + cc + n_slots)
                                                  └──────────────────┘  ← sp after prologue
```

`cc` = `popcount(callee_used_mask)` = number of callee-saved registers actually pushed by this function.

`n_slots` = `func->next_slot_id`, which already accounts for multi-word slots (arrays and structs reserve consecutive slot ids).

Stack-passed arguments live **above fp** in the caller's frame:
- `args[3]` at `fp + 1`
- `args[4]` at `fp + 2`
- …

---

### Frame helpers

Defined in `codegen.c` §2:

| Helper | Purpose |
|---|---|
| `count_slots(func)` | Returns `func->next_slot_id` — total stack words for locals (multi-word slots already accounted for). |
| `callee_used_mask(ra)` | Scans `ra->color[]` and returns a bitmask of `r8`–`r11` actually used by any colored vreg. Drives prologue/epilogue PUSH/POP. |
| `slot_fp_offset(slot_id, ra)` | Computes `−(slot_id + 1 + 1 + popcount(callee_used_mask))` — the fp-relative word offset of slot `slot_id`. The `+ 1` accounts for saved lr; the next `+ 1 + popcount` accounts for saved fp itself plus all callee-saved registers. |

---

### Low-level emitters (§3)

| Emitter | Behaviour |
|---|---|
| `emit_addi_imm(out, rd, rs, off)` | `ADDI rd, rs, #off`. If `off` is outside `[-8, 7]` (the 4-bit signed range) emits `IMM #upper12` followed by `ADDI rd, rs, #lower4`, encoding `off` as a 16-bit two's-complement value. |
| `emit_sp_adj(out, delta)` | `delta` is in words, signed (negative = allocate). Loops emitting `ADDI sp, sp, #step` with `step` clamped to `[-8, 7]` until `delta` is consumed. Used for prologue allocation, epilogue release, and CALL stack-arg allocation/cleanup. |
| `emit_load_imm(out, rd, imm)` | Emits the cheapest sequence: `MOV(rd, r0)` for 0, `ADDI rd, r0, #imm` for 1..15, otherwise `LI(rd, 0xXXXX)`. |
| `pick_scratch3(a, b, c)` | Returns a temp from `{t3, t2, t1, t0}` that doesn't collide with the named avoids. Always tries `t3` first since it's regalloc-reserved and provably safe. |
| `materialize_operand(out, v, ra, scratch)` | If `v` is a vreg, returns its color (no instruction). For `IR_VAL_IMM_INT(0)` returns `"r0"` directly. For other immediates emits `LI` / `ADDI` into `scratch`. For `IR_VAL_GLOBAL` emits `LI(scratch, label)`. |

---

### Two-address arithmetic helpers (§5)

The ISA's RR form is two-address: `OP rd, rs` means `rd = rd OP rs`. The IR is three-address: `dst = a OP b`. The codegen bridges this in three helpers.

**`emit_binop_rr(out, mnem, dst, a, b)` — commutative (ADD / AND / XOR):**

| Case | Emits |
|---|---|
| `dst == a` | `OP dst, b` |
| `dst == b` | `OP dst, a` (commute) |
| else | `MOV(dst, a); OP dst, b` |

**`emit_binop_rr_nc(out, mnem, dst, a, b)` — non-commutative (SUB / SRL / SRA):**

| Case | Emits |
|---|---|
| `dst == a` | `OP dst, b` |
| `dst == b` for SUB | `NEG(dst); ADD dst, a` (algebraic, no scratch) |
| `dst == b` for SRL/SRA | `MOV(t3, b); MOV(dst, a); OP dst, t3` (uses reserved scratch) |
| else | `MOV(dst, a); OP dst, b` |

The `dst == b ≠ a` case is reachable in practice — regalloc legitimately recycles `dst` from a dead source. A naive `MOV(dst, a); OP dst, b` would clobber `b` before reading it.

**`emit_or_rr(out, dst, a, b)` — OR with macro-internal scratch awareness:**

The `OR(rd, rs)` macro expands to `MOV(t0, rd); AND t0, rs; XOR rd, rs; XOR rd, t0`, so it internally uses `t0`. The helper handles three constraints:

1. If `dst == rhs ≠ lhs`, swap operands (commutative).
2. If `dst == t0`, manually expand `dst | rhs = (dst ^ rhs) ^ (dst & rhs)` using `t3` as scratch (using the macro would clobber its own working register). Special sub-case: if `rhs` was materialised into `t3`, save `t1` to the stack and use `t1` as scratch instead.
3. Otherwise, if `rhs == t0` (collides with macro internal), swap; emit standard `MOV(dst, lhs); OR(dst, rhs)`.

---

### Comparison ladder (§6)

The ISA has no compare-and-set, so each IR comparison becomes:

```
CMP a, b
ADDI rd, r0, #0      ; assume false
<Bcond> .cmp_true_N  ; if condition holds
BR .cmp_done_N
.cmp_true_N:
ADDI rd, r0, #1
.cmp_done_N:
```

For `IR_OP_NEQ` the sense is inverted (assume true, branch on `BEQ` to false). `cmp_to_branch()` maps each IR opcode to the (mnemonic, swap_operands) pair:

| IR op | Mnemonic | Swap operands |
|---|---|---|
| `EQ`  | `BEQ`  | no |
| `NEQ` | `BEQ`  | yes (inverted assume-true path) |
| `LTS` | `BLT`  | no |
| `LES` | `BLE`  | no |
| `GTS` | `BLT`  | yes (`a > b` ≡ `b < a`) |
| `GES` | `BLE`  | yes |
| `LTU` | `BLEU` | no |
| `LEU` | `BLETU`| no |
| `GTU` | `BLEU` | yes |
| `GEU` | `BLETU`| yes |

Comparison operands are materialised through `materialize_operand` so immediate operands work too (the SWITCH special-case still uses `RCMPI` for case constants in `[0, 15]`).

---

### Per-opcode emission (§7)

Concise overview; full implementation in `emit_instr()`.

| IR Opcode | Strategy |
|---|---|
| `IR_OP_CONST` | `emit_load_imm(rd, imm)`. |
| `IR_OP_COPY` | `materialize_operand(src, scratch=rd)` + skip `MOV` if equal. Imm or global folds straight into `LI rd, …`. |
| `IR_OP_ADD` | One imm operand → `emit_addi_imm(rd, vreg, #imm)` (no scratch). Both vreg → `emit_binop_rr` after materialisation. |
| `IR_OP_SUB` | rhs imm → `emit_addi_imm(rd, lhs, #-imm)`. Otherwise materialise + `emit_binop_rr_nc`. |
| `IR_OP_AND` / `XOR` | Materialise + `emit_binop_rr`. |
| `IR_OP_OR` | Materialise (rhs scratch picked to avoid `t0` so the OR macro's internal scratch is free) + `emit_or_rr`. |
| `IR_OP_SHL` | imm count → unrolled `SLL(rd)` instructions. Variable count → decrement-and-branch loop with `t3` as counter. |
| `IR_OP_SHRU` / `SHRS` | Materialise + `emit_binop_rr_nc`. |
| `IR_OP_NEG` / `NOT` | Imm src → constant-fold into `LI rd, …`. Otherwise `MOV; NEG / COM`. |
| `IR_OP_ADDR_OF` | Slot → `emit_addi_imm(rd, fp, slot_fp_offset)`. Global → `LI(rd, label)`. |
| `IR_OP_LOAD` | Materialise ptr + `LW rd, ptr, #0` (or `LB` for `i8`). |
| `IR_OP_STORE` | Materialise both ptr and value + `SW val, ptr, #0` (or `SB`). |
| `IR_OP_GEP` | Width 1 → `ADD rd, base, idx`. Width 2/4 → `MOV(rd, idx); SLL(rd){,SLL(rd)}; ADD rd, base`. Other widths → `__mul` runtime call (with base saved to stack across the call). |
| `IR_OP_ZEXT` | Imm src → constant-fold (mask to `0xFF` for i8, `0x1` for i1). Vreg src → `MOV; ANDI #1` (i1) or `IMM/AND mask` (i8). |
| `IR_OP_SEXT` | Imm src → constant-fold (sign-extend at codegen). Vreg src → `MOV; SLL×8; SRA r0, count` (i8) or `NEG(rd)` (i1). |
| `IR_OP_TRUNC` / `BITCAST` | `materialize_operand(src, scratch=rd)` + skip `MOV` if equal. Imm/global folds into rd directly. |
| Comparisons | Materialise both + `emit_comparison`. |
| `IR_OP_GOTO` | `BR bbN`. |
| `IR_OP_BRANCH` | Materialise pred + `CMP pred, r0; BEQ bb_false; BR bb_true`. |
| `IR_OP_SWITCH` | Materialise val. For each case, `RCMPI val, #cv` if `cv ∈ [0, 15]` else `LI scratch, cv; CMP val, scratch`, then `BEQ bb_case`. Final `BR bb_default`. |
| `IR_OP_RET` | If src is vreg, `MOV(a0, src)` if needed. If imm, `LI(a0, …)`. If global, `LI(a0, label)`. Then `emit_epilogue`. |
| `IR_OP_CALL` | See "CALL setup" below. |

---

### CALL setup (§7.7 / `IR_OP_CALL`)

The CALL handler runs in three phases to avoid clobbering live values:

**Phase 1 — Stack arguments first.**
For calls with more than `PHYS_ARG_REGS` (= 3) args, allocate `n_stack` words via `emit_sp_adj(-n_stack)`, then for each stack arg `i` (in 0..n_stack-1), emit `SW arg_value, sp, #i`. The arg ordering matches "leftmost stack arg at lowest address" (caller's args[3] at sp+0, args[4] at sp+1, …).

For vreg args, write the vreg's color directly. For imm/global args, materialise into a scratch — but the scratch must NOT be the home of any vreg arg (register OR stack), otherwise we'd corrupt that arg's source. The scratch is picked from `t0..t3` skipping `arg_homes_mask`. With `t3` reserved by regalloc, this almost always succeeds at `t3`.

**Phase 2 — Register arguments via parallel copy.**
For args 0..2, the destination is `a0`/`a1`/`a2`. A naive `MOV(a0, src0); MOV(a1, src1); MOV(a2, src2)` is unsafe when sources form a cycle through the destinations — e.g. `(a0 ← a1, a1 ← a0)` ends with both registers holding `a1`'s original value.

The codegen runs Kahn-style topological emission:

1. Emit any vreg copy whose `dst` is not the `src` of another pending copy. Repeat until no more progress.
2. If pending copies remain, they form one or more cycles. Break the next cycle by `MOV(t3, src)`, redirect all reads of `src` to `t3`, then re-run step 1.
3. Imm/global arg loads come last so they don't clobber any vreg-source register before it's read.

**Phase 3 — Call, cleanup, return value.**
`CALL(callee)`. Then `emit_sp_adj(+n_stack)` to release stack args. If non-void, `MOV(dst_color, a0)` if dst ≠ a0.

---

### Prologue (§4)

```c
PUSH(fp)
MOV(fp, sp)
PUSH(lr)
PUSH(r8) ... PUSH(r11)         ; only those in callee_used_mask
ADDI sp, sp, #-n_slots         ; allocate locals (multi-step if > 8)

; ---- stack-passed parameter loading ----
for each param i ≥ PHYS_ARG_REGS:
    LW t3, fp, #(i - PHYS_ARG_REGS + 1)    ; load from caller's frame
    SW t3, fp, #(slot_fp_offset(slot, ra)) ; store into local slot
```

The parameter-loading step is the codegen's contract with the IR layer: the IR lowering deliberately skips emitting an `addr_of slot + store` pair for stack-passed params, because routing them through a vreg would force regalloc to model all stack-param vregs as live-in simultaneously (which the IR has no construct for). Instead, the prologue loads each one straight into its slot via `t3`.

---

### Epilogue (§4)

```c
ADDI sp, sp, #+n_slots         ; free locals
POP(r11) ... POP(r8)           ; restore callee-saved in reverse
POP(lr)
POP(fp)
RET
```

Emitted at every `IR_OP_RET`. (No special handling for falling off the end — IR lowering injects an explicit `ret void` when the last block has no terminator.)

---

### Module-level emission (§9)

```c
codegen_emit_module:
    print file header banner
    for each ir_global_t in module->globals:
        if extern, emit a comment only
        else emit "name:" + g->size_words .word entries (or .asciz for strings)
    for each ir_function_t (with its corresponding regalloc_t):
        codegen_emit_function
```

Globals use `g->size_words` (set by `ir_lower_decl.c::ir_lower_global_decl` via `compute_sem_type_words`) so structs and arrays get the right number of words. The default for plain scalars is `ir_type_size_words(g->type)`.

---

### Diagnostics

The codegen emits `; [CODEGEN] …` comment lines for unhandled cases (unknown opcodes, unsupported operand kinds). These are advisory — the surrounding instruction is skipped or partially emitted, which usually produces obviously broken assembly. Real correctness errors should be caught at the IR or semantic stage.

---

### Known limitations

1. **GEP with non-power-of-2 stride** (only reachable if a future IR change emits one) calls `__mul` and saves/reloads `base` across it. Currently the IR lowering only emits widths in `{1, 2, 4}` for arrays and `1` for member access, so this path is dormant.
2. **Spilled stack-passed params** — the codegen prologue loads them straight into the slot, so this is fine. But if a regalloc later supports spilling register-passed params, it must emit the spill AFTER the param's `STORE` to slot, not before.
3. **Parallel-copy >3 args** — the algorithm scales to any cycle size; the loop terminates because each cycle-break either drains at least one copy or reduces the cycle length by 1.
4. **`emit_binop_rr` (commutative)** assumes that `dst != a && dst != b` implies `dst` doesn't overlap with any other live vreg's home. This is true by the regalloc invariant (dst's color is unique to dst at this program point). No additional defensive code needed.
