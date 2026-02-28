; 1. PREPROCESSOR & DIRECTIVES
TIMER0_CR0 .equ 0x8000      ; Timer 0 Control Register 0
 TIMER0_CR1 .equ 0x8002      ; Timer 0 Control Register 1
 STACK_TOP .equ 0x03FF      ; Initial Stack Pointer

; 2. INTERRUPT VECTOR TABLE (IVT)
.org 0x0020
    JAL zero, lr, isr_timer0 ; Vector 0: Timer 0

.org 0x0040
    JAL zero, lr, isr_timer1 ; Vector 1: Timer 1

; 4. MAIN PROGRAM ENTRY
.org 0x0100                  ; Standard Reset Vector entry point
main:
    ; Register Initialization (using ABI aliases)
    IMM #0x03                ; Prefix for 12-bit immediate
    LI(sp,STACK_TOP)         ; Load Stack Pointer
    LI(a0,0x0005)            ; Argument 0
    LI(a1,0x000A)           ; Argument 1

    ; SYSTEM INSTRUCTIONS
    CLI                      ; Disable global interrupts
    STI                      ; Enable global interrupts
    NOP                      ; No Operation (0xF000)

    ; ARITHMETIC & LOGIC (RR, RI, RRI Formats) 
    ADD a0, a1               ; RR: a0 = a0 + a1
    SUB a2, a1               ; RR: a2 - a1
    ADDI a0, a0, #1          ; RRI: a0 = a0 + 1
    AND t0, a0               ; RR: Logical AND
    XOR t1, a0               ; RR: Logical XOR

    ; MEMORY ACCESS
    ; Tests high/low byte lane split and word-addressed indexing.
    LI(t2,TIMER0_CR1)        ; Load MMIO base address
    SW a0, t2, #0           ; Store Word: Timer0_CR0 = a0
    LW t3, t2, #0           ; Load Word: t3 = Timer0_CR0
    SB a1, t2, #1           ; Store Byte
    LB t1, t2, #1         ; Load Byte

    ; CONTROL FLOW
    JAL lr, r0, leaf_func        ; Jump and Link to leaf function
    CMP a0, a1               ; Compare registers (updates CC flags)
    BEQ loop                ; Branch if Equal (conditional branch)

loop:
    BR main                  ; Unconditional branch back to main

; 5. FUNCTION 
leaf_func:
    PUSH(s0)                  ; Save callee-saved register
    ADD a0, a1
    POP(s0)                   ; Restore callee-saved register
    JAL zero, lr, #0          ; Return to caller

; 6. INTERRUPT SERVICE ROUTINES
isr_timer0:
    CLI                      ; disable interrupts, atomic context for flag saving
    GETCC t0                 ; Save Condition Codes to t0
    PUSH(t0)                  ; Preserve CC on stack
    
    ; ISR Body
    LI(t1,0x0001)
    SW t1, zero, TIMER0_CR1  ; Clear interrupt request
    
    POP(t0)                   ; Pop values back into t0 from stack
    SETCC t0                 ; Restore Condition Codes
    STI                      ; Exit atomic context
    IRET                     ; Return from interrupt (Hex: 0EE0)

.org 0x02F0
isr_timer1:
    IRET                     ; Minimal ISR for Vector 1

; 7. DATA STORAGE
.org 0x0300
    .byte 0x34
    .word 0xDEAD             ; Direct word emission
    .word 0xBEEF
