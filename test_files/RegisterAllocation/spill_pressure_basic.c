/*
 * spill_pressure_basic.c -- ten extf() results all flow as arguments
 * to a single ten-arg sink call.  This forces ten simultaneously
 * call-live virtual registers; with only K_callee = 4 callee-saved
 * registers (r8..r11), the regalloc must spill at least six of them.
 * The pipeline converges in one iteration of spill rewriting.
 */
int extf(int x);
int sink10(int a, int b, int c, int d, int e,
           int f, int g, int h, int i, int j);

int main(void) {
    return sink10(extf(1), extf(2), extf(3), extf(4), extf(5),
                  extf(6), extf(7), extf(8), extf(9), extf(10));
}
