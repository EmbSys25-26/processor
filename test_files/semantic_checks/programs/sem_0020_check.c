struct MyStruct { int x; };

int main() {
    struct MyStruct s;
    int result;
    
    result = s + 10; /* Expect: SEM020 */
    return 0;
}