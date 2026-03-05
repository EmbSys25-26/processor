
    .org 0x0100
reset:
    
    ;PRESCALER CONFIG (Offset 1 -> 0x8802)
    IMM   #000
    ADDI  a0, zero, #8    ; 0 to 8
    IMM   #0x440
    SW    a0, zero, #1    

    ;RELOAD CONFIG (Offset 2 -> 0x8804)
    
    IMM   #000
    ADDI  a0, zero, #4
    IMM   #0x440
    SW    a0, zero, #2    ; 4 to 0

    ; Enable WDT with Reset mode (Offset 0 -> 0x8800)
    ADDI  a0, zero, #3  ; Bit 0=1 (WDT Enable), Bit 1=1 (Reset Enable), Bit 2=0 (Interrupt Disable)
    IMM   #0x440
    SW    a0, zero, #0  
    
main_loop:
    NOP
    BR    main_loop
    
    
    
