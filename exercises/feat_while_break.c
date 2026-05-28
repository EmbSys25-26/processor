/* feat_while_break — break out of infinite while.
   Sum 0..6 = 21 = 0x15. */
int main(void) {
    int s = 0;
    int i = 0;
    while (1) {
        if (i >= 7) break;
        s = s + i;
        i = i + 1;
    }
    return s;
}
