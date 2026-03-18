int main(void)
{
  long large;
  double precise;
  float narrowed;
  int truncated;

  large = 100000000;
  precise = 3.14;

  truncated = precise;
  narrowed = precise;
  truncated = large;
  truncated = (int)precise;

  return 0;
}
