/* feat_array_sum — array indexing and summation.
   Sum 1+2+...+8 = 36 = 0x24. */
int main(void) {
    int a[8];
    a[0] = 1; a[1] = 2; a[2] = 3; a[3] = 4;
    a[4] = 5; a[5] = 6; a[6] = 7; a[7] = 8;
    int s = 0;
    for (int i = 0; i < 8; i = i + 1) s = s + a[i];
    return s;
}
