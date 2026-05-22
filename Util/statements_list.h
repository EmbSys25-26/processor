#ifndef STATEMENTS_LIST_H
#define STATEMENTS_LIST_H

#include <stdint.h>

/* ============================================================
 * Fields in statement_t:
 *   opcode   — which instruction/directive (4 bits for opcode field)
 *   fn       — fn code for RI instructions (4 bits for fn field)
 *   format   — instruction format: 'R','I','M','J','B','F'
 *   rd       — destination register
 *   rs       — source register
 *   imm      — immediate value (4, 8 or 12 bits depending on the format)
 *   cond     — condition code for BR instructions
 *   misc     — operand type: NO_TYPE, IMMEDIATE, LABEL, LINK
 *   line_num — line number in source code (for error reporting)
 * ============================================================ */

struct statement_s {
    uint8_t  opcode;
    uint8_t  fn;
    char     format;
    uint8_t  rd;
    uint8_t  rs;
    int32_t  imm;
    uint8_t  cond;
    uint8_t  misc;
    uint32_t line_num;
};

typedef struct statement_s statement_t;

/* ===========================================================
 * Statement list functions
 * ============================================================ */

void init_statements_list(void);
void delete_statements_list(void);
void add_statement_rr(uint8_t opcode, uint8_t fn,
                      uint8_t rd, uint8_t rs);
void add_statement_ri(uint8_t opcode, uint8_t fn,
                      uint8_t rd, int32_t imm, uint8_t misc);
void add_statement_rri(uint8_t opcode,
                       uint8_t rd, uint8_t rs, int32_t imm, uint8_t misc);
void add_statement_i12(uint8_t opcode, int32_t imm, uint8_t misc);
void add_statement_br(uint8_t opcode, uint8_t cond, int32_t disp, uint8_t misc);
void add_statement_fixed(uint8_t opcode);
void add_statement_directive(uint8_t opcode, int32_t value);

/* ===========================================================
 * Getter functions
 * ============================================================ */

uint32_t        get_location_counter(void);
uint32_t        get_statement_count(void);
statement_t     get_statement(uint32_t index);

/* ===========================================================
 * Setter functions
 * ============================================================ */

void            increment_line_number(uint32_t n);
void            set_line_number(uint32_t n);

#endif /* STATEMENTS_LIST_H */
