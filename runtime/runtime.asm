; =============================================================================
; runtime.asm — software arithmetic helpers for the gr0040 (no HW mul/div).
;
; Exports: __mul, __divu, __modu, __divs, __mods
;
; Implementation follows the algorithms documented in
;   docs/runtime/Runtime Library Specification.md
;
; ABI:
;   r1 (a0) IN  : dividend / multiplicand
;   r1 (a0) OUT : quotient / product / remainder
;   r2 (a1) IN  : divisor  / multiplier
;
; Branch convention reminder (project software-stack):
;   BLEU  -> strict  <  unsigned     (encodes hardware cond 0xC)
;   BLETU -> ≤           unsigned    (encodes hardware cond 0xE)
;
; Divide-by-zero policy: returns 0 (no trap).
;
; This file expects m4 macro expansion against tools/abi.m4 before being
; passed to the assembler. The build script handles that.
; =============================================================================

; -----------------------------------------------------------------------------
; __mul — unsigned/signed 16-bit multiply (low 16 bits)
; r1_out = r1_in * r2_in
; Leaf. Clobbers r1..r6.
; -----------------------------------------------------------------------------
__mul:
    MOV(r3, r0)             ; r3 = 0 (accumulator)
    ADDI r4, r0, #1
    IMM  #0x001             ; IMM-prefix + ADDI loads r4 = (0x001<<4)|0 = 16
    ADDI r4, r0, #0         ; r4 = 16 (loop count)
    ADDI r5, r0, #1         ; r5 = 1 (SRL shift amount)
__mul_loop:
    MOV(r6, r2)             ; r6 = r2
    ANDI r6, #1             ; r6 = r2 & 1
    CMP  r6, r0
    BEQ  __mul_no_add       ; if (r2 & 1) == 0, skip add
    ADD  r3, r1             ; accumulator += multiplicand
__mul_no_add:
    ADD  r1, r1             ; r1 <<= 1  (multiplicand doubles)
    SRL  r2, r5             ; r2 >>= 1  (consume next multiplier bit)
    ADDI r4, r4, #-1
    CMP  r4, r0
    BEQ  __mul_done
    BR   __mul_loop
__mul_done:
    MOV(r1, r3)             ; r1 = result
    RET

; -----------------------------------------------------------------------------
; __divu — unsigned 16-bit division (restoring long division, MSB-first)
; r1_out = r1_in / r2_in
; Leaf. Clobbers r1..r7. divisor==0 -> returns 0.
; -----------------------------------------------------------------------------
__divu:
    CMP  r2, r0
    BEQ  __divu_zero        ; divisor==0 -> return 0

    MOV(r3, r0)             ; r3 = remainder
    MOV(r4, r0)             ; r4 = quotient
    IMM  #0x001
    ADDI r5, r0, #0         ; r5 = 16 (loop count)
    LI(r6, 0x000F)          ; r6 = 15 (SRA shift to extract MSB of dividend)
__divu_loop:
    ADD  r3, r3             ; remainder <<= 1
    ADD  r4, r4             ; quotient  <<= 1
    MOV(r7, r1)
    SRA  r7, r6             ; sign-extend bit 15 across r7 ...
    ANDI r7, #1             ; ... then keep only bit 0 = original MSB
    OR(r3, r7)              ; remainder |= dividend MSB
    ADD  r1, r1             ; dividend <<= 1
    CMP  r3, r2
    BLEU __divu_no_sub      ; rem < divisor -> skip subtract (BLEU = strict <)
    SUB  r3, r2             ; remainder -= divisor
    ADDI r4, r4, #1         ; quotient |= 1 (set LSB)
__divu_no_sub:
    ADDI r5, r5, #-1
    CMP  r5, r0
    BEQ  __divu_done
    BR   __divu_loop
__divu_done:
    MOV(r1, r4)
    RET
__divu_zero:
    MOV(r1, r0)
    RET

