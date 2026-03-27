struct S;

void trigger(void)
{
  int x = 0;
  (struct S)x;
}

int main(void)
{
  trigger();
  return 0;
}
