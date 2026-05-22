; ============================================================
; 02_ri_basic — exercise every RI fn code with positive imms.
; Encoding: op=3 (RI), op<<12 | rd<<8 | fn<<4 | imm[3:0].
; ============================================================
.org 0x0000
RSUBI r1, #5    ; 0x3115
ANDI  r2, #0xA  ; 0x322A
XORI  r3, #0    ; 0x3330
ADCI  r4, #7    ; 0x3447
RSBCI r5, #1    ; 0x3551
RCMPI r6, #8    ; 0x3668
