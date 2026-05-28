// Array load/store + min/max in one pass.  Tests stack-allocated
// array indexing, comparison-and-update pattern.
// Expected: max=9, min=1, max-min = 8 = 0x0008
int main(void) {
    int arr[6];
    int max;
    int min;
    int i;
    arr[0] = 7;
    arr[1] = 3;
    arr[2] = 9;
    arr[3] = 1;
    arr[4] = 5;
    arr[5] = 8;
    max = arr[0];
    min = arr[0];
    i = 1;
    while (i < 6) {
        if (arr[i] > max) {
            max = arr[i];
        }
        if (arr[i] < min) {
            min = arr[i];
        }
        i = i + 1;
    }
    return max - min;
}
