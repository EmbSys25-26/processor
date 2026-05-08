/*
 * spill_loop.c -- loop body whose register pressure is multiplied by
 * loop-carried liveness.  Eight accumulators all updated every
 * iteration; each must stay live across the loop back-edge.  Combined
 * with the loop counter and the ext() call inside the body, the
 * effective simultaneous live set exceeds K and forces spilling.
 */
int ext(int x);

int main(void) {
    int a = 1, b = 2, c = 3, d = 4;
    int e = 5, f = 6, g = 7, h = 8;
    int i = 0;

    while (i < 10) {
        int t = ext(i);
        a = a + t;
        b = b + t;
        c = c + t;
        d = d + t;
        e = e + t;
        f = f + t;
        g = g + t;
        h = h + t;
        i = i + 1;
    }
    return a + b + c + d + e + f + g + h;
}
