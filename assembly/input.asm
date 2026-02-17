.include "../tools/abi.inc"

    ; ============================
    ; Constants / addresses
    ; ============================
    .equ INTR_RET,   0x0000      ; 0x0000: JAL r0, r14, #0  (interrupt return stub)
    .equ INTR_VEC,   0x0002      ; 0x0002: ISR software interrupt offset encoded at INTCAUSE
    .equ TIMER_VEC,  0x0020      ; 0x0020: timer ISR vector
    .equ TIMER1_VEC, 0x0040      ; 0x0040: timer1 ISR vector
    .equ PARIO_VEC,  0x0060      ; 0x0060: pario ISR vector
    .equ UART_VEC,   0x0080      ; 0x0080: uart ISR vector
    .equ I2C_VEC,    0x00A0      ; 0x00A0: i2c ISR vector
    .equ RESET_VEC,  0x0100      ; 0x0100: reset / main

    ; timer region (IO) – software sees sum=0x4000 --> d_ad=0x8000
    .equ TIMER_HI,   0x400       ; high 12 bits --> imm16 = 0x4000
    .equ TIMER_CR0,  0           ; CR0 at byte addr 0x8000
    .equ TIMER_CR1,  1           ; CR1 at byte addr 0x8002

    ; timer1 region (IO) – software sees sum=0x4080 --> d_ad=0x8100
    .equ TIMER1_HI,  0x408       ; high 12 bits --> imm16 = 0x4080
    .equ TIMER1_CR0, 0           ; CR0 at byte addr 0x8100
    .equ TIMER1_CR1, 1           ; CR1 at byte addr 0x8102

    ; pario region (IO) – software sees sum=0x4100 --> d_ad=0x8200
    .equ PARIO_HI,  0x410        ; high 12 bits --> imm16 = 0x4100
    .equ PARIO_DATA, 0           ; DATA at byte addr 0x8200

    ; uart region (IO) – software sees sum=0x4180 --> d_ad=0x8300
    .equ UART_HI,  0x418         ; high 12 bits --> imm16 = 0x4180
    .equ UART_DATA, 0            ; DATA at byte addr 0x8300

    ; i2c region (IO) – software sees sum=0x4200 --> d_ad=0x8400
    .equ I2C_HI,   0x420         ; high 12 bits --> imm16 = 0x4200
    .equ I2C_CTRL, 0             ; +0x00
    .equ I2C_STATUS, 1           ; +0x02
    .equ I2C_DIV, 2              ; +0x04
    .equ I2C_ADDR, 3             ; +0x06
    .equ I2C_LEN, 4              ; +0x08
    .equ I2C_DATA, 5             ; +0x0A

    ; intcause region (IO) – software sees sum=0x4F00 --> d_ad=0x8F00
    .equ INTCAUSE_HI, 0x4F0      ; high 12 bits --> imm16 = 0x4F00
    .equ INTCAUSE, 0             ; INTCAUSE at byte addr 0x8F00

    ; memory range is from 0x0000 to 0x03FF (1 KiB)
    ; Stack grows down from high address
    .equ STACK_TOP, 0x03FF     ; stack top address
    
    ; stack size is 0x100 which is 128 words
    .equ GLOBAL_DATA_START, 0x02FF ; global data segment start

; ============================================
; 0x0000 — interrupt return 
; ============================================
    .org INTR_RET
intr_ret:
    ;   sum = r14 + 0 = return PC (held in r14 at ISR entry)
    ;   new PC = sum, r14 := old PC (0x0000)
    JAL   r14, r14, #0

; ============================================
; 0x0002-0x001F — swint ISRs 
; ============================================
    .org INTR_VEC
