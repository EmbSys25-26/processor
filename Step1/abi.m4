divert(-1)
changecom(`;')
divert(0)dnl

zero .equ r0
a0   .equ r1
v0   .equ r1
a1   .equ r2
v1   .equ r2
a2   .equ r3
t0   .equ r4
t1   .equ r5
t2   .equ r6
t3   .equ r7
s0   .equ r8
s1   .equ r9
s2   .equ r10
s3   .equ r11
fp   .equ r12
sp   .equ r13
lr   .equ r14
gp   .equ r15

divert(-1)
# ============================================================ dnl
# Stack PUSH/POP dnl
# ============================================================ dnl

define(`PUSH', `ADDI sp, sp, #-1
SW $1, sp, #0')

define(`POP', `LW $1, sp, #0
ADDI sp, sp, #1')

# ============================================================ dnl
# Pseudo Operations dnl
# ============================================================ dnl

define(`MOV', 
`ADDI $1, $2, #0')

define(`SUBI', 
`ADDI $1, $2, #-$3')

define(`NEG', 
`RSUBI $1, #0')

define(`COM', 
`IMM #0xFFF
XORI $1, #-1')

define(`OR', 
`MOV(t0,$1)
AND t0, $2
XOR $1, $2
XOR $1, t0')

define(`SLL', 
`ADD $1, $1')

define(`LEA', 
`ADDI $1, $2, #$3')

define(`LBS', 
`LB $1, $2, #$3
IMM #0x008
ADDI t0, r0, #0
XOR $1, t0
SUB $1, t0')

# ============================================================ dnl
# Jump and Call Macros dnl
# ============================================================ dnl

define(`J',
`IMM #eval(($1) >> 4)
JAL r0, r0, #eval(($1) & 15)')

define(`CALL',
`IMM #eval(($1) >> 4)
JAL lr, r0, #eval(($1) & 15)')

define(`RET', `JAL r0, lr, #0')

# ============================================================ dnl
# ISR dnl
# ============================================================ dnl

define(`ISR_PROLOGUE', 
`PUSH(s0)
PUSH(s1)
PUSH(s2)
PUSH(s3)
PUSH(fp)
PUSH(sp)')

define(`ISR_EPILOGUE', 
`POP(sp)
POP(fp)
POP(s3)
POP(s2)
POP(s1)
POP(s0)
RET')

# ============================================================ dnl
# Custom Macros dnl
# ============================================================ dnl

define(`LI',
`IMM #eval(($2) >> 4)
ADDI $1, zero, #eval(($2) & 15)')

define(`PUSH_CC', 
`GETCC t0 
PUSH(t0)')

define(`POP_CC', 
`POP(t0) 
SETCC t0')

define(`ISR_PRO', 
`PUSH(lr)
PUSH_CC
STI')

define(`IRET', 
`POP_CC
POP lr
RET')

divert(0)dnl

