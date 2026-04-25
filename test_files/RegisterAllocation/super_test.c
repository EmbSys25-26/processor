/*
 * mega_test.c
 *
 * UM ÚNICO FICHEIRO com UMA ÚNICA FUNÇÃO PRINCIPAL que testa tudo.
 * Padrões baseados nos testes que já funcionam (force_spill.c, tryhard.c, etc.)
 *
 * Convenção da ABI:
 *   r1-r3  → argumentos / retorno (caller-saved, pré-coloridos)
 *   r4-r7  → caller-saved livres (para temporários curtos)
 *   r8-r11 → callee-saved (para call-live vregs)
 *
 * O padrão que força call-live REAL:
 *   consome_X(get_val(1), get_val(2), ..., get_val(N))
 *   → O compilador avalia os args da esquerda para a direita.
 *   → Quando get_val(N) corre, os resultados de 1..N-1 estão TODOS vivos.
 *   → Na call de consome_X: N vregs simultaneamente call-live.
 *   → 1 pré-colorido em r1; N-1 precisam de callee-saved.
 *   → Se N-1 > 4: (N-5) spills.
 */

/* ── Externas que forçam calls reais ────────────────────────────────────── */
int get_val(int x);          /* retorna algo em r1 */
int f(int x);                /* 1 arg */
int g(int x);                /* 1 arg */
int h(int x, int y);         /* 2 args */
int triple(int x, int y, int z); /* 3 args */
void consome4(int a, int b, int c, int d);
void consome5(int a, int b, int c, int d, int e);
void consome6(int a, int b, int c, int d, int e, int fv);

/* ════════════════════════════════════════════════════════════════════════════
 * A FUNÇÃO MONOLÍTICA
 * ════════════════════════════════════════════════════════════════════════════ */
