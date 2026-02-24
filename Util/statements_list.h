#ifndef STATEMENTS_LIST_H
#define STATEMENTS_LIST_H

#include <stdint.h>

/*
 * Campos:
 *   opcode   — qual a instrucao/diretiva (usa defines de asm_operations.h)
 *   fn       — fn code para instrucoes RR e RI (0 se nao se aplica)
 *   format   — formato da instrucao: 'R','I','M','J','B','F'
 *   rd       — registo destino
 *   rs       — registo fonte
 *   imm      — imediato (4, 8 ou 12 bits conforme o formato)
 *   cond     — condition code para instrucoes BR
 *   misc     — tipo do operando: NO_TYPE, IMMEDIATE, LABEL, LINK
 *   line_num — numero da linha no .asm (para mensagens de erro)
 */

typedef struct {
    uint8_t  opcode;
    uint8_t  fn;
    char     format;
    uint8_t  rd;
    uint8_t  rs;
    int16_t  imm;
    uint8_t  cond;
    uint8_t  misc;
    uint32_t line_num;
} statement_t;


/* inicializa a lista — chamar antes de qualquer outra funcao */
void init_statements_list(void);

/* liberta a memoria alocada — chamar no fim */
void delete_statements_list(void);

/* adiciona uma instrucao RR  (ex: ADD, SUB, CMP...) */
void add_statement_rr(uint8_t opcode, uint8_t fn,
                      uint8_t rd, uint8_t rs);

/* adiciona uma instrucao RI  (ex: ANDI, XORI...) */
void add_statement_ri(uint8_t opcode, uint8_t fn,
                      uint8_t rd, int16_t imm);

/* adiciona uma instrucao RRI (ex: ADDI, LW, SW, JAL...) */
void add_statement_rri(uint8_t opcode,
                       uint8_t rd, uint8_t rs, int16_t imm, uint8_t misc);

/* adiciona uma instrucao I12 (IMM) */
void add_statement_i12(uint8_t opcode, int16_t imm);

/* adiciona uma instrucao BR  (ex: BEQ, BLT...) */
void add_statement_br(uint8_t opcode, uint8_t cond, int16_t disp, uint8_t misc);

/* adiciona uma instrucao FIXED (CLI, STI, NOP) */
void add_statement_fixed(uint8_t opcode);

/* adiciona uma diretiva (DIR_ORG, DIR_EQU, DIR_WORD, DIR_BYTE) */
void add_statement_directive(uint8_t opcode, int16_t value);


/* getters */
uint32_t        get_location_counter(void);
uint32_t        get_statement_count(void);
statement_t     get_statement(uint32_t index);

/* linha actual — chamado pelo lexer */
void            increment_line_number(uint32_t n);
void            set_line_number(uint32_t n);


#endif /* STATEMENTS_LIST_H */
