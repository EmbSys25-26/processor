%{
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "asm_operations.h"    
#include "statements_list.h"  
#include "symbol_table.h"     

extern int yylex();
void yyerror(const char *s);
%}

%union {
    int num;
}

/* tokens definition*/

/* tokens with attributes (yylval.num), $ represents the LC */
%token <num> TOKEN_NUMBER TOKEN_REG TOKEN_IDENTIFIER 

/* BR format */
%token <num> TOKEN_BR TOKEN_BEQ TOKEN_BC TOKEN_BV TOKEN_BLT TOKEN_BLE TOKEN_BLETU TOKEN_BLEU

/* RR format */
%token TOKEN_ADD TOKEN_SUB TOKEN_AND TOKEN_XOR 
%token TOKEN_ADC TOKEN_SBC TOKEN_CMP TOKEN_SRL TOKEN_SRA

/* RI format */
%token TOKEN_RSUBI TOKEN_ANDI TOKEN_XORI 
%token TOKEN_ADCI TOKEN_RSBCI TOKEN_RCMPI

/* RRI format */
%token TOKEN_JAL TOKEN_ADDI TOKEN_LW TOKEN_LB TOKEN_SW TOKEN_SB

/* I12 format */
%token TOKEN_IMM_TOK 

/* directives */
%token TOKEN_BYTE TOKEN_WORD TOKEN_ORG TOKEN_EQU

/* others */
%token TOKEN_GETCC TOKEN_SETCC TOKEN_CLI TOKEN_STI TOKEN_NOP
%token TOKEN_ENDFILE TOKEN_COMMA TOKEN_COLON TOKEN_CARDINAL

%type <num> expression immediate_val branch_op

%%

/* grammar rules */

program     :   lines TOKEN_ENDFILE
                {
                    return 0;
                };

lines       :   lines line
            |
            ;

line        :   label_decl
            |   stmt
            |   directive
            ;

label_decl  :   TOKEN_IDENTIFIER TOKEN_COLON 
                {
                    /* gets the current LC and associates it to the declared label */
                    uint32_t current_lc = get_location_counter();
                    set_symbol_value($1, (int16_t)current_lc);    
                };

/* statements */
stmt        :   add_stmt | sub_stmt | and_stmt | xor_stmt | adc_stmt | sbc_stmt | cmp_stmt | srl_stmt | sra_stmt
            |   getcc_stmt | setcc_stmt
            |   rsubi_stmt | andi_stmt | xori_stmt | adci_stmt | rsbci_stmt | rcmpi_stmt
            |   addi_stmt | jal_stmt | lw_stmt | lb_stmt | sw_stmt | sb_stmt
            |   imm_stmt
            |   branch_stmt
            |   cli_stmt | sti_stmt | nop_stmt
            ;

/* RR format statements - no immediate values or labels are involved. */
add_stmt    :   TOKEN_ADD TOKEN_REG TOKEN_COMMA TOKEN_REG 
                { 
                    add_statement_rr(RR_OPCODE, ADD_FN, $2, $4);
                };

sub_stmt    :   TOKEN_SUB TOKEN_REG TOKEN_COMMA TOKEN_REG 
                { 
                    add_statement_rr(RR_OPCODE, SUB_FN, $2, $4);
                };

and_stmt    :   TOKEN_AND TOKEN_REG TOKEN_COMMA TOKEN_REG 
                { 
                    add_statement_rr(RR_OPCODE, AND_FN, $2, $4);
                };

xor_stmt    :   TOKEN_XOR TOKEN_REG TOKEN_COMMA TOKEN_REG 
                { 
                    add_statement_rr(RR_OPCODE, XOR_FN, $2, $4);
                };

adc_stmt    :   TOKEN_ADC TOKEN_REG TOKEN_COMMA TOKEN_REG 
                { 
                    add_statement_rr(RR_OPCODE, ADC_FN, $2, $4);
                };

sbc_stmt    :   TOKEN_SBC TOKEN_REG TOKEN_COMMA TOKEN_REG 
                { 
                    add_statement_rr(RR_OPCODE, SBC_FN, $2, $4);
                };

cmp_stmt    :   TOKEN_CMP TOKEN_REG TOKEN_COMMA TOKEN_REG 
                { 
                    add_statement_rr(RR_OPCODE, CMP_FN, $2, $4);
                };

