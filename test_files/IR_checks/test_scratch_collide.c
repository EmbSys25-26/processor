/* Many concurrent live vregs + AND-with-imm forces materialize_operand
 * to pick a scratch from {t0..t3}. If regalloc has placed live vregs in
 * those colors, the materialisation will clobber one. */
int g(int x);

int main() {
    int a = g(1);
    int b = g(2);
    int c = g(3);
    int d = g(4);
    /* a..d all live across the AND below. */
    int masked = a & 0xFF;
    return masked + b + c + d;
}
