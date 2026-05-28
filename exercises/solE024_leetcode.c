// Sum 1..N via closed-form Gauss formula.  Tests __mul + __divs in
// one expression evaluation.
//
// Inputs:
//   gauss(10) = 55
//   gauss(20) = 210
//   sum       = 265 = 0x0109

int gauss(int n) {
    return n * (n + 1) / 2;
}

int main(void) {
    return gauss(10) + gauss(20);
}
