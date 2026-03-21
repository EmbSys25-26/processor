.include "../tools/abi.inc"

    .equ RESET_VEC, 0x0100
    .equ STACK_TOP, 0x03FF
    .equ ITER_OUTER, 8      ; número de iterações do loop externo
    .equ ITER_INNER, 16     ; número de iterações do loop interno

    .org RESET_VEC

; =============================================
; Reset / inicialização
; =============================================
reset:

    ; Inicializa stack pointer com STACK_TOP = 0x03FF
    LI   sp, #STACK_TOP             ; 0x803F 0x1D0F  MEM_ADDR=0x0100

    ; s0 = contador outer loop = 0
    LI   s0, #0                     ; 0x8000 0x1800  MEM_ADDR=0x0104

    ; s1 = limite outer loop = ITER_OUTER = 8
    LI   s1, #ITER_OUTER            ; 0x8000 0x1908  MEM_ADDR=0x0108

    ; t3 = acumulador global = 0
    LI   t3, #0                     ; 0x8000 0x1700  MEM_ADDR=0x010C

; =============================================
; TEST 1: BEQ tomado — s0==s0 → Z=1 → salta ADDI
; =============================================

    ; CMP s0, s0 → Z=1
    CMP  s0, s0                     ; 0x2886  MEM_ADDR=0x0110

    ; BEQ tomado: salta o ADDI que NÃO deve executar
    BEQ  test1_ok                   ; 0x9202  MEM_ADDR=0x0112

    ; NÃO deve executar (BEQ tomado)
    ADDI t3, t3, #1                 ; 0x1771  MEM_ADDR=0x0114

; =============================================
; TEST 2: BEQ não tomado — s0!=t0 → Z=0 → não salta
; =============================================
test1_ok:

    ; t0 = 1
    LI   t0, #1                     ; 0x8000 0x1401  MEM_ADDR=0x0116

    ; CMP s0(=0), t0(=1) → Z=0
    CMP  s0, t0                     ; 0x2846  MEM_ADDR=0x011A

    ; BEQ não tomado: NÃO salta, executa ADDI t3+1
    BEQ  test2_fail                 ; 0x9203  MEM_ADDR=0x011C

    ; DEVE executar (BEQ não tomado)
    ADDI t3, t3, #1                 ; 0x1771  MEM_ADDR=0x011E

    ; Salta por cima do bloco fail
    BR   test2_ok                   ; 0x9002  MEM_ADDR=0x0120

    ; NÃO deve executar
test2_fail:
    ADDI t3, t3, #-1                ; 0x177F  MEM_ADDR=0x0122

; =============================================
; TEST 3: BLT não tomado — t0(=5) > t1(=3) → N=0 → não salta
; =============================================
test2_ok:

    ; t0 = 5, t1 = 3
    LI   t0, #5                     ; 0x8000 0x1405  MEM_ADDR=0x0124
    LI   t1, #3                     ; 0x8000 0x1503  MEM_ADDR=0x0128

    ; CMP t0(=5), t1(=3) → 5-3>0 → N=0
    CMP  t0, t1                     ; 0x2456  MEM_ADDR=0x012C

    ; BLT não tomado: NÃO salta, executa ADDI t3+1
    BLT  test3_fail                 ; 0x9803  MEM_ADDR=0x012E

    ; DEVE executar
    ADDI t3, t3, #1                 ; 0x1771  MEM_ADDR=0x0130

    ; Salta por cima do bloco fail
    BR   test3_ok                   ; 0x9002  MEM_ADDR=0x0132

    ; NÃO deve executar
test3_fail:
    ADDI t3, t3, #-1                ; 0x177F  MEM_ADDR=0x0134

; =============================================
; TEST 4: BLT tomado — t0(=2) < t1(=7) → N=1 → salta
; =============================================
test3_ok:

    ; t0 = 2, t1 = 7
    LI   t0, #2                     ; 0x8000 0x1402  MEM_ADDR=0x0136
    LI   t1, #7                     ; 0x8000 0x1507  MEM_ADDR=0x013A

    ; CMP t0(=2), t1(=7) → 2-7<0 → N=1
    CMP  t0, t1                     ; 0x2456  MEM_ADDR=0x013E

    ; BLT tomado: salta o ADDI que NÃO deve executar
    BLT  test4_ok                   ; 0x9802  MEM_ADDR=0x0140

    ; NÃO deve executar (BLT tomado)
    ADDI t3, t3, #-1                ; 0x177F  MEM_ADDR=0x0142

; =============================================
; TEST 5: BLE tomado — t0(=4) == t1(=4) → Z=1 → salta
; =============================================
test4_ok:

    ; DEVE executar
    ADDI t3, t3, #1                 ; 0x1771  MEM_ADDR=0x0144

    ; t0 = 4, t1 = 4
    LI   t0, #4                     ; 0x8000 0x1404  MEM_ADDR=0x0146
    LI   t1, #4                     ; 0x8000 0x1504  MEM_ADDR=0x014A

    ; CMP t0(=4), t1(=4) → Z=1
    CMP  t0, t1                     ; 0x2456  MEM_ADDR=0x014E

    ; BLE tomado: salta o ADDI que NÃO deve executar
    BLE  test5_ok                   ; 0x9A02  MEM_ADDR=0x0150

    ; NÃO deve executar (BLE tomado)
    ADDI t3, t3, #-1                ; 0x177F  MEM_ADDR=0x0152

