int main(void) {
    int r = 0;
    int a = 2;
    int b = 3;
    switch (a) {
        case 1:
            r = 100;
            break;
        case 2:
            switch (b) {
                case 1: r = 21; break;
                case 2: r = 22; break;
                case 3: r = 23; break;
                default: r = 29; break;
            }
            break;
        case 3:
            r = 300;
            break;
        default:
            r = 999;
            break;
    }
    return r;
}
