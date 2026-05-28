// LeetCode 204 — Count Primes up to N (inclusive trial-division).
//
// Input: N = 20.  Primes <= 20: 2, 3, 5, 7, 11, 13, 17, 19
// Expected: 8 = 0x0008

int is_prime(int n) {
    int i;
    if (n < 2) {
        return 0;
    }
    if (n == 2) {
        return 1;
    }
    if (n % 2 == 0) {
        return 0;
    }
    i = 3;
    while (i * i <= n) {
        if (n % i == 0) {
            return 0;
        }
        i = i + 2;
    }
    return 1;
}

int count_primes(int n) {
    int c;
    int i;
    c = 0;
    i = 2;
    while (i <= n) {
        if (is_prime(i)) {
            c = c + 1;
        }
        i = i + 1;
    }
    return c;
}

int main(void) {
    return count_primes(20);
}
