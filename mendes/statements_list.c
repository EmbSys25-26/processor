#include <stdio.h>
#include <stdlib.h>
#include "statements_list.h"
#include "asm_operations.h"


#define INITIAL_SIZE    128     /* tamanho inicial da lista             */
#define INCREMENT_SIZE  64      /* quanto cresce quando enche           */



static statement_t *stmt_list    = NULL;
static uint32_t     stmt_count   = 0;
static uint32_t     stmt_cap     = 0;
static uint32_t     location_counter = 0;
static uint32_t     line_number  = 1;


/* cresce a lista se estiver cheia */
static void ensure_capacity(void)
{
    if (stmt_count < stmt_cap)
        return;

    stmt_cap += INCREMENT_SIZE;
    stmt_list = realloc(stmt_list, sizeof(statement_t) * stmt_cap);

    if (stmt_list == NULL) {
        fprintf(stderr, "[ASSEMBLER] Erro: falha ao alocar memoria\n");
        exit(EXIT_FAILURE);
    }
}

/* preenche os campos comuns e insere na lista */
static void commit_statement(statement_t s)
{
    ensure_capacity();
    s.line_num = line_number;
    stmt_list[stmt_count++] = s;
}

/* actualiza o LC conforme o tipo de statement */
static void update_lc(uint8_t opcode)
{
    if (opcode == DIR_ORG)
        return;                          /* LC e definido pelo caller         */
    else if (opcode == DIR_EQU)
        return;                          /* .equ nao ocupa espaco em memoria  */
    else if (opcode == DIR_WORD)
        location_counter += LC_WORD;     /* +4 bytes */
    else if (opcode == DIR_BYTE)
        location_counter += LC_BYTE;     /* +1 byte  */
    else
        location_counter += LC_INSTRUCTION; /* +2 bytes para toda a instrucao */
}



void init_statements_list(void)
{
    stmt_list = malloc(sizeof(statement_t) * INITIAL_SIZE);

    if (stmt_list == NULL) {
        fprintf(stderr, "[ASSEMBLER] Erro: falha ao alocar memoria\n");
        exit(EXIT_FAILURE);
    }

    stmt_count       = 0;
    stmt_cap         = INITIAL_SIZE;
    location_counter = 0;
    line_number      = 1;
}

void delete_statements_list(void)
{
    free(stmt_list);
    stmt_list  = NULL;
    stmt_count = 0;
    stmt_cap   = 0;
}


// RR
void add_statement_rr(uint8_t opcode, uint8_t fn,
                      uint8_t rd, uint8_t rs)
{
    statement_t s = {0};
    s.opcode = opcode;
    s.fn     = fn;
    s.format = FMT_RR;
    s.rd     = rd;
    s.rs     = rs;
    s.misc   = NO_TYPE;
    commit_statement(s);
    update_lc(opcode);
}

// RI
void add_statement_ri(uint8_t opcode, uint8_t fn,
                      uint8_t rd, int16_t imm)
{
    statement_t s = {0};
    s.opcode = opcode;
    s.fn     = fn;
    s.format = FMT_RI;
    s.rd     = rd;
    s.imm    = imm;
    s.misc   = IMMEDIATE;
    commit_statement(s);
    update_lc(opcode);
}

/* RRI
 *
 * misc pode ser:
 *   IMMEDIATE — imediato numerico normal
 *   LABEL     — o imm guarda o indice na tabela de simbolos,
 *               a Mariana resolve no passo 2
 *   LINK      — instrucao guarda endereco de retorno (JAL com link)
 */
void add_statement_rri(uint8_t opcode,
                       uint8_t rd, uint8_t rs, int16_t imm, uint8_t misc)
{
    statement_t s = {0};
    s.opcode = opcode;
    s.format = FMT_RRI;
    s.rd     = rd;
    s.rs     = rs;
    s.imm    = imm;
    s.misc   = misc;
    commit_statement(s);
    update_lc(opcode);
}

// I12
void add_statement_i12(uint8_t opcode, int16_t imm)
{
    statement_t s = {0};
    s.opcode = opcode;
    s.format = FMT_I12;
    s.imm    = imm;
    s.misc   = IMMEDIATE;
    commit_statement(s);
    update_lc(opcode);
}

/* BR
 *
 * misc pode ser:
 *   IMMEDIATE — deslocamento numerico directo
 *   LABEL     — o imm guarda indice na tabela de simbolos
 */
void add_statement_br(uint8_t opcode, uint8_t cond,
                      int16_t disp, uint8_t misc)
{
    statement_t s = {0};
    s.opcode = opcode;
    s.format = FMT_BR;
    s.cond   = cond;
    s.imm    = disp;
    s.misc   = misc;
    commit_statement(s);
    update_lc(opcode);
}

//CLI / STI / NOP — sem operandos 
void add_statement_fixed(uint8_t opcode)
{
    statement_t s = {0};
    s.opcode = opcode;
    s.format = FMT_FIXED;
    s.misc   = NO_TYPE;
    commit_statement(s);
    update_lc(opcode);
}

/* DIRETIVAS:
 *
 * .org  — value = novo endereco; LC e actualizado aqui
 * .equ  — value = valor da constante (ja resolvido pelo parser)
 * .word — value = valor a escrever em memoria (4 bytes)
 * .byte — value = valor a escrever em memoria (1 byte)
 */
void add_statement_directive(uint8_t opcode, int16_t value)
{
    statement_t s = {0};
    s.opcode = opcode;
    s.format = FMT_FIXED;   /* diretivas nao geram instrucao */
    s.imm    = value;
    s.misc   = NO_TYPE;
    commit_statement(s);

    if (opcode == DIR_ORG)
        location_counter = (uint32_t)value;
    else
        update_lc(opcode);
}


/*
* getters
*/

uint32_t get_location_counter(void)
{
    return location_counter;
}

uint32_t get_statement_count(void)
{
    return stmt_count;
}

statement_t get_statement(uint32_t index)
{
    if (index >= stmt_count) {
        fprintf(stderr, "[ASSEMBLER] Erro: indice %u fora dos limites\n", index);
        exit(EXIT_FAILURE);
    }
    return stmt_list[index];
}

void increment_line_number(uint32_t n)
{
    line_number += n;
}

void set_line_number(uint32_t n)
{
    line_number = n;
}
