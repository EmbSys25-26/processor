// Recursive GCD via Euclid's algorithm.  Tests recursion depth and
// runtime __mods inside a tail-recursive call.
//
// Inputs:
//   gcd_rec(48, 18) = 6
//   gcd_rec(100, 75) = 25
//   sum             = 31 = 0x001F

int gcd_rec(int a, int b) {
    if (b == 0) {
        return a;
    }
    return gcd_rec(b, a % b);
}

int main(void) {
    return gcd_rec(48, 18) + gcd_rec(100, 75);
}
