#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

static void trim(char *s) {
    // remove leading spaces
    while (isspace((unsigned char)*s)) memmove(s, s+1, strlen(s));
    // remove trailing spaces
    size_t n = strlen(s);
    while (n > 0 && isspace((unsigned char)s[n-1])) s[--n] = '\0';
}

int main(int argc, char **argv) {
    if (argc != 4) {
        fprintf(stderr, "Usage: %s program.hex memH.hex memL.hex\n", argv[0]);
        return 1;
    }

    FILE *in = fopen(argv[1], "r");
    if (!in) { perror(argv[1]); return 1; }

    FILE *hi = fopen(argv[2], "w");
    if (!hi) { perror(argv[2]); fclose(in); return 1; }

    FILE *lo = fopen(argv[3], "w");
    if (!lo) { perror(argv[3]); fclose(in); fclose(hi); return 1; }

    char line[256];
    while (fgets(line, sizeof(line), in)) {
        trim(line);
        if (line[0] == '\0') continue;

        // aceitar "0x1325" ou "1325"
        unsigned int value = 0;
        if (strncmp(line, "0x", 2) == 0 || strncmp(line, "0X", 2) == 0)
            value = (unsigned int)strtoul(line + 2, NULL, 16);
        else
            value = (unsigned int)strtoul(line, NULL, 16);

        unsigned int high = (value >> 8) & 0xFF;
        unsigned int low  = value & 0xFF;

        fprintf(hi, "%02X\n", high);
        fprintf(lo, "%02X\n", low);
    }

    fclose(in);
    fclose(hi);
    fclose(lo);
    return 0;
}

