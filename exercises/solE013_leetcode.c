// Bubble sort an array in place; return arr[0]*10 + arr[n-1] (so min*10+max).
// Tests nested loops, swap via temp, in-place updates.
//
// Input: {5, 2, 8, 1, 4}.  Sorted: {1, 2, 4, 5, 8}.
// Expected: 1*10 + 8 = 18 = 0x0012

int main(void) {
    int arr[5];
    int i;
    int j;
    int t;
    arr[0]=5; arr[1]=2; arr[2]=8; arr[3]=1; arr[4]=4;
    i = 0;
    while (i < 5) {
        j = 0;
        while (j < 4 - i) {
            if (arr[j] > arr[j+1]) {
                t = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = t;
            }
            j = j + 1;
        }
        i = i + 1;
    }
    return arr[0] * 10 + arr[4];
}
