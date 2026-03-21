int main() {
    int my_array[5];
    float my_float = 1.5;
    int result;
    
    result = my_array[my_float]; /* Expect: SEM031 */
    
    return 0;
}