srl_stmt    :   TOKEN_SRL TOKEN_REG TOKEN_COMMA TOKEN_REG 
                { 
                    add_statement_rr(RR_OPCODE, SRL_FN, $2, $4);
                };

sra_stmt    :   TOKEN_SRA TOKEN_REG TOKEN_COMMA TOKEN_REG 
                { 
                    add_statement_rr(RR_OPCODE, SRA_FN, $2, $4);
                };

getcc_stmt  :   TOKEN_GETCC TOKEN_REG 
                { 
                    add_statement_rr(CC_OPCODE, GETCC_FN, $2, 0);
                };

setcc_stmt  :   TOKEN_SETCC TOKEN_REG 
                { 
                    add_statement_rr(CC_OPCODE, SETCC_FN, 0, $2);
                };

/* RI format statements - since RI format does not support the LABEL flag in the IR, identifiers are resolved immediately */
rsubi_stmt  :   TOKEN_RSUBI TOKEN_REG TOKEN_COMMA immediate_val 
                { 
                    add_statement_ri(RI_OPCODE, RSUBI_FN, $2, $4);
                }
            |   TOKEN_RSUBI TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER 
                { 
                    add_statement_ri(RI_OPCODE, RSUBI_FN, $2, get_symbol_value($4));
                };

andi_stmt   :   TOKEN_ANDI TOKEN_REG TOKEN_COMMA immediate_val  
                { 
                    add_statement_ri(RI_OPCODE, ANDI_FN, $2, $4);
                }
            |   TOKEN_ANDI TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER  
                { 
                    add_statement_ri(RI_OPCODE, ANDI_FN, $2, get_symbol_value($4));
                };

xori_stmt   :   TOKEN_XORI TOKEN_REG TOKEN_COMMA immediate_val  
                { 
                    add_statement_ri(RI_OPCODE, XORI_FN, $2, $4);
                }
            |   TOKEN_XORI TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER  
                { 
                    add_statement_ri(RI_OPCODE, XORI_FN, $2, get_symbol_value($4));
                };

adci_stmt   :   TOKEN_ADCI TOKEN_REG TOKEN_COMMA immediate_val  
                { 
                    add_statement_ri(RI_OPCODE, ADCI_FN, $2, $4);
                }
            |   TOKEN_ADCI TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER  
                { 
                    add_statement_ri(RI_OPCODE, ADCI_FN, $2, get_symbol_value($4));
                };

rsbci_stmt  :   TOKEN_RSBCI TOKEN_REG TOKEN_COMMA immediate_val 
                { 
                    add_statement_ri(RI_OPCODE, RSBCI_FN, $2, $4);
                }
            |   TOKEN_RSBCI TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER 
                { 
                    add_statement_ri(RI_OPCODE, RSBCI_FN, $2, get_symbol_value($4));
                };

rcmpi_stmt  :   TOKEN_RCMPI TOKEN_REG TOKEN_COMMA immediate_val 
                { 
                    add_statement_ri(RI_OPCODE, RCMPI_FN, $2, $4);
                }
            |   TOKEN_RCMPI TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER 
                { 
                    add_statement_ri(RI_OPCODE, RCMPI_FN, $2, get_symbol_value($4));
                };

/* RRI format statements - RRI supports the LABEL flag. Identifiers are passed as table indexes for Step 2 resolution. */
addi_stmt   :   TOKEN_ADDI TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA immediate_val 
                { 
                    /* the value is a number saved as IMMEDIATE, no Step 2 needed */
                    add_statement_rri(ADDI_OPCODE, $2, $4, $6, IMMEDIATE);
                }
            |   TOKEN_ADDI TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER 
                { 
                    /* the value is a Label. forwarding the symbol table index ($6) to the IR, to be resolved in Step 2. */
                    add_statement_rri(ADDI_OPCODE, $2, $4, $6, LABEL);
                };

jal_stmt    :   TOKEN_JAL TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA immediate_val  
                { 
                    add_statement_rri(JAL_OPCODE, $2, $4, $6, IMMEDIATE);
                }
            |   TOKEN_JAL TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER  
                { 
                    add_statement_rri(JAL_OPCODE, $2, $4, $6, LABEL);
                };

