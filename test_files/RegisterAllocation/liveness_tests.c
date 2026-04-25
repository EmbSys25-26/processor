/* ── test 1: três variáveis vivas ao mesmo tempo ── */
int test_overlap() {
    int a = 1;
    int b = 2;
    int c = 3;
    int d = a + b + c;
    return d;
}

/* ── test 2: vidas sequenciais, cada var morre antes da próxima nascer ── */
int test_sequential() {
    int a = 10;
    int b = a + 5;
    int c = b * 2;
    int d = c - 1;
    return d;
}

/* ── test 3: ramos if/else, x sobrevive aos dois ramos ── */
int test_branching(int cond) {
    int x = 100;
    int y;
    if (cond) {
        y = 1;
    } else {
        y = 2;
    }
    return x + y;
}

/* ── test 4: loop — sum e i vivos ao mesmo tempo em cada iteração ── */
int test_loop() {
    int sum = 0;
    int i = 0;
    while (i < 10) {
        sum = sum + i;
        i = i + 1;
    }
    return sum;
}

/* ── test 5: x tem um "buraco" na sua vida (não usado durante y/z) ── */
int test_lifetime_hole() {
    int x = 5;
    int y = 10;
    int z = y * 2;
    int result = x + z;
    return result;
}

/* ── test 6: cadeia linear, cada vreg morre logo a seguir ── */
int chain_linear() {
    int a = 1;
    int b = a + 2;
    int c = b + 3;
    return c;
}

/* ── test 7: duas vars independentes somadas ── */
int two_vars() {
    int a = 1;
    int b = 2;
    int c = a + b;
    return c;
}

/* ── test 8: três vars independentes todas vivas até ao add ── */
int three_overlap() {
    int a = 1;
    int b = 2;
    int c = 3;
    int d = a + b + c;
    return d;
}

/* ── test 9: cadeia com rename, cada step depende do anterior ── */
int rename_chain() {
    int a = 1;
    int b = a + 1;
    int a2 = b + 1;
    return a2;
}

/* ── test 10: if/else que define 'a' em cada ramo, merge no return ── */
int branch_merge(int x) {
    int a;
    if (x > 0)
        a = 1;
    else
        a = 2;
    return a;
}
