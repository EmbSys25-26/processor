/* feat_while — plain while loop.
   Sum 10+9+...+1 = 55 = 0x37. */
int main(void) {
    int s = 0;
    int n = 10;
    while (n > 0) {
        s = s + n;
        n = n - 1;
    }
    return s;
}