lw_stmt     :   TOKEN_LW TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA immediate_val   
                { 
                    add_statement_rri(LW_OPCODE, $2, $4, $6, IMMEDIATE);
                }
            |   TOKEN_LW TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER   
                { 
                    add_statement_rri(LW_OPCODE, $2, $4, $6, LABEL);
                };

lb_stmt     :   TOKEN_LB TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA immediate_val   
                { 
                    add_statement_rri(LB_OPCODE, $2, $4, $6, IMMEDIATE);
                }
            |   TOKEN_LB TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER   
                { 
                    add_statement_rri(LB_OPCODE, $2, $4, $6, LABEL);
                };

sw_stmt     :   TOKEN_SW TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA immediate_val   
                { 
                    add_statement_rri(SW_OPCODE, $2, $4, $6, IMMEDIATE);
                }
            |   TOKEN_SW TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER   
                { 
                    add_statement_rri(SW_OPCODE, $2, $4, $6, LABEL);
                };

sb_stmt     :   TOKEN_SB TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA immediate_val   
                { 
                    add_statement_rri(SB_OPCODE, $2, $4, $6, IMMEDIATE);
                }
            |   TOKEN_SB TOKEN_REG TOKEN_COMMA TOKEN_REG TOKEN_COMMA TOKEN_IDENTIFIER   
                { 
                    add_statement_rri(SB_OPCODE, $2, $4, $6, LABEL);
                };

/* I12 format statements */
imm_stmt    :   TOKEN_IMM_TOK immediate_val 
                { 
                    add_statement_i12(IMM_OPCODE, $2);
                }
            |   TOKEN_IMM_TOK TOKEN_IDENTIFIER 
                { 
                    /* immediate resolution for 12-bit prefix */
                    add_statement_i12(IMM_OPCODE, get_symbol_value($2));
                };

/* BR format statements */
branch_stmt :   branch_op immediate_val 
                { 
                    add_statement_br(BR_OPCODE, $1, $2, IMMEDIATE);
                }
            |   branch_op TOKEN_IDENTIFIER 
                { 
                    /* branch targets are stored as indexes (LABEL flag) for relative displacement calculation in Step 2 */
                    add_statement_br(BR_OPCODE, $1, $2, LABEL);
                };

cli_stmt    :   TOKEN_CLI 
                { 
                    add_statement_fixed(CLI_OPCODE);
                };

sti_stmt    :   TOKEN_STI 
                { 
                    add_statement_fixed(STI_OPCODE);
                };

nop_stmt    :   TOKEN_NOP 
                { 
                    add_statement_fixed(NOP_OPCODE);
                };

/* Directives update the LC or Symbol Table directly, without generating code */
directive   :   TOKEN_ORG expression 
                { 
                    add_statement_directive(DIR_ORG, $2);
                }
            |   TOKEN_WORD expression 
                { 
                    add_statement_directive(DIR_WORD, $2);
                }
            |   TOKEN_WORD TOKEN_IDENTIFIER 
                { 
                    add_statement_directive(DIR_WORD, get_symbol_value($2));
                }
            |   TOKEN_BYTE expression 
                { 
                    add_statement_directive(DIR_BYTE, $2);
                }
            |   TOKEN_BYTE TOKEN_IDENTIFIER 
                { 
                    add_statement_directive(DIR_BYTE, get_symbol_value($2));
                }
            |   TOKEN_IDENTIFIER TOKEN_EQU expression 
                {
                    /* assigns a constant value to a symbol explicitly */
                    set_symbol_value($1, $3);
                    add_statement_directive(DIR_EQU, $3); 
                };

branch_op   :   TOKEN_BR    { $$ = $1; }
            |   TOKEN_BEQ   { $$ = $1; }
            |   TOKEN_BC    { $$ = $1; }
            |   TOKEN_BV    { $$ = $1; }
            |   TOKEN_BLT   { $$ = $1; }
            |   TOKEN_BLE   { $$ = $1; }
            |   TOKEN_BLETU { $$ = $1; }
            |   TOKEN_BLEU  { $$ = $1; }
            ;

/* mathematical expressions and direct values */
expression  :   TOKEN_NUMBER 
                { 
                    $$ = $1;
                }
            ;

immediate_val:  TOKEN_CARDINAL expression 
                { 
                    $$ = $2;
                }
            ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parser- Syntax error %s\n", s);
}