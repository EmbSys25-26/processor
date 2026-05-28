// Recursive Fibonacci (exponential).  Stresses the call/return path,
// stack frames, and lr save/restore many times.
//
// Input: n = 8.  fib(8) = 21 = 0x0015

int fib(int n) {
    if (n < 2) {
        return n;
    }
    return fib(n - 1) + fib(n - 2);
}

int main(void) {
    return fib(8);
}
