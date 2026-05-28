int main(void) {
    int r = 0;
    int x = 2;
    switch (x) {
        case 1: r += 100;
        case 2: r += 10;
        case 3: r += 1; break;
        default: r += 999;
    }
    return r;
}
