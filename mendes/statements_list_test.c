#include <stdio.h>
#include <assert.h>
#include "statements_list.h"
#include "asm_operations.h"

/* compila com:
   gcc test_statements.c statements_list.c -o test && ./test
*/

static int tests_run    = 0;
static int tests_passed = 0;

#define CHECK(desc, cond)                                          \
    do {                                                           \
        tests_run++;                                               \
        if (cond) {                                                \
            printf("[OK]   %s\n", desc);                          \
            tests_passed++;                                        \
        } else {                                                   \
            printf("[FAIL] %s  (linha %d)\n", desc, __LINE__);   \
        }                                                          \
    } while(0)


/* ============================================================
 * Testes do location counter
 * ============================================================ */
void test_lc_instrucao_incrementa_2(void)
{
    init_statements_list();
    CHECK("LC começa a 0", get_location_counter() == 0);

    add_statement_rr(RR_OPCODE, ADD_FN, 1, 2);
    CHECK("ADD incrementa LC em 2", get_location_counter() == 2);

    add_statement_rr(RR_OPCODE, SUB_FN, 1, 2);
    CHECK("segunda instrucao: LC == 4", get_location_counter() == 4);

    delete_statements_list();
}

void test_lc_word_incrementa_4(void)
{
    init_statements_list();
    add_statement_directive(DIR_WORD, 42);
    CHECK(".word incrementa LC em 4", get_location_counter() == 4);
    delete_statements_list();
}

void test_lc_byte_incrementa_1(void)
{
    init_statements_list();
    add_statement_directive(DIR_BYTE, 0xFF);
    CHECK(".byte incrementa LC em 1", get_location_counter() == 1);
    delete_statements_list();
}

void test_lc_org_define_valor(void)
{
    init_statements_list();
    add_statement_directive(DIR_ORG, 0x1000);
    CHECK(".org define LC = 0x1000", get_location_counter() == 0x1000);

    add_statement_rr(RR_OPCODE, ADD_FN, 1, 2);
    CHECK("instrucao apos .org: LC == 0x1002", get_location_counter() == 0x1002);

    delete_statements_list();
}

void test_lc_equ_nao_altera_lc(void)
{
    init_statements_list();
    add_statement_directive(DIR_EQU, 64);
    CHECK(".equ NAO altera LC (deve ser 0)", get_location_counter() == 0);
    delete_statements_list();
}


/* ============================================================
 * Testes do conteudo das statements
 * ============================================================ */
void test_statement_rr_guardada_correctamente(void)
{
    init_statements_list();
    add_statement_rr(RR_OPCODE, ADD_FN, 3, 5);

    statement_t s = get_statement(0);
    CHECK("RR: opcode correcto",  s.opcode == RR_OPCODE);
    CHECK("RR: fn correcto",      s.fn     == ADD_FN);
    CHECK("RR: formato correcto", s.format == FMT_RR);
    CHECK("RR: rd correcto",      s.rd     == 3);
    CHECK("RR: rs correcto",      s.rs     == 5);

    delete_statements_list();
}

void test_statement_br_guardada_correctamente(void)
{
    init_statements_list();
    add_statement_br(BR_OPCODE, BEQ_COND, -4, IMMEDIATE);

    statement_t s = get_statement(0);
    CHECK("BR: opcode correcto", s.opcode == BR_OPCODE);
    CHECK("BR: cond correcto",   s.cond   == BEQ_COND);
    CHECK("BR: disp correcto",   s.imm    == -4);
    CHECK("BR: misc correcto",   s.misc   == IMMEDIATE);

    delete_statements_list();
}

void test_contagem_de_statements(void)
{
    init_statements_list();
    add_statement_rr(RR_OPCODE, ADD_FN, 1, 2);
    add_statement_fixed(NOP_OPCODE);
    add_statement_directive(DIR_EQU, 10);   /* nao gera instrucao mas entra na lista */
    CHECK("3 statements guardadas", get_statement_count() == 3);
    delete_statements_list();
}

void test_line_number(void)
{
    init_statements_list();
    set_line_number(5);
    add_statement_rr(RR_OPCODE, ADD_FN, 1, 2);
    CHECK("line_num guardado correctamente", get_statement(0).line_num == 5);

    increment_line_number(3);
    add_statement_fixed(NOP_OPCODE);
    CHECK("line_num apos incremento", get_statement(1).line_num == 8);

    delete_statements_list();
}


/* ============================================================
 * main
 * ============================================================ */
int main(void)
{
    printf("=== TESTES statements_list ===\n\n");

    test_lc_instrucao_incrementa_2();
    test_lc_word_incrementa_4();
    test_lc_byte_incrementa_1();
    test_lc_org_define_valor();
    test_lc_equ_nao_altera_lc();
    test_statement_rr_guardada_correctamente();
    test_statement_br_guardada_correctamente();
    test_contagem_de_statements();
    test_line_number();

    printf("\n%d/%d testes passaram\n", tests_passed, tests_run);
    return (tests_passed == tests_run) ? 0 : 1;
}