int mega_test(int a, int b, int c) {

    /* ────────────────────────────────────────────────────────────────────────
     * ZONA 1 — Pressão 4, SEM SPILL
     * get_val(1), (2), (3) ficam vivos enquanto get_val(4) corre.
     * Na call de consome4: exactamente 4 vregs call-live → r8, r9, r10, r11.
     * ──────────────────────────────────────────────────────────────────────── */
    consome4(get_val(1), get_val(2), get_val(3), get_val(4));

    /* ────────────────────────────────────────────────────────────────────────
     * ZONA 2 — Pressão 5, 1 SPILL
     * 5 call-live → 1 para r1 (pré-cor.), 4 precisam callee-saved, 4 existem.
     * Mas o 5º não cabe → SPILL. Deve ver: spills: 1, 2 iterações.
     * ──────────────────────────────────────────────────────────────────────── */
    consome5(get_val(1), get_val(2), get_val(3), get_val(4), get_val(5));

    /* ────────────────────────────────────────────────────────────────────────
     * ZONA 3 — Pressão 6, 2 SPILLS
     * 6 call-live → 1 r1, 4 callee-saved, faltam 2 → 2 spills.
     * ──────────────────────────────────────────────────────────────────────── */
    consome6(get_val(1), get_val(2), get_val(3), get_val(4), get_val(5), get_val(6));

    /* ────────────────────────────────────────────────────────────────────────
     * ZONA 4 — Calls aninhadas (nested)
     * triple(f(a), g(b), h(a,b)):
     *   - f(a) avaliado 1º  → resultado fica vivo enquanto g() e h() correm
     *   - g(b) avaliado 2º  → resultado fica vivo enquanto h() corre
     *   - h(a,b) avaliado 3º
     *   - triple recebe os 3 em r1, r2, r3
     * Testa pré-coloração múltipla e call-live em cascata.
     * ──────────────────────────────────────────────────────────────────────── */
    int r4 = triple(f(a), g(b), h(a, b));

    /* ────────────────────────────────────────────────────────────────────────
     * ZONA 5 — Args a, b, c call-live sobre triple interno
     * a→r1, b→r2, c→r3 na entrada.
     * triple(10,20,30) clobbers r1-r7 → a, b, c têm de ir para r8-r10.
     * 3 call-live; cabe nos 4 callee-saved disponíveis. Sem spill.
     * ──────────────────────────────────────────────────────────────────────── */
    int m5 = triple(10, 20, 30);
    int s5 = a + b + c + m5;

    /* ────────────────────────────────────────────────────────────────────────
     * ZONA 6 — Um valor sobrevive a 4 calls consecutivas
     * 'z' tem de cruzar f(), g(), h() e triple().
     * 1 call-live em cada ponto → r8 basta. Sem spill.
     * ──────────────────────────────────────────────────────────────────────── */
    int z = get_val(42);
    int ra = f(1);
    int rb = g(2);
    int rc = h(3, 4);
    int rd = triple(5, 6, 7);
    int s6 = z + ra + rb + rc + rd;

    /* ────────────────────────────────────────────────────────────────────────
     * ZONA 7 — Branch com call-live
     * 'pre' nasce antes do if/else e morre depois.
     * Em cada ramo há uma call que o obriga a estar em callee-saved.
     * ──────────────────────────────────────────────────────────────────────── */
    int pre = get_val(77);
    int br;
    if (a > b) {
        br = f(a);
    } else {
        br = g(b);
    }
    int s7 = pre + br;

    /* ────────────────────────────────────────────────────────────────────────
     * ZONA 8 — Loop simples, 1 acumulador call-live
     * 'acc' sobrevive a f(i) em cada iteração.
     * 1 call-live → r8 basta. Sem spill.
     * ──────────────────────────────────────────────────────────────────────── */
    int acc = 0;
    int i = 0;
    while (i < 5) {
        int v = f(i);
        acc = acc + v;
        i = i + 1;
    }

    /* ────────────────────────────────────────────────────────────────────────
     * ZONA 9 — Loop com 4 acumuladores call-live, SEM SPILL
     * acc1..acc4 sobrevivem a f(j) em cada iteração.
     * Exactamente 4 callee-saved necessários (r8-r11). Sem spill.
     * ──────────────────────────────────────────────────────────────────────── */
    int acc1 = 0;
    int acc2 = 0;
    int acc3 = 0;
    int acc4 = 0;
    int j = 0;
    while (j < 3) {
        int w = f(j);
        acc1 = acc1 + w;
        acc2 = acc2 + w;
        acc3 = acc3 + w;
        acc4 = acc4 + w;
        j = j + 1;
    }
    int s9 = acc1 + acc2 + acc3 + acc4;

    /* ────────────────────────────────────────────────────────────────────────
     * ZONA 10 — Loop com 5 acumuladores, 1 SPILL POR ITERAÇÃO
     * acc1..acc5 sobrevivem a f(k) em cada iteração.
     * 5 call-live → 1 spill obrigatório.
     * ──────────────────────────────────────────────────────────────────────── */
    int b1 = 0;
    int b2 = 0;
    int b3 = 0;
    int b4 = 0;
    int b5 = 0;
    int k = 0;
    while (k < 3) {
        int u = f(k);
        b1 = b1 + u;
        b2 = b2 + u;
        b3 = b3 + u;
        b4 = b4 + u;
        b5 = b5 + u;
        k = k + 1;
    }
    int s10 = b1 + b2 + b3 + b4 + b5;

    /* ────────────────────────────────────────────────────────────────────────
     * ZONA 11 — Ondas não-interferentes (duas ondas de 4, SEM SPILL)
     * Onda A usa r8-r11; morre completamente antes de Onda B.
     * Onda B reutiliza r8-r11. Sem conflito → sem spill.
     * ──────────────────────────────────────────────────────────────────────── */
    consome4(get_val(10), get_val(11), get_val(12), get_val(13));
    consome4(get_val(20), get_val(21), get_val(22), get_val(23));

    /* ────────────────────────────────────────────────────────────────────────
     * ZONA 12 — Branch com 5 call-live no ramo ELSE (spill apenas num ramo)
     * Ramo IF:   4 call-live → sem spill
     * Ramo ELSE: 5 call-live → 1 spill
     * ──────────────────────────────────────────────────────────────────────── */
    int br2;
    if (c > 0) {
        consome4(get_val(1), get_val(2), get_val(3), get_val(4));
        br2 = f(c);
    } else {
        consome5(get_val(1), get_val(2), get_val(3), get_val(4), get_val(5));
        br2 = g(c);
    }

    /* ────────────────────────────────────────────────────────────────────────
     * ZONA 13 — Aritmética pura, sem calls
     * Nenhum callee-saved necessário. O alocador deve usar só r4-r7.
     * Máxima sobreposição: 4 valores vivos em simultâneo.
     * ──────────────────────────────────────────────────────────────────────── */
    int p = a + 1;
    int q = b + 2;
    int r = c + 3;
    int s = a + b + c;
    int s13 = p + q + r + s;

    return r4 + s5 + s6 + s7 + acc + s9 + s10 + br2 + s13;
}
