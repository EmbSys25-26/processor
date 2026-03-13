struct P { int x; };

int main(void) {
  struct P { int y; } p;
  return p.y;
}
