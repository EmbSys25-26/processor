// Climbing Stairs variant — steps {1, 2, 3}.  Number of ways to reach
// step n.  f(n) = f(n-1) + f(n-2) + f(n-3), f(0)=1, f(1)=1, f(2)=2.
//
// Input: n = 5.
//   f(0)=1, f(1)=1, f(2)=2, f(3)=4, f(4)=7, f(5)=13
// Expected: 13 = 0x000D

int climb3(int n) {
    int a;
    int b;
    int c;
    int t;
    int i;
    if (n == 0) {
        return 1;
    }
    if (n == 1) {
        return 1;
    }
    if (n == 2) {
        return 2;
    }
    a = 1;
    b = 1;
    c = 2;
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

int main(void) {
    return climb3(5);
}