; =============================================
; TEST 6: BR — always branch incondicional
; =============================================
test5_ok:

    ; DEVE executar
    ADDI t3, t3, #1                 ; 0x1771  MEM_ADDR=0x0154

    ; BR sempre tomado: salta o ADDI que NÃO deve executar
    BR   test6_ok                   ; 0x9002  MEM_ADDR=0x0156

    ; NÃO deve executar (BR sempre tomado)
    ADDI t3, t3, #-1                ; 0x177F  MEM_ADDR=0x0158

; =============================================
; Inicialização do loop principal
; =============================================
test6_ok:

    ; DEVE executar
    ADDI t3, t3, #1                 ; 0x1771  MEM_ADDR=0x015A

    ; s0 = outer counter = 0
    LI   s0, #0                     ; 0x8000 0x1800  MEM_ADDR=0x015C

; =============================================
; OUTER LOOP: repete ITER_OUTER=8 vezes
; =============================================
outer_loop:

    ; s2 = inner counter = 0
    LI   s2, #0                     ; 0x8000 0x1A00  MEM_ADDR=0x0160

    ; t2 = inner limit = ITER_INNER = 16
    LI   t2, #ITER_INNER            ; 0x8001 0x1600  MEM_ADDR=0x0164

; =============================================
; INNER LOOP: repete ITER_INNER=16 vezes por outer
;   Cada iteração exercita BEQ, BLT, BLE
; =============================================
inner_loop:

    ; t3 += s2  (acumula valor do counter)
    ADD  t3, s2                     ; 0x27A0  MEM_ADDR=0x0168

    ; --- BEQ: branch se s2 == s0 (outer counter) ---
    ; CMP s2, s0 → Z=1 apenas quando s2==s0
    CMP  s2, s0                     ; 0x2A86  MEM_ADDR=0x016A

    ; BEQ tomado quando s2==s0 (1 vez por outer iteration)
    BEQ  inner_eq                   ; 0x9203  MEM_ADDR=0x016C

    ; DEVE executar quando s2 != s0
    ADDI t3, t3, #1                 ; 0x1771  MEM_ADDR=0x016E

    ; Salta por cima do bloco eq
    BR   inner_eq_done              ; 0x9002  MEM_ADDR=0x0170

    ; DEVE executar quando s2 == s0
inner_eq:
    ADDI t3, t3, #-1                ; 0x177F  MEM_ADDR=0x0172

    ; --- BLT: branch se s2 < 8 ---
inner_eq_done:

    ; t0 = 8
    LI   t0, #8                     ; 0x8000 0x1408  MEM_ADDR=0x0174

    ; CMP s2, t0(=8) → BLT tomado quando s2<8 (primeiras 8 iterações)
    CMP  s2, t0                     ; 0x2A46  MEM_ADDR=0x0178

    ; BLT tomado quando s2<8
    BLT  inner_lt_ok                ; 0x9803  MEM_ADDR=0x017A

    ; DEVE executar quando s2 >= 8
    ADDI t3, t3, #-1                ; 0x177F  MEM_ADDR=0x017C

    ; Salta por cima do bloco lt_ok
    BR   inner_lt_done              ; 0x9002  MEM_ADDR=0x017E

    ; DEVE executar quando s2 < 8
inner_lt_ok:
    ADDI t3, t3, #1                 ; 0x1771  MEM_ADDR=0x0180

    ; --- BLE: branch se s2 <= 8 ---
inner_lt_done:

    ; t0 = 8
    LI   t0, #8                     ; 0x8000 0x1408  MEM_ADDR=0x0182

    ; CMP s2, t0(=8) → BLE tomado quando s2<=8 (primeiras 9 iterações)
    CMP  s2, t0                     ; 0x2A46  MEM_ADDR=0x0186

    ; BLE tomado quando s2<=8
    BLE  inner_le_ok                ; 0x9A03  MEM_ADDR=0x0188

    ; DEVE executar quando s2 > 8
    ADDI t3, t3, #-1                ; 0x177F  MEM_ADDR=0x018A

    ; Salta por cima do bloco le_ok
    BR   inner_le_done              ; 0x9002  MEM_ADDR=0x018C

    ; DEVE executar quando s2 <= 8
inner_le_ok:
    ADDI t3, t3, #1                 ; 0x1771  MEM_ADDR=0x018E

    ; --- Incrementa inner counter e verifica fim ---
inner_le_done:

    ; s2++
    ADDI s2, s2, #1                 ; 0x1AA1  MEM_ADDR=0x0190

    ; CMP s2, t2(=ITER_INNER) → BEQ tomado quando s2==16
    CMP  s2, t2                     ; 0x2A66  MEM_ADDR=0x0192

    ; BEQ tomado quando s2==ITER_INNER → fim do inner loop
    BEQ  inner_done                 ; 0x9202  MEM_ADDR=0x0194

    ; Volta ao início do inner loop
    BR   inner_loop                 ; 0x90E9  MEM_ADDR=0x0196

; =============================================
; Fim inner loop — incrementa outer e verifica
; =============================================
inner_done:

    ; s0++
    ADDI s0, s0, #1                 ; 0x1881  MEM_ADDR=0x0198

    ; CMP s0, s1(=ITER_OUTER) → BEQ tomado quando s0==8
    CMP  s0, s1                     ; 0x2896  MEM_ADDR=0x019A

    ; BEQ tomado quando s0==ITER_OUTER → fim do outer loop
    BEQ  outer_done                 ; 0x9202  MEM_ADDR=0x019C

    ; Volta ao início do outer loop
    BR   outer_loop                 ; 0x90E1  MEM_ADDR=0x019E

; =============================================
; Fim — CPU pára aqui (loop infinito)
; =============================================
outer_done:

halt:
    ; BR halt → disp=0 → salta para si próprio
    BR   halt                       ; 0x9000  MEM_ADDR=0x01A0
