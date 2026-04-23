int main() {
    int a = 7;
    int b = a; /* must generate IR_OP_COPY */
    int c = b + 1;
    return c;
}
