/* feat_nested_if — if inside else of an outer if.
   x=8, y=3: x>=5 true, then nested y>5 false → else returns 0x77. */
int main(void) {
    int x = 8;
    int y = 3;
    int r;
    if (x < 5) {
        r = 0x11;
    } else {
        if (y > 5) {
            r = 0x66;
        } else {
            r = 0x77;
        }
    }
    return r;
}
