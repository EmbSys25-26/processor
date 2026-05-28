// Count occurrences of target in array.
//
// Input: arr = {1, 2, 2, 3, 2, 4, 2, 5}, target = 2
// Expected: 4 occurrences = 0x0004

int main(void) {
    int arr[8];
    int target;
    int count;
    int i;
    arr[0]=1; arr[1]=2; arr[2]=2; arr[3]=3;
    arr[4]=2; arr[5]=4; arr[6]=2; arr[7]=5;
    target = 2;
    count = 0;
    i = 0;
    while (i < 8) {
        if (arr[i] == target) {
            count = count + 1;
        }
        i = i + 1;
    }
    return count;
}
