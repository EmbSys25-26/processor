# ABI Specification (Current Project Contract)

_Last reviewed: 2026-02-07_

### Scope
- This ABI is the software contract between:
  - handwritten assembly,
  - future compiler output,
  - interrupt handlers,
  - and current RTL behavior.
- Primary sources:
  - `tools/abi.inc`
  - `docs/report/docs.tex` (ABI/interrupt sections)
  - RTL behavior in `m_cpu.v`, `m_ctrl_unit.v`, `m_datapath.v`, `m_irq_ctrl.v`.

## 1. Register Allocation

### General note
- Register width: 16-bit.
- `r0` is hardwired zero in the register file (`writes ignored`).

### Register roles
- `r0`  (`zero`): ALWAYS ZERO, NOT WRITABLE.
- `r1`  (`a0`/`v0`): arg0 / return value 0.
- `r2`  (`a1`/`v1`): arg1 / optional return value 1.
- `r3`  (`a2`): arg2.
- `r4`  (`t0`): caller-saved temporary.
- `r5`  (`t1`): caller-saved temporary.
- `r6`  (`t2`): caller-saved temporary.
- `r7`  (`t3`): caller-saved temporary.
- `r8`  (`s0`): callee-saved.
- `r9`  (`s1`): callee-saved.
- `r10` (`s2`): callee-saved.
- `r11` (`s3`): callee-saved.
- `r12` (`fp`): frame pointer (callee-saved by convention).
- `r13` (`sp`): stack pointer.
- `r14` (`lr`): link/return address register.
- `r15` (`gp`): global pointer (reserved for data model growth).

### Save/restore responsibility
- Caller-saved: `a0-a2`, `t0-t3`, condition flags (see section 6).
- Callee-saved: `s0-s3`, `fp`, `sp`, `lr`.

## 2. Function Call Convention

### Arguments and return
- Up to 3 integer/pointer arguments in `a0`, `a1`, `a2`.
- Primary return in `a0` (`v0`).
- Optional second return in `a1` (`v1`) if needed by software convention.

### CALL/RET encoding intent
- `CALL target` macro in `abi.inc`:
  - `IMM target>>4`
  - `JAL lr, r0, target&0xF`
- `RET` macro:
  - `JAL r0, lr, #0`

### Leaf function rule
- May use caller-saved registers without stack frame.
- Must preserve callee-saved regs if touched.

### Non-leaf function rule
- Must preserve `lr` before nested calls.
- Must preserve any used callee-saved regs.

## 3. Stack Model

### Growth and addressing
- Full-descending stack.
- `PUSH reg` macro:
  - `ADDI sp, sp, #-2`
  - `SW reg, sp, #0`
- `POP reg` macro:
  - `LW reg, sp, #0`
  - `ADDI sp, sp, #2`
- Stack pointer (`sp`) is a byte address and should be kept word-aligned (even).

### Initial SP convention
- For a 1 KiB RAM mapped at byte addresses `0x0000 - 0x03FF`, a common convention is:
  - initialize `sp = 0x0400` (one-past-end, word-aligned),
  - first `PUSH` stores at `0x03FE`.
- Recommended stack region for a 128-word stack is byte range `0x0300 - 0x03FF` (256 bytes).

### Alignment
- Project docs recommend 8-byte alignment at ABI boundaries for compiler readiness.
- Current macros operate in word steps; alignment discipline is software-managed.

## 4. Control-Flow and Return Semantics

### JAL class
- Base ISA uses `JAL rd, rs, imm4`.
- Architecturally used for:
  - function call,
  - absolute/relative jumps (with `IMM` prefix for wide targets),
  - returns via `lr`.

### Branch class
- Branches are PC-relative by word displacement (assembler computes from byte label addresses).
- Supported condition mnemonics in assembler: `BR`, `BEQ`, `BC`, `BV`, `BLT`, `BLE`, `BLTU`, `BLEU`.

## 5. Interrupt ABI Contract

### Entry
- On interrupt take (`irq_take=1`), CPU hardware:
  - saves pre-interrupt PC into `lr` path,
  - redirects PC to `irq_vector`,
  - clears global interrupt enable latch.

### Exit
- Software must clear/ack source-specific interrupt condition.
- Software returns using the project-defined interrupt return sequence (see caveat below).
  - RTL detects interrupt-return only for a specific encoding (`16'h00E0`), so ISR epilogues must use the standardized `IRET` macro in `abi.inc`.

### Nesting
- IRQ controller supports nesting depth up to 2 levels.
- Higher-priority IRQ may preempt lower-priority IRQ when enabled.

## 6. Flags/PSW ABI Extension

### Why
- Interrupts are asynchronous, so ALU flag state can be corrupted if not preserved.

### State model
- CPU tracks `Z, N, C, V` plus carry latch used by `ADC/SBC` sequencing.
- `GETCC rd`: exports packed PSW bits to GPR.
- `SETCC rs`: restores flags/carry from GPR lower bits.

### ABI rule
- Condition flags are caller-saved.
- ISR prologue/epilogue should preserve flags explicitly:
  - save: `GETCC t0; PUSH t0`
  - restore: `POP t0; SETCC t0`

## 7. CLI/STI and Critical Sections

### Intent
- `CLI`: clear global interrupt enable.
- `STI`: set global interrupt enable.

### ABI-safe ISR pattern
- Prologue: `CLI`, save context/flags.
- Body: optionally `STI` to allow preemption.
- Epilogue: `CLI`, restore context/flags, final return.

## 8. ABI Macros Defined in `tools/abi.inc`

### Core utility
- `PUSH`, `POP`, `MOV`, `SUBI`, `NEG`, `COM`, `OR`, `SLL`, `LEA`, `J`, `CALL`, `RET`, `LBS`, `LI`.

### Interrupt helpers
- `PUSH_CC`, `POP_CC`, `ISR_PROLOGUE`, `ISR_EPILOGUE`, `ISR_PRO`, `IRET`.

## 9. ABI Caveats in Current RTL/Tooling (Important for Refactor)

- `iret_detected` in CPU control checks exact instruction word `16'h00E0`
  - This corresponds to `JAL r0, r14, #0`.
  - ABI `IRET` macro emits this encoding (standardized).

- Include path expectation in assembler
  - `.include` is resolved relative to the including file directory.
  - There is currently no automatic fallback search into `tools/`; use explicit relative includes (for example, `.include "../tools/abi.inc"` from `assembly/input.asm`).

- Address-generation caveat in current RTL
  - Datapath currently computes `d_ad = (sum << 1)` for load/store/MMIO.
  - SoC byte operations use `d_ad[1]` for lane selection.
  - Existing assembly code accounts for this with pre-shift constants for MMIO and data references.

## 10. ABI Requirements for Compiler Backend (Subset-C Target)

For the planned compiler backend, emitted code should guarantee:
- argument mapping to `a0-a2` before calls,
- return in `a0` (optional `a1` for pair returns),
- callee-saved restoration for any touched `s*`, `fp`, `lr`,
- full-descending stack usage (`sp` updates in bytes, preserving word alignment),
- explicit flags save/restore around call boundaries only when needed,
- ISR codegen (if supported) must follow CLI/STI + GETCC/SETCC discipline.
