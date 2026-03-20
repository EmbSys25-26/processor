struct Ponto
{
  int x;
  int y;
};


int main(void) {
  struct Ponto p;   
  int limit = 1;
  int a = 10;

    a=limit? 50 : p; // 'p' is a struct, incompatible with int
  
  return 0;
}
