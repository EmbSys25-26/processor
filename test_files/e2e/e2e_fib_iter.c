// Iterative Fibonacci. Tests while-loop, multi-variable update,
// no function calls (leaf main).
// Expected: fib(10) = 55 = 0x0037
int main(void) {
    int a;
    int b;
    int t;
    int i;
    a = 0;
    b = 1;
    i = 0;
    while (i < 10) {
        t = a + b;
        a = b;
        b = t;
        i = i + 1;
    }
    return a;
}
