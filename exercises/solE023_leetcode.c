// LeetCode 69 — Integer Square Root.  Linear search since the values
// stay small enough not to need Newton's method.
//
// Test inputs:
//   isqrt(100) = 10
//   isqrt(25)  = 5
//   sum        = 15 = 0x000F

int isqrt(int n) {
    int x;
    x = 0;
    while ((x + 1) * (x + 1) <= n) {
        x = x + 1;
    }
    return x;
}

int main(void) {
    return isqrt(100) + isqrt(25);
}
