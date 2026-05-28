// LeetCode 9 — Palindrome Number
// https://leetcode.com/problems/palindrome-number/
//
// Return 1 if integer is a palindrome (reads the same forwards and back),
// 0 otherwise.  Negatives are never palindromes per the problem's rules.
//
// Approach: build the reverse and compare.
//
// Test inputs (composed):
//   is_pal(121)   = 1
//   is_pal(123)   = 0
//   is_pal(12321) = 1
//   is_pal(0)     = 1   (single digit is a palindrome)
//   is_pal(10)    = 0
//
// Encoded result: (is_pal(121)   << 4)
//               | (is_pal(123)   << 3)
//               | (is_pal(12321) << 2)
//               | (is_pal(0)     << 1)
//               |  is_pal(10)
//               = 16 | 0 | 4 | 2 | 0 = 22 = 0x0016

int is_palindrome(int n) {
    int orig;
    int rev;
    int d;
    if (n < 0) {
        return 0;
    }
    orig = n;
    rev = 0;
    while (n > 0) {
        d = n % 10;
        rev = rev * 10 + d;
        n = n / 10;
    }
    if (orig == rev) {
        return 1;
    }
    return 0;
}

int main(void) {
    int r;
    r = (is_palindrome(121)   << 4)
      | (is_palindrome(123)   << 3)
      | (is_palindrome(12321) << 2)
      | (is_palindrome(0)     << 1)
      |  is_palindrome(10);
    return r;
}
