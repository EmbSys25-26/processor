int main() { 
  int x = 0;
  int y = 0;  

  struct _ {
    int x;
    int y; 
  } p; 


  p.x = x; 
  p.y = y; 

  return p.x * p.x + p.y * p.y; 
}