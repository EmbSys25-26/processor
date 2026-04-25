int sum3(int x, int y, int z);

int call_three_args(int a, int b, int c) {
    int r = sum3(a, b, c);
    return r;
}