isr_swint:
    ; Read INTCAUSE at 0x8F00 to find cause
    IMM   #INTCAUSE_HI          ; imm16 = 0x4F00
    LW    t0, zero, #INTCAUSE   ; t0 = INTCAUSE 

    ; t0 bit1 -> timer1, bit0 -> timer0
    MOV t1, t0                 ; t1 = t0 (macro -> ADDI t1, t0, #0)

    ; test timer1 (bit1)
    ANDI t0, #2 
    SUBI t0, t0, #2 
    BEQ  +4

    ; test timer0 
    ANDI t1, #1
    SUBI t1, t1, #1
    BEQ  +2

    ; Unknown cause, return 
    BR    intr_ret              ; PC_next = 0x0000

    ; Jump to timer1 ISR
    BR    isr_timer1            ; PC_next = TIMER1_VEC

    ; Jump to timer0 ISR
    BR    isr_timer             ; PC_next = TIMER_VEC


; ============================================
; 0x0020 — timer ISR
; ============================================
    .org TIMER_VEC ; interrupt vector table entry for timer
isr_timer:
    ; Clear timer int_req (CR1) at 0x8002
    ISR_PRO
    NOP 
    NOP

    IMM   #TIMER_HI           ; imm16 = 0x4000
    SW    zero, zero, #TIMER_CR1 ; sum = 0x4000 + 1 = 0x4001, temporarily using r0 as 0 while stack is not established
                              ; d_ad = 0x4001 << 1 = 0x8002
                              ; write 0 (r0) to CR1 --> clears int_req (timer)

    
    ; IRET: pop cc and lr, restore pc through link register 
    IRET

; ============================================
; 0x0040 — timer1 ISR
; ============================================
    .org TIMER1_VEC ; interrupt vector table entry for timer
isr_timer1:
    ; Clear timer int_req (CR1) at 0x8102
    ISR_PRO

    IMM   #TIMER1_HI           ; imm16 = 0x4080
    SW    zero, zero, #TIMER1_CR1 ; sum = 0x4080 + 1 = 0x4081, temporarily using r0 as 0 while stack is not established
                              ; d_ad = 0x4081 << 1 = 0x8102
                              ; write 0 (r0) to CR1 --> clears int_req (timer1)
    ; IRET: pop cc and lr, restore pc through link register 
    IRET

; ============================================
; 0x0060 — pario ISR
; ============================================
    .org PARIO_VEC
isr_pario:
    ISR_PRO
    
    ; Write 0xF to PARIO DATA (turn on 4 LEDs)
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

    ; Read UART DATA to clear RX interrupt
    IMM  #UART_HI          ; imm16 = 0x4180
    LW   t0, zero, #UART_DATA   ; read RX (clears pending)
    IRET

; ============================================
; 0x00A0 — i2c ISR
; ============================================
    .org I2C_VEC
isr_i2c:
    ISR_PRO
    PUSH t0

    ; Clear sticky I2C STATUS flags (W1C): done(bit1), ack_err(bit2), irq_pend(bit4)
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
    ; optional: user level init of sp, gp, etc. for now assume hw reset does this 
    ; Initialize stack pointer
    LI  sp, #STACK_TOP

    ; Initialize global pointer
    LI  gp, #GLOBAL_DATA_START           ; assuming data segment starts at 0x6000

    ; Configure timer0:
    ; CR0 bit0 = int_en, bit1 = timer_mode
    ; set CR0 = 0b11 = 3  --> interrupts enabled, timer mode active
    ADDI a0, zero, #3          ; a0 = 3
    IMM   #TIMER_HI           ; imm16 = 0x4000
    SW    a0, zero, #TIMER_CR0  ; store 3 to 0x8000
    
    ; Configure timer1:
    ; CR0 bit0 = int_en, bit1 = timer_mode
    ; set CR0 = 0b11 = 3  --> interrupts enabled, timer
    ; ADDI a0, zero, #3          ; a0 = 3
    ; IMM   #TIMER1_HI          ; imm16 = 0x4080
    ; SW    a0, zero, #TIMER1_CR0 ; store 3 to 0x8100

    ; FALL into test harness 
    J main

; ============================================
; Simple ABI / ISA self-test
; ============================================

; int add3 (int x, int y, int z) { return x + y + z; }
add3: 
    ; a0 = x, a1 = y, a2 = z 
    ADD a0, a1 
    ADD a0, a2
    RET 

; int use_saved(int x, int y) 
; {
;    s0 = x; 
;    s1 = y;
;    return (x | y) + 1;    
; }
use_saved:
    ; a0 = x, a1 = y
    PUSH s0
    PUSH s1

    MOV s0, a0        ; s0 = x
    MOV s1, a1        ; s1 = y
    OR a0, a1         ; a0 = x | y
    ADDI a0, a0, #1   ; a0 = (x | y) + 1

    POP s1
    POP s0
    RET

; Non leaf function 
; int foo(int x, int y) 
; {
;    // use s0, s1 (callee-saved)
;    t0 = x + y; 
;    return add3(t0, 1, 2);
; }
foo:
    ; prologue - save callee-saved regs 
    PUSH s0 
    PUSH s1
    PUSH lr 

    ; a0 = x, a1 = y

    ; save x y in callee saved regs 
    MOV s0, a0       ; s0 = x
    MOV s1, a1       ; s1 = y

    ; t0 = x + y
    MOV t0, a0      ; t0 = x
    ADD t0, a1      ; t0 = x + y

    ; call add3(t0, x, y)
    MOV a0, t0      ; a0 = t0
    ADDI a1, zero, #1 ; a1 = 1
    ADDI a2, zero, #2 ; a2 = 2
    CALL add3        ; call add3

    ; v0 (a0) now has result

    ; epilogue - restore callee-saved regs
    POP lr
    POP s1
    POP s0
    RET

main: 
    ; baseline s0 s1 to check if they're being saved 
    LI s0, #0x0123
    LI s1, #0x4567

    ; call add3(1,2,3)
    ADDI a0, zero, #1
    ADDI a1, zero, #2
    ADDI a2, zero, #3
    CALL add3
    ; a0 = 1 + 2 + 3 = 6

    ; call use_saved(4,5)
    ADDI a0, zero, #4
    ADDI a1, zero, #5
    CALL use_saved
    ; a0 = (4 | 5) + 1 = (5) + 1 = 6

    ; call foo(7,8): non leaf + stack 
    ADDI a0, zero, #7
    ; ADDI a1, zero, #8 ; invalid because immediate too large
    LI a1, #8
    CALL foo 
    ; a0 = add3(7+8,1,2) = add3(15,1,2) = 18

    ; check in ILA if s0, s1 are preserved
    ; s0 should be 0x0123
    ; s1 should be 0x4567

    ; inf loop  

main_loop:
    BR #-1
