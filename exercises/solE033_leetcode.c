// Sum of squares 1^2 + 2^2 + ... + N^2.  Tests __mul accumulated into
// a sum.
//
// Input: N = 10.  Sum = 385 = 0x0181

int main(void) {
    int sum;
    int i;
    sum = 0;
    i = 1;
    while (i <= 10) {
        sum = sum + i * i;
        i = i + 1;
    }
    return sum;
}
