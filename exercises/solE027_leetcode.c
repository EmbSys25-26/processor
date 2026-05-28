// LeetCode 169 — Majority Element (Boyer-Moore majority vote).
// One-pass with O(1) extra space.
//
// Input: arr = {3, 2, 3, 3, 2, 3, 3} (3 appears 5/7 times)
// Expected: 3 = 0x0003

int main(void) {
    int arr[7];
    int candidate;
    int count;
    int i;
    arr[0]=3; arr[1]=2; arr[2]=3; arr[3]=3;
    arr[4]=2; arr[5]=3; arr[6]=3;
    candidate = 0;
    count = 0;
    i = 0;
    while (i < 7) {
        if (count == 0) {
            candidate = arr[i];
        }
        if (arr[i] == candidate) {
            count = count + 1;
        } else {
            count = count - 1;
        }
        i = i + 1;
    }
    return candidate;
}
