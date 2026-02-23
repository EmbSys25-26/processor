#define MAX 100
#include <stdio.h>
#include "scanner.h"
#undef MAX
#define MAX 200

int main(void) {
    int x = 42;
    float f = 3.14;
    char c = 'A';
    const char *msg = "hello";

    if (x == 0) {
        return -1;
    }

    for (int i = 0; i < MAX; i++) {
        x += i;
    }

    // comentario de linha
    /* comentario
       de bloco */

    return x;
}
