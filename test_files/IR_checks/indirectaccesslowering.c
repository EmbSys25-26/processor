int main(void) {
    int arr[3];
    int v;
    int a;
    int *p;
    int b;

    arr[0] = 10;
    arr[1] = 20;
    arr[2] = 30;
    v = arr[1];

    a = 5;
    p = &a;
    b = *p;
    *p = 99;

    return v;
}
