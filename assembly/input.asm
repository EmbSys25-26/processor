.include "../tools/abi.inc"

; ============================
; Constants / addresses
; ============================
    .equ INTR_RET,   0x0000
    .equ INTR_VEC,   0x0002
    .equ TIMER_VEC,  0x0020
    .equ TIMER1_VEC, 0x0040
    .equ PARIO_VEC,  0x0060
    .equ UART_VEC,   0x0080
    .equ I2C_VEC,    0x00A0
    .equ PS2_VEC,    0x00C0
    .equ RESET_VEC,  0x0100

    .equ UART_HI,    0x418
    .equ UART_DATA,  0
    .equ UART_STATUS, 1

    .equ PS2_HI,     0x428
    .equ PS2_DR,     0
    .equ PS2_SR,     1
    .equ PS2_CR,     2

    .equ STACK_TOP,  0x03FF

; ============================================
; 0x0000 - interrupt return
; ============================================
    .org INTR_RET
intr_ret:
    JAL r14, r14, #0

    .org INTR_VEC
isr_swint:
    BR intr_ret

    .org TIMER_VEC
isr_timer:
    ISR_PRO
    IRET

    .org TIMER1_VEC
isr_timer1:
    ISR_PRO
    IRET

    .org PARIO_VEC
isr_pario:
    ISR_PRO
    IRET

    .org UART_VEC
isr_uart:
    ISR_PRO
    IRET

    .org I2C_VEC
isr_i2c:
    ISR_PRO
    IRET

; ============================================
; 0x00C0 - PS/2 ISR
;  recebe byte do teclado e envia pela UART
; ============================================
    .org PS2_VEC
isr_ps2:
    ISR_PRO
    PUSH a0

    ; read scancode from PS2DR (clears RXNE)
    IMM  #PS2_HI
    LW   a0, zero, #PS2_DR

    ; send scancode byte via UART
    IMM  #UART_HI
    SW   a0, zero, #UART_DATA

    POP  a0
    IRET

; ============================================
; 0x0100 - reset / main
; ============================================
.org RESET_VEC
reset:
    LI  sp, #STACK_TOP

    ; ativar PS/2: EN=1 (bit1), RXIE=1 (bit0)
    ADDI a0, zero, #3
    IMM  #PS2_HI
    SW   a0, zero, #PS2_CR

    ; enviar 0xFF (reset)
    LI   a0, #0xFF
    IMM  #PS2_HI
    SW   a0, zero, #PS2_DR

main_loop:
    BR #-1
