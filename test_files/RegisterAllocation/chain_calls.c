int inc(int x);

int chain(int a) {
    int b = inc(a);
    int c = inc(b);
    int d = inc(c);
    return d;
}
