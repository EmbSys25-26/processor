#ifndef _SYMBOL_TABLE_H_
#define _SYMBOL_TABLE_H_

#include <stdint.h>

#define NULL_PTR            0
#define UNINITIALIZED_VALUE -1
   

void init_symbol_table();
void delete_symbol_table();

uint16_t add_symbol(char *name);
uint16_t set_symbol_value(uint16_t index, int16_t value);
int16_t get_symbol_value(uint16_t index);
char* get_symbol_name(uint16_t index);

void print_table();

#endif
