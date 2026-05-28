// LeetCode 412-derived — Sum of multiples of 3 or 5 up to N.
// (Differs from FizzBuzz string output — we sum instead.)
//
// Input: N = 20.  Multiples 3,5,6,9,10,12,15,18,20 -> 98
// Expected: 98 = 0x0062

int main(void) {
    int n;
    int sum;
    int i;
    n = 20;
    sum = 0;
    i = 1;
    while (i <= n) {
        if (i % 3 == 0 || i % 5 == 0) {
            sum = sum + i;
        }
        i = i + 1;
    }
    return sum;
}
