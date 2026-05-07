struct Point {
    int x;
    int y;
};

int main(void) {
    struct Point p1;
    struct Point p2;
    p1.x = 1;
    p1.y = 2;
    p2 = p1; // Should reject this usage as struct copying is not supported in this context
    return 0;
}