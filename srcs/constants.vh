`ifndef CONSTANTS_VH
`define CONSTANTS_VH

/*************************************************************************************
 * CPU BUS WIDTHS
 ************************************************************************************/
`define CPU_W  16   // register width 
`define CPU_N  15   // register MSB
`define CPU_AN 15   // address MSB
`define CPU_IN 15   // instruction MSB

/*************************************************************************************
 * OPCODES
 ************************************************************************************/
`define OP_JAL  4'h0
`define OP_ADDI 4'h1
`define OP_RR   4'h2
`define OP_RI   4'h3
`define OP_LW   4'h4
`define OP_LB   4'h5
`define OP_SW   4'h6
`define OP_SB   4'h7
`define OP_IMM  4'h8
`define OP_BX   4'h9
`define OP_SYS  4'hA  // SYS is used for both CLI and STI
`define OP_CLI  4'hB  // CLI disables interrupts
`define OP_STI  4'hC  // STI enables interrupts
`define OP_NOP  4'hF

/*************************************************************************************
 * ALU FUNCTIONS
 ************************************************************************************/
`define FN_ADD   4'h0
`define FN_SUB   4'h1
`define FN_AND   4'h2
`define FN_XOR   4'h3
`define FN_ADC   4'h4
`define FN_SBC   4'h5
`define FN_CMP   4'h6
`define FN_SRL   4'h7
`define FN_SRA   4'h8
`define FN_GETCC 4'h9
`define FN_SETCC 4'hA

/*************************************************************************************
 * BRANCH CONDITIONS
 ************************************************************************************/
`define BR_BR   4'h0
`define BR_BEQ  4'h2
`define BR_BC   4'h4
`define BR_BV   4'h6
`define BR_BLT  4'h8
`define BR_BLE  4'hA
`define BR_BLTU 4'hC
`define BR_BLEU 4'hE

/*************************************************************************************
 * CPU CONSTANTS
 ************************************************************************************/
`define CPU_RESET_VEC 16'h0100
`define CPU_NOP_INSN  16'hF000
`define CPU_IRET_INSN 16'h0EE0 // JAL lr, lr, #0

`endif
