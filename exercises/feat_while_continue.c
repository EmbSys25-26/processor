int main(void) {
    int s = 0;
    int i = 0;
    while (i < 10) {
        i++;
        if (i % 2 == 0) continue;
        s += i;
    }
    return s;
}
