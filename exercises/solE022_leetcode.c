// Tribonacci T(n).  T(0)=0, T(1)=T(2)=1, T(n)=T(n-1)+T(n-2)+T(n-3).
// Iterative bottom-up.
//
// Input: n = 10.  Series: 0,1,1,2,4,7,13,24,44,81,149.
// Expected: T(10) = 149 = 0x0095

int main(void) {
    int a;
    int b;
    int c;
    int t;
    int n;
    int i;
    a = 0;
    b = 1;
    c = 1;
    n = 10;
    i = 3;
    while (i <= n) {
        t = a + b + c;
        a = b;
        b = c;
        c = t;
        i = i + 1;
    }
    return c;
}
