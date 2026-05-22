; ============================================================
; 11_compiler_idioms — combines every idiom the C compiler produces:
; dot-labels, BLEU/BLETU, LI(rd, global), CALL(label), unsigned compare
; ladder. Mirrors the shape of CodeGen/codegen.c output for an `<`/`<=`
; comparison ladder.
; ============================================================
.org 0x0000
a:
.word 0x0000     ; global @a
b:
.word 0x0000     ; global @b

main:
    PUSH(fp)
    MOV(fp, sp)
    PUSH(lr)
    LI(t0, a)              ; &@a (m4 expands -> IMM + ADDI)
    LW t1, t0, #0
    LI(t0, b)
    LW t0, t0, #0
    CMP t1, t0
    ADDI t0, r0, #0        ; assume false
    BLEU .cmp_true_0       ; "<" branch (compiler convention)
    BR .cmp_done_0
.cmp_true_0:
    ADDI t0, r0, #1        ; condition true
.cmp_done_0:
    CMP t0, r0
    BEQ .ret_zero
    CALL(__mul)            ; an external runtime call symbol
.ret_zero:
    POP(lr)
    POP(fp)
    RET
__mul:                     ; stub so the CALL above resolves
    RET
