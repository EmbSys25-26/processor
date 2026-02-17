%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int line_num = 1;

typedef struct {
    int opcode;
    int rd;
    int rs;
    int fn;
    int imm;
    int cond;
    int disp;
    char format; // 'R' = RR, 'I' = RI, 'M' = RRI, 'J' = I12, 'B' = BR
} instruction_t;

instruction_t insn = {0};

void decode_instruction() {
    unsigned short insn_format = 0;
    
    switch(insn.format) {
        case 'R': // RR format: op(4) rd(4) rs(4) fn(4)
            insn_format = (insn.opcode << 12) | (insn.rd << 8) | 
                          (insn.rs << 4) | insn.fn;
            break;
        case 'I': // RI format: op(4) rd(4) fn(4) imm(4)
            insn_format = (insn.opcode << 12) | (insn.rd << 8) | 
                          (insn.fn << 4) | (insn.imm & 0xF);
            break;
        case 'M': // RRI format: op(4) rd(4) rs(4) imm(4)
            insn_format = (insn.opcode << 12) | (insn.rd << 8) | 
                          (insn.rs << 4) | (insn.imm & 0xF);
            break;
        case 'J': // I12 format: op(4) imm(12)
            insn_format = (insn.opcode << 12) | (insn.imm & 0xFFF);
            break;
        case 'B': // BR format: op(4) cond(4) disp(8)
            insn_format = (insn.opcode << 12) | (insn.cond << 8) | 
                          (insn.disp & 0xFF);
            break;
    }
    
    printf("%04X\n", insn_format);
    memset(&insn, 0, sizeof(instruction_t));
}

int reg_count = 0;

%}

%option noyywrap
%option yylineno
%option noinput
%option nounput

%%

[ \t]+              { /* ignore whitespace */ }
;.*                 { /* ignore comments */ }

"ADD" { insn.opcode = 2; insn.fn = 0; insn.format = 'R'; reg_count = 0; }
"SUB" { insn.opcode = 2; insn.fn = 1; insn.format = 'R'; reg_count = 0; }
"AND" { insn.opcode = 2; insn.fn = 2; insn.format = 'R'; reg_count = 0; }
"XOR" { insn.opcode = 2; insn.fn = 3; insn.format = 'R'; reg_count = 0; }
"ADC" { insn.opcode = 2; insn.fn = 4; insn.format = 'R'; reg_count = 0; }
"SBC" { insn.opcode = 2; insn.fn = 5; insn.format = 'R'; reg_count = 0; }
"CMP" { insn.opcode = 2; insn.fn = 6; insn.format = 'R'; reg_count = 0; }
"SRL" { insn.opcode = 2; insn.fn = 7; insn.format = 'R'; reg_count = 0; }
"SRA" { insn.opcode = 2; insn.fn = 8; insn.format = 'R'; reg_count = 0; }

 
"RSUBI" { insn.opcode = 3; insn.fn = 1; insn.format = 'I'; reg_count = 0; }
"ANDI" { insn.opcode = 3; insn.fn = 2; insn.format = 'I'; reg_count = 0; }
"XORI" { insn.opcode = 3; insn.fn = 3; insn.format = 'I'; reg_count = 0; }
"ADCI" { insn.opcode = 3; insn.fn = 4; insn.format = 'I'; reg_count = 0; }
"RSBCI" { insn.opcode = 3; insn.fn = 5; insn.format = 'I'; reg_count = 0; }
"RCMPI" { insn.opcode = 3; insn.fn = 6; insn.format = 'I'; reg_count = 0; }

"JAL"  { insn.opcode = 0; insn.format = 'M'; reg_count = 0; }
"ADDI" { insn.opcode = 1; insn.format = 'M'; reg_count = 0; }
"LW"   { insn.opcode = 4; insn.format = 'M'; reg_count = 0; }
"LB"   { insn.opcode = 5; insn.format = 'M'; reg_count = 0; }
"SW"   { insn.opcode = 6; insn.format = 'M'; reg_count = 0; }
"SB"   { insn.opcode = 7; insn.format = 'M'; reg_count = 0; }


"IMM" { insn.opcode = 8; insn.format = 'J'; reg_count = 0; }

   
"BR"    { insn.opcode = 9; insn.cond = 0; insn.format = 'B'; reg_count = 0; }
"BEQ"   { insn.opcode = 9; insn.cond = 2; insn.format = 'B'; reg_count = 0; }
"BC"    { insn.opcode = 9; insn.cond = 4; insn.format = 'B'; reg_count = 0; }
"BV"    { insn.opcode = 9; insn.cond = 6; insn.format = 'B'; reg_count = 0; }
"BLT"   { insn.opcode = 9; insn.cond = 8; insn.format = 'B'; reg_count = 0; }
"BLE"   { insn.opcode = 9; insn.cond = 0xA; insn.format = 'B'; reg_count = 0; }
"BLETU" { insn.opcode = 9; insn.cond = 0xC; insn.format = 'B'; reg_count = 0; }
"BLEU"  { insn.opcode = 9; insn.cond = 0xE; insn.format = 'B'; reg_count = 0; }

"GETCC" { insn.opcode = 10; insn.fn = 9; insn.format = 'R'; reg_count = 0; }
"SETCC" { insn.opcode = 10; insn.fn = 10; insn.format = 'R'; reg_count = 0; }
"CLI"   { printf("B000\n"); /* op=11 */ }
"STI"   { printf("C000\n"); /* op=12 */ }
"NOP"   { printf("F000\n"); /* op=15 */ }

    /* R0-15 or r0-15*/
[Rr][0-9]|[Rr]1[0-5] {  

    int reg = atoi(yytext + 1); //skips the R/r character
    
    if (reg_count == 0) {
        insn.rd = reg;
    } else if (reg_count == 1) {
        insn.rs = reg;
    }
    reg_count++; 
}

    /* Immediate values */
"#"-?[0-9]+ {
    int val = atoi(yytext+1);
    if (insn.format == 'B')
        insn.disp = val;
    else
        insn.imm = val;
}

"#"0[xX][0-9A-Fa-f]+ {
    int val = (int)strtol(yytext+3, NULL, 16);
    if (insn.format == 'B')
        insn.disp = val;
    else
        insn.imm = val;
}

    /* Separators */
","                 { /* ignore commas */ }

    /* Newline - emit instruction */
\n { 
    if (insn.format != 0) {
        decode_instruction();
    }
    line_num++;
}

. { fprintf(stderr, "Line %d: Unexpected character '%s'\n", line_num, yytext); }

%%

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror(argv[1]);
            return 1;
        }
        yyin = file;
    }
    yylex();
    return 0;
}
