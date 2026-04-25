int scale(int x);

int call_and_arith(int a, int b) {
    int s = scale(a);
    int r = s + b;
    return r;
}
