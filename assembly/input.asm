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
    .equ RESET_VEC,  0x0100

    .equ TIMER_HI,   0x400
    .equ TIMER_CR0,  0
    .equ TIMER_CR1,  1

    .equ TIMER1_HI,  0x408
    .equ TIMER1_CR0, 0
    .equ TIMER1_CR1, 1

    .equ PARIO_HI,  0x410
    .equ PARIO_DATA, 0

    .equ UART_HI,  0x418
    .equ UART_DATA, 0

    .equ I2C_HI,   0x420
    .equ I2C_CTRL, 0
    .equ I2C_STATUS, 1
    .equ I2C_DIV, 2
    .equ I2C_ADDR, 3
    .equ I2C_LEN, 4
    .equ I2C_DATA, 5

    .equ INTCAUSE_HI, 0x4F0
    .equ INTCAUSE, 0

    .equ STACK_TOP, 0x03FF
    .equ GLOBAL_DATA_START, 0x02FF

; ============================================
; 0x0000 — interrupt return
; ============================================
    .org INTR_RET
intr_ret:
    JAL   r14, r14, #0

; ============================================
; 0x0002-0x001F — swint ISRs
; ============================================
    .org INTR_VEC
isr_swint:
    IMM   #INTCAUSE_HI
    LW    t0, zero, #INTCAUSE
    MOV t1, t0
    ANDI t0, #2
    SUBI t0, t0, #2
    BEQ  +4
    ANDI t1, #1
    SUBI t1, t1, #1
    BEQ  +2
    BR    intr_ret
    BR    isr_timer1
    BR    isr_timer

; ============================================
; 0x0020 — timer ISR
; ============================================
    .org TIMER_VEC
isr_timer:
    ISR_PRO
    NOP
    NOP
    IMM   #TIMER_HI
    SW    zero, zero, #TIMER_CR1
    IRET

; ============================================
; 0x0040 — timer1 ISR
; ============================================
    .org TIMER1_VEC
isr_timer1:
    ISR_PRO
    IMM   #TIMER1_HI
    SW    zero, zero, #TIMER1_CR1
    IRET

; ============================================
; 0x0060 — pario ISR
; ============================================
    .org PARIO_VEC
isr_pario:
    ISR_PRO
    ADDI a0, zero, #0xF
    IMM  #PARIO_HI
    SW   a0, zero, #PARIO_DATA
    IRET

; ============================================
; 0x0080 — uart ISR
; ============================================
    .org UART_VEC
isr_uart:
    ISR_PRO
    IMM  #UART_HI
    LW   t0, zero, #UART_DATA
    IRET

; ============================================
; 0x00A0 — i2c ISR
; ============================================
    .org I2C_VEC
isr_i2c:
    ISR_PRO
    PUSH t0
    LI   t0, #0x0016
    IMM  #I2C_HI
    SW   t0, zero, #I2C_STATUS
    POP  t0
    IRET

; ============================================
; 0x0100 — reset / main
; ============================================
    .org RESET_VEC
reset:
    LI  sp, #STACK_TOP
    LI  gp, #GLOBAL_DATA_START

    ; Configure timer0
    ADDI a0, zero, #3
    IMM   #TIMER_HI
    SW    a0, zero, #TIMER_CR0

    ; Configure WDT: PS=8, RELOAD=4, WEN=1, RSTEN=1
    ADDI  a0, zero, #8
    IMM   #0x440
    SW    a0, zero, #1
    ADDI  a0, zero, #4
    IMM   #0x440
    SW    a0, zero, #2
    ADDI  a0, zero, #3
    IMM   #0x440
    SW    a0, zero, #0

    J main

; ============================================
; Simple ABI / ISA self-test
; ============================================

add3:
    ADD a0, a1
    ADD a0, a2
    RET

use_saved:
    PUSH s0
    PUSH s1
    MOV s0, a0
    MOV s1, a1
    OR a0, a1
    ADDI a0, a0, #1
    POP s1
    POP s0
    RET

foo:
    PUSH s0
    PUSH s1
    PUSH lr
    MOV s0, a0
    MOV s1, a1
    MOV t0, a0
    ADD t0, a1
    MOV a0, t0
    ADDI a1, zero, #1
    ADDI a2, zero, #2
    CALL add3
    POP lr
    POP s1
    POP s0
    RET

main:
    LI s0, #0x0123
    LI s1, #0x4567

    ADDI a0, zero, #1
    ADDI a1, zero, #2
    ADDI a2, zero, #3
    CALL add3

    ADDI a0, zero, #4
    ADDI a1, zero, #5
    CALL use_saved

    ADDI a0, zero, #7
    LI   a1, #8
    CALL foo

main_loop:
    BR #-1
