int main(void) {
    int log[1];
    log[0] = 0;
    int a = 1;
    /* If short-circuit OR works, the second operand is never evaluated
       because a == 1 makes (a == 1) true. log[0] stays 0. */
    if ((a == 1) || ((log[0] = 1), 1)) {
        /* taken */
    }
    return log[0];
}
