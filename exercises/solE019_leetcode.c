// LeetCode 342 — Power of Four.  n is a power of 4 iff n>0,
// (n & (n-1)) == 0 (single set bit), and the bit sits in an even
// position (mask 0x5555 in 16 bits).
//
// Test inputs (composed):
//   is_pow4(16) = 1   (4^2)
//   is_pow4(8)  = 0   (2^3)
//   is_pow4(64) = 1   (4^3)
//   is_pow4(1)  = 1   (4^0)
// Encoded: (is_pow4(16) << 3) | (is_pow4(8) << 2)
//        | (is_pow4(64) << 1) |  is_pow4(1)
//        = 8 | 0 | 2 | 1 = 11 = 0x000B

int is_pow4(int n) {
    if (n <= 0) {
        return 0;
    }
    if ((n & (n - 1)) != 0) {
        return 0;
    }
    if ((n & 0x5555) != 0) {
        return 1;
    }
    return 0;
}

int main(void) {
    int r;
    r = (is_pow4(16) << 3)
      | (is_pow4(8)  << 2)
      | (is_pow4(64) << 1)
      |  is_pow4(1);
    return r;
}
