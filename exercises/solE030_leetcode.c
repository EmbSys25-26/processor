// LeetCode 53 — Maximum Subarray (Kadane's algorithm).  Tests handling
// of negative inputs and signed comparisons.
//
// Input: arr = {-2, 1, -3, 4, -1, 2}
//   running max ends at index 5: 4 + (-1) + 2 = 5
// Expected: 5 = 0x0005

int main(void) {
    int arr[6];
    int max_so_far;
    int max_ending;
    int i;
    arr[0]=-2; arr[1]=1; arr[2]=-3; arr[3]=4; arr[4]=-1; arr[5]=2;
    max_so_far = arr[0];
    max_ending = arr[0];
    i = 1;
    while (i < 6) {
        if (max_ending + arr[i] > arr[i]) {
            max_ending = max_ending + arr[i];
        } else {
            max_ending = arr[i];
        }
        if (max_ending > max_so_far) {
            max_so_far = max_ending;
        }
        i = i + 1;
    }
    return max_so_far;
}
