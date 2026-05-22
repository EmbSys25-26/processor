; ============================================================
; 06_fixed_and_directives — CLI/STI/NOP fixed encodings, .org skip,
; .equ forward reference, .byte / .word value emission.
; ============================================================
.org 0x0000
CLI            ; 0xB000
STI            ; 0xC000
NOP            ; 0xF000

.word 0xDEAD   ; emits 4 bytes 00 00 DE AD at LC 0x0006 (BUG4: int32_t .word)
.byte 0xAA     ; emits 1 byte at LC 0x000A
.byte 0xBB

.org 0x0020
USE_FWD_EQU:
ANDI r1, FORWARD_VAL    ; resolved at Pass 2 from .equ below
ADDI r2, r0, FORWARD_VAL ; same, in RRI form

FORWARD_VAL .equ 7
