/* Force a 2-cycle in CALL register-arg coloring.
 *
 * The two callees swap parameter order: g(a, b) → h(b, a).  After regalloc
 * gives `a` the home a0 and `b` the home a1, the call setup must perform
 *     a0 ← a1   AND   a1 ← a0
 * simultaneously.  A naive "MOV(a0, a1); MOV(a1, a0)" sequence ends with
 * both registers holding the original a1 value.
 */
int h(int x, int y);

int g(int a, int b) {
    return h(b, a);
}

int main() {
    return g(7, 11);
}
