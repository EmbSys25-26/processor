int main(void) {
    int arr[3] = {1, 2, 3}; // Should reject this usage as aggregate initialization is not supported in this context
    return arr[0]; 
}