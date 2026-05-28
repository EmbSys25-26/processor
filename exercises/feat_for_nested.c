/* feat_for_nested — nested for-loops.
   Sum (i+j) for i in 0..2, j in 0..2:
   each outer pass contributes 3*i + (0+1+2) = 3*i + 3.
   Total = 3 + 6 + 9 = 18 = 0x12. */
int main(void) {
    int s = 0;
    for (int i = 0; i < 3; i = i + 1) {
        for (int j = 0; j < 3; j = j + 1) {
            s = s + i + j;
        }
    }
    return s;
}
