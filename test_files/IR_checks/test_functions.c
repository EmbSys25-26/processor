int add(int a, int b) {
    return a + b;
}

int sub(int a, int b) {
    return a - b;
}

int mul(int a, int b) {
    return a * b;
}

void set_zero(int a) {
    a = 0;
    return;
}

int identity(int x) {
    return x;
}

int double_val(int x) {
    return add(x, x);
}

int triple_val(int x) {
    int d;
    d = double_val(x);
    return add(d, x);
}

int compute(int a, int b, int c) {
    int t1;
    int t2;
    t1 = add(a, b);
    t2 = mul(t1, c);
    return sub(t2, a);
}

int main(void) {
    int r;
    r = add(3, 4);
    r = sub(10, 3);
    r = mul(4, 5);
    set_zero(r);
    r = identity(42);
    r = double_val(5);
    r = triple_val(3);
    r = compute(2, 3, 4);
    return r;
}
