// Codeforces 791A — Bear and Big Brother
// https://codeforces.com/problemset/problem/791/A
//
// Limak's weight triples each year, Bob's doubles.  Count years until
// Limak strictly exceeds Bob.
//
// Test input: a = 4, b = 7
//   year 0: 4, 7  (a<=b)
//   year 1: 12, 14
//   year 2: 36, 28  (a > b, stop)
// Expected: 2 = 0x0002

int years(int a, int b) {
    int y;
    y = 0;
    while (a <= b) {
        a = a * 3;
        b = b * 2;
        y = y + 1;
    }
    return y;
}

int main(void) {
    return years(4, 7);
}
