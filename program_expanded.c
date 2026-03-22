# 0 "program.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 0 "<command-line>" 2
# 1 "program.c"
# 11 "program.c"
enum Cor { VERMELHO, VERDE = 5, AZUL };


struct Ponto {
    int x;
    int y;
    struct Ponto* p;
};


union Dados {
    int i;
    float f;
};


int soma(int a, int b);


int contador = 0;
static int privado = 42;
extern int externo;
const int LIMITE = 100;
unsigned int flags = 0;
int arr_global[10];


int soma(int a, int b) {
    return a + b;
}


void trocar(int* a, int* b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}


float media(float arr[], int n) {
    float s = 0;
    int i;
    for (i = 0; i < n; i++) {
        s = s + arr[i];
    }
    return s / n;
}


void mover_ponto(struct Ponto* p, int dx, int dy) {
    p->x = p->x + dx;
    p->y = p->y + dy;
}


int operadores(int a, int b) {
    int r = a + b * a - b / a % 2;
    r += 1;
    r -= 1;
    r *= 2;
    r /= 2;
    r %= 3;
    return r;
}


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


int comparacoes(int a, int b) {
    return (a == b) + (a != b) + (a < b) + (a > b) + (a <= b) + (a >= b);
}


int inc_dec(int a) {
    a++;
    a--;
    ++a;
    --a;
    return a;
}


int classify(int x) {
    if (x < 0) {
        return -1;
    } else if (x == 0) {
        return 0;
    } else {
        return 1;
    }
}


int sw(int op, int a, int b) {
    int r;
    switch (op) {
        case 0: r = a + b; break;
        case 1: r = a - b; break;
        default: r = 0; break;
    }
    return r;
}


int loop_while(int n) {
    int s = 0;
    while (n > 0) {
        s = s + n;
        n--;
    }
    return s;
}


int loop_do_while(int n) {
    int s = 0;
    do {
        s = s + n;
        n--;
    } while (n > 0);
    return s;
}


int loop_for(int n) {
    int s = 0;
    for (int i = 0; i < n; i++) {
        if (i % 2 == 0) continue;
        if (i > 10) break;
        s = s + i;
    }
    return s;
}


int ternario(int a, int b) {
    return a > b ? a : b;
}


int casts(int a) {
    float b = (float) a;
    int c = (int) b;
    int s = sizeof(int) + sizeof(a) + sizeof(struct Ponto);
    return c + s;
}


void ponteiros(void) {
    int x = 5;
    int* p = &x;
    int** pp = &p;
    *p = 10;
    **pp = 20;
}


void qualificadores(void) {
    const int k = 42;
    volatile int v = 0;
    unsigned int u = 100;
    signed int s = -50;
    static int st = 0;
    st = st + 1;
}


static int funcao_static(int x) { return x * 2; }
inline int funcao_inline(int x) { return x + 1; }


void funcao_void(int x) {
    int y = x + 1;
    return;
}


int main() {
    int a = 10;
    int b = 3;

    int s = soma(a, b);
    int cl = classify(a);
    int sw1 = sw(0, a, b);
    int wh = loop_while(5);
    int dw = loop_do_while(5);
    int fr = loop_for(10);
    int tr = ternario(a, b);
    int cs = casts(a);
    int op = operadores(a, b);
    int cmp = comparacoes(a, b);
    int id = inc_dec(a);
    int bt = bits(a, b);

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
