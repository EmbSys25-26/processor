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

    ; Deactivate TimerH int_en
    IMM  #0x408                 ; [8|408] = 0x8408  (prefix: upper 12 bits of MMIO word-address 0x8100)               | MEM_ADDR = 0x0104
    SW   r0, r0, #0             ; [6|0|0|0] = 0x6000  (MEM[0+0x8100] = r0 = 0, using prefix)                         | MEM_ADDR = 0x0106

    ; ============================
    ; TEST 1: MEM→EX forwarding (distance 1)
    ; t0 produced in EX, consumed next cycle when t0 is in MEM
    ; without forwarding: t0 still in EX → regfile read returns stale value
    ; expected: t1=2, t2=3, t3=4
    ; ============================
    LI   t0, #1                 ; => IMM #0x000        [8|000] = 0x8000  (prefix: 1>>4 = 0)                           | MEM_ADDR = 0x0108
                                ; => ADDI t0,zero,#0x1  [1|4|0|1] = 0x1401  (t0 = 1)                                 | MEM_ADDR = 0x010A

    ADDI t1, t0, #1             ; [1|5|4|1] = 0x1541  (t1 = t0+1 = 2  — t0 forwarded MEM→EX)                        | MEM_ADDR = 0x010C
    ADDI t2, t1, #1             ; [1|6|5|1] = 0x1651  (t2 = t1+1 = 3  — t1 forwarded MEM→EX)                        | MEM_ADDR = 0x010E
    ADDI t3, t2, #1             ; [1|7|6|1] = 0x1761  (t3 = t2+1 = 4  — t2 forwarded MEM→EX)                        | MEM_ADDR = 0x0110

    ; ============================
    ; TEST 2: WB→EX forwarding (distance 2)
    ; t0 produced in EX, 1 instruction gap, consumed when t0 is in WB
    ; without forwarding: t0 not yet committed to regfile → stale read
    ; expected: t1=11
    ; ============================
    LI   t0, #10                ; => IMM #0x000        [8|000] = 0x8000  (prefix: 10>>4 = 0)                          | MEM_ADDR = 0x0112
                                ; => ADDI t0,zero,#0xA  [1|4|0|A] = 0x140A  (t0 = 10)                                | MEM_ADDR = 0x0114

    ADDI s0, s0, #0             ; [1|8|8|0] = 0x1880  (gap instruction, does not use t0)                              | MEM_ADDR = 0x0116
    ADDI t1, t0, #1             ; [1|5|4|1] = 0x1541  (t1 = t0+1 = 11 — t0 forwarded WB→EX)                         | MEM_ADDR = 0x0118

    ; ============================
    ; TEST 3: back-to-back MEM→EX dependency chain on both rd and rs
    ; ADD t0,t0 reads t0 as both operands — both need forwarding simultaneously
    ; expected: t0 = 1→2→4→8→16
    ; ============================
    LI   t0, #1                 ; => IMM #0x000        [8|000] = 0x8000  (prefix: 1>>4 = 0)                           | MEM_ADDR = 0x011A
                                ; => ADDI t0,zero,#0x1  [1|4|0|1] = 0x1401  (t0 = 1)                                 | MEM_ADDR = 0x011C

    ADD  t0, t0                 ; [2|4|4|0] = 0x2440  (t0 = t0+t0 = 2  — t0 forwarded MEM→EX for both rd and rs)     | MEM_ADDR = 0x011E
    ADD  t0, t0                 ; [2|4|4|0] = 0x2440  (t0 = t0+t0 = 4  — t0 forwarded MEM→EX for both rd and rs)     | MEM_ADDR = 0x0120
    ADD  t0, t0                 ; [2|4|4|0] = 0x2440  (t0 = t0+t0 = 8  — t0 forwarded MEM→EX for both rd and rs)     | MEM_ADDR = 0x0122
    ADD  t0, t0                 ; [2|4|4|0] = 0x2440  (t0 = t0+t0 = 16 — t0 forwarded MEM→EX for both rd and rs)     | MEM_ADDR = 0x0124

    ; ============================
    ; TEST 4: two independent forwards into the same instruction
    ; t2 produced 1 cycle ago (MEM→EX), t3 produced 2 cycles ago (WB→EX)
    ; expected: t2 = 3+5 = 8
    ; ============================
    LI   t0, #3                 ; => IMM #0x000        [8|000] = 0x8000  (prefix: 3>>4 = 0)                           | MEM_ADDR = 0x0126
                                ; => ADDI t0,zero,#0x3  [1|4|0|3] = 0x1403  (t0 = 3)                                 | MEM_ADDR = 0x0128

    LI   t1, #5                 ; => IMM #0x000        [8|000] = 0x8000  (prefix: 5>>4 = 0)                           | MEM_ADDR = 0x012A
                                ; => ADDI t1,zero,#0x5  [1|5|0|5] = 0x1505  (t1 = 5)                                 | MEM_ADDR = 0x012C

    ADD  t2, t0                 ; [2|6|4|0] = 0x2640  (t2 = t0 = 3 — t0 forwarded WB→EX)                             | MEM_ADDR = 0x012E
    ADD  t3, t1                 ; [2|7|5|0] = 0x2750  (t3 = t1 = 5 — t1 forwarded MEM→EX)                            | MEM_ADDR = 0x0130
    ADD  t2, t3                 ; [2|6|7|0] = 0x2670  (t2 = t2+t3 = 8 — t2 forwarded MEM→EX, t3 forwarded WB→EX)    | MEM_ADDR = 0x0132

    ; ============================
    ; TEST 5: forwarding with SUB and CMP
    ; SUB produces t2, CMP consumes t2 (MEM→EX) and t1 (WB→EX) in the next cycle
    ; expected: CMP(8-0, 3) → N=0 Z=0
    ; ============================
    LI   t0, #8                 ; => IMM #0x000        [8|000] = 0x8000  (prefix: 8>>4 = 0)                           | MEM_ADDR = 0x0134
                                ; => ADDI t0,zero,#0x8  [1|4|0|8] = 0x1408  (t0 = 8)                                 | MEM_ADDR = 0x0136

    LI   t1, #3                 ; => IMM #0x000        [8|000] = 0x8000  (prefix: 3>>4 = 0)                           | MEM_ADDR = 0x0138
                                ; => ADDI t1,zero,#0x3  [1|5|0|3] = 0x1503  (t1 = 3)                                 | MEM_ADDR = 0x013A

    SUB  t2, t0                 ; [2|6|4|1] = 0x2641  (t2 = t2-t0 — t0 forwarded WB→EX)                              | MEM_ADDR = 0x013C
    CMP  t2, t1                 ; [2|6|5|6] = 0x2656  (CMP t2,t1 — t2 forwarded MEM→EX, t1 forwarded WB→EX)          | MEM_ADDR = 0x013E

    ; ============================
    ; 0x0140 — halt
    ; ============================
halt:
    BR   halt                   ; [9|0|00] = 0x9000  (disp=0: infinite self-loop)                                     | MEM_ADDR = 0x0140
