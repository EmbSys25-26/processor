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
    LI   sp, #STACK_TOP         ; => IMM #0x03F        [8|03F] = 0x803F  (prefix: upper 12 bits of STACK_TOP=0x03FF)  | MEM_ADDR = 0x0100
                                ; => ADDI sp,zero,#0xF  [1|D|0|F] = 0x1D0F  (sp = 0x03FF with prefix)                | MEM_ADDR = 0x0102

main:
    LI   t0, #0                 ; => IMM #0x000        [8|000] = 0x8000  (prefix: 0>>4 = 0)                           | MEM_ADDR = 0x0104
                                ; => ADDI t0,zero,#0x0  [1|4|0|0] = 0x1400  (t0 = 0, iteration counter)              | MEM_ADDR = 0x0106

    LI   t1, #16                ; => IMM #0x001        [8|001] = 0x8001  (prefix: 16>>4 = 1)                           | MEM_ADDR = 0x0108
                                ; => ADDI t1,zero,#0x0  [1|5|0|0] = 0x1500  (t1 = 16, loop limit)                    | MEM_ADDR = 0x010A

    ; Deactivate TimerH int_en -- MMIO write requires input address to be (final_address >>1)
    IMM  #0x408                 ; [8|408] = 0x8408  (prefix: upper 12 bits of MMIO word-address 0x8100)               | MEM_ADDR = 0x010C
    SW   r0, r0, #0             ; [6|0|0|0] = 0x6000  (MEM[0+0x8100] = r0 = 0, using prefix)                         | MEM_ADDR = 0x010E

    ; ============================
    ; 0x0110 — main loop (16 iterations, 4 BR always each)
    ; ============================
loop:
    BR   b1                     ; [9|0|02] = 0x9002  (always taken, skips dead ADDI)                                  | MEM_ADDR = 0x0110
    ADDI t0, t0, #-1            ; [1|4|4|F] = 0x144F  (never executes)                                               | MEM_ADDR = 0x0112

b1:
    BR   b2                     ; [9|0|02] = 0x9002  (always taken, skips dead ADDI)                                  | MEM_ADDR = 0x0114
    ADDI t0, t0, #-1            ; [1|4|4|F] = 0x144F  (never executes)                                               | MEM_ADDR = 0x0116

b2:
    BR   b3                     ; [9|0|02] = 0x9002  (always taken, skips dead ADDI)                                  | MEM_ADDR = 0x0118
    ADDI t0, t0, #-1            ; [1|4|4|F] = 0x144F  (never executes)                                               | MEM_ADDR = 0x011A

b3:
    BR   b4                     ; [9|0|02] = 0x9002  (always taken, skips dead ADDI)                                  | MEM_ADDR = 0x011C
    ADDI t0, t0, #-1            ; [1|4|4|F] = 0x144F  (never executes)                                               | MEM_ADDR = 0x011E

b4:
    ; increment counter and loop back if t0 < 16
    ADDI t0, t0, #1             ; [1|4|4|1] = 0x1441  (t0++)                                                         | MEM_ADDR = 0x0120
    CMP  t0, t1                 ; [2|4|5|6] = 0x2456  (t0 - t1, updates CC)                                          | MEM_ADDR = 0x0122
    BLT  loop                   ; [9|8|F6] = 0x98F6  (disp=-10: loop_byte=0x0110, taken 15x)                         | MEM_ADDR = 0x0124

    ; ============================
    ; 0x0126 — halt
    ; ============================
halt:
    BR   halt                   ; [9|0|00] = 0x9000  (disp=0: infinite self-loop)                                     | MEM_ADDR = 0x0126
