; ============================================================
; Register Aliases || Binary Interface (ABI)
; ============================================================

; Argument / return 
.equ a0,    r1
.equ v0,    r1
.equ a1,    r2
.equ v1,    r2
.equ a2,    r3

; Caller-saved temps 
.equ t0,    r4
.equ t1,    r5
.equ t2,    r6
.equ t3,    r7

; Callee-saved temps 
.equ s0,    r8
.equ s1,    r9
.equ s2,    r10 
.equ s3,    r11 

; Frame + stack pointers
.equ fp,    r12        ; frame-pointer
.equ sp,    r13        ; stack-pointer

; Link + global
.equ lr,    r14        ; link register
.equ gp,    r15        ; global pointer

; ============================================================
; Stack PUSH POP 
; ============================================================

.macro PUSH reg
    ADDI sp, sp, #-1      ; word-addressing stack
    SW   \reg, sp, #0
.endm 

.macro POP reg
    LW   \reg, sp, #0
    ADDI sp, sp, #1
.endm 

; ============================================================
; Gray-style pseudo ops
; ============================================================
; (Macros defined before users, order matters for expansion.)
; ============================================================

; mov rd,rs  => addi rd,rs,0
.macro MOV rd, rs
    ADDI \rd, \rs, #0
.endm

; subi rd,rs,imm  => addi rd,rs,-imm
.macro SUBI rd, rs, imm
    ADDI \rd, \rs, #-\imm
.endm

; neg rd  => rsubi rd,0
.macro NEG rd
    RSUBI \rd, #0
.endm

; com rd  => bitwise NOT, full 16 bits
; uses IMM to load 0xFFFF then XORI with -1.
.macro COM rd
    IMM  #0xFFF          ; high 12 bits of 0xFFFF
    XORI \rd, #-1        ; low nibble 0xF
.endm

; or rd,rs  (clobbers t0)
; Gray: mov r1,rd; and r1,rs; xor rd,rs; xor rd,r1
.macro OR rd, rs
    MOV  t0, \rd        ; t0 = rd
    AND  t0, \rs        ; t0 = rd & rs
    XOR  \rd, \rs       ; rd = rd ^ rs
    XOR  \rd, t0        ; rd = rd ^ t0 = rd | rs
.endm

; sll rd  => shift left by 1
.macro SLL rd
    ADD \rd, \rd
.endm

; lea rd, rs, imm  (Gray's lea rd,imm(rs))
; call as: LEA rd, rs, imm
.macro LEA rd, rs, imm
    ADDI \rd, \rs, \imm
.endm

; j target  => absolute jump with prefix
; target is a label or absolute address.
.macro J target
    IMM  \target >> 4          ; upper 12 bits of address
    JAL  r0, r0, \target & 0xF ; rd=r0 (ignored), base=r0=0
.endm

; call target  => absolute CALL with link in lr
.macro CALL target
    IMM  \target >> 4
    JAL  lr, r0, \target & 0xF ; lr = return PC, pc = target
.endm 

; ret  => return via lr
.macro RET
    JAL r0, lr, #0             ; lr = pc, pc = lr + 0
.endm

; lbs rd,rs,imm  (load-byte, sign-extending)
; Gray: lb; lea const 0x80; xor; sub
; Here: uses t0 as scratch and a prefix to form 0x0080.
.macro LBS rd, rs, imm
    LB   \rd, \rs, \imm        ; low byte into rd
    IMM  #0x008                ; prefix for 0x0080
    ADDI t0, r0, #0            ; t0 = 0x0080
    XOR  \rd, t0
    SUB  \rd, t0               ; rd now sign-extended
.endm

; ============================================================
; ISR prologue / epilogue
; ============================================================

.macro ISR_PROLOGUE 
    PUSH s0
    PUSH s1
    PUSH s2
    PUSH s3
    PUSH fp 
    PUSH sp
.endm 

.macro ISR_EPILOGUE 
    POP  sp
    POP  fp
    POP  s3
    POP  s2
    POP  s1
    POP  s0
    RET                     ; IRET via lr
.endm

; ============================================================
; My own macros (shove it)
; ============================================================

; LI rd, imm16
;     imm16 is a byte address or arbitrary 16-bit constant.
;     Example usage: LI sp, STACK_TOP

.macro LI rd, imm
    IMM \imm >> 4
    ADDI \rd, zero, \imm & 0xF
.endm

.macro PUSH_CC
    GETCC t0
    PUSH  t0
.endm

.macro POP_CC
    POP   t0
    SETCC t0
.endm

.macro ISR_PRO
    PUSH lr 
    PUSH_CC 
    STI 
.endm

.macro IRET
    POP_CC
    POP lr
    RET
.endm
