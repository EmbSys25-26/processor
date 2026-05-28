/* feat_div_signed — signed division (lowered to __divs helper).
   100 / 7 = 14 = 0x0E. */
int main(void) {
    int a = 100;
    int b = 7;
    return a / b;
}
