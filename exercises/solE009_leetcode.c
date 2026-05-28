// LeetCode-style — minimum of 3 numbers.  Tests cascaded ifs and
// 3-argument function calls.
//
// Test inputs:
//   min3(7, 3, 5) = 3
//   min3(1, 2, 3) = 1
//   sum           = 4 = 0x0004

int min3(int a, int b, int c) {
    int m;
    m = a;
    if (b < m) {
        m = b;
    }
    if (c < m) {
        m = c;
    }
    return m;
}

int main(void) {
    return min3(7, 3, 5) + min3(1, 2, 3);
}
