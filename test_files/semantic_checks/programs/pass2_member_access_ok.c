struct Point {
  int x;
  int y;
};

int main(void) {
  struct Point p;
  struct Point *pp;

  p.x = 1;
  pp->y = 2;
  return p.x + pp->y;
}
