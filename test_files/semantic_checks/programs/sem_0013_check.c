int main() {
    int *int_ptr;
    float *float_ptr;
    
    int_ptr = float_ptr; /* Expect: SEM013 */
    
    return 0;
}