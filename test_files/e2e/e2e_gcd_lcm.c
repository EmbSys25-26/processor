// gcd via Euclid + lcm via gcd.  Tests nested calls (lcm -> gcd),
// runtime __mul + __divu + __modu, while + multi-return-path control.
// gcd(12,18) = 6 ; lcm = (12/6)*18 = 36
// Expected: 36 = 0x0024
int gcd(int a, int b) {
    int t;
    while (b != 0) {
        t = a % b;
        a = b;
        b = t;
    }
    return a;
}

int lcm(int a, int b) {
    int g;
    g = gcd(a, b);
    return (a / g) * b;
}

int main(void) {
    return lcm(12, 18);
}
