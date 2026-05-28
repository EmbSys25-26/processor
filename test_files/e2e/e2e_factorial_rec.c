// Recursive factorial. Tests CALL/JAL link, frame management,
// caller-saved restore, multiplication via runtime __mul.
// Expected: fact(6) = 720 = 0x02D0
int fact(int n) {
    if (n <= 1) {
        return 1;
    }
    return n * fact(n - 1);
}

int main(void) {
    return fact(6);
}
