#include <stdio.h>
#include <stdlib.h>
#include "statements_list.h" 
#include "symbol_table.h"     
#include "asm_operations.h"   

extern int yyparse(void);
extern void init_lexer(const char *filename); 
extern FILE *yyin; /* exposed by flex so we can close the file */

/* aux function to print IR */
static void dump_intermediate_representation(void)
{
    print_table(); /* */
    uint32_t count = get_statement_count(); 
    
    for (uint32_t i = 0; i < count; i++) {
        statement_t st = get_statement(i); 
        
        printf("[%03u] Line: %03u | Fmt: %c | Op: %02u | RD: %02u | RS: %02u | Imm: %04d",
               i, st.line_num, st.format, st.opcode, st.rd, st.rs, st.imm); /* */
               
        if (st.misc == LABEL) { /* */
            int16_t real_address = get_symbol_value(st.imm); /* */
            printf(" (Label -> Addr: %d)", real_address);
        }
        printf("\n");
    }
}

int main(int argc, char **argv)
{
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file.asm>\n", argv[0]);
        return EXIT_FAILURE;
    }

    init_symbol_table();     
    init_statements_list();  
    init_lexer(argv[1]);     

    /* step 1 (lexical & syntax analysis) */
    if (yyparse() != 0) {
        delete_statements_list(); 
        delete_symbol_table();    
        if (yyin) fclose(yyin);
        return EXIT_FAILURE;
    }

    dump_intermediate_representation();


    delete_statements_list(); 
    delete_symbol_table();    
    if (yyin) fclose(yyin);

    return EXIT_SUCCESS;
}