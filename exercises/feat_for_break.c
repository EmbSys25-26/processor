/* feat_for_break — break out of a for-loop early.
   Sum 0..4 only (break at i==5): 10 = 0x0A. */
int main(void) {
    int s = 0;
    for (int i = 0; i < 100; i = i + 1) {
        if (i >= 5) break;
        s = s + i;
    }
    return s;
}
