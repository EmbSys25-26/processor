// ==========================================
// TESTE 1: VALIDAÇÃO EXAUSTIVA DO PARSER
// ==========================================
.org 0x0000

// 1. Diretivas e Constantes
CONST_VAL .equ 15 
MASK      .equ 0xFF

START:
    // 2. Instruções FIXED (Sem operandos)
    CLI
    STI
    NOP

    // 3. Formato RRI (3 operandos: Reg, Reg, Imm/Label)
    ADDI R1, R0, #0
    ADDI R2, R0, CONST_VAL
    LW   R3, R1, #4
    LB   R4, R1, #8
    SW   R3, R1, #12
    SB   R4, R1, #16
    JAL  R31, R0, FWD_LABEL   // Salto para a frente (Forward reference)

    // 4. Formato RR (2 operandos: Reg, Reg)
    ADD  R1, R2
    SUB  R3, R1
    AND  R1, R2
    XOR  R3, R1
    ADC  R1, R2
    SBC  R3, R1
    CMP  R1, R2
    SRL  R1, R2
    SRA  R3, R1

    // 4.1. Formato RR Especiais (GETCC e SETCC só recebem 1 registo)
    GETCC R5
    SETCC R5

    // 5. Formato RI (2 operandos: Reg, Imm/Label)
    RSUBI R1, #20
    ANDI  R2, MASK
    XORI  R3, #0x0F
    ADCI  R1, #5
    RSBCI R2, #1
    RCMPI R3, #10

    // 6. Formato I12 (1 operando: Imm/Label de 12 bits)
    IMM 0xABC

    // 7. Formato BR (Branches)
    BEQ  FWD_LABEL
    BC   FWD_LABEL
    BV   FWD_LABEL
    BLT  FWD_LABEL
    BLE  FWD_LABEL
    BLETU FWD_LABEL
    BLEU FWD_LABEL
    BR   START               // Salto para trás (Backward reference)

FWD_LABEL:
    NOP

    // 8. Diretivas de Memória
    .byte 255
    .word 0xDEAD
