#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "symbol_table.h"

void test_add_and_retrieve() {
    uint16_t idx = add_symbol("myVar");
    assert(idx != NULL_PTR);
    assert(strcmp(get_symbol_name(idx), "myVar") == 0);
    printf("PASS: add and retrieve\n");
}

void test_no_duplicates() {
    uint16_t idx1 = add_symbol("x");
    uint16_t idx2 = add_symbol("x");
    assert(idx1 == idx2);  // same symbol should return same index
    printf("PASS: no duplicates\n");
}

void test_set_and_get_value() {
    uint16_t idx = add_symbol("counter");
    set_symbol_value(idx, 42);
    assert(get_symbol_value(idx) == 42);
    printf("PASS: set and get value\n");
}

void test_uninitialized_value() {
    uint16_t idx = add_symbol("newSym");
    assert(get_symbol_value(idx) == UNINITIALIZED_VALUE);
    printf("PASS: default uninitialized value\n");
}

void test_many_symbols() {
    char name[16];
    for (int i = 0; i < 200; i++) {  // forces a realloc
        sprintf(name, "sym_%hd", i);
        uint16_t idx = add_symbol(name);
        set_symbol_value(idx, i);
    }
    // verify a few after realloc
    assert(get_symbol_value(add_symbol("sym_0")) == 0);
    assert(get_symbol_value(add_symbol("sym_150")) == 150);
    printf("PASS: many symbols (realloc stress)\n");
}

void test_hash_collision() {
    // Add many symbols and make sure lookups still work correctly
    uint16_t a = add_symbol("abc");
    uint16_t b = add_symbol("bca");  // may collide depending on your hash
    set_symbol_value(a, 1);
    set_symbol_value(b, 2);
    assert(get_symbol_value(a) == 1);
    assert(get_symbol_value(b) == 2);
    printf("PASS: hash collision handling\n");
}

int main() {
    init_symbol_table();
    test_add_and_retrieve();
    test_no_duplicates();
    test_set_and_get_value();
    test_uninitialized_value();
    test_many_symbols();
    test_hash_collision();
    print_table();
    delete_symbol_table();
    printf("\nAll tests passed.\n");
    return 0;
}
