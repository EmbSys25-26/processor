/* ============================================================
 *  test_parser.c  —  Teste extensivo do parser C
 *  Cobre: tipos, declarações, ponteiros, arrays, structs,
 *         unions, enums, funções, expressões, operadores,
 *         controlo de fluxo, casts, sizeof, ternário
 * ============================================================ */

/* ---------- Enums ---------- */
enum Cor { VERMELHO, VERDE = 5, AZUL, AMARELO = -1 };
enum Estado { ATIVO, INATIVO, PENDENTE };

/* ---------- Structs ---------- */
struct Ponto {
    int x;
    int y;
};

struct Retangulo {
    struct Ponto origem;
    int largura;
    int altura;
};

struct Lista {
    int valor;
    struct Lista* proximo;
};

/* ---------- Unions ---------- */
union Dados {
    int i;
    float f;
    char c;
};

/* ---------- Protótipos ---------- */
int soma(int a, int b);
float media(float arr[], int n);
void trocar(int* a, int* b);
int busca_binaria(int arr[], int n, int target);
//struct Ponto criar_ponto(int x, int y);
int* alocar(int n);

/* ---------- Variáveis globais ---------- */
int contador = 0;
float pi = 3;
static int privado = 42;
extern int externo;
const int MAX = 100;
unsigned int flags = 0;
long int grande = 1000000;
short int pequeno = 10;

int arr_global[10];
int matriz[3][3];
char nome[50];

/* ---------- Funções simples ---------- */

int soma(int a, int b) {
    return a + b;
}

int subtracao(int a, int b) {
    return a - b;
}

int multiplicacao(int a, int b) {
    return a * b;
}

int divisao(int a, int b) {
    return a / b;
}

int modulo(int a, int b) {
    return a % b;
}

/* ---------- Ponteiros ---------- */

void trocar(int* a, int* b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

int soma_via_ptr(int* a, int* b) {
    return *a + *b;
}

int** matriz_ptr(int n) {
    int** m;
    return m;
}

void incrementar(int* p) {
    *p = *p + 1;
}

/* ---------- Arrays ---------- */

float media(float arr[], int n) {
    float soma = 0;
    int i;
    for (i = 0; i < n; i++) {
        soma = soma + arr[i];
    }
    return soma / n;
}

int busca_binaria(int arr[], int n, int target) {
    int lo = 0;
    int hi = n - 1;
    while (lo <= hi) {
        int mid = (lo + hi) / 2;
        if (arr[mid] == target) {
            return mid;
        } else if (arr[mid] < target) {
            lo = mid + 1;
        } else {
            hi = mid - 1;
        }
    }
    return -1;
}

void preencher_array(int arr[], int n, int valor) {
    int i;
    for (i = 0; i < n; i++) {
        arr[i] = valor;
    }
}

void copiar_array(int dest[], int src[], int n) {
    int i;
    for (i = 0; i < n; i++) {
        dest[i] = src[i];
    }
}

/* ---------- Structs como argumentos ---------- */

/*struct Ponto criar_ponto(int x, int y) {
    struct Ponto p;
    p.x = x;
    p.y = y;
    return p;
}*/

int distancia_quadrada(struct Ponto a, struct Ponto b) {
    int dx = a.x - b.x;
    int dy = a.y - b.y;
    return dx * dx + dy * dy;
}

void mover_ponto(struct Ponto* p, int dx, int dy) {
    p->x = p->x + dx;
    p->y = p->y + dy;
}

int area_retangulo(struct Retangulo r) {
    return r.largura * r.altura;
}

/* ---------- Expressões complexas ---------- */

int expressoes(int a, int b, int c) {
    int r1 = a + b * c;
    int r2 = (a + b) * c;
    int r3 = a - b + c;
    int r4 = a * b / c;
    int r5 = a % b + c;
    int r6 = a + b + c + r1 + r2;
    return r6;
}

int operadores_logicos(int a, int b, int c) {
    int r1 = a && b;
    int r2 = a || b;
    int r3 = !a;
    int r4 = a && b || c;
    int r5 = a && (b || c);
    int r6 = !a && !b;
    return r1 + r2 + r3 + r4 + r5 + r6;
}

int operadores_bitwise(int a, int b) {
    int r1 = a & b;
    int r2 = a | b;
    int r3 = a ^ b;
    int r4 = ~a;
    int r5 = a << 2;
    int r6 = b >> 1;
    int r7 = a & b | r5 ^ r6;
    return r7;
}

int comparacoes(int a, int b) {
    int r1 = a == b;
    int r2 = a != b;
    int r3 = a < b;
    int r4 = a > b;
    int r5 = a <= b;
    int r6 = a >= b;
    return r1 + r2 + r3 + r4 + r5 + r6;
}

/* ---------- Compound assignments ---------- */

void compound_assigns(int* x) {
    *x += 5;
    *x -= 3;
    *x *= 2;
    *x /= 4;
    *x %= 7;
    *x &= 0xFF;
    *x |= 0x01;
    *x ^= 0x10;
    *x <<= 1;
    *x >>= 1;
}

/* ---------- Incremento / Decremento ---------- */

int inc_dec(int a) {
    int b = a;
    b++;
    b--;
    ++b;
    --b;
    int c = b++;
    int d = ++b;
    int e = b-- + --d;
    return e;
}

/* ---------- Controlo de fluxo ---------- */

int if_else_chain(int x) {
    if (x < 0) {
        return -1;
    } else if (x == 0) {
        return 0;
    } else if (x < 10) {
        return 1;
    } else if (x < 100) {
        return 2;
    } else {
        return 3;
    }
}

int switch_completo(int op, int a, int b) {
    int resultado;
    switch (op) {
        case 0:
            resultado = a + b;
            break;
        case 1:
            resultado = a - b;
            break;
        case 2:
            resultado = a * b;
            break;
        case 3:
            if (b != 0) {
                resultado = a / b;
            } else {
                resultado = -1;
            }
            break;
        default:
            resultado = 0;
            break;
    }
    return resultado;
}

int loops_while(int n) {
    int soma = 0;
    int i = 0;
    while (i < n) {
        soma = soma + i;
        i++;
    }
    return soma;
}

int loop_do_while(int n) {
    int soma = 0;
    int i = 0;
    do {
        soma = soma + i;
        i++;
    } while (i < n);
    return soma;
}

int loop_for_basico(int n) {
    int soma = 0;
    int i;
    for (i = 0; i < n; i++) {
        soma = soma + i;
    }
    return soma;
}

int loop_for_decl(int n) {
    int soma = 0;
    for (int i = 0; i < n; i++) {
        soma = soma + i;
    }
    return soma;
}

int loop_for_compound(int n) {
    int soma = 0;
    for (int i = 0; i < n; i += 2) {
        soma = soma + i;
    }
    return soma;
}

int loop_break_continue(int n) {
    int soma = 0;
    for (int i = 0; i < n; i++) {
        if (i % 2 == 0) {
            continue;
        }
        if (i > 10) {
            break;
        }
        soma = soma + i;
    }
    return soma;
}

int loops_aninhados(int n) {
    int soma = 0;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            soma = soma + i * j;
        }
    }
    return soma;
}

