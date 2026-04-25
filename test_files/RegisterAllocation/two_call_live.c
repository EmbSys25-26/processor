int f(int x);

int two_call_live(int a, int b) {
    int r1 = f(a);
    int r2 = f(b);
    return r1 + r2;
}
