#include <stdio.h>
#include <stdlib.h>
#include "statements_list.h"
#include "asm_operations.h"


#define INITIAL_SIZE    127      // prime to reduce collision patterns
#define INCREMENT_SIZE  61       // prime increment to help spread growth


static statement_t *stmt_list    = NULL;
static uint32_t     stmt_count   = 0;
static uint32_t     stmt_cap     = 0;
static uint32_t     location_counter = 0;
static uint32_t     line_number  = 1;


/// @brief function to grow the statements list when capacity cap is exceeded
static void ensure_capacity(void)
{
    if (stmt_count < stmt_cap)
        return;

    stmt_cap += INCREMENT_SIZE;
    stmt_list = realloc(stmt_list, sizeof(statement_t) * stmt_cap);
    if (stmt_list == NULL) {
        fprintf(stderr, "[ASSEMBLER]: Failed to allocate memory\n");
        exit(EXIT_FAILURE);
    }
}

/// @brief function to add a statement to the list and increase the line number
/// @param s statement to be added to the list
static void commit_statement(statement_t s)
{
    ensure_capacity();
    s.line_num = line_number;
    stmt_list[stmt_count++] = s;
}

/// @brief function to update the location counter based on the statement type
/// @param opcode the opcode of the statement
static void update_lc(uint8_t opcode)
{
    if (opcode == DIR_ORG)
        return;                             // LC set by counter 
    else if (opcode == DIR_EQU)
        return;                             // .EQU is a directive
    else if (opcode == DIR_WORD)
        location_counter += LC_WORD;        // LC updated by +4 bytes
    else if (opcode == DIR_BYTE)
        location_counter += LC_BYTE;        // LC updated by +1 byte
    else
        location_counter += LC_INSTRUCTION; // LC updated by +2 bytes
}

/// @brief initializes the statements list with default values
void init_statements_list(void)
{
    stmt_list = malloc(sizeof(statement_t) * INITIAL_SIZE);
    if (stmt_list == NULL) {
        fprintf(stderr, "[ASSEMBLER]: Failed to allocate memory\n");
        exit(EXIT_FAILURE);
    }

    stmt_count       = 0;
    stmt_cap         = INITIAL_SIZE;
    location_counter = 0;
    line_number      = 1;
}

/// @brief  function to free the memory allocated for the statements list and reset the counters
void delete_statements_list(void)
{
    free(stmt_list);
    stmt_list  = NULL;
    stmt_count = 0;
    stmt_cap   = 0;
}

/// @brief adds a RR statement to the list
/// @param opcode the opcode of the instruction
/// @param fn the function code
/// @param rd the destination register
/// @param rs the source register
void add_statement_rr(uint8_t opcode, uint8_t fn,
                      uint8_t rd, uint8_t rs)
{
    statement_t s = {
        .opcode = opcode,
        .fn     = fn,
        .format = FMT_RR,
        .rd     = rd,
        .rs     = rs,
        .imm    = 0,
        .cond   = 0,
        .misc   = NO_TYPE,
        .line_num = 0
    };
    commit_statement(s);
    update_lc(opcode);
}

/// @brief adds a RI statement to the list
/// @param opcode the opcode of the instruction
/// @param fn the function code
/// @param rd the destination register
/// @param imm the immediate value
/// @param misc the operand type: IMMEDIATE, LABEL, etc (used for code generation)
void add_statement_ri(uint8_t opcode, uint8_t fn,
                      uint8_t rd, int32_t imm, uint8_t misc)
{
    statement_t s = {
        .opcode = opcode,
        .fn     = fn,
        .format = FMT_RI,
        .rd     = rd,
        .imm    = imm,
        .rs     = 0,
        .cond   = 0,
        .misc   = misc,
        .line_num = 0
    };
    commit_statement(s);
    update_lc(opcode);
}

/// @brief adds a RRI statement to the list
/// @param opcode the instruction opcode
/// @param rd the destination register
/// @param rs the source register
/// @param imm the immediate value
/// @param misc the operand type: IMMEDIATE, LABEL, etc (used for code generation)
void add_statement_rri(uint8_t opcode,
                       uint8_t rd, uint8_t rs, int32_t imm, uint8_t misc)
{
    statement_t s = {
        .opcode = opcode,
        .fn     = 0,
        .format = FMT_RRI,
        .rd     = rd,
        .rs     = rs,
        .imm    = imm,
        .cond   = 0,
        .misc   = misc,
        .line_num = 0
    };
    commit_statement(s);
    update_lc(opcode);
}

/// @brief adds a I12 statement to the list
/// @param opcode the instruction opcode
/// @param imm the immediate value
/// @param misc the operand type: IMMEDIATE, LABEL, etc (used for code generation)
void add_statement_i12(uint8_t opcode, int32_t imm, uint8_t misc)
{
    statement_t s = {
        .opcode = opcode,
        .fn     = 0,
        .format = FMT_I12,
        .rd     = 0,
        .rs     = 0,
        .imm    = imm,
        .cond   = 0,
        .misc   = misc,
        .line_num = 0
    };
    commit_statement(s);
    update_lc(opcode);
}

/// @brief adds a BR statement to the list
/// @param opcode the instruction opcode
/// @param cond the condition code
/// @param disp the displacement value
/// @param misc the operand type: IMMEDIATE, LABEL, etc (used for code generation)
void add_statement_br(uint8_t opcode, uint8_t cond,
                      int32_t disp, uint8_t misc)
{
    statement_t s = {
        .opcode = opcode,
        .fn     = 0,
        .format = FMT_BR,
        .rd     = 0,
        .rs     = 0,
        .imm    = disp,
        .cond   = cond,
        .misc   = misc,
        .line_num = 0
    };
    commit_statement(s);
    update_lc(opcode);
}

/// @brief adds a FIXED statement to the list
/// @param opcode the instruction opcode
void add_statement_fixed(uint8_t opcode)
{
    statement_t s = {
        .opcode = opcode,
        .fn     = 0,
        .format = FMT_FIXED,
        .rd     = 0,
        .rs     = 0,
        .imm    = 0,
        .cond   = 0,
        .misc   = NO_TYPE,
        .line_num = 0
    };
    commit_statement(s);
    update_lc(opcode);
}

/// @brief adds a directive statement to the list
/// @param opcode the directive opcode
/// @param value the value associated with the directive
void add_statement_directive(uint8_t opcode, int32_t value)
{
    statement_t s = {
        .opcode = opcode,
        .fn     = 0,
        .format = FMT_FIXED,
        .rd     = 0,
        .rs     = 0,
        .imm    = value,
        .cond   = 0,
        .misc   = NO_TYPE,
        .line_num = 0
    };
    commit_statement(s);

    // if .ORG, set location counter to the specified value; otherwise, update LC based on the directive type
    if (opcode == DIR_ORG)
        location_counter = (uint32_t)value;
    else
        update_lc(opcode);
}

/* Getters */
uint32_t get_location_counter(void) { return location_counter; }
uint32_t get_statement_count(void) { return stmt_count; }
statement_t get_statement(uint32_t index)
{
    if (index >= stmt_count) {
        fprintf(stderr, "[ASSEMBLER]: Error: index %u out of bounds\n", index);
        exit(EXIT_FAILURE);
    }
    return stmt_list[index];
}

/* Setters */
void increment_line_number(uint32_t n) { line_number += n; }
void set_line_number(uint32_t n) { line_number = n; }
