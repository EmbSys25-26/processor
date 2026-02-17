# 🛠️ Custom Assembler

A simple assembler toolchain for a custom 16-bit RISC architecture. It uses **Flex** for lexical analysis, **M4** for macro preprocessing, and **C** for memory splitting utilities.

---

## 📁 Project Files

| File | Description |
|------|-------------|
| `assembler.l` | Flex lexer — translates assembly instructions into 16-bit hex |
| `abi.m4` | M4 macro file — defines register aliases and pseudo-instructions |
| `Makefile` | Automates the full build pipeline |
| `test.asm` | **Your input file** — write your assembly program here |
| `split_mem.c` | Splits the hex output into high and low memory files |

---

## 🚀 How to Use

### 1. Write your program

Open `test.asm` and write your assembly instructions. For example:

```asm
ADDI r1, r0, #5     ; r1 = 5
ADDI r2, r0, #3     ; r2 = 3
ADD r3, r1          ; r3 = r1 + r2
```

You can use both raw instructions and macros defined in `abi.m4`. SCROLL DOWN TO SEE WHAT INSTRUCTIONS YOU CAN USE AND HOW TO WRITE THEM IN THE .ASM FILE

### 2. Build

Simply run:

```bash
make
```

### 3. Output files generated

After `make`, the following files are created:

| File | Description |
|------|-------------|
| `program.asm` | Your program after M4 macro expansion (macros replaced by real instructions) |
| `program.hex` | Your program in 16-bit hexadecimal, one instruction per line |
| `memH.hex` | High byte of each instruction (upper 8 bits) |
| `memL.hex` | Low byte of each instruction (lower 8 bits) |

### 4. Clean up

To remove all generated files and return to the base source files:

```bash
make clean
```

After cleaning, you'll be left with only: `abi.m4`, `assembler.l`, `Makefile`, `test.asm`, and `split_mem.c`.

---

## 📋 Register Table (ABI)

| Register | Alias | Usage | Saved By |
|----------|-------|-------|----------|
| r0 | zero | Always reads 0, writes ignored | — |
| r1 | a0 / v0 | Argument 0 / Return value | Caller |
| r2 | a1 | Argument 1 | Caller |
| r3 | a2 | Argument 2 | Caller |
| r4–r7 | t0–t3 | Temporaries | Caller |
| r8–r11 | s0–s3 | Saved registers | Callee |
| r12 | fp | Frame pointer | Callee |
| r13 | sp | Stack pointer | Callee |
| r14 | lr | Link register (return address) | Callee |
| r15 | gp | Global pointer (unused currently) | — |

You can use either the register number (`r1`) or the alias (`a0`) — they are interchangeable thanks to `abi.m4`. FOLLOW THIS CONVENTIONS!!

---

## 🔧 Instruction Set

### RR Format — Register-to-Register Operations
```
Encoding: op(4) rd(4) rs(4) fn(4)
```

| Instruction | Example | Description |
|-------------|---------|-------------|
| `ADD rd, rs` | `ADD r3, r1` | rd = rd + rs |
| `SUB rd, rs` | `SUB r3, r1` | rd = rd − rs |
| `AND rd, rs` | `AND r3, r1` | rd = rd AND rs |
| `XOR rd, rs` | `XOR r3, r1` | rd = rd XOR rs |
| `ADC rd, rs` | `ADC r3, r1` | rd = rd + rs + carry |
| `SBC rd, rs` | `SBC r3, r1` | rd = rd − rs − borrow |
| `CMP rd, rs` | `CMP r3, r1` | Set flags for rd − rs (no write) |
| `SRL rd, rs` | `SRL r3, r1` | Shift rd right logical by rs |
| `SRA rd, rs` | `SRA r3, r1` | Shift rd right arithmetic by rs |
| `GETCC rd` | `GETCC r4` | Read condition codes into rd |
| `SETCC rd` | `SETCC r4` | Write condition codes from rd |

---

### RI Format — Register-Immediate Operations
```
Encoding: op(4) rd(4) fn(4) imm(4)
imm can be #0-15 (decimal number) or #0-F(hexa number)
```

| Instruction | Example | Description |
|-------------|---------|-------------|
| `RSUBI rd, #imm` | `RSUBI r1, #5` | rd = imm − rd |
| `ANDI rd, #imm` | `ANDI r1, #0xF` | rd = rd AND imm |
| `XORI rd, #imm` | `XORI r1, #3` | rd = rd XOR imm |
| `ADCI rd, #imm` | `ADCI r1, #1` | rd = rd + imm + carry |
| `RSBCI rd, #imm` | `RSBCI r1, #0` | rd = imm − rd − borrow |
| `RCMPI rd, #imm` | `RCMPI r1, #5` | Set flags for imm − rd |

---

### RRI (Memory) Format — Load/Store and Jump-and-Link
```
Encoding: op(4) rd(4) rs(4) imm(4)
imm can be #0-15 (decimal number) or #0-F(hexa number)
```

