// Sum of multiples of 3 from 1..20.  Tests runtime __mods (modulo),
// while-loop, conditional accumulation.
// Expected: 3+6+9+12+15+18 = 63 = 0x003F
int main(void) {
    int sum;
    int i;
    sum = 0;
    i = 1;
    while (i <= 20) {
        if (i % 3 == 0) {
            sum = sum + i;
        }
        i = i + 1;
    }
    return sum;
}