; -----------------------------------------------------------------------------
; __modu — unsigned 16-bit remainder
; r1_out = r1_in % r2_in
; Leaf. Clobbers r1..r7. divisor==0 -> returns 0.
; Same loop as __divu but returns remainder instead of quotient.
; -----------------------------------------------------------------------------
__modu:
    CMP  r2, r0
    BEQ  __modu_zero

    MOV(r3, r0)             ; remainder
    IMM  #0x001
    ADDI r5, r0, #0         ; r5 = 16
    LI(r6, 0x000F)          ; r6 = 15
__modu_loop:
    ADD  r3, r3             ; remainder <<= 1
    MOV(r7, r1)
    SRA  r7, r6
    ANDI r7, #1
    OR(r3, r7)
    ADD  r1, r1
    CMP  r3, r2
    BLEU __modu_no_sub      ; strict less-than -> skip
    SUB  r3, r2
__modu_no_sub:
    ADDI r5, r5, #-1
    CMP  r5, r0
    BEQ  __modu_done
    BR   __modu_loop
__modu_done:
    MOV(r1, r3)
    RET
__modu_zero:
    MOV(r1, r0)
    RET

; -----------------------------------------------------------------------------
; __divs — signed 16-bit division (truncated toward zero)
; r1_out = r1_in / r2_in (signed)
; Non-leaf: calls __divu. Saves fp, lr, r8.
;
; sign_flag (r8) is XOR-toggled per negative operand:
;   * one negative  -> r8=1  -> negate quotient
;   * two negatives -> r8=2  -> ANDI r8,#1=0 -> no negation
; -----------------------------------------------------------------------------
__divs:
    PUSH(fp)
    MOV(fp, sp)
    PUSH(lr)
    PUSH(r8)

    CMP  r1, r0
    BEQ  __divs_zero_dividend

    MOV(r8, r0)             ; sign_flag = 0
    CMP  r1, r0
    BLT  __divs_neg_dividend
    BR   __divs_check_divisor
__divs_neg_dividend:
    NEG(r1)
    ADDI r8, r8, #1         ; flag ^= 1 (toggle via add — value is 0 or 1)
__divs_check_divisor:
    CMP  r2, r0
    BLT  __divs_neg_divisor
    BR   __divs_do_unsigned
__divs_neg_divisor:
    NEG(r2)
    ADDI r8, r8, #1         ; flag ^= 1
__divs_do_unsigned:
    CALL(__divu)
    ANDI r8, #1             ; keep low bit (0 or 1)
    CMP  r8, r0
    BEQ  __divs_done
    NEG(r1)
__divs_done:
    POP(r8)
    POP(lr)
    POP(fp)
    RET
__divs_zero_dividend:
    MOV(r1, r0)
    POP(r8)
    POP(lr)
    POP(fp)
    RET

; -----------------------------------------------------------------------------
; __mods — signed 16-bit remainder (sign matches dividend, per C99)
; r1_out = r1_in % r2_in (signed)
; Non-leaf: calls __modu. Saves fp, lr, r8.
; -----------------------------------------------------------------------------
__mods:
    PUSH(fp)
    MOV(fp, sp)
    PUSH(lr)
    PUSH(r8)

    CMP  r1, r0
    BEQ  __mods_zero_dividend

    MOV(r8, r0)             ; neg_flag = 0
    CMP  r1, r0
    BLT  __mods_neg_dividend
    BR   __mods_check_divisor
__mods_neg_dividend:
    NEG(r1)
    ADDI r8, r0, #1         ; neg_flag = 1 (only dividend sign matters)
__mods_check_divisor:
    CMP  r2, r0
    BLT  __mods_abs_divisor
    BR   __mods_do_unsigned
__mods_abs_divisor:
    NEG(r2)
__mods_do_unsigned:
    CALL(__modu)
    CMP  r8, r0
    BEQ  __mods_done
    NEG(r1)
__mods_done:
    POP(r8)
    POP(lr)
    POP(fp)
    RET
__mods_zero_dividend:
    MOV(r1, r0)
    POP(r8)
    POP(lr)
    POP(fp)
    RET
