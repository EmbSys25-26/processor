struct Pt { int x; int y; };

int main(void) {
    struct Pt p;
    p.x = 3;
    p.y = 4;
    return p.x + p.y;
}
