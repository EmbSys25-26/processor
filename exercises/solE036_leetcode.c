// LeetCode 136 — Single Number.  Every element appears twice except one.
// XOR all elements; pairs cancel, the unique element survives.
//
// Input: arr = {4, 1, 2, 1, 2, 4, 3}.  Unique = 3 = 0x0003

int main(void) {
    int arr[7];
    int x;
    int i;
    arr[0]=4; arr[1]=1; arr[2]=2; arr[3]=1;
    arr[4]=2; arr[5]=4; arr[6]=3;
    x = 0;
    i = 0;
    while (i < 7) {
        x = x ^ arr[i];
        i = i + 1;
    }
    return x;
}
