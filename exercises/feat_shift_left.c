/* feat_shift_left — left shift by a runtime amount.
   0x000F << 4 = 0x00F0. */
int main(void) {
    int v = 0x000F;
    int k = 4;
    return v << k;
}
