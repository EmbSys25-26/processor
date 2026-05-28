// Count divisors of N.  Tests modulo in tight loop + function-call
// composition.
//
// Inputs:
//   count_divisors(12) = 6  (1, 2, 3, 4, 6, 12)
//   count_divisors(7)  = 2  (1, 7)
//   sum                = 8 = 0x0008

int count_divisors(int n) {
    int c;
    int i;
    c = 0;
    i = 1;
    while (i <= n) {
        if (n % i == 0) {
            c = c + 1;
        }
        i = i + 1;
    }
    return c;
}

int main(void) {
    return count_divisors(12) + count_divisors(7);
}
