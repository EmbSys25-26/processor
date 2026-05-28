// Count distinct values in an array using O(n^2) nested-loop search.
//
// Input: arr = {1, 2, 2, 3, 1, 4, 3}
// Expected: distinct {1, 2, 3, 4} -> 4 = 0x0004

int main(void) {
    int arr[7];
    int distinct;
    int seen;
    int i;
    int j;
    arr[0]=1; arr[1]=2; arr[2]=2; arr[3]=3;
    arr[4]=1; arr[5]=4; arr[6]=3;
    distinct = 0;
    i = 0;
    while (i < 7) {
        seen = 0;
        j = 0;
        while (j < i) {
            if (arr[j] == arr[i]) {
                seen = 1;
            }
            j = j + 1;
        }
        if (seen == 0) {
            distinct = distinct + 1;
        }
        i = i + 1;
    }
    return distinct;
}
