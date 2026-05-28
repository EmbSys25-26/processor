// test.c

int foo(int a) {
    return (a / 11) * 2;
}

int main(void) {
    int s = 0;
    if (0) {
        for (int i = 1; i <= 10; i = i + 1) s = s + i; // 55 = 0x0037 
    } else {
        for (int i = 1; i <= 11; i = i + 1) s = s + i; // 66 = 0x0042
    }
    s = foo(s);
    return s;
}