int main(void) {
    int s = 0;
    int i;
    for (i = 0; ; i++) {
        if (i >= 5) break;
        s += i;
    }
    return s;
}
