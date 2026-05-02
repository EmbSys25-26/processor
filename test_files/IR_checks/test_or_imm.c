int a;
int main() {
    /* Forces OR with imm as src[1].  If the result vreg lands in t0,
     * the dst==t0 special path collides with our t3-materialised imm. */
    return a | 0xFF;
}
