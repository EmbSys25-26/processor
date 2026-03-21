struct TypeA { int a; };
struct TypeB { int b; };

int main() {
    struct TypeA a;
    struct TypeB b;
    
    a = b; /* Expect: SEM014 */
    
    return 0;
}