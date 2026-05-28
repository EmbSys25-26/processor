/* feat_shift_right_signed — arithmetic right shift preserves sign.
   (int)-16 = 0xFFF0; -16 >> 2 = -4 = 0xFFFC. */
int main(void) {
    int v = -16;
    int k = 2;
    return v >> k;
}
