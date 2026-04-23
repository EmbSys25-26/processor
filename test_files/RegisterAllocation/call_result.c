int helper(int x);

int calls_f() {
    int a = 1;
    int b = helper(a);
    return b;
}
