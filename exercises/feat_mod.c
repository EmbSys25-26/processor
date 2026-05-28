/* feat_mod — signed modulo (lowered to __mods helper).
   100 % 7 = 2 = 0x02. */
int main(void) {
    int a = 100;
    int b = 7;
    return a % b;
}
