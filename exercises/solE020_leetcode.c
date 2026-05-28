// Recursive sum 1..N.  Tests recursion depth (10 frames) and addition.
//
// Input: N = 10.  Sum = 55 = 0x0037

int sum_rec(int n) {
    if (n <= 0) {
        return 0;
    }
    return n + sum_rec(n - 1);
}

int main(void) {
    return sum_rec(10);
}
