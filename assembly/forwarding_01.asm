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
    LI   sp, #STACK_TOP         ; => IMM #0x03F        [8|03F] = 0x803F                                               | MEM_ADDR = 0x0100
                                ; => ADDI sp,zero,#0xF  [1|D|0|F] = 0x1D0F  (sp = 0x03FF)                            | MEM_ADDR = 0x0102
main:
    ; Deactivate TimerH int_en
    IMM  #0x408                 ; [8|408] = 0x8408                                                                    | MEM_ADDR = 0x0104
    SW   r0, r0, #0             ; [6|0|0|0] = 0x6000  (MEM[0x8100] = 0)                                              | MEM_ADDR = 0x0106

    ; ============================
    ; TEST 1: MEM→EX forwarding (distância 1, sem gap)
    ; Produz t0 em EX, consome t0 no ciclo seguinte quando t0 está em MEM.
    ; Sem forwarding: regfile devolve valor desatualizado.
    ; esperado: t1 = 1+1 = 2
    ; ============================
    LI   t0, #1                 ; => IMM #0x000        [8|000] = 0x8000                                               | MEM_ADDR = 0x0108
                                ; => ADDI t0,zero,#0x1  [1|4|0|1] = 0x1401  (t0 = 1)                                 | MEM_ADDR = 0x010A
    ADDI t1, t0, #1             ; [1|5|4|1] = 0x1541  (t1 = t0+1 = 2 — forward MEM→EX)                               | MEM_ADDR = 0x010C

    ; ============================
    ; TEST 2: forwarding com 1 gap (distância 2)
    ; Antes do WB ser removido este caso era WB→EX.
    ; Agora é simplesmente MEM→EX com 1 instrução de gap.
    ; Produz t0=10, instrução independente no meio, consome t0.
    ; Sem forwarding: t0 ainda não escrito no regfile → valor errado.
    ; esperado: t1 = 10+1 = 11
    ; ============================
    LI   t0, #10                ; => IMM #0x000        [8|000] = 0x8000                                               | MEM_ADDR = 0x010E
                                ; => ADDI t0,zero,#0xA  [1|4|0|A] = 0x140A  (t0 = 10)                                | MEM_ADDR = 0x0110
    ADDI s0, s0, #0             ; [1|8|8|0] = 0x1880  (gap: instrução independente)                                   | MEM_ADDR = 0x0112
    ADDI t1, t0, #1             ; [1|5|4|1] = 0x1541  (t1 = t0+1 = 11 — forward MEM→EX com 1 gap)                    | MEM_ADDR = 0x0114

    ; ============================
    ; TEST 3: dois forwards simultâneos com 1 gap cada
    ; Produz t0=3 e t1=5 em instruções separadas.
    ; A instrução ADD t2,t3 consome ambos com 1 gap de distância.
    ; ADD t2,t0: t2 = 0+3 = 3  (t0 com 1 gap → MEM→EX)
    ; ADD t3,t1: t3 = 0+5 = 5  (t1 com distância 1 → MEM→EX)
    ; ADD t2,t3: t2 = 3+5 = 8  (t2 MEM→EX, t3 com 1 gap → MEM→EX)
    ; esperado: t2 = 8, t3 = 5
    ; ============================
    LI   t0, #3                 ; => IMM #0x000        [8|000] = 0x8000                                               | MEM_ADDR = 0x0116
                                ; => ADDI t0,zero,#0x3  [1|4|0|3] = 0x1403  (t0 = 3)                                 | MEM_ADDR = 0x0118
    LI   t1, #5                 ; => IMM #0x000        [8|000] = 0x8000                                               | MEM_ADDR = 0x011A
                                ; => ADDI t1,zero,#0x5  [1|5|0|5] = 0x1505  (t1 = 5)                                 | MEM_ADDR = 0x011C
    LI   t2, #0                 ; => IMM #0x000        [8|000] = 0x8000                                               | MEM_ADDR = 0x011E
                                ; => ADDI t2,zero,#0x0  [1|6|0|0] = 0x1600  (t2 = 0)                                 | MEM_ADDR = 0x0120
    LI   t3, #0                 ; => IMM #0x000        [8|000] = 0x8000                                               | MEM_ADDR = 0x0122
                                ; => ADDI t3,zero,#0x0  [1|7|0|0] = 0x1700  (t3 = 0)                                 | MEM_ADDR = 0x0124

    ADD  t2, t0                 ; [2|6|4|0] = 0x2640  (t2 = 0+3 = 3 — t0 com 1 gap: MEM→EX)                          | MEM_ADDR = 0x0126
    ADD  t3, t1                 ; [2|7|5|0] = 0x2750  (t3 = 0+5 = 5 — t1 MEM→EX)                                     | MEM_ADDR = 0x0128
    ADD  t2, t3                 ; [2|6|7|0] = 0x2670  (t2 = 3+5 = 8 — t2 MEM→EX, t3 com 1 gap: MEM→EX)               | MEM_ADDR = 0x012A

    ; ============================
    ; TEST 4: cadeia com gaps alternados
    ; Verifica que o forwarding com 1 gap funciona em sequência contínua.
    ; t0=1, t0=t0*2 (ADD t0,t0 com 1 gap entre cada par)
    ; gap = ADDI s0,s0,#0 (instrução independente)
    ; esperado: t0 = 1 → 2 → 4 → 8
    ; ============================
    LI   t0, #1                 ; => IMM #0x000        [8|000] = 0x8000                                               | MEM_ADDR = 0x012C
                                ; => ADDI t0,zero,#0x1  [1|4|0|1] = 0x1401  (t0 = 1)                                 | MEM_ADDR = 0x012E
    ADDI s0, s0, #0             ; [1|8|8|0] = 0x1880  (gap 1)                                                         | MEM_ADDR = 0x0130
    ADD  t0, t0                 ; [2|4|4|0] = 0x2440  (t0 = 1+1 = 2  — t0 com 1 gap: MEM→EX)                         | MEM_ADDR = 0x0132
    ADDI s0, s0, #0             ; [1|8|8|0] = 0x1880  (gap 2)                                                         | MEM_ADDR = 0x0134
    ADD  t0, t0                 ; [2|4|4|0] = 0x2440  (t0 = 2+2 = 4  — t0 com 1 gap: MEM→EX)                         | MEM_ADDR = 0x0136
    ADDI s0, s0, #0             ; [1|8|8|0] = 0x1880  (gap 3)                                                         | MEM_ADDR = 0x0138
    ADD  t0, t0                 ; [2|4|4|0] = 0x2440  (t0 = 4+4 = 8  — t0 com 1 gap: MEM→EX)                         | MEM_ADDR = 0x013A

    ; ============================
    ; TEST 5: SUB e CMP com 1 gap (caso antes coberto pelo WB→EX)
    ; t0=8, t1=3, gap, SUB t0,t1 → t0 = 8-3 = 5 (t1 com 1 gap: MEM→EX)
    ; gap, CMP t0,t1 → CMP(5,3): Z=0 N=0 (t0 MEM→EX, t1 com 1 gap: MEM→EX)
    ; esperado: t0 = 5, Z=0, N=0
    ; ============================
    LI   t0, #8                 ; => IMM #0x000        [8|000] = 0x8000                                               | MEM_ADDR = 0x013C
                                ; => ADDI t0,zero,#0x8  [1|4|0|8] = 0x1408  (t0 = 8)                                 | MEM_ADDR = 0x013E
    LI   t1, #3                 ; => IMM #0x000        [8|000] = 0x8000                                               | MEM_ADDR = 0x0140
                                ; => ADDI t1,zero,#0x3  [1|5|0|3] = 0x1503  (t1 = 3)                                 | MEM_ADDR = 0x0142
    ADDI s0, s0, #0             ; [1|8|8|0] = 0x1880  (gap: instrução independente)                                   | MEM_ADDR = 0x0144
    SUB  t0, t1                 ; [2|4|5|1] = 0x2451  (t0 = 8-3 = 5 — t1 com 1 gap: MEM→EX)                          | MEM_ADDR = 0x0146
    ADDI s0, s0, #0             ; [1|8|8|0] = 0x1880  (gap: instrução independente)                                   | MEM_ADDR = 0x0148
    CMP  t0, t1                 ; [2|4|5|6] = 0x2456  (CMP(5,3): Z=0 N=0 — t0 MEM→EX, t1 com 1 gap: MEM→EX)          | MEM_ADDR = 0x014A

    ; ============================
    ; 0x014C — halt
    ; ============================
halt:
    BR   halt                   ; [9|0|00] = 0x9000  (self-loop)                                                       | MEM_ADDR = 0x014C
