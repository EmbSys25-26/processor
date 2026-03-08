/* ============================================================
 *  test_parser.c  —  One example of each supported feature
 * ============================================================ */

/* ---------- Pre-processor ---------- */
#define MAX 10
#undef MAX
#define MAX 15

/* ---------- Enum ---------- */
enum Cor { VERMELHO, VERDE = 5, AZUL };

/* ---------- Struct ---------- */
struct Ponto {
    int x;
    int y;
    struct Ponto* p;
};

/* ---------- Union ---------- */
union Dados {
    int i;
    float f;
};

/* ---------- Prototype ---------- */
int soma(int a, int b);

/* ---------- Global variables ---------- */
int contador = 0;
static int privado = 42;
extern int externo;
const int LIMITE = 100;
unsigned int flags = 0;
int arr_global[10];

/* ---------- Basic function ---------- */
int soma(int a, int b) {
    return a + b;
}

/* ---------- Pointers ---------- */
void trocar(int* a, int* b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

/* ---------- Array ---------- */
float media(float arr[], int n) {
    float s = 0;
    int i;
    for (i = 0; i < n; i++) {
        s = s + arr[i];
    }
    return s / n;
}

/* ---------- Struct as argument / dot / arrow ---------- */
void mover_ponto(struct Ponto* p, int dx, int dy) {
    p->x = p->x + dx;
    p->y = p->y + dy;
}

/* ---------- Arithmetic & compound assignment ---------- */
int operadores(int a, int b) {
    int r = a + b * a - b / a % 2;
    r += 1;
    r -= 1;
    r *= 2;
    r /= 2;
    r %= 3;
    return r;
}

/* ---------- Logical & bitwise operators ---------- */
int bits(int a, int b) {
    int r = a && b;
    r = a || b;
    r = !a;
    r = a & b;
    r = a | b;
    r = a ^ b;
    r = ~a;
    r = a << 2;
    r = b >> 1;
    r &= 0xFF;
    r |= 0x01;
    r ^= 0x10;
    r <<= 1;
    r >>= 1;
    return r;
}

/* ---------- Comparison ---------- */
int comparacoes(int a, int b) {
    return (a == b) + (a != b) + (a < b) + (a > b) + (a <= b) + (a >= b);
}

/* ---------- Increment / Decrement ---------- */
int inc_dec(int a) {
    a++;
    a--;
    ++a;
    --a;
    return a;
}

/* ---------- If / else ---------- */
int classify(int x) {
    if (x < 0) {
        return -1;
    } else if (x == 0) {
        return 0;
    } else {
        return 1;
    }
}

/* ---------- Switch ---------- */
int sw(int op, int a, int b) {
    int r;
    switch (op) {
        case 0:  r = a + b; break;
        case 1:  r = a - b; break;
        default: r = 0;     break;
    }
    return r;
}

/* ---------- While ---------- */
int loop_while(int n) {
    int s = 0;
    while (n > 0) {
        s = s + n;
        n--;
    }
    return s;
}

/* ---------- Do-while ---------- */
int loop_do_while(int n) {
    int s = 0;
    do {
        s = s + n;
        n--;
    } while (n > 0);
    return s;
}

/* ---------- For + break/continue ---------- */
int loop_for(int n) {
    int s = 0;
    for (int i = 0; i < n; i++) {
        if (i % 2 == 0) continue;
        if (i > 10)     break;
        s = s + i;
    }
    return s;
}

/* ---------- Ternary ---------- */
int ternario(int a, int b) {
    return a > b ? a : b;
}

/* ---------- Type cast & sizeof ---------- */
int casts(int a) {
    float b = (float) a;
    int c = (int) b;
    int s = sizeof(int) + sizeof(a) + sizeof(struct Ponto);
    return c + s;
}

/* ---------- Reference & double pointer ---------- */
void ponteiros(void) {
    int x = 5;
    int* p = &x;
    int** pp = &p;
    *p = 10;
    **pp = 20;
}

/* ---------- Type qualifiers ---------- */
void qualificadores(void) {
    const int k = 42;
    volatile int v = 0;
    unsigned int u = 100;
    signed int s = -50;
    static int st = 0;
    st = st + 1;
}

/* ---------- Visibility qualifiers ---------- */
static int funcao_static(int x) { return x * 2; }
inline int funcao_inline(int x) { return x + 1; }

/* ---------- Void return ---------- */
void funcao_void(int x) {
    int y = x + 1;
    return;
}

/* ---------- Main ---------- */
int main() {
    int a = 10;
    int b = 3;

    int s   = soma(a, b);
    int cl  = classify(a);
    int sw1 = sw(0, a, b);
    int wh  = loop_while(5);
    int dw  = loop_do_while(5);
    int fr  = loop_for(10);
    int tr  = ternario(a, b);
    int cs  = casts(a);
    int op  = operadores(a, b);
    int cmp = comparacoes(a, b);
    int id  = inc_dec(a);
    int bt  = bits(a, b);

    trocar(&a, &b);
    ponteiros();
    qualificadores();
    funcao_void(a);

    struct Ponto p;
    p.x = 3;
    p.y = 4;
    mover_ponto(&p, 1, -1);

    union Dados d;
    d.i = 42;

    enum Cor cor = VERDE;

    int arr[5];
    arr[0] = 1;
    arr[4] = 9;

    return s + cl + sw1 + wh + dw + fr + tr + cs + op + cmp + id + bt;
}
