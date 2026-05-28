/* feat_for_continue — skip odd iterations via continue.
   Sum of even i in 0..9: 0+2+4+6+8 = 20 = 0x14. */
int main(void) {
    int s = 0;
    for (int i = 0; i < 10; i = i + 1) {
        if ((i & 1) != 0) continue;
        s = s + i;
    }
    return s;
}
