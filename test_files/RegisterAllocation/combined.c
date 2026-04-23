int transform(int x);

int combined(int a, int b) {
    int c = transform(a); /* c to r1, a to r1 (argument) */
    int d = c + b;
    return d;             /* d to r1 */
}
