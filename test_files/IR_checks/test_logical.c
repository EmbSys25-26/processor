int g(int x);

int main() {
    int a = 5, b = 0;
    if (a > 0 && b == 0) {   /* Tests &&: short-circuits when a > 0 false */
        g(1);
    }
    if (a > 100 || b == 0) { /* Tests ||: short-circuits when a > 100 true */
        g(2);
    }
    int v = (a > 0) && (b < 10);  /* Tests && in value context */
    return v;
}
