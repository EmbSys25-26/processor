/* feat_array_write_read — fill an array with squares, read back one.
   a[i] = i*i for i in 0..7. Returns a[6] = 36 = 0x24. */
int main(void) {
    int a[8];
    for (int i = 0; i < 8; i = i + 1) a[i] = i * i;
    return a[6];
}
