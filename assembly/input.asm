.include "../tools/abi.inc"

; ============================================================
; MMIO ADDRESSING EXPLANATION
; ============================================================
; The CPU datapath: o_d_ad = (_sum << 1)
; So _d_ad is a BYTE address = word_address * 2
;
; SW uses a WORD offset in the immediate field.
; Final byte addr = (IMM_prefix<<4 | imm4 + base_reg) << 1
;
; periph_bus selects register via i_addr[2:1] (byte addr bits 2:1)
; which equals word_offset bits [1:0].
;
; VGA base byte addr = 0x8600 (periph_bus VGA=4'h6, bit15=1)
; VGA base word addr = 0x4300
; IMM prefix = 0x430, base=zero, imm=offset
;
; Register offsets (WORD offsets → byte addr[2:1]):
;   CNTRL  : word offset 0 → byte 0x8600 → addr[2:1]=00
;   VGASEL : word offset 1 → byte 0x8602 → addr[2:1]=01 (AVOID: Odd offset bug)
;   CHAR   : word offset 2 → byte 0x8604 → addr[2:1]=10
;
; Same logic applies to all peripherals.
; ============================================================

    .equ INTR_RET,    0x0000
    .equ INTR_VEC,    0x0002
    .equ TIMER_VEC,   0x0020
    .equ TIMER1_VEC,  0x0040
    .equ PARIO_VEC,   0x0060
    .equ UART_VEC,    0x0080
    .equ I2C_VEC,     0x00A0
    .equ PS2_VEC,     0x00C0
    .equ RESET_VEC,   0x0200     ; CRITICAL FIX: Byte addr 0x0200 = Word addr 0x0100

    ; Word base addresses for peripherals
    .equ TIMER0_BASE, 0x4000
    .equ TIMER1_BASE, 0x4080
    .equ PARIO_BASE,  0x4100
    .equ PS2_BASE,    0x4280
    .equ VGA_BASE,    0x4300

    ; Register offsets (0 to 15)
    .equ CTRL_REG,    0
    .equ VGA_VGASEL,  1
    .equ VGA_CHAR,    2
    
    .equ PS2_CR,      2

    .equ STACK_TOP,   0x03FF
    .equ CDC_DELAY,   16

; ============================================================
; ISR vector table
; ============================================================
    .org INTR_RET
intr_ret:
    JAL r14, r14, #0

    .org INTR_VEC
    IRET
    .org TIMER_VEC
    IRET
    .org TIMER1_VEC
    IRET
    .org PARIO_VEC
    IRET
    .org UART_VEC
    IRET
    .org I2C_VEC
    IRET
    .org PS2_VEC
    IRET

; ============================================================
; 0x0100 - Reset / main (CPU wakes up here!)
; ============================================================
    .org RESET_VEC
reset:
    LI   sp, #STACK_TOP

    ; 1. Disable timers
    LI   t0, #TIMER0_BASE
    SW   zero, t0, #CTRL_REG
    LI   t0, #TIMER1_BASE
    SW   zero, t0, #CTRL_REG

    ; 2. Wait for CDC propagation
    LI   t1, #CDC_DELAY
cdc_wait:
    ADDI t1, t1, #-1
    RCMPI t1, #0
    BEQ  cdc_done
    BR   cdc_wait
cdc_done:

    ; 3. Enable VGA (CNTRL=0x03)
    LI   t0, #VGA_BASE
    LI   a0, #0x03
    SW   a0, t0, #CTRL_REG

    ; 4. Enable PS/2 Receiver Bypass (EN=bit1=1, RXIE=bit0=0 -> Value 2)
    ; Interrupts are OFF so it won't crash the CPU, but hardware bypass stays ON!
    LI   t0, #PS2_BASE
    LI   a0, #0x02
    SW   a0, t0, #PS2_CR

    ; 5. Write "VGA TEXT OK > "
    LI   t0, #VGA_BASE      ; Base address for VGA
    
    LI   a0, #0x56  ; 'V'
    SW   a0, t0, #VGA_CHAR  ; offset = 2
    LI   a0, #0x47  ; 'G'
    SW   a0, t0, #VGA_CHAR
    LI   a0, #0x41  ; 'A'
    SW   a0, t0, #VGA_CHAR
    LI   a0, #0x20  ; ' '
    SW   a0, t0, #VGA_CHAR
    LI   a0, #0x54  ; 'T'
    SW   a0, t0, #VGA_CHAR
    LI   a0, #0x45  ; 'E'
    SW   a0, t0, #VGA_CHAR
    LI   a0, #0x58  ; 'X'
    SW   a0, t0, #VGA_CHAR
    LI   a0, #0x54  ; 'T'
    SW   a0, t0, #VGA_CHAR
    LI   a0, #0x20  ; ' '
    SW   a0, t0, #VGA_CHAR
    LI   a0, #0x4F  ; 'O'
    SW   a0, t0, #VGA_CHAR
    LI   a0, #0x4B  ; 'K'
    SW   a0, t0, #VGA_CHAR
    LI   a0, #0x20  ; ' '
    SW   a0, t0, #VGA_CHAR
    LI   a0, #0x3E  ; '>'
    SW   a0, t0, #VGA_CHAR
    LI   a0, #0x20  ; ' '
    SW   a0, t0, #VGA_CHAR

    ; 6. End configuration & Halt
    STI
    
    LI   t0, #PARIO_BASE
    LI   a0, #0x07
    SW   a0, t0, #CTRL_REG  ; LEDs = 0111 (Ready)

main_loop:
    BR   #-1