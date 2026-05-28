int main(void) {
    int r = 7;
    int x = 42;
    switch (x) {
        case 1: r += 100; break;
        case 2: r += 200; break;
        case 3: r += 300; break;
    }
    return r;
}
