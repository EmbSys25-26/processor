/* feat_call_3args — three-argument call uses all ABI arg registers.
   sum3(1, 2, 3) = 6 = 0x06. */
int sum3(int a, int b, int c) {
    return a + b + c;
}

int main(void) {
    return sum3(1, 2, 3);
}
