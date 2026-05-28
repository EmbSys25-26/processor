int main(void) {
    int s = 0;
    int i = 0;
    do {
        i++;
        if (i % 2 == 0) continue;
        s += i;
    } while (i < 10);
    return s;
}
