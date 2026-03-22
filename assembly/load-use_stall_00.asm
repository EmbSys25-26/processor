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
    ; Deactivate TimerH int_en
    IMM  #0x408                 ; [8|408] = 0x8408  (prefix: upper 12 bits of MMIO word-address 0x8100)               | MEM_ADDR = 0x0104
    SW   r0, r0, #0             ; [6|0|0|0] = 0x6000  (MEM[0+0x8100] = r0 = 0, using prefix)                         | MEM_ADDR = 0x0106

    ; Setup: store known values into memory for later loads
    ; MEM[sp+0] = 7,  MEM[sp+1] = 3
    LI   t0, #7                 ; => IMM #0x000        [8|000] = 0x8000  (prefix: 7>>4 = 0)                           | MEM_ADDR = 0x0108
                                ; => ADDI t0,zero,#0x7  [1|4|0|7] = 0x1407  (t0 = 7)                                 | MEM_ADDR = 0x010A
    SW   t0, sp, #0             ; [6|4|D|0] = 0x64D0  (MEM[sp+0] = 7)                                                | MEM_ADDR = 0x010C

    LI   t0, #3                 ; => IMM #0x000        [8|000] = 0x8000  (prefix: 3>>4 = 0)                           | MEM_ADDR = 0x010E
                                ; => ADDI t0,zero,#0x3  [1|4|0|3] = 0x1403  (t0 = 3)                                 | MEM_ADDR = 0x0110
    SW   t0, sp, #1             ; [6|4|D|1] = 0x64D1  (MEM[sp+1] = 3)                                                | MEM_ADDR = 0x0112

    ; t1 = 0xFF (mask — AND with any value ≤ 0xFF gives that value directly)
    LI   t1, #0xFF              ; => IMM #0x00F        [8|00F] = 0x800F  (prefix: 0xFF>>4 = 0xF)                      | MEM_ADDR = 0x0114
                                ; => ADDI t1,zero,#0xF  [1|5|0|F] = 0x150F  (t1 = 0x00FF)                            | MEM_ADDR = 0x0116

    ; ============================
    ; TEST 1: load-use with 0 gap — 2 stalls expected
    ; AND enters ID while LW is still in MEM (mem_wait cycle 1)
    ; pipeline stalls AND twice before t0 is available via WB→EX forward
    ; expected: t1 = 0xFF & 7 = 7
    ; ============================
    LW   t0, sp, #0             ; [4|4|D|0] = 0x44D0  (t0 = MEM[sp+0] = 7)                                           | MEM_ADDR = 0x0118
    AND  t1, t0                 ; [2|5|4|2] = 0x2542  (t1 = 0xFF & 7 = 7 — load-use: 0 gap → 2 stalls)               | MEM_ADDR = 0x011A

    ; ============================
    ; TEST 2: load-use with 1 gap — 1 stall expected
    ; 1 independent instruction absorbs 1 stall cycle, 1 stall still needed
    ; expected: t1 = 7 & 7 = 7
    ; ============================
    LI   t1, #0xFF              ; => IMM #0x00F        [8|00F] = 0x800F  (prefix: 0xFF>>4 = 0xF)                      | MEM_ADDR = 0x011C
                                ; => ADDI t1,zero,#0xF  [1|5|0|F] = 0x150F  (t1 = 0x00FF)                            | MEM_ADDR = 0x011E
    LW   t0, sp, #0             ; [4|4|D|0] = 0x44D0  (t0 = MEM[sp+0] = 7)                                           | MEM_ADDR = 0x0120
    ADDI s0, s0, #0             ; [1|8|8|0] = 0x1880  (gap: independent, absorbs 1 stall cycle)                       | MEM_ADDR = 0x0122
    AND  t1, t0                  ; [2|5|4|2] = 0x2542  (t1 = 0xFF & 7 = 7 — load-use: 1 gap → 1 stall)                | MEM_ADDR = 0x0124

    ; ============================
    ; TEST 3: load-use with 2 gaps — 1 stall expected
    ; 2 independent instructions fully hide the 2-cycle memory latency
    ; expected: t1 = 0xFF & 7 = 7
    ; ============================
    LI   t1, #0xFF              ; => IMM #0x00F        [8|00F] = 0x800F  (prefix: 0xFF>>4 = 0xF)                      | MEM_ADDR = 0x0126
                                ; => ADDI t1,zero,#0xF  [1|5|0|F] = 0x150F  (t1 = 0x00FF)                            | MEM_ADDR = 0x0128
    LW   t0, sp, #0             ; [4|4|D|0] = 0x44D0  (t0 = MEM[sp+0] = 7)                                           | MEM_ADDR = 0x012A
    ADDI s0, s0, #0             ; [1|8|8|0] = 0x1880  (gap 1: independent, absorbs stall cycle 1)                     | MEM_ADDR = 0x012C
    ADDI s1, s1, #0             ; [1|9|9|0] = 0x1990  (gap 2: independent, absorbs stall cycle 2)                     | MEM_ADDR = 0x012E
    AND  t1, t0                 ; [2|5|4|2] = 0x2542  (t1 = 0xFF & 7 = 7 — no stall, latency fully hidden)            | MEM_ADDR = 0x0130

    ; ============================
    ; TEST 4: back-to-back loads both used immediately
    ; each LW→use pair causes 2 stalls independently
    ; expected: t2 = 7 + 3 = 10
    ; ============================
    LI   t2, #0                 ; => IMM #0x000        [8|000] = 0x8000  (prefix: 0>>4 = 0)                           | MEM_ADDR = 0x0132
                                ; => ADDI t2,zero,#0x0  [1|6|0|0] = 0x1600  (t2 = 0, cleared)                        | MEM_ADDR = 0x0134
    LW   t0, sp, #0             ; [4|4|D|0] = 0x44D0  (t0 = MEM[sp+0] = 7)                                           | MEM_ADDR = 0x0136
    ADD  t2, t0                 ; [2|6|4|0] = 0x2640  (t2 = 0+7 = 7 — load-use: 0 gap → 2 stalls)                    | MEM_ADDR = 0x0138
    LW   t1, sp, #1             ; [4|5|D|1] = 0x45D1  (t1 = MEM[sp+1] = 3)                                           | MEM_ADDR = 0x013A
    ADD  t2, t1                 ; [2|6|5|0] = 0x2650  (t2 = 7+3 = 10 — load-use: 0 gap → 2 stalls)                   | MEM_ADDR = 0x013C

    ; ============================
    ; TEST 5: load-use on store data operand (0 gap)
    ; SW uses t0 as the data to write — hazard unit must also stall for this case
    ; expected: MEM[sp+2] = 7
    ; ============================
    LW   t0, sp, #0             ; [4|4|D|0] = 0x44D0  (t0 = MEM[sp+0] = 7)                                           | MEM_ADDR = 0x013E
    SW   t0, sp, #2             ; [6|4|D|2] = 0x64D2  (MEM[sp+2] = t0 = 7 — load-use: 0 gap → 2 stalls)              | MEM_ADDR = 0x0140

    ; ============================
    ; 0x0142 — halt
    ; ============================
halt:
    BR   halt                   ; [9|0|00] = 0x9000  (disp=0: infinite self-loop)                                     | MEM_ADDR = 0x0142
