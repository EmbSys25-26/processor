int add(int a, int b) {
    return a + b;
}

int main(void) {
    int (*func_ptr)(int, int) = add; // Function pointer to 'add'
    return func_ptr(1, 2); // Should reject this usage as function pointers are not supported in this context
}