// Linear integer exponentiation a^b (b iterations).  Tests __mul in
// a counted loop.
//
// Input: a = 2, b = 10.  Result = 1024 = 0x0400

int power_lin(int a, int b) {
    int r;
    r = 1;
    while (b > 0) {
        r = r * a;
        b = b - 1;
    }
    return r;
}

int main(void) {
    return power_lin(2, 10);
}
