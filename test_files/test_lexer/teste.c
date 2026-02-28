int main() {
    /* teste original */
    int x = 5;
    float y = 3.14;
    char c = '\n';
    int *p = 0;

    if (x > 0) {
        x += 1;
    } else {
        x--;
    }

    for (int i = 0; i < 10; i++) {
        x = x * 2;
    }

    /* ── números negativos ── */
    int a = -5;
    int b = -3 + 2;
    int neg = -(x + 1);

    /* ── operações ── */
    int sub = 5 - 3;
    int mul = 5 * 3;
    int div = 10 / 2;
    int mod = 10 % 3;

    /* ── ponteiros ── */
    int *ptr = 0;
    int **pp = 0;
    *ptr = 5;
    int addr = &x;

    /* ── arrays ── */
    int arr[10];
    int matrix[5][5];
    arr[0] = 5;
    matrix[1][2] = 3;

    /* ── ternário ── */
    int t = x > 0 ? 1 : -1;

    /* ── bitwise ── */
    int bw = x & 0xFF;
    int bor = x | 0x01;
    int bxor = x ^ 0x0F;
    int bnot = ~x;
    int lsh = x << 2;
    int rsh = x >> 1;

    /* ── lógicos ── */
    int l1 = x > 0 && y < 10.0;
    int l2 = x > 0 || y < 0.0;
    int l3 = !x;

    /* ── cast ── */
    int cast1 = (int) y;
    float cast2 = (float) x;
    int *cast3 = (int *) ptr;

    /* ── comparações ── */
    int eq  = x == 5;
    int neq = x != 5;
    int lt  = x < 5;
    int gt  = x > 5;
    int lte = x <= 5;
    int gte = x >= 5;

    /* ── atribuições compostas ── */
    x += 1;
    x -= 1;
    x *= 2;
    x /= 2;
    x %= 3;
    x &= 0xFF;
    x |= 0x01;
    x ^= 0x0F;
    x <<= 1;
    x >>= 1;

    /* ── incremento e decremento ── */
    x++;
    x--;
    ++x;
    --x;

    /* ── switch ── */
    switch (x) {
        case 1:
            x = 10;
            break;
        case 2:
            x = 20;
            break;
        default:
            x = 0;
            break;
    }

    /* ── while e do while ── */
    while (x > 0) {
        x--;
    }

    do {
        x++;
    } while (x < 10);

    /* ── goto e label ── */
    goto fim;
    x = 999;
fim:
    x = 0;

    /* ── continue e break ── */
    for (int i = 0; i < 10; i++) {
        if (i == 5) continue;
        if (i == 8) break;
    }

    /* ── chamada de função ── */
    int r = add(x, 5);
    int r2 = add(x + 1, y * 2);

    /* ── string e char ── */
    char *str = "hello world";
    char ch1 = 'a';
    char ch2 = '\t';
    char ch3 = '\\';
    char ch4 = '\'';
    char ch5 = '\0';

    /* ── hex ── */
    int h1 = 0xFF;
    int h2 = 0x1A2B;

    /* ── múltiplas declarações ── */
    int m1, m2, m3;
    int n1 = 1, n2 = 2, n3 = 3;

    return 0;
}

/* ── protótipo e definição de função ── */
int add(int a, int b);

int add(int a, int b) {
    return a + b;
}

/* ── função com ponteiro no retorno ── */
int *get_ptr(int *p) {
    return p;
}

/* ── variáveis globais ── */
static int global1 = 0;
const int global2 = 10;
extern int global3;
