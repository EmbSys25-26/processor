/* feat_div_unsigned — unsigned division (lowered to __divu helper).
   65000 / 7 = 9285 = 0x2445 when both operands are unsigned. */
int main(void) {
    unsigned int a = 65000;
    unsigned int b = 7;
    unsigned int q = a / b;
    int r = q;
    return r;
}
