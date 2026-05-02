int f5(int a, int b, int c, int d, int e);
int g(int x);

int main() {
    /* g(0) returns into a0; precolor likely keeps p there until used.
     * f5 receives p as the 4th arg (stack-passed).  If the call setup
     * loads register args (a0..a2) before pushing stack args, p's
     * source register a0 gets overwritten by the literal 1 before the
     * push. */
    int p = g(0);
    return f5(1, 2, 3, p, 5);
}
