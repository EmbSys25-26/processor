struct MyStruct { int x; };

int main() {
    struct MyStruct s;
    int my_int = 10;
    int result;
    
    result = my_int[2];  /* Expect: SEM032 */
    
    return 0;
}