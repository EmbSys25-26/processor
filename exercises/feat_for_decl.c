/* feat_for_decl — for-loop with declaration in the init slot.
   Regression for the IR-lowering bug where `for (int i = ...)`
   silently dropped the body. Expect 1+2+...+10 = 55 = 0x37. */
int main(void) {
    int s = 0;
    for (int i = 1; i <= 10; i = i + 1) s = s + i;
    return s;
}
