// LeetCode 70 — Climbing Stairs
// https://leetcode.com/problems/climbing-stairs/
//
// n stairs, each move is 1 or 2 steps.  How many distinct ways to reach
// the top?  Classic Fibonacci recurrence:  f(n) = f(n-1) + f(n-2),
// f(1) = 1, f(2) = 2.
//
// Iterative bottom-up O(n) version (no recursion -> no runtime calls).
//
// Test input: n = 10  ->  89 = 0x0059

int climb(int n) {
    int a;
    int b;
    int t;
    int i;
    if (n <= 2) {
        return n;
    }
    a = 1;
    b = 2;
    i = 3;
    while (i <= n) {
        t = a + b;
        a = b;
        b = t;
        i = i + 1;
    }
    return b;
}

int main(void) {
    return climb(10);
}
