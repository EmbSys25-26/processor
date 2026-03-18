.include "../tools/abi.inc"

    ; ============================
    ; Constants / addresses
    ; ============================
    .equ RESET_VEC,  0x0100
    .equ STACK_TOP,  0x03FF

    ; ============================
    ; 0x0100 — reset / main
    ; ============================
    .org RESET_VEC
reset:
    LI   sp, #STACK_TOP

main:
    LI   r1, 1          ; r1 = 1        → IMM #0x000 + ADDI r1, r0, #1
    LI   r2, 3          ; r2 = 3        → IMM #0x000 + ADDI r2, r0, #3
    MOV  r3, r1         ; r3 = r1       → ADDI r3, r1, #0
    ADD  r3, r2         ; r3 = r3 + r2  → RR ADD
    SW   r1, r0, #5     ; mem[10] = r1  → byte addr = (r0+5)<<1 = 10
    LW   r4, r0, #5     ; r4 = mem[10]  → byte addr = (r0+5)<<1 = 10

main_loop:
    BR   #-1
