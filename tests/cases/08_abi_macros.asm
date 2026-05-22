; ============================================================
; 08_abi_macros — every m4-defined macro in abi.m4. Verifies that
; the macros lower to a stable instruction sequence.
; ============================================================
.org 0x0000

; Stack ops
PUSH(r1)        ; ADDI sp, sp, #-1 ; SW r1, sp, #0
POP(r1)         ; LW r1, sp, #0    ; ADDI sp, sp, #1

; Pseudo-instructions
MOV(r3, r2)     ; ADDI r3, r2, #0
SUBI(r4, r1, 2) ; ADDI r4, r1, #-2
NEG(r5)         ; RSUBI r5, #0
COM(r6)         ; IMM #0xFFF ; XORI r6, #-1
SLL(r7)         ; ADD r7, r7
LEA(r8, sp, 4)  ; ADDI r8, sp, #4
OR(r9, r1)      ; MOV(t0,r9); AND t0,r1; XOR r9,r1; XOR r9,t0

; Call / return / jump
RET             ; JAL r0, lr, #0
