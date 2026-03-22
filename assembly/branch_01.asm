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
    LI   sp, #STACK_TOP         ; => IMM #0x03F        [8|03F] = 0x803F  (prefix: upper 12 bits of STACK_TOP=0x03FF) | MEM_ADDR = 0x0100
                                ; => ADDI sp,zero,#0xF  [1|D|0|F] = 0x1D0F  (sp = 0x03FF with prefix)                | MEM_ADDR = 0x0102
main:
    LI   t0, #0                 ; => IMM #0x000        [8|000] = 0x8000  (prefix: 0>>4 = 0)                          | MEM_ADDR = 0x0104
                                ; => ADDI t0,zero,#0x0  [1|4|0|0] = 0x1400  (t0 = 0)                                 | MEM_ADDR = 0x0106

    LI   t1, #1                 ; => IMM #0x000        [8|000] = 0x8000  (prefix: 1>>4 = 0)                          | MEM_ADDR = 0x0108
                                ; => ADDI t1,zero,#0x1  [1|5|0|1] = 0x1501  (t1 = 1)                                 | MEM_ADDR = 0x010A

    LI   t2, #0                 ; => IMM #0x000        [8|000] = 0x8000  (prefix: 0>>4 = 0)                          | MEM_ADDR = 0x010C
                                ; => ADDI t2,zero,#0x0  [1|6|0|0] = 0x1600  (t2 = 0, iteration counter)              | MEM_ADDR = 0x010E

    ; Deactivate TimerH int_en -- MMIO write requires input address to be (final_address >>1)
    IMM  #0x408                 ; [8|408] = 0x8408  (prefix: upper 12 bits of MMIO word-address 0x8100)              | MEM_ADDR = 0x0110
    SW   r0, r0, #0             ; [6|0|0|0] = 0x6000  (MEM[0+0x8100] = r0 = 0, using prefix)                         | MEM_ADDR = 0x0112

    ; ============================
    ; 0x0114 — main loop (16 iterations, 4 branches each)
    ; ============================
loop:
    ; branch 1: BEQ not taken (t0=0 != t1=1 → Z=0)
    CMP  t0, t1                 ; [2|4|5|6] = 0x2456  (t0 - t1, updates CC)                                          | MEM_ADDR = 0x0114
    BEQ  halt                   ; [9|2|0E] = 0x920E  (disp=+14: halt_byte=0x0132, not taken)                         | MEM_ADDR = 0x0116

    ; branch 2: BR always taken
    BR   b2_land                ; [9|0|02] = 0x9002  (disp=+2: skips dead ADDI)                                      | MEM_ADDR = 0x0118
    ADDI t2, t2, #-1            ; [1|6|6|F] = 0x166F  (never executes)                                               | MEM_ADDR = 0x011A

    ; branch 3: BLT taken (t0=0 < t1=1 → N=1)
b2_land:
    CMP  t0, t1                 ; [2|4|5|6] = 0x2456  (t0 - t1, updates CC)                                          | MEM_ADDR = 0x011C
    BLT  b3_land                ; [9|8|02] = 0x9802  (disp=+2: skips dead ADDI, taken)                               | MEM_ADDR = 0x011E
    ADDI t2, t2, #-1            ; [1|6|6|F] = 0x166F  (never executes)                                               | MEM_ADDR = 0x0120

    ; branch 4: BLE taken (t0=0 <= t1=1 → N=1 or Z=1)
b3_land:
    CMP  t0, t1                 ; [2|4|5|6] = 0x2456  (t0 - t1, updates CC)                                          | MEM_ADDR = 0x0122
    BLE  b4_land                ; [9|A|02] = 0x9A02  (disp=+2: skips dead ADDI, taken)                               | MEM_ADDR = 0x0124
    ADDI t2, t2, #-1            ; [1|6|6|F] = 0x166F  (never executes)                                               | MEM_ADDR = 0x0126

    ; increment counter, loop back if t2 < 16
b4_land:
    ADDI t2, t2, #1             ; [1|6|6|1] = 0x1661  (t2++)                                                         | MEM_ADDR = 0x0128

    LI   t3, #16                ; => IMM #0x001        [8|001] = 0x8001  (prefix: 16>>4 = 1)                         | MEM_ADDR = 0x012A
                                ; => ADDI t3,zero,#0x0  [1|7|0|0] = 0x1700  (t3 = 0x10 = 16 with prefix)             | MEM_ADDR = 0x012C

    ; branch 5: BLT taken while t2 < 16, not taken on last iteration
    CMP  t2, t3                 ; [2|6|7|6] = 0x2676  (t2 - t3, updates CC)                                          | MEM_ADDR = 0x012E
    BLT  loop                   ; [9|8|F2] = 0x98F2  (disp=-14: loop_byte=0x0114, taken 15x)                         | MEM_ADDR = 0x0130

    ; ============================
    ; 0x0132 — halt
    ; ============================
halt:
    BR   halt                   ; [9|0|00] = 0x9000  (disp=0: infinite self-loop)                                     | MEM_ADDR = 0x0132
