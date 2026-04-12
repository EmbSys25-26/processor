int classify(int x) {
    if (x < 0) {
        return -1;
    }
    if (x == 0) {
        return 0;
    }
    return 1;
}

int max(int a, int b) {
    int r;
    if (a > b) {
        r = a;
    } else {
        r = b;
    }
    return r;
}

int sum_while(int n) {
    int s;
    s = 0;
    while (n > 0) {
        s = s + n;
        n = n - 1;
    }
    return s;
}

int sum_do_while(int n) {
    int s;
    s = 0;
    do {
        s = s + n;
        n = n - 1;
    } while (n > 0);
    return s;
}

int sum_for(int n) {
    int s;
    int i;
    s = 0;
    for (i = 0; i < n; i++) {
        s = s + i;
    }
    return s;
}

int loop_break(int n) {
    int s;
    int i;
    s = 0;
    for (i = 0; i < n; i++) {
        if (i > 5) {
            break;
        }
        s = s + i;
    }
    return s;
}

int loop_continue(int n) {
    int s;
    int i;
    s = 0;
    for (i = 0; i < n; i++) {
        if (i % 2 == 0) {
            continue;
        }
        s = s + i;
    }
    return s;
}


int switch_case(int x) {
    int r;
    switch (x) {
        case 1:
            r = 10;
            break;
        case 2:
            r = 20;
            break;
        default:
            r = 0;
    }
    return r;
}


int main(void) {
    int r;
    r = classify(-5);
    r = classify(0);
    r = classify(3);
    r = max(10, 3);
    r = sum_while(5);
    r = sum_do_while(5);
    r = sum_for(10);
    r = loop_break(10);
    r = loop_continue(10);
    r = switch_case(1);
    r = switch_case(2);
    r = switch_case(3);
    return r;
}
