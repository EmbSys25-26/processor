/* feat_cmp_signed — signed comparisons.
   a = -3, b = 5.
     bit0: a <  b   → 1
     bit1: a <= b   → 1
     bit2: a >  b   → 0
     bit3: a >= b   → 0
     bit4: a == b   → 0
     bit5: a != b   → 1
   Pack into low bits: 0b100011 = 0x23. */
int main(void) {
    int a = -3;
    int b = 5;
    int r = 0;
    if (a <  b) r = r | 0x01;
    if (a <= b) r = r | 0x02;
    if (a >  b) r = r | 0x04;
    if (a >= b) r = r | 0x08;
    if (a == b) r = r | 0x10;
    if (a != b) r = r | 0x20;
    return r;
}
