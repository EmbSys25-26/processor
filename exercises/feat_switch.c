/* feat_switch — switch picks case 2, break exits cleanly.
   x=2 → return 0x22. */
int main(void) {
    int x = 2;
    int r;
    switch (x) {
        case 1: r = 0x11; break;
        case 2: r = 0x22; break;
        case 3: r = 0x33; break;
        default: r = 0x99; break;
    }
    return r;
}
