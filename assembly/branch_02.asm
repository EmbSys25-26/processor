.include "../tools/abi.inc"

    ; ============================
    ; Constants / addresses
    ; ============================
    .equ RESET_VEC, 0x0100
    .equ STACK_TOP, 0x03FF

    ; ============================
    ; 0x0100 — reset / init
    ; ============================
    .org RESET_VEC

reset:
    LI   sp, #STACK_TOP         ; @0x0100: 0x803F (IMM prefix)  +  @0x0102: 0x1D0F (ADDI sp=STACK_TOP)

main:
    LI   t0, #0                 ; @0x0104: 0x8000 (IMM prefix)  +  @0x0106: 0x1400 (ADDI t0=0, counter)

    LI   t1, #32                ; @0x0108: 0x8002 (IMM prefix)  +  @0x010A: 0x1500 (ADDI t1=32, limit)

    LI   t2, #0                 ; @0x010C: 0x8000 (IMM prefix)  +  @0x010E: 0x1600 (ADDI t2=0, toggle)

    LI   t3, #0                 ; @0x0110: 0x8000 (IMM prefix)  +  @0x0112: 0x1700 (ADDI t3=0, counter)

    LI   s0, #31                ; @0x0114: 0x8001 (IMM prefix)  +  @0x0116: 0x180F (ADDI s0=31, threshold)

    ; Deactivate TimerH int_en -- MMIO write requires input address to be (final_address >>1)
    IMM  #0x408                 ; @0x0118: 0x8408 (IMM prefix for 0x8100)
    SW   r0, r0, #0             ; @0x011A: 0x6000 (MEM[0+0x8100] = r0 = 0, using prefix)

    ; ========================================================================
    ; Region A starts at 0x0140.
    ; Branch at phase_a_head is intentionally placed to alias with Region B's
    ; first branch at 0x01C0 for index bits PC[6:1] in the 64-entry BPU.
    ; ========================================================================
    .org 0x0140

phase_a_head:
    ; Branch A1: mostly NOT taken (taken once when t0 == 31)
    CMP  t0, s0                 ; @0x0140: 0x2486  (compare iteration against 31)
    BEQ  a_rare_taken           ; @0x0142: 0x9209  (usually not taken, taken exactly once)

    ; Branch A2: alternating outcome via software toggle
    ; if t2 == 0 -> branch taken path, set t2=1
    ; if t2 == 1 -> fall-through path, set t2=0
    CMP  t2, r0                 ; @0x0144: 0x2606  (compare toggle against 0)
    BEQ  a_alt_taken            ; @0x0146: 0x9204  (T,N,T,N,... alternating pattern)

a_alt_not_taken:
    LI   t2, #0                 ; @0x0148: 0x8000  +  
                                ; @0x014A: 0x1600  (t2 = 0)
    BR   a_alt_done             ; @0x014C: 0x9003  (skip taken-path body)

a_alt_taken:
    LI   t2, #1                 ; @0x014E: 0x8000  +  
                                ; @0x0150: 0x1601  (t2 = 1)

a_alt_done:
    ; Branch A3: always taken, jumps to Region B (alias pressure setup)
    BR   phase_b_head           ; @0x0152: 0x9037  (unconditional transfer to Region B)

; Rare path body (entered once)
a_rare_taken:
    ADDI t3, t3, #1             ; @0x0154: 0x1771  (record rare branch fired)
    BR   a_alt_done             ; @0x0156: 0x90FE  (return to main flow)

    ; ========================================================================
    ; Region B starts at 0x01C0 (0x80 bytes after Region A head).
    ; Branch at phase_b_head shares same PC[6:1] index as phase_a_head.
    ; ========================================================================
    .org 0x01C0

phase_b_head:
    ; Branch B1: always taken at an aliasing PC index
    BR   b_land                 ; @0x01C0: 0x9002  (always taken, trains predictor)
    ADDI t0, t0, #-1            ; @0x01C2: 0x144F  (dead code, must be skipped)

b_land:
    ; Loop progress / termination
    ADDI t0, t0, #1             ; @0x01C4: 0x1441  (t0++)
    CMP  t0, t1                 ; @0x01C6: 0x2456  (compare t0 against 32)
    BLT  phase_a_head           ; @0x01C8: 0x98BC  (loop: taken 31x, not-taken once at exit)

    ; ============================
    ; Halt
    ; ============================
halt:
    BR   halt                   ; @0x01CA: 0x9000  (infinite self-loop)
