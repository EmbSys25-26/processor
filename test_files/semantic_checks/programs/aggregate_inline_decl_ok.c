struct Point {
    int x;
    int y;
} point;

union Data {
    int i;
    float f;
} data;

enum Color {
    RED,
    GREEN = 5,
    BLUE
} color;

int main(void)
{
    return 0;
}
