/* feat_for_assign — for-loop with plain assignment init.
   Sum 0+1+2+3+4 = 10 = 0x0A. */
int main(void) {
    int i;
    int s = 0;
    for (i = 0; i < 5; i = i + 1) s = s + i;
    return s;
}