| Instruction | Example | Description |
|-------------|---------|-------------|
| `ADDI rd, rs, #imm` | `ADDI r1, r0, #5` | rd = rs + imm |
| `JAL rd, rs, #imm` | `JAL r14, r0, #0` | rd = PC+1; PC = rs + imm |
| `LW rd, rs, #imm` | `LW r1, r13, #0` | rd = Mem[rs + imm] (word) |
| `LB rd, rs, #imm` | `LB r1, r13, #0` | rd = Mem[rs + imm] (byte) |
| `SW rd, rs, #imm` | `SW r1, r13, #0` | Mem[rs + imm] = rd (word) |
| `SB rd, rs, #imm` | `SB r1, r13, #0` | Mem[rs + imm] = rd (byte) |

---

### I12 Format — 12-bit Immediate Prefix
```
Encoding: op(4) imm(12)
imm can be #0-4095 (decimal number) or #0-FFF(hexa number)
```

| Instruction | Example | Description |
|-------------|---------|-------------|
| `IMM #imm` | `IMM #0x123` | Loads upper 12 bits for the next instruction |

---

### BR Format — Conditional Branches
```
Encoding: op(4) cond(4) disp(8)
imm can be #0-255 (decimal number) or #0-FF(hexa number)
```

| Instruction | Example | Description |
|-------------|---------|-------------|
| `BR #disp` | `BR #4` | Unconditional branch (offset) |
| `BEQ #disp` | `BEQ #-2` | Branch if equal (Z=1) |
| `BC #disp` | `BC #2` | Branch if carry |
| `BV #disp` | `BV #2` | Branch if overflow |
| `BLT #disp` | `BLT #-4` | Branch if less than (signed) |
| `BLE #disp` | `BLE #-4` | Branch if less than or equal (signed) |
| `BLETU #disp` | `BLETU #-4` | Branch if less than or equal (unsigned) |
| `BLEU #disp` | `BLEU #-4` | Branch if less than (unsigned) |

---

### Fixed-Encoding Instructions
```
No operands needed — output a fixed hex word
```

| Instruction | Output | Description |
|-------------|--------|-------------|
| `CLI` | `B000` | Clear interrupt enable flag |
| `STI` | `C000` | Set interrupt enable flag |
| `NOP` | `F000` | No operation |

---

## 🧩 Macros (defined in `abi.m4`)

Macros are expanded by M4 before assembling. They generate multiple real instructions and are visible in `program.asm`.

### Stack Operations

| Macro | Expands To | Description |
|-------|-----------|-------------|
| `PUSH(reg)` | `ADDI sp, sp, #-1` + `SW reg, sp, #0` | Push register onto stack |
| `POP(reg)` | `LW reg, sp, #0` + `ADDI sp, sp, #1` | Pop register from stack |

```asm
PUSH(r1)   ; save r1
POP(r1)    ; restore r1
```

---

### Pseudo-Instructions

| Macro | Expands To | Description |
|-------|-----------|-------------|
| `MOV(rd,rs)` | `ADDI dst, src, #0` | Copy register |
| `SUBI(rd,rs,imm)` | `ADDI rd, rs, #-imm` | Subtract immediate |
| `NEG(rd)` | `RSUBI rd, #0` | Negate register |
| `COM(rd)` | `IMM #0xFFF` + `XORI rd, #-1` | Bitwise complement |
| `SLL(rd)` | `ADD rd, rd` | Shift left logical by 1 |
| `LEA(rd,rs,imm)` | `ADDI rd, rs, #imm` | Load effective address |
| `OR(rd,rs)` | `MOV(t0, rd)` + `AND t0, rs` + `XOR rd, rs` + `XOR rd, t0` | Bitwise OR |
| `LBS(rd,rs,imm)` | `LB` + sign-extend sequence | Load byte signed |

```asm
MOV(r2,r1)       ; r2 = r1
SUBI(r3,r1,4)   ; r3 = r1 - 4
NEG(r1)           ; r1 = -r1
SLL(r2)           ; r2 = r2 << 1
OR(r1,r2)        ; r1 = r1 | r2
```

---

### Jump and Call

| Macro | Expands To | Description |
|-------|-----------|-------------|
| `J(addr)` | `IMM` + `JAL r0, r0, #...` | Unconditional jump to absolute address |
| `CALL(addr)` | `IMM` + `JAL lr, r0, #...` | Call subroutine (saves return address in `lr`) |
| `RET` | `JAL r0, lr, #0` | Return from subroutine |

```asm
CALL(0x050)   ; call subroutine at address 0x050
RET           ; return from subroutine
J(0x010)      ; jump to address 0x010
```

---

### Interrupt Handling

| Macro | Description |
|-------|-------------|
| `ISR_PROLOGUE` | Saves s0–s3, fp, sp onto the stack |
| `ISR_EPILOGUE` | Restores sp, fp, s3–s0 from stack, then returns |
| `ISR_PRO` | Saves lr and condition codes, enables interrupts (STI) |
| `IRET` | Restores condition codes, restores lr, returns |
| `PUSH_CC` | Saves condition codes register (via t0) onto stack |
| `POP_CC` | Pops condition codes register from stack (via t0) |

```asm
; Full interrupt service routine:
ISR_PRO        ; save lr, CC, enable interrupts
; ... ISR body here ...
IRET           ; restore CC, lr, return
```

---

### Load Immediate (Large Values)

| Macro | Description |
|-------|-------------|
| `LI(rd, imm)` | Load a full 16-bit immediate into `rd` using `IMM` prefix + `ADDI` |

```asm
LI(r1, 0x1A3)   ; r1 = 0x1A3 (uses IMM for upper bits, ADDI for lower)
```
