.include "../tools/abi.inc"

; ============================================================
; Interrupt Vector Table (IVT) Stubs
; ============================================================
    .org 0x0000
    J    reset              ; Reset vector

    .org 0x0020
    J    reset              ; Timer0 vector (unused, redirects to reset)

    .org 0x0040
    J    reset              ; Timer1 vector (unused, redirects to reset)

; ============================================================
; PARIO Interrupt Service Routine (ISR)
; Placed directly inside the IVT starting at 0x0060.
; Since we have free space up to 0x0100, the entire ISR fits 
; here perfectly without needing an extra Jump instruction!
; ============================================================
    .org 0x0060
pario_isr:
    PUSH lr                 ; Save the return address (Link Register)
    PUSH_CC                 ; Save Condition Codes (Flags)

    ADDI t3, t3, #1         ; Increment the interrupt event counter

    ; -- Create a reliable zero base address in t2 --
    LI   t2, #0
    NOP                     ; Data hazard prevention (wait for LI to reach RegFile)
    NOP

    ; -- Read from PARIO_IN (Word Addr = 0x4102 / Byte Addr = 0x8204) --
    IMM  #0x410
    LW   t1, t2, #2         ; Load the input pin values into t1

    NOP                     ; Load-Use hazard prevention (wait for memory read)
    NOP

    ; -- Write to PARIO_OUT (Word Addr = 0x4100 / Byte Addr = 0x8200) --
    IMM  #0x410
    SW   t1, t2, #0         ; Echo the input values to the output LEDs

    ; -- Mask PARIO Interrupt (IRQ_MASK Word Addr = 0x4782) --
    ; We write 0 to the mask to prevent continuous re-triggering (Interrupt Storm)
    ; since the hardware input pin remains high.
    IMM  #0x478
    SW   t2, t2, #2

    STI                     ; Re-enable Global Interrupts (GIE = 1)
    IRET                    ; Return from Interrupt (restores context and PC)

; ============================================================
; Reset / Main Program
; ============================================================
    .org 0x0100
reset:
    CLI                     ; Clear Interrupts (GIE = 0) during initialization

    ; -- Initialize Stack and Counters --
    LI   sp, #0x03FE        ; Initialize Stack Pointer (Aligned to an even Word address!)
    LI   t3, #0             ; Initialize our event counter to 0

    ; -- Disable Timer0 (Word Addr = 0x4000) --
    LI   t0, #0
    NOP                     ; Data hazard prevention
    IMM  #0x400
    SW   t0, r0, #0         ; Write 0 to Timer0 Control register

    ; -- Enable PARIO in IRQ_MASK (Word Addr = 0x4782) --
    LI   t0, #4             ; Bit 2 corresponds to PARIO interrupt
    NOP
    IMM  #0x478
    SW   t0, r0, #2         ; Write 0x0004 to IRQ_MASK

    ; -- Clear PARIO_OUT (Word Addr = 0x4100) --
    LI   t0, #0
    NOP
    IMM  #0x410
    SW   t0, r0, #0         ; Ensure output pins start at 0

    STI                     ; Initialization complete, re-enable Global Interrupts

main_loop:
    NOP                     ; Idle state
    BR   main_loop          ; Infinite loop waiting for hardware interrupts
