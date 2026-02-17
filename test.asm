; Test program
LW r1, r2, #3
SB r4, r13, #8
ADD r1, r2
XOR r3, r4
ADC r15, r14
SBC r4, r5
CMP r6,r7
SRL r1,r1
SRA r2,r2
BEQ #0xFF
MOV(r4,r5)
POP(a0)
ISR_EPILOGUE
CALL(0X0020)
LI(R3,0X9404)

