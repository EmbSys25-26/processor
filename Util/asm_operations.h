#ifndef ASM_OPERATIONS_H
#define ASM_OPERATIONS_H

/* ============================================================
 * INSTRUCTION FORMATS
 *
 * RR   : op(4) rd(4) rs(4) fn(4)       — register to register
 * RI   : op(4) rd(4) fn(4) imm(4)      — register + 4-bit immediate
 * RRI  : op(4) rd(4) rs(4) imm(4)      — register + register + 4-bit immediate
 * I12  : op(4) imm(12)                  — 12-bit immediate prefix
 * BR   : op(4) cond(4) disp(8)          — conditional branch
 * FIXED: hardcoded 16-bit word          — no operands
 * ============================================================ */

#define FMT_RR      'R'
#define FMT_RI      'I'
#define FMT_RRI     'M'
#define FMT_I12     'J'
#define FMT_BR      'B'
#define FMT_FIXED   'F'


/* 
 * OPCODES  (campo op — 4 bits) 
 */

#define JAL_OPCODE      0   /* RRI — jump and link                     */
#define ADDI_OPCODE     1   /* RRI — add immediate                     */
#define RR_OPCODE       2   /* RR  — todas as operacoes RR (ver fn)    */
#define RI_OPCODE       3   /* RI  — todas as operacoes RI (ver fn)    */
#define LW_OPCODE       4   /* RRI — load word                         */
#define LB_OPCODE       5   /* RRI — load byte                         */
#define SW_OPCODE       6   /* RRI — store word                        */
#define SB_OPCODE       7   /* RRI — store byte                        */
#define IMM_OPCODE      8   /* I12 — prefixo de imediato de 12 bits    */
#define BR_OPCODE       9   /* BR  — branches condicionais             */
#define CC_OPCODE       10  /* RR  — GETCC / SETCC                     */
#define CLI_OPCODE      11  /* clear interrupt enable (B000)   */
#define STI_OPCODE      12  /* set interrupt enable  (C000)    */
#define NOP_OPCODE      15  /* no operation          (F000)    */


/* 
 * FN CODES  do formato rr
 */

#define ADD_FN      0   /* rd = rd + rs                    */
#define SUB_FN      1   /* rd = rd - rs                    */
#define AND_FN      2   /* rd = rd AND rs                  */
#define XOR_FN      3   /* rd = rd XOR rs                  */
#define ADC_FN      4   /* rd = rd + rs + carry            */
#define SBC_FN      5   /* rd = rd - rs - borrow           */
#define CMP_FN      6   /* flags para rd - rs (sem escrita)*/
#define SRL_FN      7   /* rd = rd >> rs (logical)         */
#define SRA_FN      8   /* rd = rd >> rs (arithmetic)      */
#define GETCC_FN    9   /* rd = condition codes            */
#define SETCC_FN    10  /* condition codes = rd            */


/* 
 * FN CODES do formato ri
 */

#define RSUBI_FN    1   /* rd = imm - rd                   */
#define ANDI_FN     2   /* rd = rd AND imm                 */
#define XORI_FN     3   /* rd = rd XOR imm                 */
#define ADCI_FN     4   /* rd = rd + imm + carry           */
#define RSBCI_FN    5   /* rd = imm - rd - borrow          */
#define RCMPI_FN    6   /* flags para imm - rd             */


/* 
 * CONDITION CODES — formato BR  
 */

#define BR_COND         0   /* unconditional branch            */
#define BEQ_COND        2   /* branch if equal      (Z=1)      */
#define BC_COND         4   /* branch if carry                 */
#define BV_COND         6   /* branch if overflow              */
#define BLT_COND        8   /* branch if less than  (signed)   */
#define BLE_COND        0xA /* branch if less/equal (signed)   */
#define BLETU_COND      0xC /* branch if less/equal (unsigned) */
#define BLEU_COND       0xE /* branch if less than  (unsigned) */




#define CLI_ENCODING    0xB000
#define STI_ENCODING    0xC000
#define NOP_ENCODING    0xF000


/* 
 * DIRETIVAS
*/

#define DIR_ORG         50 // é so um numero grande para nao colidir com os outros
#define DIR_EQU         51
#define DIR_WORD        52
#define DIR_BYTE        53


/* 
 * LC INCREMENTS  (location counter)
 */

#define LC_INSTRUCTION  2   /* toda a instrucao ocupa 2 bytes (16 bits) */
#define LC_WORD         4   /* .word ocupa 4 bytes                      */
#define LC_BYTE         1   /* .byte ocupa 1 byte                       */


/* ============================================================
 * TIPO DO TERCEIRO OPERANDO  (campo misc na statement_t)
 * ============================================================ */

#define NO_TYPE         0   /* operando e registo normal               */
#define IMMEDIATE       1   /* operando e imediato numerico            */
#define LABEL           2   /* operando e label (resolver no passo 2)  */
#define LINK            3   /* instrucao guarda endereco de retorno     */


#endif /* ASM_OPERATIONS_H */
