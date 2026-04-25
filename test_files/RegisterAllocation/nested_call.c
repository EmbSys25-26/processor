int f(int x);
int g(int x, int y);

int nested_call(int a, int b) {
    int r = g(f(a), b);
    return r;
}
