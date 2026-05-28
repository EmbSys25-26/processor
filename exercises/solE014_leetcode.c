// LeetCode 1 — Two Sum (O(n^2) version).  Return i*10 + j for the first
// pair (i < j) with arr[i] + arr[j] == target.
//
// Input: arr = {2, 7, 11, 15, 3, 6}, target = 9
//   pair (0, 1): 2+7 = 9 ✓
// Expected: 0*10 + 1 = 1 = 0x0001

int main(void) {
    int arr[6];
    int target;
    int i;
    int j;
    arr[0]=2; arr[1]=7; arr[2]=11; arr[3]=15; arr[4]=3; arr[5]=6;
    target = 9;
    i = 0;
    while (i < 6) {
        j = i + 1;
        while (j < 6) {
            if (arr[i] + arr[j] == target) {
                return i * 10 + j;
            }
            j = j + 1;
        }
        i = i + 1;
    }
    return -1;
}
