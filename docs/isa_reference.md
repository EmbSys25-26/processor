# ISA Reference (Current RTL/Assembler Contract)

_Last reviewed: 2026-02-07_

## 1. Word size and register model
- Instruction width: 16 bits.
- Register file: 16 general-purpose registers (`r0..r15`).
- `r0` is constant zero (writes ignored).

## 2. Instruction field formats

JAL / ADDI / MEM class
- `[15:12]=op`, `[11:8]=rd`, `[7:4]=rs`, `[3:0]=imm4`

RR ALU class
- `[15:12]=0x2`, `[11:8]=rd`, `[7:4]=rs`, `[3:0]=fn`

RI ALU class
- `[15:12]=0x3`, `[11:8]=rd`, `[7:4]=fn`, `[3:0]=imm4`

IMM prefix class
- `[15:12]=0x8`, `[11:0]=imm12`

### Branch class
- `[15:12]=0x9`, `[11:8]=cond`, `[7:0]=disp8`

SYS class
- `[15:12]=0xA`, `[11:8]=rd`, `[7:4]=rs`, `[3:0]=fn`

## 3. Opcode map
- `0x0` JAL
- `0x1` ADDI
- `0x2` RR ALU
- `0x3` RI ALU
- `0x4` LW
- `0x5` LB
- `0x6` SW
- `0x7` SB
- `0x8` IMM
- `0x9` BR class
- `0xA` SYS (`GETCC`, `SETCC`)
- `0xB` CLI
- `0xC` STI
- `0xF` NOP

## 4. Function code map (`fn`) for ALU/SYS

### RR/RI ALU fn map
- `0x0` ADD
- `0x1` SUB
- `0x2` AND
- `0x3` XOR
- `0x4` ADC
- `0x5` SBC
- `0x6` CMP
- `0x7` SRL
- `0x8` SRA

### SYS fn map
- `0x9` GETCC
- `0xA` SETCC

### RI-only assembler mnemonics map to fn
- `RSUBI` -> fn=1
- `ANDI`  -> fn=2
- `XORI`  -> fn=3
- `ADCI`  -> fn=4
- `RSCBI` -> fn=5
- `RCMPI` -> fn=6

## 5. Branch conditions

### Assembler mnemonic -> cond nibble
- `BR`   -> 0x0
- `BEQ`  -> 0x2
- `BC`   -> 0x4
- `BV`   -> 0x6
- `BLT`  -> 0x8
- `BLE`  -> 0xA
- `BLTU` -> 0xC
- `BLEU` -> 0xE

### Note
- RTL branch logic supports inversion through low cond bit (`cond[0]`), but assembler currently emits the even encodings above.

## 6. Immediate and prefix behavior
- `IMM` stores upper 12 bits for next immediate-using instruction.
- Next instruction consumes combined immediate as:
  - upper bits from `IMM.i12`
  - lower nibble from current instruction `imm4`
- Without prefix, the RTL derives `imm16` from `imm4` as a signed nibble (-8..+7) sign-extended to 16 bits.
- Practical rule of thumb:
  - use `IMM` when you need a full 16-bit constant/address.
  - otherwise `imm4` behaves like a small signed offset/constant.

## 7. Flag/PSW model
- CPU maintains flags: Z, N, C, V.
- Additional carry latch is tracked for ADC/SBC interlock behavior.
- `GETCC` exports packed low PSW bits into a GPR.
- `SETCC` restores those bits from a GPR.

## 8. Interrupt-related instructions
- `CLI`: clear global interrupt enable latch.
- `STI`: set global interrupt enable latch.
- Hardware interrupt entry stores link/return PC into `lr` path and vectors PC.

## 9. Address generation note
- Instruction addresses (`i_ad`) are byte addresses (PC increments by 2 per instruction).
- Current datapath computes `d_ad = (sum << 1)` (`srcs/m_datapath.v`).
  - Effective addresses issued by the CPU are even-byte-aligned.
- SoC byte-lane behavior for core-generated `LB/SB` uses `d_ad[1]`:
  - `d_ad[1]=0` selects high byte
  - `d_ad[1]=1` selects low byte
- `LB` returns zero-extended selected byte data.

## 10. Canonical pseudo-instructions (via ABI macros)
- `CALL target` -> `IMM + JAL lr,r0,imm4`
- `RET` -> `JAL r0,lr,#0`
- `LI rd,imm16` -> `IMM + ADDI`
- `PUSH/POP` -> `ADDI` + `SW/LW`

## 11. Interrupt return convention caveat
- RTL `iret_detected` checks exact instruction `16'h00E0`.
- ABI `IRET` macro is expected to emit exactly this encoding so wrapper/controller depth return signaling triggers reliably.
