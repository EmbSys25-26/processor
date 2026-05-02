struct point {
    int x;
    int y;
};

struct point p;

int main() {
    p.x = 5;
    p.y = 7;
    return p.x + p.y;
}
