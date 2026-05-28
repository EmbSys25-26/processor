// LeetCode 50 — Fast exponentiation pow(x, n) for non-negative n.
// Tests bitwise AND with 1, right shift, and conditional multiply.
//
// Input: x = 2, n = 10.  Result = 1024 = 0x0400

int fastpow(int x, int n) {
    int r;
    r = 1;
    while (n > 0) {
        if ((n & 1) != 0) {
            r = r * x;
        }
        x = x * x;
        n = n >> 1;
    }
    return r;
}

int main(void) {
    return fastpow(2, 10);
}
