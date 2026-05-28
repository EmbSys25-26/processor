// Codeforces 4A — Watermelon
// https://codeforces.com/problemset/problem/4/A
//
// Pete and Billy bought a watermelon weighing w kilos and want to split it
// into two parts such that BOTH parts weigh an EVEN, POSITIVE number of
// kilos.  Return 1 for YES, 0 for NO.
//
// Possible iff w > 2 and w is even (then w = 2 + (w-2), both even and > 0).
//
// Test inputs (composed into one return value via bit-shifts):
//   w = 8   -> YES (1)
//   w = 2   -> NO  (0)  (split would have a zero part)
//   w = 7   -> NO  (0)  (odd)
//   w = 4   -> YES (1)
//   w = 100 -> YES (1)
//
// Encoded result: (yes(8) << 4) | (yes(2) << 3) | (yes(7) << 2)
//               | (yes(4) << 1) |  yes(100)
//               = (1<<4) | (0<<3) | (0<<2) | (1<<1) | 1
//               = 16 + 2 + 1 = 19 = 0x0013

int can_split(int w) {
    if (w > 2) {
        if ((w % 2) == 0) {
            return 1;
        }
    }
    return 0;
}

int main(void) {
    int r;
    r = (can_split(8)   << 4)
      | (can_split(2)   << 3)
      | (can_split(7)   << 2)
      | (can_split(4)   << 1)
      |  can_split(100);
    return r;
}
