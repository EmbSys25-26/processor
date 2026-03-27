enum vida {
  VIDA_BOA,
  VIDA_MA,
}; 

void foo(void) {
  int op; 
  char c; 

  switch (op) {
    case 1: 
      c = 'a';
      break; 

    case 2: 
      c = 'b';
      break; 

    case 3: 
      c = 'c';
      break; 

    case 3: 
      c = '3';
      break; 

    case 'a': 
      c = '1'; 
      break;

    case VIDA_BOA: 
      c = 'x'; 
      break; 
    
    case VIDA_BOA: 
      c = 'o';
      break; 

    default: 
      break; 
  }

  return; 
}