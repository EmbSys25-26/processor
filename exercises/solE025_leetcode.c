// In-place array reversal.  Tests two-pointer pattern with swap-via-temp.
//
// Input: {1, 2, 3, 4, 5}
// After reversal: {5, 4, 3, 2, 1}
// Returns arr[0]*100 + arr[4] = 5*100 + 1 = 501 = 0x01F5

int main(void) {
    int arr[5];
    int i;
    int j;
    int t;
    arr[0]=1; arr[1]=2; arr[2]=3; arr[3]=4; arr[4]=5;
    i = 0;
    j = 4;
    while (i < j) {
        t = arr[i];
        arr[i] = arr[j];
        arr[j] = t;
        i = i + 1;
        j = j - 1;
    }
    return arr[0] * 100 + arr[4];
}
