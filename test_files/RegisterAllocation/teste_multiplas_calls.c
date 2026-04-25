int g(int x);
int h(int a, int b);

int exhaustive(int a, int b, int c) {
    int t1 = a + b;
    int t2 = b + c;
    int t3 = a + c;

    int r1 = g(t1);
    int r2 = g(t2);
    int r3 = g(t3);

    int s1 = h(r1, r2);
    int s2 = h(r2, r3);

    return s1 + s2;
}
