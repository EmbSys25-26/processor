/* Try to force `b`'s vreg to land in t0 (r4) at the same time `dst==a`. */
int main() {
    int a = 5;
    int b = 3;
    a = a | b;
    return a;
}
