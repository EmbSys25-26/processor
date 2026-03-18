struct Point {
    int x;
};

int main(void)
{
    struct Point p;

    if (p) {
        return 1;
    }

    return 0;
}