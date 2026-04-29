.include "../tools/abi.inc"

; ============================================================
; Interrupt Vector Table (IVT)
; ============================================================
    .org 0x0000
    J    reset              ; Reset vector

    .org 0x0020
    J    reset              ; Timer0 vector

    .org 0x0040
    J    reset              ; Timer1 vector

    .org 0x0060
    J    reset              ; PARIO vector

; ============================================================
; UART ISR (Echo Routine)
; Triggered when a new byte arrives at UART_RX
; ============================================================
    .org 0x0080
uart_isr:
    PUSH lr
    PUSH_CC

    ; -- Create a zero base in t2 --
    LI   t2, #0
    NOP
    NOP

    ; -- Read UART_RX (Word Addr = 0x4180) --
    ; Reading from the data register usually clears the UART IRQ flag!
    IMM  #0x418
    LW   t1, t2, #0         ; t1 = Received Character (e.g., 'A')

    NOP                     ; Load-Use Hazard prevention
    NOP

    ; -- Write back to UART_TX (Word Addr = 0x4180) --
    ; Writing to the same offset triggers the transmission
    IMM  #0x418
    SW   t1, t2, #0         ; Send the character back to the PC!

    NOP
    NOP

    STI                     ; Re-enable interrupts
    IRET

; ============================================================
; Reset / Main Program
; ============================================================
    .org 0x0100
reset:
    CLI                     ; Disable interrupts during init

    LI   sp, #0x03FE        ; Initialize Stack

    ; -- Disable Timer0 (Word Addr = 0x4000) --
    LI   t0, #0
    NOP
    IMM  #0x400
    SW   t0, r0, #0

    ; -- Enable UART in IRQ_MASK (Word Addr = 0x4782) --
    LI   t0, #8             ; Bit 3 corresponds to UART (0x08)
    NOP
    IMM  #0x478
    SW   t0, r0, #2

    ; -- SIMULATION TRICK: Send the first character ('Z') to kickstart --
    ; In simulation, if you wire TX to RX, sending a char here will 
    ; trigger the first interrupt automatically!
    LI   t0, #0x5A          ; ASCII code for 'Z'
    NOP
    IMM  #0x418
    SW   t0, r0, #0         ; Send 'Z'

    STI                     ; Enable interrupts globally

main_loop:
    NOP
    BR   main_loop
    BR	 main_loop
    BR 	 main_loop
    BR   main_loop
    BR   main_loop
