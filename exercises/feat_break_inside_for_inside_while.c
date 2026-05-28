int main(void) {
    int s = 0;
    int outer = 0;
    while (outer < 3) {
        int i = 0;
        for (i = 0; i < 10; i++) {
            if (i == 2) break;
            s += 1;
        }
        s += 100;
        outer++;
    }
    return s;
}
