// LeetCode 231 — Power of Two
// https://leetcode.com/problems/power-of-two/
//
// Return 1 if n is a power of two, 0 otherwise.  Bit trick:
//   n > 0 && (n & (n - 1)) == 0
//
// Test inputs composed via bit-shifts.  We pack 5 results into the low
// nibble plus one bit:
//   pow2(16) = 1
//   pow2(15) = 0
//   pow2(8)  = 1
//   pow2(0)  = 0     (zero is not a power of two)
//   pow2(1)  = 1     (1 = 2^0)
//
// Encoded result: (pow2(16) << 4)
//               | (pow2(15) << 3)
//               | (pow2(8)  << 2)
//               | (pow2(0)  << 1)
//               |  pow2(1)
//               = 16 | 0 | 4 | 0 | 1 = 21 = 0x0015

int is_pow2(int n) {
    if (n <= 0) {
        return 0;
    }
    if ((n & (n - 1)) == 0) {
        return 1;
    }
    return 0;
}

int main(void) {
    int r;
    r = (is_pow2(16) << 4)
      | (is_pow2(15) << 3)
      | (is_pow2(8)  << 2)
      | (is_pow2(0)  << 1)
      |  is_pow2(1);
    return r;
}
