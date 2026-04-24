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
;   VGASEL : word offset 1 → byte 0x8602 → addr[2:1]=01
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
    .equ RESET_VEC,   0x0100

    ; TIMER0 base: periph_bus TIMER0=4'h0 → byte 0x8000 → word 0x4000
    .equ TIMER0_HI,   0x400
    .equ TIMER0_CTRL, 0       ; word offset 0

    ; TIMER1 base: periph_bus TIMER1=4'h1 → byte 0x8100 → word 0x4080
    .equ TIMER1_HI,   0x408
    .equ TIMER1_CTRL, 0       ; word offset 0

    ; PARIO base: periph_bus PARIO=4'h2 → byte 0x8200 → word 0x4100
    .equ PARIO_HI,    0x410
    .equ PARIO_OUT,   0       ; word offset 0 → output register
    .equ PARIO_IN,    1       ; word offset 1 → input register

    ; PS2 base: periph_bus PS2=4'h5 → byte 0x8500 → word 0x4280
    .equ PS2_HI,      0x428
    .equ PS2_DR,      0       ; word offset 0 → data register
    .equ PS2_SR,      1       ; word offset 1 → status register
    .equ PS2_CR,      2       ; word offset 2 → control register

    ; VGA base: periph_bus VGA=4'h6 → byte 0x8600 → word 0x4300
    .equ VGA_HI,      0x430
    .equ VGA_CNTRL,   0       ; word offset 0 → bit0=enVGA, bit1=auto_inc
    .equ VGA_VGASEL,  1       ; word offset 1 → bit4=mode(1=text,0=image)
    .equ VGA_CHAR,    2       ; word offset 2 → write ASCII char here

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
isr_ps2:
    J handle_ps2

; ============================================================
; 0x0100 - Reset / main
; ============================================================
    .org RESET_VEC
reset:
    LI   sp, #STACK_TOP

    ; ----------------------------------------------------------
    ; Disable timers first to stop spurious interrupts
    ; ----------------------------------------------------------
    IMM  #TIMER0_HI
    SW   r0, r0, #TIMER0_CTRL

    IMM  #TIMER1_HI
    SW   r0, r0, #TIMER1_CTRL

    ; ----------------------------------------------------------
    ; Set text mode: VGASEL bit4=1 (word offset 1)
    ; ----------------------------------------------------------
    LI   a0, #0x10
    IMM  #VGA_HI
    SW   a0, zero, #VGA_VGASEL   ; → byte 0x8602 → addr[2:1]=01 ✓

    ; ----------------------------------------------------------
    ; Wait for CDC propagation (mode_switch_reg → clkVGA domain)
    ; ----------------------------------------------------------
    LI   t1, #CDC_DELAY
cdc_wait:
    ADDI t1, t1, #-1
    RCMPI t1, #0
    BEQ  cdc_done
    BR   cdc_wait
cdc_done:

    ; ----------------------------------------------------------
    ; Enable VGA: CNTRL=0x03 (enVGA=1, auto_inc=1)
    ; ----------------------------------------------------------
    LI   a0, #0x03
    IMM  #VGA_HI
    SW   a0, zero, #VGA_CNTRL    ; → byte 0x8600 → addr[2:1]=00 ✓

    ; LEDs = 0001 (VGA enabled)
    LI   a0, #0x01
    IMM  #PARIO_HI
    SW   a0, zero, #PARIO_OUT

    ; ----------------------------------------------------------
    ; Write "VGA TEXT OK > " to char buffer
    ; ----------------------------------------------------------
    LI   t0, #VGA_CHAR           ; t0 = word offset 2
    IMM  #VGA_HI

    LI   a0, #0x56  ; 'V'
    SW   a0, t0, #0
    LI   a0, #0x47  ; 'G'
    SW   a0, t0, #0
    LI   a0, #0x41  ; 'A'
    SW   a0, t0, #0
    LI   a0, #0x20  ; ' '
    SW   a0, t0, #0
    LI   a0, #0x54  ; 'T'
    SW   a0, t0, #0
    LI   a0, #0x45  ; 'E'
    SW   a0, t0, #0
    LI   a0, #0x58  ; 'X'
    SW   a0, t0, #0
    LI   a0, #0x54  ; 'T'
    SW   a0, t0, #0
    LI   a0, #0x20  ; ' '
    SW   a0, t0, #0
    LI   a0, #0x4F  ; 'O'
    SW   a0, t0, #0
    LI   a0, #0x4B  ; 'K'
    SW   a0, t0, #0
    LI   a0, #0x20  ; ' '
    SW   a0, t0, #0
    LI   a0, #0x3E  ; '>'
    SW   a0, t0, #0
    LI   a0, #0x20  ; ' '
    SW   a0, t0, #0

    ; LEDs = 0011 (chars written)
    LI   a0, #0x03
    IMM  #PARIO_HI
    SW   a0, zero, #PARIO_OUT

    ; ----------------------------------------------------------
    ; Init PS/2: CR=3 (EN=bit1=1, RXIE=bit0=1)
    ; word offset 2 → byte 0x8504 → addr[2:1]=10 ✓
    ; ----------------------------------------------------------
    ADDI a0, zero, #3
    IMM  #PS2_HI
    SW   a0, zero, #PS2_CR

    ; ----------------------------------------------------------
    ; Enable global interrupts
    ; ----------------------------------------------------------
    STI

    ; LEDs = 0111 (ready, PS2 enabled)
    LI   a0, #0x07
    IMM  #PARIO_HI
    SW   a0, zero, #PARIO_OUT

main_loop:
    BR   #-1

; ============================================================
; PS/2 ISR — Intercepts keys 1, 2, 3 (Image Mode) and 4 (Text Mode)
; ============================================================
handle_ps2:
    PUSH lr
    PUSH a0
    PUSH t0

    ; 1. Read the raw scancode from PS2 data register
    IMM  #PS2_HI
    LW   a0, zero, #PS2_DR

    ; 2. Check for '1' (Top Row: 0x16, Numpad: 0x69)
    RCMPI a0, #0x16
    BEQ   set_image_mode
    RCMPI a0, #0x69
    BEQ   set_image_mode
    
    ; 3. Check for '2' (Top Row: 0x1E, Numpad: 0x72)
    RCMPI a0, #0x1E
    BEQ   set_image_mode
    RCMPI a0, #0x72
    BEQ   set_image_mode

    ; 4. Check for '3' (Top Row: 0x26, Numpad: 0x7A)
    RCMPI a0, #0x26
    BEQ   set_image_mode
    RCMPI a0, #0x7A
    BEQ   set_image_mode

    ; 5. Check for '4' (Top Row: 0x25, Numpad: 0x6B)
    RCMPI a0, #0x25
    BEQ   set_text_mode
    RCMPI a0, #0x6B
    BEQ   set_text_mode

    ; If any other key is pressed, just exit
    BR    end_ps2

set_image_mode:
    ; Set Bit 4 to 0 (0x00) for Image Mode
    LI   t0, #0x00
    BR   update_mode

set_text_mode:
    ; Set Bit 4 to 1 (0x10) for Text Mode
    LI   t0, #0x10

update_mode:
    ; Write the chosen mode to the VGASEL register
    IMM  #VGA_HI
    SW   t0, zero, #VGA_VGASEL

end_ps2:
    POP  t0
    POP  a0
    POP  lr
    IRET     ; <--- CRITICAL: Must be IRET to re-enable global interrupts!