// Maximum element in array.  Tests array load + comparison + update in
// a single loop with leaf main.
//
// Input array: { 3, 1, 9, 7, 2, 8, 5, 4 }
// Expected:   max = 9 = 0x0009

int main(void) {
    int arr[8];
    int max;
    int i;
    arr[0] = 3; arr[1] = 1; arr[2] = 9; arr[3] = 7;
    arr[4] = 2; arr[5] = 8; arr[6] = 5; arr[7] = 4;
    max = arr[0];
    i = 1;
    while (i < 8) {
        if (arr[i] > max) {
            max = arr[i];
        }
        i = i + 1;
    }
    return max;
}
