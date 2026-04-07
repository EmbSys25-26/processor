int x;
int y;

int arithmetic(int a, int b) {
    int r;
    r = a + b;
    r = a - b;
    r = a * b;
    r = a / b;
    r = a % b;
    r = r + 1;
    r = r - 1;
    r = r * 2;
    r = r / 2;
    r = r % 3;
    return r;
}

int assignment(int a) {
    int r;
    r = a;
    r = r + 1;
    r += 10;
    r -= 5;
    r *= 2;
    r /= 3;
    r %= 7;
    return r;
}

int bitwise(int a, int b) {
    int r;
    r = a & b;
    r = a | b;
    r = a ^ b;
    r = ~a;
    r = a << 2;
    r = a >> 1;
    r &= 255;
    r |= 1;
    r ^= 16;
    r <<= 1;
    r >>= 1;
    return r;
}

int unary(int a) {
    int r;
    r = -a;
    r = a;
    r++;
    r--;
    ++r;
    --r;
    return r;
}

int main(void) {
    int a;
    int b;
    int r;
    a = 10;
    b = 3;
    r = arithmetic(a, b);
    r = assignment(a);
    r = bitwise(a, b);
    r = unary(a);
    x = a + b;
    y = x * 2;
    return r;
}
