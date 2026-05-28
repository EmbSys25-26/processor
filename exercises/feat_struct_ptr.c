struct Pt { int x; int y; };

void bump(struct Pt *p) {
    p->x = 11;
    p->y = 22;
}

int main(void) {
    struct Pt s;
    s.x = 0;
    s.y = 0;
    bump(&s);
    return s.x + s.y;
}
