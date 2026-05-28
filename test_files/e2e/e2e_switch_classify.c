// switch-case with default fall-through-less paths.  Tests the
// switch-lowering and function-call return value addition.
// Expected: 100 + 200 + 300 + 999 = 1599 = 0x063F
int classify(int x) {
    int r;
    switch (x) {
        case 0:  r = 100; break;
        case 1:  r = 200; break;
        case 2:  r = 300; break;
        default: r = 999; break;
    }
    return r;
}

int main(void) {
    int s;
    s = classify(0);
    s = s + classify(1);
    s = s + classify(2);
    s = s + classify(5);
    return s;
}
