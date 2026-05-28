// LeetCode 7 — Reverse Integer (positive subset)
// https://leetcode.com/problems/reverse-integer/
//
// Reverse the digits of a non-negative 16-bit integer.  We only handle
// the non-negative subset to avoid two's-complement edge cases; the
// LeetCode statement asks for sign preservation, which we skip.
//
// Test inputs: sum two reverses to mix multiple cases.
//   reverse(123) = 321
//   reverse(54)  = 45
//   sum          = 366 = 0x016E

int reverse(int n) {
    int r;
    int d;
    r = 0;
    while (n > 0) {
        d = n % 10;
        r = r * 10 + d;
        n = n / 10;
    }
    return r;
}

int main(void) {
    return reverse(123) + reverse(54);
}
