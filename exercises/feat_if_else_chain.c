/* feat_if_else_chain — if / else if / else picks middle branch.
   x=20 → 20 is between 10 and 50 → return 0x22. */
int main(void) {
    int x = 20;
    int r;
    if (x < 10) {
        r = 0x11;
    } else if (x < 50) {
        r = 0x22;
    } else if (x < 100) {
        r = 0x33;
    } else {
        r = 0x44;
    }
    return r;
}
