int main(void) {
    int log[1];
    log[0] = 0;
    int a = 0;
    /* If short-circuit AND works, the second operand is never evaluated
       because a != 1. So log[0] stays 0. Otherwise, log[0] becomes 1. */
    if ((a == 1) && ((log[0] = 1), 1)) {
        log[0] = 9;
    }
    return log[0];
}
