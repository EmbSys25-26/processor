int main() {
    int my_int = 42;
    int *my_ptr;
    
    my_ptr = my_int; /* Expect: SEM012 */
    
    return 0;
}