/* ---------- Ternário ---------- */

int ternario(int a, int b) {
    int max = a > b ? a : b;
    int min = a < b ? a : b;
    int abs_val = a >= 0 ? a : -a;
    int nested = a > 0 ? (b > 0 ? 1 : 2) : (b > 0 ? 3 : 4);
    return max + min + abs_val + nested;
}

/* ---------- Type cast e sizeof ---------- */

int casts_e_sizeof() {
    int a = 10;
    float b = (float) a;
    int c = (int) b;
    int s1 = sizeof(int);
    int s2 = sizeof(float);
    int s3 = sizeof(a);
    int s4 = sizeof(struct Ponto);
    return s1 + s2 + s3 + s4;
}

/* ---------- Referências e ponteiros avançados ---------- */

void ponteiros_avancados() {
    int x = 5;
    int* p = &x;
    int** pp = &p;
    *p = 10;
    **pp = 20;
    int arr[5];
    int* pa = &arr[0];
    *pa = 1;
    *(pa + 1) = 2;
}

/* ---------- Arrow operator ---------- */

void arrow_operator(struct Ponto* p) {
    p->x = 10;
    p->y = 20;
    int soma = p->x + p->y;
    p->x += 1;
    p->y -= 1;
}

void lista_ligada(struct Lista* no) {
    no->valor = 42;
    no->proximo = no;
    int v = no->proximo->valor;
}

/* ---------- Função com vários tipos de retorno ---------- */

void funcao_void(int x) {
    int y = x + 1;
    return;
}

int funcao_return_exp(int a, int b, int c) {
    return a * b + c - 1;
}

/* ---------- Declarações múltiplas ---------- */

int declaracoes_multiplas() {
    int a, b, c;
    int x = 1, y = 2;
    float f1, f2;
    int arr1[5], arr2[10];
    a = 1;
    b = 2;
    c = a + b;
    return c;
}

/* ---------- Qualificadores de tipo ---------- */

void qualificadores() {
    const int k = 42;
    volatile int v = 0;
    unsigned int u = 100;
    signed int s = -50;
    static int st = 0;
    st = st + 1;
    u = u + 1;
    v = v + 1;
}

/* ---------- Funções inline/static/extern ---------- */

static int funcao_static(int x) {
    return x * 2;
}

inline int funcao_inline(int x) {
    return x + 1;
}

/* ---------- main ---------- */

int main() {
    int a = 10;
    int b = 3;

    int s = soma(a, b);
    int d = subtracao(a, b);
    int m = multiplicacao(a, b);
    int dv = divisao(a, b);
    int mod = modulo(a, b);

    trocar(&a, &b);

    int arr[10];
    preencher_array(arr, 10, 0);
    arr[0] = 1;
    arr[1] = 5;
    arr[2] = 3;
    arr[9] = 42;

    int idx = busca_binaria(arr, 10, 5);

    /*struct Ponto p1;
    p1.x = 3;
    p1.y = 4;*/

    //struct Ponto p2 = criar_ponto(6, 8);
    int dist = distancia_quadrada(p1, p2);
    mover_ponto(&p1, 1, -1);

    struct Retangulo r;
    r.largura = 10;
    r.altura = 5;
    int area = area_retangulo(r);

    union Dados dado;
    dado.i = 42;
    dado.f = 3;

    enum Cor cor = VERDE;
    enum Estado estado = ATIVO;

    int expr = expressoes(a, b, 2);
    int logico = operadores_logicos(1, 0, 1);
    int bitwise = operadores_bitwise(a, b);
    int comp = comparacoes(a, b);

    int tern = ternario(a, b);
    int tamanhos = casts_e_sizeof();

    int soma_while = loops_while(10);
    int soma_do = loop_do_while(10);
    int soma_for = loop_for_basico(10);
    int soma_for2 = loop_for_decl(10);
    int soma_for3 = loop_for_compound(10);
    int soma_break = loop_break_continue(20);
    int soma_nest = loops_aninhados(5);

    int cat = if_else_chain(50);
    int sw = switch_completo(0, a, b);

    int ic = inc_dec(5);

    int decl = declaracoes_multiplas();

    return soma_while + soma_for + cat + sw + dist + area + ic + decl;
}
