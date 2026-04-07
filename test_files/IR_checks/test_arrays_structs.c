int arr_sum(int n) {
    int arr[5];
    int s;
    int i;
    arr[0] = 10;
    arr[1] = 20;
    arr[2] = 30;
    arr[3] = 40;
    arr[4] = 50;
    s = 0;
    for (i = 0; i < n; i++) {
        s = s + arr[i];
    }
    return s;
}

int arr_access(void) {
    int arr[3];
    int r;
    arr[0] = 1;
    arr[1] = 2;
    arr[2] = 3;
    r = arr[0] + arr[1] + arr[2];
    return r;
}

void swap(int *a, int *b) {
    int t;
    t = *a;
    *a = *b;
    *b = t;
    return;
}

int deref(int *p) {
    return *p;
}

void increment(int *p) {
    *p = *p + 1;
    return;
}

int double_deref(int *p) {
    int r;
    r = *p * 2;
    return r;
}

int main(void) {
    int r;
    int a;
    int b;

    r = arr_sum(5);
    r = arr_access();

    a = 5;
    b = 10;
    swap(&a, &b);
    r = deref(&a);
    increment(&b);
    r = deref(&b);
    r = double_deref(&a);

    return r;
}
