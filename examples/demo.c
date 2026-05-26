/*
 * examples/demo.c — canonical compiler showcase
 *
 * Exercises every major backend feature in one file:
 *
 *   1. struct  — field write and read  (p.x, p.y)
 *   2. 2-D array — mat[row][col]
 *   3. 5+ arguments — d and e are passed via the stack (beyond r1-r3)
 *   4. nested call — g(h(x, y), y)  forces h result call-live during g
 *   5. signed division   → CALL(__divs, a, b)
 *      unsigned division → CALL(__divu, a, b)
 *   6. if with && and ||  (short-circuit control-flow lowering)
 *
 * Build and run:
 *   make
 *   ./compiler examples/demo.c
 *
 * The resulting output.asm is archived as output.asm
 */

/* ── externals resolved at link time ───────────────────────────────────── */
int g(int x, int y);
int h(int x, int y);

/* ── 1. struct with field access ────────────────────────────────────────── */
int use_point(int px, int py) {
    struct Point { int x; int y; } p;
    p.x = px;          /* write field x  (GEP index 0 * 2) */
    p.y = py;          /* write field y  (GEP index 1 * 2) */
    int a = p.x;       /* read  field x */
    int b = p.y;       /* read  field y */
    return a + b;
}

/* ── 2. 2-D array ───────────────────────────────────────────────────────── */
int sum_corners(int a, int b, int c, int d) {
    int mat[2][2];
    mat[0][0] = a;
    mat[0][1] = b;
    mat[1][0] = c;
    mat[1][1] = d;
    return mat[0][0] + mat[1][1];   /* top-left + bottom-right */
}

/* 3. 5+ arguments — d and e spill onto the stack past r1/r2/r3 ───────── */
int five_args(int a, int b, int c, int d, int e) {
    return a + b + c + d + e;
}

/* 4. nested call: h result stays call-live while g runs ─────────────── */
int nested_calls(int x, int y) {
    return g(h(x, y), y);
}

/* 5a. signed   division  →  CALL(__divs, a1, a2) ────────────────────── */
int signed_div(int a, int b) {
    return a / b;
}

/* 5b. unsigned division  →  CALL(__divu, a1, a2) ────────────────────── */
int unsigned_div(int a, int b) {
    int q = a / b;
    return q;
}
/* 6. if with && and || (short-circuit) ───────────────────────────────── */
int cond_logic(int a, int b, int c) {
    if (a > 0 && b > 0) {    /* rhs only evaluated when lhs is true  */
        return a + b;
    }
    if (a < 0 || c > 10) {   /* rhs only evaluated when lhs is false */
        return c;
    }
    return 0;
}