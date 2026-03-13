struct Inner { int b; };
struct Mid { struct Inner a; };
struct Outer { struct Mid *x; int c[4]; };

int sum(int lhs, int rhs);

int foo(int a, int b, int c, int d, int x, int y, int i, struct Outer *p)
{
    x = y = 0;
    x = 1, y = 2;
    a << b + c;
    a & b == c;
    ~a * b;
    sizeof x;
    p->x->a.b;
    p->c[i];
    sum(a = b, c);
    a ? b : c + d;
    return x;
}
