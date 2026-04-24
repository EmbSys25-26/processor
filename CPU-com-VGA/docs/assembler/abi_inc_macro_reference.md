# ABI Macro Reference (`tools/abi.inc`)

_Last reviewed: 2026-02-07_

### Purpose
- Central macro/pseudo-op layer used by assembly programs.
- Encodes calling convention helpers, stack helpers, and ISR helpers.

### Register alias constants (`.equ`)
- Args/returns: `a0/v0=r1`, `a1/v1=r2`, `a2=r3`
- Caller-saved temps: `t0=r4`, `t1=r5`, `t2=r6`, `t3=r7`
- Callee-saved: `s0=r8`, `s1=r9`, `s2=r10`, `s3=r11`
- Pointers/link: `fp=r12`, `sp=r13`, `lr=r14`, `gp=r15`

### Macro Catalog

### Stack and movement
- `PUSH reg`
  - `ADDI sp, sp, #-2`
  - `SW reg, sp, #0`
  - Clobbers: `sp`

- `POP reg`
  - `LW reg, sp, #0`
  - `ADDI sp, sp, #2`
  - Clobbers: `sp`, destination reg

- `MOV rd, rs`
  - `ADDI rd, rs, #0`

### Arithmetic/logical helpers
- `SUBI rd, rs, imm`
  - `ADDI rd, rs, #-imm`

- `NEG rd`
  - `RSUBI rd, #0`

- `COM rd`
  - `IMM #0xFFF`
  - `XORI rd, #-1`

- `OR rd, rs`
  - `MOV t0, rd`
  - `AND t0, rs`
  - `XOR rd, rs`
  - `XOR rd, t0`
  - Clobbers: `t0`

- `SLL rd`
  - `ADD rd, rd`

### Address/control helpers
- `LEA rd, rs, imm`
  - `ADDI rd, rs, imm`

- `J target`
  - `IMM target >> 4`
  - `JAL r0, r0, target & 0xF`

- `CALL target`
  - `IMM target >> 4`
  - `JAL lr, r0, target & 0xF`
  - Clobbers: `lr`

- `RET`
  - `JAL r0, lr, #0`

### Load/byte helper
- `LBS rd, rs, imm`
  - `LB rd, rs, imm`
  - `IMM #0x008`
  - `ADDI t0, r0, #0`
  - `XOR rd, t0`
  - `SUB rd, t0`
  - Clobbers: `t0`

### Immediate load helper
- `LI rd, imm16`
  - `IMM imm >> 4`
  - `ADDI rd, zero, imm & 0xF`

### Flags helpers
- `PUSH_CC`
  - `GETCC t0`
  - `PUSH t0`
  - Clobbers: `t0`, `sp`

- `POP_CC`
  - `POP t0`
  - `SETCC t0`
  - Clobbers: `t0`, `sp`

### ISR helper groups
- `ISR_PROLOGUE`
  - Pushes `s0`, `s1`, `s2`, `s3`, `fp`, `sp`
  - Clobbers: `sp`

- `ISR_EPILOGUE`
  - Pops `sp`, `fp`, `s3`, `s2`, `s1`, `s0`
  - `JAL r0, lr, #0` (IRET encoding)
  - Clobbers: popped regs, `sp`

- `ISR_PRO`
  - `PUSH lr`
  - `PUSH_CC`
  - `STI`
  - Clobbers: `sp`, `t0`, `lr`

- `IRET`
  - `POP_CC`
  - `POP lr`
  - `JAL r0, lr, #0` (must match RTL iret_detected = `16'h00E0`)
  - Clobbers: `sp`, `t0`, `lr`

### Macro usage guidance for refactor
- Keep `abi.inc` as single source of truth for call/stack policy.
- Compiler backend should either:
  1. emit canonical macro-supported instruction sequences, or
  2. emit raw ISA while preserving this exact register-save contract.
- If interrupt return encoding changes in RTL, update `IRET`/`RET` macros and checklist docs together.
