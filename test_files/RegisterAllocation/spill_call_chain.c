/*
 * spill_call_chain.c -- generalisation of force_spill.c upward.
 * Nine get_val(i) results all flow directly into a final 9-arg sink
 * call without being stored to local slots first.  This keeps the nine
 * results call-live across each subsequent get_val() call, so the
 * regalloc must spill at least 9 - 4 = 5 of them onto the stack
 * because only r8..r11 are callee-saved.
 */
int gv(int x);
int sink(int a, int b, int c, int d, int e, int f, int g, int h, int i);

int main(void) {
    return sink(
        gv(1),
        gv(2),
        gv(3),
        gv(4),
        gv(5),
        gv(6),
        gv(7),
        gv(8),
        gv(9)
    );
}
