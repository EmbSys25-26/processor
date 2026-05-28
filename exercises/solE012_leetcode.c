// LeetCode 704 — Binary Search.  Tests integer division by 2 and
// loop termination with both ascending and descending pointer moves.
//
// Input: sorted arr {1,3,5,7,9,11,13,15}, target = 11
// Expected: index 5 = 0x0005

int main(void) {
    int arr[8];
    int target;
    int lo;
    int hi;
    int mid;
    arr[0]=1;  arr[1]=3;  arr[2]=5;  arr[3]=7;
    arr[4]=9;  arr[5]=11; arr[6]=13; arr[7]=15;
    target = 11;
    lo = 0;
    hi = 7;
    while (lo <= hi) {
        mid = (lo + hi) / 2;
        if (arr[mid] == target) {
            return mid;
        }
        if (arr[mid] < target) {
            lo = mid + 1;
        } else {
            hi = mid - 1;
        }
    }
    return -1;
}
