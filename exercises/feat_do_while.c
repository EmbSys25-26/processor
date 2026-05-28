/* feat_do_while — do/while runs body at least once.
   n decreases from 5: 5+4+3+2+1 = 15 = 0x0F. */
int main(void) {
    int s = 0;
    int n = 5;
    do {
        s = s + n;
        n = n - 1;
    } while (n > 0);
    return s;
}
