// Codeforces 1A — Theatre Square
// https://codeforces.com/problemset/problem/1/A
//
// Theatre Square is rectangular n x m metres.  Flagstones are a x a metres
// and may not be broken.  What is the LEAST number of flagstones to cover
// the whole square (covering more than the square is OK, but flagstones
// must align with the square's sides)?
//
// Answer = ceil(n / a) * ceil(m / a), computed without floats as
//          ((n + a - 1) / a) * ((m + a - 1) / a).
//
// Test input: n = 6, m = 6, a = 4
//   ceil(6/4) = 2 ; answer = 2 * 2 = 4 = 0x0004
//
// Uses runtime __divs (signed division) and __mul (multiplication).

int ceil_div(int n, int a) {
    return (n + a - 1) / a;
}

int tiles(int n, int m, int a) {
    return ceil_div(n, a) * ceil_div(m, a);
}

int main(void) {
    return tiles(6, 6, 4);
}
