// LeetCode 1281-ish — Sum of Digits
// Compute sum of decimal digits of N.  Tests __mods (n % 10) and
// __divs (n / 10) in a tight loop.
//
// Test inputs (combined):
//   sum_digits(12345) = 15
//   sum_digits(99)    = 18
//   total             = 33 = 0x0021

int sum_digits(int n) {
    int s;
    s = 0;
    while (n > 0) {
        s = s + (n % 10);
        n = n / 10;
    }
    return s;
}

int main(void) {
    return sum_digits(12345) + sum_digits(99);
}
