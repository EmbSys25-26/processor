; ============================================================
; 03_rri_mem — ADDI, JAL, LW/LB/SW/SB with positive and negative
; immediates. Verifies signed imm4 truncation to low 4 bits.
; Encoding: op<<12 | rd<<8 | rs<<4 | imm[3:0].
; ============================================================
.org 0x0000
ADDI r1, r2, #3   ; 0x1123
ADDI r3, r4, #-2  ; 0x134E  (-2 & 0xF = 0xE)
JAL  r0, r0, #0   ; 0x0000
JAL  r14, r0, #4  ; 0x0E04  rd=14 rs=0 imm=4
LW   r1, r13, #0  ; 0x41D0
LB   r2, r13, #1  ; 0x52D1
SW   r3, r13, #-1 ; 0x63DF  (-1 & 0xF = 0xF)
SB   r4, r13, #2  ; 0x74D2
