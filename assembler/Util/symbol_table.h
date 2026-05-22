#ifndef _SYMBOL_TABLE_H_
#define _SYMBOL_TABLE_H_

#include <stdint.h>

#define NULL_PTR            0
#define UNINITIALIZED_VALUE -1
#define MAX_NAME_LEN                    32


/* ===========================================================
 * Symbol table entry structure
 * ============================================================ */

struct symbol_s {
    char name[MAX_NAME_LEN];
    int16_t value;
    uint16_t link;
};

typedef struct symbol_s symbol_t;
   
/* ===========================================================
 * Symbol table init / delete functions
 * ============================================================ */

void init_symbol_table();
void delete_symbol_table();

/* ===========================================================
 * Manipulation functions - add symbol, set/get symbols, etc.
 * ============================================================ */

uint16_t add_symbol(char *name);
uint16_t set_symbol_value(uint16_t index, int16_t value);
int16_t get_symbol_value(uint16_t index);
char* get_symbol_name(uint16_t index);


/* ===========================================================
 * Debug function to print the symbol table
 * ============================================================ */

void print_table();

#endif
