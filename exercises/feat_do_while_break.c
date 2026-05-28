int main(void) {
    int s = 0;
    int i = 0;
    do {
        i++;
        if (i == 5) break;
        s += i;
    } while (i < 10);
    return s;
}
