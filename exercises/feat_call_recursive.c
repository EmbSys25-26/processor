/* feat_call_recursive — recursive factorial.
   fact(5) = 5*4*3*2*1 = 120 = 0x78. */
int fact(int n) {
    if (n <= 1) return 1;
    return n * fact(n - 1);
}

int main(void) {
    return fact(5);
}
