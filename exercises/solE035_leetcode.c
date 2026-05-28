// Median of three integers — fully covered cascading ifs.
//
// Test inputs:
//   median3(3, 1, 2) = 2
//   median3(7, 9, 5) = 7
//   sum              = 9 = 0x0009

int median3(int a, int b, int c) {
    if (a <= b) {
        if (b <= c) {
            return b;
        }
        if (a <= c) {
            return c;
        }
        return a;
    }
    if (a <= c) {
        return a;
    }
    if (b <= c) {
        return c;
    }
    return b;
}

int main(void) {
    return median3(3, 1, 2) + median3(7, 9, 5);
}
