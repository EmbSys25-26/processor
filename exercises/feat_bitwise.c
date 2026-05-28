/* feat_bitwise — AND, OR, XOR, NOT combined.
   a = 0xF0F0, b = 0xAAAA.
     a & b = 0xA0A0
     a | b = 0xFAFA
     a ^ b = 0x5A5A
     ~a    = 0x0F0F
   Combine: ((a&b) ^ (a|b)) + ((a^b) & ~a) wraps 16-bit:
     (0xA0A0 ^ 0xFAFA) = 0x5A5A
     (0x5A5A & 0x0F0F) = 0x0A0A
     0x5A5A + 0x0A0A   = 0x6464   (no overflow)
   Expect 0x6464. */
int main(void) {
    int a = 0xF0F0;
    int b = 0xAAAA;
    return ((a & b) ^ (a | b)) + ((a ^ b) & ~a);
}
