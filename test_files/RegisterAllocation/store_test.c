int main() {
    int x;
    int *p = &x;
    *p = 99;
    int res = *p;
    return res;
}
