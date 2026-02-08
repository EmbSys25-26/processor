# ISA <-> ABI <-> Assembler Checklist

_Last reviewed: 2026-02-07_

### Purpose
- Map the implemented ISA (RTL) to ABI conventions and assembler support.
- Use this checklist during refactor to keep software/hardware contracts aligned.

### Legend
- [x] implemented/used
- [ ] not implemented or not currently used

## A. Opcode-Class Coverage (Top Nibble `insn[15:12]`)

[ x ] op=0x0 JAL
- RTL decode: yes (`JAL` macro in control/datapath)
- Assembler mnemonic: `JAL`
- ABI/macros use it: yes (`CALL`, `RET`, `J`, interrupt-return conventions)

[ x ] op=0x1 ADDI
- RTL decode: yes
- Assembler mnemonic: `ADDI`
- ABI/macros use it: yes (`MOV`, `SUBI`, `LEA`, `LI`, stack updates)

[ x ] op=0x2 RR ALU
- RTL decode: yes
- Assembler mnemonics: `ADD SUB AND XOR ADC SBC CMP SRL SRA`
- ABI/macros use it: yes (`OR`, `SLL`, arithmetic helpers)

[ x ] op=0x3 RI ALU
- RTL decode: yes
- Assembler mnemonics: `RSUBI ANDI XORI ADCI RSCBI RCMPI`
- ABI/macros use it: yes (`NEG`, `COM`, software tests)

[ x ] op=0x4 LW
- RTL decode: yes
- Assembler mnemonic: `LW`
- ABI/macros use it: yes (`POP`, peripheral reads)

[ x ] op=0x5 LB
- RTL decode: yes
- Assembler mnemonic: `LB`
- ABI/macros use it: yes (`LBS` macro)

[ x ] op=0x6 SW
- RTL decode: yes
- Assembler mnemonic: `SW`
- ABI/macros use it: yes (`PUSH`, peripheral writes)

[ x ] op=0x7 SB
- RTL decode: yes
- Assembler mnemonic: `SB`
- ABI/macros use it: no direct default macro use

[ x ] op=0x8 IMM (prefix)
- RTL decode: yes (`imm_pre` / `i12_pre` path)
- Assembler mnemonic: `IMM`
- ABI/macros use it: yes (`CALL`, `J`, `LI`, `COM`, constant/address formation)

[ x ] op=0x9 Bx (conditional branch class)
- RTL decode: yes
- Assembler mnemonics: `BR BEQ BC BV BLT BLE BLTU BLEU`
- ABI/macros use it: yes (control flow in software ISR stubs and loops)

[ x ] op=0xA SYS
- RTL decode: yes (`GETCC` fn=9, `SETCC` fn=10)
- Assembler mnemonics: `GETCC`, `SETCC`
- ABI/macros use it: yes (`PUSH_CC`, `POP_CC`, ISR helpers)

[ x ] op=0xB CLI
- RTL decode: yes
- Assembler mnemonic: `CLI`
- ABI/macros use it: expected in ISR-safe templates (docs); macro wrappers may omit in current sample macros

[ x ] op=0xC STI
- RTL decode: yes
- Assembler mnemonic: `STI`
- ABI/macros use it: yes (`ISR_PRO`)

[ ] op=0xD reserved
- RTL decode: no current instruction class
- Assembler mnemonic: none

[ ] op=0xE reserved
- RTL decode: no current instruction class
- Assembler mnemonic: none

[ x ] op=0xF NOP
- RTL decode: yes
- Assembler mnemonic: `NOP`
- ABI/macros use it: padding and branch-annul safety path

## B. Branch Condition Map (Assembler -> cond nibble)

[ x ] BR   -> cond=0x0
[ x ] BEQ  -> cond=0x2
[ x ] BC   -> cond=0x4
[ x ] BV   -> cond=0x6
[ x ] BLT  -> cond=0x8
[ x ] BLE  -> cond=0xA
[ x ] BLTU -> cond=0xC
[ x ] BLEU -> cond=0xE

### Note
- RTL supports inversion through `cond[0]` behavior, but assembler currently exposes only even-condition mnemonics above.

## C. ABI Macro Coverage Against Assembler

### Stack/call
[ x ] PUSH uses `ADDI` + `SW`
[ x ] POP uses `LW` + `ADDI`
[ x ] CALL uses `IMM` + `JAL`
[ x ] RET uses `JAL`
[ x ] LI uses `IMM` + `ADDI`

### ALU helpers
[ x ] MOV uses `ADDI`
[ x ] SUBI uses `ADDI`
[ x ] NEG uses `RSUBI`
[ x ] COM uses `IMM` + `XORI`
[ x ] OR uses `MOV` + `AND` + `XOR`
[ x ] SLL uses `ADD`
[ x ] LEA uses `ADDI`
[ x ] LBS uses `LB` + `IMM` + `ADDI` + `XOR` + `SUB`

### ISR/flags
[ x ] PUSH_CC uses `GETCC` + `PUSH`
[ x ] POP_CC uses `POP` + `SETCC`
[ x ] ISR_PRO uses `PUSH` + `PUSH_CC` + `STI`
[ x ] IRET uses `POP_CC` + `POP` + `JAL r0,lr,#0` (canonical IRET encoding)

## D. ABI/RTL Contract Risk Checks

[ x ] `IRET` macro encoding matches hardware `iret_detected`
- Current status: standardized to `0x00E0` (`JAL r0,r14,#0`).

[ ] Sample source include layout is build-clean by default without explicit paths
- Current status: assembler resolves includes only relative to the including file; explicit relative paths are required.

[ x ] UART status register addressing reachable through CPU path
- Current status: UART status is word-aligned at `0x8302` (bus passes `addr[1:0]` to `uart_mmio`).

[ x ] LB/SB byte-lane behavior matches intended byte-address model
- Current status: datapath emits `d_ad = (sum << 1)` and SoC uses `d_ad[1]` as byte-lane select for core-generated `LB/SB`; `LB` is zero-extended from selected lane.

## E. Refactor Exit Criteria (Suggested)
- [ ] All ABI macros assemble and execute under regression testbench.
- [ ] Interrupt return sequence standardized (one canonical encoding).
- [ ] Assembler include model documented and CI-tested.
- [ ] ISA matrix remains synchronized with RTL decode and assembler mnemonic map.
