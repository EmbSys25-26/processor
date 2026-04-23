int main() {
    int a = 1;
    int b = 2;
    /* "a" and "b" are both alive, so there will be interference */
    int c = a + b;
    return c;
}
