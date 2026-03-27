int main() {
  float x = 3.14;        // produces SEMW001 due to infering 3.14 as double 
  float y = (float)3.14; // no warning 
  // float z = 3.14f;    // parse error
  return 0; 
}