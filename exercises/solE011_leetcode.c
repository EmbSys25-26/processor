// Linear search — return index of target, or -1 if not found.
//
// Input: arr = {10,20,30,40,50,60}, target = 40
// Expected: index 3 = 0x0003

int main(void) {
    int arr[6];
    int target;
    int i;
    arr[0]=10; arr[1]=20; arr[2]=30; arr[3]=40; arr[4]=50; arr[5]=60;
    target = 40;
    i = 0;
    while (i < 6) {
        if (arr[i] == target) {
            return i;
        }
        i = i + 1;
    }
    return -1;
}
