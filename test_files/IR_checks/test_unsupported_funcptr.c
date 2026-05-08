int add(int a, int b) {
    return a + b;
}

// int main(void) {
//     int result = (&add)(2, 3);  // Should reject this usage as function pointer calls are not supported in this context
//     return 0;
// }

int main(void) {
    int (*func_ptr)(int, int) = &add; // Should reject this usage as function pointers are not supported in this context
    int result = func_ptr(2, 3);       // Should reject this usage as function pointer calls are not supported in this context
    return 0;
}
