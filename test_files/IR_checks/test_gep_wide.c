/* Each row of `matrix` is 7 i16 elements = 14 bytes, exceeding the
 * width-1/2/4 fast paths in IR_OP_GEP and falling through to the __mul
 * helper.  __mul clobbers caller-saved registers including the one that
 * holds the base pointer, so the post-call ADD reads garbage. */
int matrix[5][7];

int main() {
    return matrix[3][2];
}
