#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "symbol_table.h"
#include "logger.h"

#define INITIAL_SYMBOL_TABLE_SIZE       128
#define INC_SYMBOL_TABLE                64 
#define HASH_TABLE_SIZE                 512
#define MAX_NAME_LEN                    32

struct symbol_s{
    char name[MAX_NAME_LEN];
    int16_t value;
    uint16_t link;
};

static uint8_t ready =  0;
static uint16_t sym_tab_size = INITIAL_SYMBOL_TABLE_SIZE;
static uint16_t hash_table[HASH_TABLE_SIZE];
static uint16_t next_free_index = 1;
static struct symbol_s *sym_table = NULL;

static uint16_t insert_symbol(char *symbol_name, uint16_t hash_value);
static uint16_t hash(char *symbol_name);

/// @brief function to initialize the symbol table
/// @param table 
void init_symbol_table()
{
    //allocates memory for symbol table
    sym_table = (struct symbol_s*) malloc(sizeof(struct symbol_s) * INITIAL_SYMBOL_TABLE_SIZE);
    if(sym_table == NULL){
        LOG_DEBUG("Error allocating memory\n");

        exit(EXIT_FAILURE);
    }

    //set the initial symbol table size and free index
    sym_tab_size  = INITIAL_SYMBOL_TABLE_SIZE;
    next_free_index = 1;

    //initialize hash table
    for (uint16_t i = 0; i < HASH_TABLE_SIZE; i++){
        hash_table[i] = NULL_PTR;
    }

    ready = 1;

    //adds the first symbol to the symbol table
    uint16_t zero_ptr = add_symbol("0");
    sscanf(sym_table[zero_ptr].name, "%hd", &sym_table[zero_ptr].value);
}

/// @brief function to delete the symbol table allocated memory
/// @param table 
void delete_symbol_table()
{
    free(sym_table);
}

/// @brief function to calculate the hash value
/// @param symbol_name 
/// @return hash value
static uint16_t hash(char *symbol_name)
{
    unsigned long hash_value = 5381;
    int c;

    while ((c = *symbol_name++))
        hash_value = ((hash_value << 5) + hash_value) + c;  // hash * 33 + c

    return (uint16_t)(hash_value % HASH_TABLE_SIZE);
}

/// @brief function to insert a symbol in the table
/// @param table
/// @param symbol_name 
/// @param hash_value 
/// @return position of added symbol
static uint16_t insert_symbol(char *symbol_name, uint16_t hash_value){
	uint16_t index;
	index = next_free_index;
	next_free_index++;
	
	if(next_free_index >= sym_tab_size){
		sym_tab_size += INC_SYMBOL_TABLE;
		sym_table = (struct symbol_s*) realloc(sym_table, sizeof(struct symbol_s) * sym_tab_size);

		if(sym_table == NULL){
		    LOG_DEBUG("Error reallocating memory\n");

		    exit(EXIT_FAILURE);
		}
		
	}
	strcpy(sym_table[index].name, symbol_name);
	sym_table[index].link = hash_table[hash_value];
	hash_table[hash_value] = index;
	sym_table[index].value = UNINITIALIZED_VALUE;
	
	return index;	
}

/**
 * @brief Adds a symbol to the symbol table
 * @param table- A pointer to the symbol table
 * @param name- The name of the symbol to be added
 * @return The index of the symbol in the symbol table
 */
uint16_t add_symbol(char *name)
{
    uint16_t hash_value;
    uint16_t index;
    
    if(!ready){
        LOG_DEBUG("Symbol table uninitialized\n");

        exit(EXIT_FAILURE);
    }
    else{
        // Calculate the hash value and the index for the symbol name
        hash_value = hash(name);
        index = hash_table[hash_value];
        
        while((index != NULL_PTR)){

            // If the symbol with the same name already exists, return its index
            if(!strcmp(sym_table[index].name, name))
                return index;

            else
                //Move to the next symbol
                index = sym_table[index].link;
        }
        // If the symbol doesn't exist, insert it into the symbol table and return its index
        index = insert_symbol(name, hash_value);

        return index;
    }
}

/// @brief function to change the value of an existing symbol
/// @param index 
/// @param value 
/// @return error handler
uint16_t set_symbol_value(uint16_t index, int16_t value)
{
    if(!ready){
        LOG_DEBUG("Symbol table uninitialized\n");

        exit(EXIT_FAILURE);
    }
    else if(index >= sym_tab_size){
        LOG_DEBUG("Symbol doesn't exist\n");

        exit(EXIT_FAILURE);
    } 
    else{
        sym_table[index].value = value;
    }
    return index;
}


int16_t get_symbol_value(uint16_t index)
{
    return  sym_table[index].value;
}


char* get_symbol_name(uint16_t index)
{
    return sym_table[index].name;
}

/// @brief function to print the symbol table
/// @param table
void print_table()
{
    printf("\n\n-------------SYMBOL TABLE-------------\n");

    for (int i = 1; i < next_free_index; i++){
        printf("index: %03d  |  value: %05d  |  name: %s\n", i, sym_table[i].value, sym_table[i].name);
    }

    printf("----------------------------------------\n\n");
}



