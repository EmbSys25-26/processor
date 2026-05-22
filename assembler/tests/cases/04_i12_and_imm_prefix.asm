; ============================================================
; 04_i12_and_imm_prefix — exercise IMM prefix with explicit imm,
; full LI macro flow, and the JAL pair produced by CALL/J.
; ============================================================
.org 0x0000
IMM #0x000      ; 0x8000
IMM #0xFFF      ; 0x8FFF
IMM #0x123      ; 0x8123

; LI(r1, 0x1234) -> IMM #0x123 ; ADDI r1, r0, #4
LI(r1, 0x1234)  ; 0x8123 0x1104
LI(r2, 0x000F)  ; 0x8000 0x120F

; Full CALL macro to numeric address 0x050:
;   IMM #0x005 ; JAL lr(r14), r0, #0
CALL(0x0050)    ; 0x8005 0x0E00

; J(0x100) -> IMM #0x010 ; JAL r0, r0, #0
J(0x0100)       ; 0x8010 0x0000
