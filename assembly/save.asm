    ; Deactivate TimerH int_en -- MMIO write requires input address to be (final_address >>1)
    IMM  #0x081        
    SW   r0, r0, #0    ; MEM[r0 + 0x8100] = r0 = 0
    
    LI   r1, 1          ; r1 = 1        → IMM #0x000 + ADDI r1, r0, #1
    LI   r2, 3          ; r2 = 3        → IMM #0x000 + ADDI r2, r0, #3
    MOV  r3, r1         ; r3 = r1       → ADDI r3, r1, #0
    ADD  r3, r2         ; r3 = r3 + r2  → RR ADD
    SW   r1, r0, #5     ; mem[10] = r1  → byte addr = (r0+5)<<1 = 10
    LW   r4, r0, #5     ; r4 = mem[10]  → byte addr = (r0+5)<<1 = 10  -> r4 = 1
    ADD r2, r4		; r2 = r2 + r4  → r2 = 3 + 1 = 4
    
    LI r3, 5
    LI r2, 5
    ADD r2, r1
    CMP r2, r1
    BEQ loop
