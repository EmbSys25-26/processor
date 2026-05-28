// LeetCode 191 — Number of 1 Bits (popcount / Hamming weight).
// Tests bitwise AND with literal 1 and logical right shift in a loop.
//
// Test inputs:
//   popcount(0x001F) = 5
//   popcount(0x00FF) = 8
//   sum              = 13 = 0x000D

int popcount(int n) {
    int c;
    c = 0;
    while (n != 0) {
        c = c + (n & 1);
        n = n >> 1;
    }
    return c;
}

int main(void) {
    return popcount(0x001F) + popcount(0x00FF);
}
