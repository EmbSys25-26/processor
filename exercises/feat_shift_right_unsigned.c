/* feat_shift_right_unsigned — logical right shift fills zero.
   0xF000 >> 4 = 0x0F00 when operand is unsigned. */
int main(void) {
    unsigned int v = 0xF000;
    unsigned int k = 4;
    unsigned int s = v >> k;
    int r = s;
    return r;
}
