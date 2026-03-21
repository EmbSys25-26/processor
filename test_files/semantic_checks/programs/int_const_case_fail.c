enum Numbers {
    TWO = 2
};

int main(void) {
    int x = 0;

    switch (x) {
        case "a":  // SEM054 is never emitted here because valid case labels are already constrained by the parser/AST builder
            break;
    }

    return 0;
}