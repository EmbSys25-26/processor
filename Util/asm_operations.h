#ifndef ASM_OPERATIONS_H
#define ASM_OPERATIONS_H

/* ============================================================
 * INSTRUCTION FORMATS
 *
 * RR   : op(4) rd(4) rs(4) fn(4)       — reg2reg
 * RI   : op(4) rd(4) fn(4) imm(4)      — reg + 4-bit imm
 * RRI  : op(4) rd(4) rs(4) imm(4)      — reg + reg + 4-bit imm
 * I12  : op(4) imm(12)                  — 12-bit imm prefix
 * BR   : op(4) cond(4) disp(8)          — branch
 * FIXED: hardcoded 16-bit word          — no operands -- review this part 
 * ============================================================ */

#define FMT_RR      'R'
#define FMT_RI      'I'
#define FMT_RRI     'M'
#define FMT_I12     'J'
#define FMT_BR      'B'
#define FMT_FIXED   'F'


/* ============================================================
 * OPCODES  (op field — 4 bits) 
 * ============================================================ */

#define JAL_OPCODE      0   /* RRI — jump and link                    */
#define ADDI_OPCODE     1   /* RRI — add immediate                    */
#define RR_OPCODE       2   /* RR  — RR instructions (fn tiebreaker)  */
#define RI_OPCODE       3   /* RI  — RI instructions (fn tiebreaker)  */
#define LW_OPCODE       4   /* LW — load word                         */
#define LB_OPCODE       5   /* LB — load byte                         */
#define SW_OPCODE       6   /* SW — store word                        */
#define SB_OPCODE       7   /* SB — store byte                        */
#define IMM_OPCODE      8   /* I12 — 12-bit immediate prefix          */
#define BR_OPCODE       9   /* BR  — conditional branches             */
#define CC_OPCODE       10  /* CC  — GETCC / SETCC                    */
#define CLI_OPCODE      11  /* Clear interrupt enable (B000)          */
#define STI_OPCODE      12  /* Set interrupt enable   (C000)          */
#define NOP_OPCODE      15  /* No OPeration           (F000)          */


/* ============================================================
 * fn field codes - RR
 * ============================================================ */

#define ADD_FN      0   /* rd = rd + rs                    */
#define SUB_FN      1   /* rd = rd - rs                    */
#define AND_FN      2   /* rd = rd AND rs                  */
#define XOR_FN      3   /* rd = rd XOR rs                  */
#define ADC_FN      4   /* rd = rd + rs + carry            */
#define SBC_FN      5   /* rd = rd - rs - borrow           */
#define CMP_FN      6   /* update flags with rd - rs       */
#define SRL_FN      7   /* rd = rd >> rs (logical)         */
#define SRA_FN      8   /* rd = rd >> rs (arithmetic)      */
#define GETCC_FN    9   /* rd = condition codes            */
#define SETCC_FN    10  /* condition codes = rd (bitmask)  */


/* ============================================================
 * fn field codes - RI
 * ============================================================ */

#define RSUBI_FN    1   /* rd = imm - rd                   */
#define ANDI_FN     2   /* rd = rd AND imm                 */
#define XORI_FN     3   /* rd = rd XOR imm                 */
#define ADCI_FN     4   /* rd = rd + imm + carry           */
#define RSBCI_FN    5   /* rd = imm - rd - borrow          */
#define RCMPI_FN    6   /* update flags with imm - rd      */


/* ============================================================
 * cond field codes -  branch instructions
 * ============================================================ */

#define BR_COND         0   /* unconditional branch             */
#define BEQ_COND        2   /* branch if equal      (Z=1)       */
#define BC_COND         4   /* branch if carry                  */
#define BV_COND         6   /* branch if overflow               */
#define BLT_COND        8   /* branch if less than  (signed)    */
#define BLE_COND        0xA /* branch if less/equal (signed)    */
#define BLTU_COND       0xC /* < unsigned                       */
#define BLETU_COND      0xE /* ≤ unsigned (hardware BLEU)       */
#define BLEU_COND       0xC /* alias for compatibility          */


/* ============================================================
 * Interrupt enable instructions 
 * ============================================================ */

#define CLI_ENCODING    0xB000
#define STI_ENCODING    0xC000
#define NOP_ENCODING    0xF000


/* ============================================================
 * Assembler directives (.org, .equ, .word, .byte) 
 * ============================================================ */

#define DIR_ORG         50  /* set location counter (LC) to imm */
#define DIR_EQU         51  /* set symbol value to imm          */
#define DIR_WORD        52  /* emit 4 bytes with value imm      */
#define DIR_BYTE        53  /* emit 1 byte with value imm       */


/* ============================================================
 * Location Counter (LC) increments 
 * ============================================================ */

#define LC_INSTRUCTION  2   /* default instruction size (16 bits)       */
#define LC_WORD         4   /* .word ocupa 4 bytes                      */
#define LC_BYTE         1   /* .byte ocupa 1 byte                       */


/* ============================================================
 * Third Operand type (misc field in statement_t)
 * ============================================================ */

#define NO_TYPE         0   /* operand is a normal register             */
#define IMMEDIATE       1   /* operand is an immediate numeric value    */
#define LABEL           2   /* operand is a label (resolved in pass 2)  */
#define LINK            3   /* instruction saves return address         */


#endif /* ASM_OPERATIONS_H */
