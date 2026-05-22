; ============================================================
; 01_rr_basic — exercise every RR opcode/fn pair
; Encoding: op=2 (RR), op=10 (CC). Verifies fn map 0..A.
; ============================================================
.org 0x0000
ADD   r1, r2     ; 0x2120  op=2 rd=1 rs=2 fn=0
SUB   r3, r4     ; 0x2341
AND   r5, r6     ; 0x2562
XOR   r7, r8     ; 0x2783
ADC   r9, r10    ; 0x29A4
SBC   r11, r12   ; 0x2BC5
CMP   r1, r2     ; 0x2126
SRL   r3, r4     ; 0x2347
SRA   r5, r6     ; 0x2568
GETCC r7         ; 0xA709  op=10 rd=7 rs=0 fn=9
SETCC r8         ; 0xA08A  op=10 rd=0 rs=8 fn=10
