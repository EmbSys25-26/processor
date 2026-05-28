/* feat_switch_default — no matching case → default branch fires.
   x=7 → return 0x99. */
int main(void) {
    int x = 7;
    int r;
    switch (x) {
        case 1: r = 0x11; break;
        case 2: r = 0x22; break;
        case 3: r = 0x33; break;
        default: r = 0x99; break;
    }
    return r;
}
