/* feat_cmp_unsigned — unsigned comparisons differ from signed
   for values with the high bit set.
   a = 0xFFFD (treated as unsigned 65533), b = 5.
     bit0: a <  b   → 0
     bit1: a <= b   → 0
     bit2: a >  b   → 1
     bit3: a >= b   → 1
     bit4: a == b   → 0
     bit5: a != b   → 1
   Pack: 0b101100 = 0x2C. */
int main(void) {
    unsigned int a = 0xFFFD;
    unsigned int b = 5;
    int r = 0;
    if (a <  b) r = r | 0x01;
    if (a <= b) r = r | 0x02;
    if (a >  b) r = r | 0x04;
    if (a >= b) r = r | 0x08;
    if (a == b) r = r | 0x10;
    if (a != b) r = r | 0x20;
    return r;
}
