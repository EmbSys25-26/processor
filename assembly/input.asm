; ============================================================
; TEST 1 — Apenas hazards (pior CPI)
;
; Hazards explorados:
;   A) load-use (LW→uso imediato)      : 1 stall cada (20 pares)
;   B) branch taken em loop             : 2 stalls por iteração
;   C) CC hazard (ADDI→BEQ sem folga)  : stall de CC (10 pares)
; ============================================================

.include "abi.inc"

    .equ MEM_BASE, 0x0200

    .org 0x0100

; ------------------------------------------------------------
; PARTE A — 20 pares load-use
; LW seguido imediatamente de instrução que usa o resultado
; ------------------------------------------------------------
    LI   t0, #MEM_BASE           ; t0 = base do array

    LW   t1, t0, #0
    ADD  t1, t1

    LW   t2, t0, #1
    ADD  t2, t2

    LW   t3, t0, #2
    ADD  t3, t3

    LW   s0, t0, #3
    ADD  s0, s0

    LW   s1, t0, #4
    ADD  s1, s1

    LW   t1, t0, #0
    ADDI t1, t1, #1

    LW   t2, t0, #1
    ADDI t2, t2, #2

    LW   t3, t0, #2
    ADDI t3, t3, #3

    LW   t1, t0, #0
    SW   t1, t0, #5

    LW   t2, t0, #1
    SW   t2, t0, #6

    LW   s0, t0, #3
    AND  s0, t1

    LW   s1, t0, #4
    XOR  s1, t2

    LW   t1, t0, #0
    SUB  t1, t2

    LW   t2, t0, #1
    ADD  t1, t2

    LW   t3, t0, #2
    ADD  t3, t1

    LW   s0, t0, #0
    ADDI s0, s0, #0xF

    LW   s1, t0, #1
    ADDI s1, s1, #0xF

    LW   t1, t0, #2
    CMP  t1, t2

    LW   t2, t0, #3
    CMP  t2, t3

    LW   t3, t0, #0
    ADD  t3, s0

; ------------------------------------------------------------
; PARTE B — loop com branch always-taken
; 14 iterações × 2 stalls = 28 stalls de branch
; ------------------------------------------------------------
    ADDI t0, zero, #0

branch_loop:
    ADDI t0, t0, #1
    ADDI t1, zero, #0xE
    CMP  t0, t1
    BEQ  branch_done
    BR   branch_loop

branch_done:

; ------------------------------------------------------------
; PARTE C — CC hazard: ADDI→BEQ/BLT sem folga (10 pares)
; ------------------------------------------------------------
    ADDI t2, zero, #0
    BEQ  cc2
    ADDI t2, t2, #1
cc2:
    ADDI t2, zero, #1
    BEQ  cc3
    ADDI t2, t2, #1
cc3:
    ADDI t2, zero, #0
    BEQ  cc4
    ADDI t2, t2, #1
cc4:
    ADDI t2, zero, #2
    BLT  cc5
    ADDI t2, t2, #1
cc5:
    ADDI t2, zero, #0
    BEQ  cc6
    ADDI t2, t2, #1
cc6:
    ADDI t2, zero, #3
    BLT  cc7
    ADDI t2, t2, #1
cc7:
    ADDI t2, zero, #0
    BEQ  cc8
    ADDI t2, t2, #1
cc8:
    ADDI t2, zero, #4
    BLT  cc9
    ADDI t2, t2, #1
cc9:
    ADDI t2, zero, #0
    BEQ  cc10
    ADDI t2, t2, #1
cc10:
    ADDI t2, zero, #5
    BLT  cc11
    ADDI t2, t2, #1
cc11:

end_loop:
    BR   end_loop
