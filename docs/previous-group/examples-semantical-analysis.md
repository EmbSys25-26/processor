**Colocar o máximo de exemplos para poder verificar e ver maneira de tentar resolver (algo assim)**

**Declaração antes de uso e scope  MARCO**

**Compatibilidade de tipos  TIAGO**

**Verificação de Funções RUI**  
A verificação de funções faz parte da análise semântica e utiliza a informação  armazenada na tabela de símbolos.

**– Números de argumentos**  
Comparar o número de argumentos passados na chamada com o ***parameter Number*** guardado na tabela de símbolos.

Quando se encontra uma chamada de função na AST, usa-se `fetchSymbol()` para ir buscar a função à tabela de símbolos e ler quantos parâmetros ela espera (`parameterNumber`). Depois conta-se quantos argumentos foram passados na chamada, percorrendo os siblings dos filhos do nodo. Se os números não coincidirem, emite-se erro.

Exemplos:  
![][image1]  
Ainda existem:  
Função sem parâmetros chamada com argumentos:   
int g();  
g(1);       // ERRO  
Função com parâmetros chamada sem argumentos:  
int h(int x);  
h();        // ERRO  
**– Tipos de argumento**  
Para cada argumento, comparar o tipo inferido da expressão com o tipo do parâmetro correspondente em ***parameters\[i\]***. 

O símbolo da função já está anexado ao nodo da chamada da fase anterior, por isso não é necessário fazer `fetchSymbol()` novamente. Percorre-se cada argumento passado em paralelo com o array `parameters[]` da função, comparando o tipo de cada argumento com o tipo esperado (`parameters[i].varType`). Se um parâmetro for ponteiro, verifica-se também se o argumento é ponteiro do mesmo tipo. Se os tipos não coincidirem, emite-se erro.

Exemplos:  
int f(int a, float b);

f(10, 2.5);    // int, float → Ok  
f(10, 2);    // int, float → Analisar?  
f(2.5, 10);  //ERRO \- Tipo diferente

void g(int\* p);  
int x;  
g(x);        // ERRO \- Apontador esperado

void g(int x);

int\* p;  
g(p);        // ERRO \- Valor normal esperado  
void g(int\* p);

float\* q;  
g(q);       // ERRO \- Apontadores de tipos diferentes

void g(int\* p);

float arr\[10\];  
g(arr);     // ERRO \- Array passado como tipo incompatível

int f();  
void g(int x);

g(f);       // ERRO \- Função apontada como argumento

void g(int\* p);

g(3 \+ 4);   // ERRO \- Expressão incompatível  
**– Tipo de retorno**

Verificar cada instrução return dentro do corpo da função com o tipo de retorno declarado (funcSym-\>type).

Quando se encontra um `return` na AST, usa-se `fetchSymbol()` para ir buscar o símbolo da função onde estamos e anexá-lo ao nodo. Na fase de type checking, compara-se o tipo de retorno declarado da função com o tipo do valor que está a ser retornado. Se forem incompatíveis emite-se erro. Verifica-se também se uma função `void` tenta retornar um valor, ou se uma função não-`void` não tem `return`.

Exemplos:

int f(){

    return 5; 

}              //Ok

int f(){

    return 3.5;   

}              // ERRO \- float → int

int\* f(){

    return 5;  

}            // ERRO \- Retornar valor quando esperado ponteiro

int\* f(){

    float\* p;

    return p;   

}           // ERRO \- Apontadores de tipos diferentes

void f(){

    return 5;  

}              // ERRO \- Retorno em função void com valor

int f(){

    int x \= 5;

}               // ERRO \- Sem return

return 5;      // ERRO \- Return fora de função

int f(){

    return (a \> b);  // ERRO \- Retorno de expressão incompatível

}

**L values e R values  RUI**

Um L-value é uma expressão que representa uma localização persistente em memória (tem endereço).

 Um R-value é um valor temporário sem localização própria. Esta distinção é verificada em vários contextos: atribuição, incremento/decremento, operador & e qualificador const.

O operando esquerdo de qualquer atribuição (=, \+=, \-=, \*=, /=, %=, etc.) deve ser um L-value modificável.  
Exemplos:  
![][image2]

Os operadores \++ e \-- requerem um L-value modificável. A distinção pré/pós altera o tipo da expressão resultante.  
![][image3]

O operando de & deve ser um L-value. Pode ser readonly (pode-se tirar o endereço de uma variável const).

![][image4]

**Pointers     TIAGO**

- Tipo do ponteiro compatível  
- Desreferenciação válida

**Arrays  MARCO**  
 **tamanho, nome do arrays**

**Constantes MARCO**

**Statements (if, switch, while, struct...)  TIAGO**

**Conversões de tipo (cast)   MARIANA**

**Implicit (no cast written) — hard errors:**

Assigning an integer literal (non-zero) to a pointer without a cast. Assigning a pointer to an integer without a cast. Assigning between two incompatible pointer types, such as an int pointer to a float pointer. Assigning a struct or union value to another struct or union of a different type. Assigning a function pointer to a data pointer or vice versa. Assigning an array to a scalar type. Assigning a pointer to a floating point type or vice versa. Passing a pointer where an arithmetic type is expected in a function call without a cast. Passing an arithmetic type where a pointer is expected in a function call without a cast. Passing a struct of type A where a struct of type B is expected. Returning a pointer from a function declared to return an arithmetic type without a cast. Returning an arithmetic type from a function declared to return a pointer without a cast. Returning a struct of one type from a function declared to return a struct of a different type.

**Explicit casts — hard errors:**

Casting a floating point type to a pointer type. Casting a pointer type to a floating point type. Casting a struct or union to any other type that is not a struct or union of the same type. Casting a function pointer to a data pointer. Casting a data pointer to a function pointer. Casting an array type directly, since arrays are not a castable lvalue in C. Casting to a void type is only valid as a statement to discard a value, so casting the result of a void cast and using it as a value is an error. Casting to or from an incomplete type, meaning a struct or union that has been declared but not defined yet. Casting between two incompatible function pointer signatures, such as different return types or parameter types, is technically allowed by C but causes undefined behavior and many compilers treat this as an error in strict mode.

**Type system violations that always error regardless of implicit or explicit context:**

Using a non-scalar type such as a struct or array as a condition in an if, while, or for statement. Applying arithmetic operators to structs or unions. Applying bitwise operators to floating point types. Applying the modulo operator to floating point types. Dereferencing a void pointer directly without casting it first. Performing pointer arithmetic on a void pointer, since the element size is undefined. Assigning to or casting to a function type directly, as opposed to a function pointer type. Using a value of type void anywhere an actual value is expected.

Implicit Conversions  
→ Allow:  
int i \= 42;  
long l \= i;          // int → long (widening, safe)  
float f \= i;         // int → float (safe, possible precision loss but allowed)  
double d \= f;        // float → double (widening, safe)  
int x \= 'A';         // char → int (integral promotion, fine) ASCII value 65

enum Color c \= 5;   // implicit int → enum, warn (value may not be a named member)  
int i \= c;          // enum → int, allow silently

→Warn but allow:  
double d \= 3.14;  
float f \= d;         // double → float (precision loss, warn)  
int i \= d;           // double → int (truncation, warn)  
int i \= 100000000L;  // long → int (possible overflow, warn)  
unsigned int u \= \-1; // signed → unsigned (well-defined but suspicious, warn)

→ Reject (not valid):  
int \*p \= 42;         // integer literal → pointer (not void\*, reject)  
int i \= (int\[\]){1};  // array → int, nonsensical  
struct A a \= struct\_b; // incompatible struct types, reject

Explicit Casts  
→ Allow:  
double d \= 3.14;  
int i \= (int)d;           // explicit truncation, programmer's intent

int \*p \= (int \*)malloc(4); // void\* → any pointer (classic C, allow)  
void \*v \= p;               // any pointer → void\* (always safe)

unsigned int u \= (unsigned int)-1;  // signed → unsigned, explicit \= ok  
char c \= (char)300;        // explicit narrowing, allow (but maybe warn)

→ Warn but allow:  
float f \= (float)some\_double;  // explicit precision loss, mild warn  
int i \= (int)(long)some\_ptr;   // pointer → integer, warn about portability (use intptr\_t)

→ Reject:  
int i \= (int)"hello";     // pointer → int without intptr\_t, reject or hard warn  
float \*fp \= (float \*)\&some\_struct;  // type-punning without union, UB — warn strongly  
int (\*fp)(int) \= (int(\*)(int))some\_data\_ptr; // data ptr → function ptr, reject (UB)  
struct A \*a \= (struct A \*)\&b;  // incompatible struct pointer cast — warn strongly

// Casting away const is legal C but dangerous:  
const int \*cp \= \&x;  
int \*p \= (int \*)cp;  // warn: discarding const qualifier

**Operadores …. QUEM SOBRAR TEMPO**

**Qualificadores- const, volatile…   MENDES**

A analise semantica dos qualificadores const, volatile, static, extern e inline deve assegurar que estes sao usados nos contextos adequados e que as operacoes sobre os objetos qualificados respeitam as restricoes impostas pela linguagem. Abaixo estao descritos todos os casos que devem ser diagnosticados, com a indicacao se constituem erro grave (rejeicao da compilacao) ou apenas aviso (compilacao permitida mas com alerta), bem como os usos considerados validos sem qualquer diagnostico.

 

# **const**

O qualificador const indica que o objeto nao pode ser modificado. Qualquer tentativa de escrita numa variavel declarada com const e um erro semantico. Isto inclui atribuicoes diretas, operadores de atribuicao composta (+=, \-=, \*=, /=, %=, etc.) e os operadores de incremento e decremento, tanto na forma prefixa como posfixa.

 

## **Hard errors**

**Modificar uma variavel const apos declaracao**

Depois de declarada, nenhuma forma de escrita e permitida sobre uma variavel const.

const int x \= 5;

x \= 10;         // ERRO: assignment of read-only variable 'x'

x \+= 1;         // ERRO: compound assignment of read-only variable 'x'

x \-= 1;         // ERRO: idem

x \*= 2;         // ERRO: idem

x /= 2;         // ERRO: idem

x %= 2;         // ERRO: idem

x++;            // ERRO: increment of read-only variable 'x'

x--;            // ERRO: decrement of read-only variable 'x'

\++x;            // ERRO: idem (prefixo)

\--x;            // ERRO: idem (prefixo)

 

**Declaracao const local sem inicializacao**

Em scope local, a variavel nunca podera receber um valor apos a declaracao, tornando-a inutilizavel. Em scope global, a omissao do inicializador e permitida porque a variavel tem duracao estatica e e inicializada implicitamente a zero pelo standard C.

// Scope local \-- erro semantico

void foo() {

	const int y;    	// ERRO: uninitialized const local variable 'y'

	const float pi; 	// ERRO: uninitialized const local variable 'pi'

	const int \*p;   	// OK: ponteiro nao-const, nao inicializado e permitido

}

 

**Atribuir const T\* a T\* sem cast explícito**

Esta atribuicao descarta o qualificador const e permite modificar o objeto apontado, o que viola diretamente o contrato de imutabilidade.

const int y \= 10;

const int \*cp \= \&y;

 

int \*p \= cp;        // ERRO: assignment discards 'const' qualifier

Nota: O caso com cast explicito (int \*)cp e tratado na parte da Mariana (casts) como aviso.

 

**Passar const T\* a funcao que espera T\***

A funcao receptora poderia modificar o valor atraves do ponteiro, violando o contrato const do chamador.

void foo(int \*p) { \*p \= 99; }

 

const int x \= 5;

foo(\&x);   // ERRO: passing 'const int\*' as 'int\*' discards const qualifier

 

**Modificar o endereco de um ponteiro que e ele proprio const**

int a \= 1, b \= 2;

int \* const p \= \&a;

 

p \= \&b;     // ERRO: assignment of read-only variable 'p'

\*p \= 99;	// OK: o valor apontado pode ser modificado

 

**Modificar o valor apontado ou o ponteiro quando ambos sao const**

const int val \= 5;

const int \* const p \= \&val;

 

p \= NULL;   // ERRO: assignment of read-only variable 'p'

\*p \= 10;	// ERRO: assignment of read-only location '\*p'

 

## **Warn but allow**

**Qualificador const no tipo de retorno escalar de uma funcao**

O valor retornado por uma funcao e sempre uma copia (rvalue). O const nao e observavel e nao tem qualquer efeito sobre o valor devolvido. O GCC e o Clang emitem aviso controlado por \-Wignored-qualifiers para assinalar a redundancia.

const int f1(void) { return 42; }        	// WARN: 'const' qualifier on return type has no effect

const volatile int f2(void) { return 42; }   // WARN: qualifiers on return type have no effect

 

const int\* f3(void) { return NULL; }     	// OK: const aplica-se ao valor apontado, nao ao retorno

 

## **Allow**

**Declaracao const no scope global sem inicializacao**

Variaveis globais tem duracao estatica e sao inicializadas implicitamente a zero pelo standard C. O const apenas impede modificacoes posteriores.

const int x;        // OK: inicializado implicitamente a 0

const float f;      // OK: inicializado implicitamente a 0.0

const int \*p;       // OK: ponteiro inicializado a NULL

 

**Ponteiro para const e ponteiro const**

// Ponteiro para const (o valor apontado nao pode ser modificado, o ponteiro pode)

const int y \= 10;

const int \*cp \= \&y;   // OK

cp \= NULL;            // OK: o ponteiro em si nao e const

 

// Ponteiro const (o endereco nao pode mudar, o valor apontado pode)

int a \= 1;

int \* const p \= \&a;   // OK

\*p \= 99;              // OK: o valor apontado pode ser modificado

 

# **volatile**

O qualificador volatile informa o compilador que o objeto pode ser alterado por fatores externos ao fluxo normal do programa (como interrupcoes de hardware ou acesso concorrente), impedindo otimizacoes sobre acessos a essa variavel. Em termos de analise semantica, ha poucas restricoes diretas, mas a perda do qualificador deve ser assinalada.

 

## **Warn but allow**

**Atribuir volatile T\* a T\* sem cast**

O qualificador volatile e descartado na atribuicao, o que pode levar o compilador a aplicar otimizacoes indevidas sobre acessos ao objeto. O GCC aceita esta atribuicao emitindo apenas um aviso. O LLVM/Clang trata este caso como erro em modo estrito. Para este compilador optamos por aviso, alinhando com o comportamento do GCC.

volatile int reg \= 0;

volatile int \*vp \= \&reg;

 

int \*p \= vp;         	// WARN: assignment discards 'volatile' qualifier

 

**Cast explicito que remove o qualificador volatile**

Mesmo com cast explicito, a remocao de volatile e suspeita e deve ser assinalada.

volatile int reg \= 0;

volatile int \*vp \= \&reg;

 

int \*p \= (int \*)vp;  	// WARN: cast removes 'volatile' qualifier

 

**Qualificador volatile no tipo de retorno escalar de uma funcao**

Pela mesma razao que const, o volatile no tipo de retorno escalar nao tem efeito observavel porque o valor devolvido e uma copia.

volatile int f4(void) { return 42; }	// WARN: 'volatile' qualifier on return type has no effect

 

volatile int\* f5(void) { ... }      	// OK: volatile aplica-se ao valor apontado

 

## **Allow**

**Combinacao const volatile**

A combinacao const volatile e completamente valida e idiomatica em sistemas embebidos para representar registos de hardware que sao read-only do ponto de vista do programa mas podem ser alterados externamente. Nao ha qualquer diagnostico para estes casos.

const volatile int hw\_status \= 0;   // OK: registo de hardware read-only

const volatile int \*port;       	// OK: ponteiro para registo de hardware

 

# **static**

O qualificador static tem varios significados consoante o contexto: linkage interno para simbolos globais e duracao estatica para variaveis locais. O seu uso e geralmente valido em todos os contextos que a gramatica permite.

 

## **Allow**

**Conflito static \+ extern no mesmo simbolo**

O standard C permite que um mesmo simbolo seja declarado primeiro com static e depois com extern. A declaracao extern mantem o linkage interno estabelecido pelo static e nao o altera para externo. O GCC aceita sem qualquer erro ou aviso, e por isso aceitamos tambem.

static int x \= 5;

extern int x;          // OK: extern mantem o linkage interno do static

 

**Usos validos de static**

static int global\_counter \= 0;	// OK: variavel global com linkage interno

static void helper(void) { }  	// OK: funcao com linkage interno

 

void foo() {

	static int calls \= 0;     	// OK: variavel local com duracao estatica

	calls++;

}

Nota: O uso de static em parametros de funcao (void foo(static int x)) e rejeitado diretamente pelo parser pois a gramatica de param nao inclui decl\_specifiers\_opt. Nao e responsabilidade da analise semantica.

 

# **extern**

O qualificador extern indica que o simbolo esta definido noutro local. Em scope local, uma declaracao extern serve apenas para declarar a existencia do simbolo e nunca pode ser uma definicao. Em scope global, e o uso tipico para referenciar simbolos definidos noutros ficheiros.

 

## **Hard errors**

**extern com inicializacao dentro de uma funcao**

Em scope local, extern serve apenas para declarar a existencia do simbolo, nao para o definir. O parser aceita esta construcao pois local\_item \-\> var\_decl com decl\_specifiers\_opt e initializer\_opt permite-a sintaticamente.

void bar() {

	extern int x \= 5;          	// ERRO: 'extern' variable cannot have an initializer in local scope

	extern float pi \= 3.14;    	// ERRO: idem

	extern int arr\[5\] \= {1,2,3};   // ERRO: idem

}

 

## **Warn but allow**

**extern com inicializacao no scope global**

O standard C permite que uma declaracao extern global tenha um inicializador, tornando-a uma definicao e ignorando o extern. E uma pratica confusa e provavelmente nao intencional, pelo que se emite um aviso.

extern int x \= 5;    	// WARN: 'extern' variable has initializer \-- treated as definition, extern ignored

extern float f \= 3.14;   // WARN: idem

 

## **Allow**

**Declaracoes extern normais**

Declaracoes extern sem inicializador sao o uso tipico para referenciar simbolos definidos noutros ficheiros e sao completamente validas.

extern int global\_var;     	// OK

extern float some\_value;   	// OK

extern int foo(int x);     	// OK: declaracao de funcao externa

extern void callback(void);	// OK

 

# **inline**

O qualificador inline so e semanticamente valido em funcoes. A gramatica inclui TOKEN\_INLINE em decl\_specifier, o que faz o parser aceitar inline em variaveis e prototipos sem qualquer erro sintatico. Cabe a analise semantica rejeitar esses casos.

 

## **Hard errors**

**inline em declaracao de variavel**

O qualificador inline nao tem significado nem efeito quando aplicado a uma variavel. O parser aceita estas construcoes pois TOKEN\_INLINE faz parte de decl\_specifier na gramatica.

inline int x \= 5;          	// ERRO: 'inline' is not valid for a variable

inline float pi \= 3.14;    	// ERRO: idem

inline int arr\[10\];        	// ERRO: idem

inline char \*str;          	// ERRO: idem

inline const int limit \= 100;  // ERRO: idem

 

**inline em prototipo de funcao sem definicao no mesmo ficheiro**

Uma funcao inline precisa de ter o corpo disponivel no mesmo ficheiro para o compilador poder realizar a expansao inline. Um prototipo inline sem definicao e sempre um erro, mesmo que nao haja chamadas a funcao.

inline int square(int x);     	// ERRO: inline function 'square' declared but never defined

inline void print\_val(int x); 	// ERRO: idem

 

## **Allow**

**inline com definicao completa no mesmo ficheiro**

inline int square(int x) {

	return x \* x;	// OK

}

 

inline int max(int a, int b) {

	return a \> b ? a : b;	// OK

}

 

 

# **Resumo dos diagnosticos**

Em sintese, a analise semantica dos qualificadores deve rejeitar qualquer tentativa de modificar um objeto const, rejeitar declaracoes de variaveis const locais sem inicializador, rejeitar a atribuicao implicita de const T\* para T\* e a passagem de const T\* a funcoes que esperam T\*, emitir aviso para qualificadores const ou volatile no tipo de retorno escalar de funcoes, emitir aviso para a perda de volatile em atribuicoes de ponteiros, aceitar static \+ extern no mesmo simbolo sem diagnostico, rejeitar extern com inicializador em scope local, emitir aviso para extern com inicializador em scope global, rejeitar inline em declaracoes de variaveis, e rejeitar prototipos inline sem definicao no mesmo ficheiro.

 

| Caso | Acao |   |
| :---- | :---- | :---- |
| const sem inicializacao \-- scope global | Allow |   |
| const sem inicializacao \-- scope local | Hard error |   |
| Atribuicao / \++ / \-- / op= em variavel const | Hard error |   |
| const T\* atribuido a T\* sem cast | Hard error |   |
| const T\* passado a funcao que espera T\* | Hard error |   |
| Modificar endereco de int \* const | Hard error |   |
| Cast explicito que remove const | Warn (parte da Mariana) |   |
| const no tipo de retorno escalar de funcao | Warn | GCC/Clang \-Wignored-qualifiers |
| volatile T\* atribuido a T\* sem cast | Warn | GCC avisa, LLVM/Clang erro em strict |
| Cast explicito que remove volatile | Warn |   |
| volatile no tipo de retorno escalar de funcao | Warn |   |
| const volatile T | Allow |  |
| static \+ extern no mesmo simbolo | Allow | GCC aceita |
| extern com inicializacao dentro de funcao | Hard error |   |
| extern com inicializacao no scope global | Warn |   |
| Declaracoes extern normais | Allow |   |
| inline em variavel | Hard error |   |
| inline em prototipo sem definicao | Hard error |   |
| inline com definicao completa | Allow |   |

**TABELA DE SÍMBOLOS…**  
**\---------------------------------------------------------------------------------------------------------------------------**  
**Tiago**  
**TYPE CHECKING**

**Algoritmo geral do type checker:**

1. O nó avalia os seus children (e.g. Child1 e Child2) e recolhe os seus tipos (e.g. Type1 e Type2)  
2. **if (Type1 \== Type2) {success}** , segue em frente  
3. Se não forem do mesmo tipo, chama uma função auxiliar que diz se é possível fazer Cast Implícito de um tipo para outro (e.g. can\_cast\_implicitly(Type1, Type2)  
4. Se a função auxiliar retornar verdadeiro, cria um novo nó na AST  
5. Se a função auxiliar retornar falso (e.g. tentar atribuir uma struct a um int), gerar erro de compilação

**Exemplo:**

**double x \= 5;**

AST antes da verificação   
![][image5]

* Como double \!= int, o compilador pergunta “posso fazer um cast implícito de int para double?” \- “can\_cast\_implicitly(int, double)”  
* Como isso é permitido em C, a função retorna verdadeiro  
* Como retorna verdadeiro, cria-se um novo nó (e.g. CastNode) que converte o que está abaixo dele na árvore para double.

AST depois da verificação  
![][image6]

* Se for uma atribuição, como neste exemplo (**double x \= 5**), o cast deve ser do tipo da direita da atribuição (int) para o tipo da esquerda (double)  
* Se for uma operação matemática, o cast deve ser do tipo menor para o maior, segundo a hierarquia (long double \> double \> float \> unsigned long long \> long long \> unsigned long \> long \> unsigned int \> int) \- não sei se vamos ter estes tipos todos.

**STATEMENTS**

### **1\. Instruções de Condição (if, while, do-while, for)**

A regra de ouro em C para qualquer condição que controle um ciclo ou um if é: a expressão tem de resultar num tipo escalar (inteiros, floats/doubles ou apontadores). Não se pode testar tipos agregados (e.g. structs e arrays)

* A verificação na AST: O compilador olha para o nó da condição dentro do if.  
  1. Exemplo válido: **if (5 \> 3\)** (Resulta em int, válido)  
  2. Exemplo inválido: **struct Ponto p; if (p) { ... }**  
* Como o Compilador Resolve:  
  1. Avalia o nó da condição  
  2. Se for uma struct ou union, dá erro  
  3. Se o tipo for válido (ex: um pointer ou um float), o C moderno assume implicitamente uma comparação com zero. Ou seja, a nível da AST, a semântica transforma um **“if(pointer)”** em  **“if (pointer \!= NULL)”**, ou **“if(float)”** em **“if (float \!= 0.0)”**

**2\. Switch case**

O switch é das estruturas com mais regras na Análise Semântica em C

**Regra 1: a expressão do switch tem de ser inteira**

Avaliar o tipo da expressão dentro dos parênteses: **switch(expressao)**. Se for um float, double, struct ou pointer, dá erro. Apenas int, char e enum são permitidos.

**Regra 2: Os valores do case têm de ser constantes**

Verificar se o nó a seguir à palavra case é avaliável em tempo de compilação (Constant Folding)

**Regra 3: Valores de case não se podem repetir**

Enquanto o Analisador Semântico percorre o bloco do switch, tem que se criar uma estrutura de dados temporária (como uma Hashset). Cada vez que encontra um case 5:, ele tenta inserir o 5 no Set. Se o 5 já lá estiver, erro.

### **3\. Structs \- acesso (. e \-\>)**

Recorrer à Tabela de Símbolos.

e.g. **pessoa.idade \= 20**; ou **ponteiro\_pessoa-\>idade \= 20;**

* A verificação para o operador ponto (.):  
  * O compilador olha para o lado esquerdo (pessoa). Vai à Tabela de Símbolos e pergunta: "Isto é do tipo struct/union?". Se não for, dá erro  
  * Sabendo que é uma struct Pessoa, o compilador procura na definição dessa struct específica se existe um campo chamado idade.  
  * Se não existir, dá erro  
  * Se existir, o nó inteiro da expressão pessoa.idade herda o tipo desse campo (neste caso, int). Isto é crucial para que a atribuição \= 20 funcione a seguir.  
* A verificação para o operador seta (-\>): a regra é igualzinha à de cima, mas com um passo extra no início: o lado esquerdo tem de ser um apontador para uma struct. O Analisador Semântico verifica se é um apontador, faz a "desreferenciação" implícita, e depois vai procurar o campo na Tabela de Símbolos  
* Regra Extra na declaração: verifica se uma struct não contém uma instância de si mesma  
  * Inválido: **struct Node { int valor; struct Node proximo; };** (Erro: o tipo está incompleto, o tamanho de memória seria infinito)  
  * Válido: **struct Node { int valor; struct Node \*proximo; };** (apontadores têm tamanho fixo de 4 ou 8 bytes, logo o compilador aceita)

### **4\. return**

O return interliga o corpo de uma função com a sua declaração.

* Verificação: Quando o Analisador Semântico encontra um nó de **return expressao;**, ele precisa de saber em que função estamos atualmente.  
* Como o Compilador Resolve:  
  1. Descobre o tipo da expressão a ser retornada (ex: **return 5.5;** \-\> tipo double).  
  2. Consulta a Tabela de Símbolos para ver o tipo de retorno declarado da função atual (e.g. **int minhaFuncao() {...}** \-\> tipo int).  
  3. Tenta fazer um cast implícito do double para o int. Se conseguir (inserindo o CastNode), emite um aviso (warning de perda de dados). Se não conseguir (ex: tentar retornar uma struct numa função que pede um int), dá erro.

**APONTADORES**

### **1\. Type Checking**

Quando existe uma atribuição entre dois apontadores (e.g. **p1 \= p2;**), não basta ambos serem apontadores. O tipo para o qual eles apontam também deve ser igual.

#### **Regra A: O Tipo Base tem de ser exatamente igual**

Em C, ao contrário dos tipos numéricos (onde um int pode virar double facilmente), a conversão implícita entre apontadores de tipos diferentes é estritamente proibida (com uma exceção).

* Exemplo: **int \*p\_int; float \*p\_float; p\_int \= p\_float;**  
* Verificação na AST:  
  1. O compilador avalia o tipo do lado esquerdo: Pointer(int).  
  2. Avalia o tipo do lado direito: Pointer(float).  
  3. Compara os tipos base: int \!= float.  
* Ação do Compilador: Como os tipos não coincidem, ele não tenta fazer um Cast implícito (não insere o CastNode como fazia na matemática). Gera imediatamente um erro.

#### **Regra B: void \***

O void \* é a exceção à Regra A. Representa um endereço de memória sem tipo associado.

* Exemplo: **int \*p \= \&x; void \*v \= p; int \*p2 \= v;**  
* Verificação: O compilador vê Pointer(void) de um lado e Pointer(int) do outro.  
* Ação do Compilador: C define que void \* é compatível com qualquer apontador de dados

#### **Regra C: qualificadores (const)**

O compilador também verifica a segurança das permissões de escrita.

* Se se tentar passar um const int \* (um apontador para um dado que não pode ser alterado) para um int \* (que permite alterações), o Analisador Semântico dá erro porque se está a remover uma “proteção de segurança”

### **2\. Desreferenciação válida (operador \*)**

A desreferenciação é o ato de ir até ao endereço de memória que o apontador guarda e aceder ao seu conteúdo (representado pelo operador \*)

Quando o compilador encontra a expressão \*p, tem de fazer validações críticas:

#### **Validação 1: O operando TEM de ser um apontador**

* Exemplo Inválido: **int x \= 5; int y \= \*x;**  
* Verificação na AST:  
  1. O compilador visita o nó do operador unário \*.  
  2. Pede o tipo do seu filho (a variável x). O tipo retornado é int.  
* Ação do Compilador: O Analisador Semântico sabe que não pode "viajar" para um número inteiro comum como se fosse um endereço. Dá erro.

#### **Validação 2: É proibido desreferenciar void \***

Esta é uma das regras semânticas mais importantes de construir\!

* Exemplo Inválido: **void \*ptr; \*ptr \= 10;**  
* Verificação na AST:  
  1. Filho do nó \* é do tipo Pointer(void). É um ponteiro, logo passa a Validação 1\.  
  2. No entanto, qual é o tamanho do dado lá no destino? É um char (1 byte)? Um int (4 bytes)? Um double (8 bytes)? O tipo void significa "tamanho desconhecido" (Incomplete Type).  
* Ação do Compilador: Como o compilador não sabe quantos bytes deve ler ou escrever, dá erro. Para resolver, o programador tem de forçar um cast explícito (e.g. **\*(int \*)ptr \= 10;**), o que altera a AST para dar um tamanho conhecido à operação.

#### **Validação 3: Propagação de L-value**

Quando a desreferenciação é bem-sucedida (e.g. **\*p\_int**), o Analisador Semântico não apenas valida a operação, como também define o tipo resultante do nó.

* Se o filho é Pointer(int), o nó \* passa a ter o tipo int.  
* Além disso, o compilador marca este nó como um L-value (Locator Value). Isto significa que o compilador sabe que esta expressão representa um local válido na memória e, portanto, pode ser colocada do lado esquerdo de um sinal de igual (**\*p\_int \= 20;**).

### **3\. O operador &**

Regras do Analisador Semântico

* Verifica se o que está à frente tem um endereço de memória fixo  
* Exemplo inválido: **int \*p \= &5;**  
* O compilador avalia o 5 como um literal (um R-value, um valor temporário que só existe no processador e não na RAM), e dá erro.

**\---------------------------------------------------------------------------------------------------------------------------**

[image1]: <data:image/png;base64,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>

[image2]: <data:image/png;base64,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>

[image3]: <data:image/png;base64,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>

[image4]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAjkAAAE9CAYAAADpknPmAABAFUlEQVR4Xu2dT8sd25nd9UVMf4EMQrBBk5BJR0nsUYIJ3RMnwaYJomf2oO2JwSDJ8UyyETT0wKCBaS5Oo4AdGjqD9MADD+SBoaGR3F/gDi6Xe3WvwIKTrNMseWndZ+/aVadOvefUu36wOaf232c/+9+qOlK9dw4hhBBCCDvkjkeEEEIIIeyBiJwQQggh7JKInBBCCCHskvdEzh9//X43/MM//pNmvzj+5M++d7Tz7/7+154UQgghhFtGRE4IIYQQdkkpci5dzLSIyAkhhBACmS1yfvxXf33M8+d/8aN3cRQXP/ubv30Xh3R9CqQwDvn5nfV9/0d/+S4ObRG2wfYZVNBUIkfb0HYI+qrp3m4IIYQQrpNS5FQB4oOoqKEoqUSPB+LxDFU5Cq4qrZWHIscFkYYpW/I0KIQQQrhuFokcCABP9zQVPRQbfELCMrxWMdISLLxWO/i0iHFehnXqEyZ9IqRPcUIIIYSwL0qR0/u5iqgwURHRe3pCMeLt8CclFUYUMKyb4kRt83Iqcii2EKd4Gf9ZDSGEEEII189ikaPiQJ+u9EQOhYW348IDbCVyiIud/LucEEII4bpZJHL8H/NSWGiaiwjF26nKtERO9XMVBcncn6sqKltCCCGEcH2UIqcVIB7037HgWgUPaf0jYYoNXi8ROVVo/Tue1lMlPt2p/mcVQ0sEhRBCCOE6mC1y/OkJ4P+wqv4HFoM+TWHcEpHjT5H0qZOLHOD5/QlNJXQicEIIIYTr52r+dlUlYEIIIYQQWkTkhBBCCGGXROSEEEIIYZdcjcgJIYQQQphDRE4IIYQQdklETgghhBB2SUROCCGEEHZJRE4IIYQQdklETgghhBB2yY2InC9/7dsetSu++Z0fH/7o7rfehRe//Z1nCSGEEMKZuRGRs4Tv/vDZ1YgFiJxrsTWEEELYK5uKHAgVPt1QIAgQp09A8J189Rs/eO/JyOjTkZ/89BfHvCgPWPbnv/yV5VyXKZFDu85tRwghhHCb2VTkEBUwBAe+/owFYaJCYemTHJRje/g+Iiwouqowgv9c5UTkhBBCCOfnokQODn/iosav58AnSFW75wY280lSCCGEELbjVogctIeAOkY49UmOU/U3hBBCCOflqkQOf95BvtGnI8hHcTNH6CwFNuvPbrDV+8ufs0IIIYRwPjYVOTj8/ckIhIs+OaHY8Scnmmf0v6BTTFAQsf1zCx30oWcr+xlCCCGE87GpyAn1k50QQgghrM9mIufDO3cOb1+9On5//fDh8RqfJ10/enS8DiGEEEJwNhM5rx88OHx8797hzfPnR4Hy6ZMnJ31+9uzZ4aO7dw+fP33qTYUQQgghbCdywCf379dPZBZe//7Fi8Nnjx8fv4cQQgghKJuKnBBCCCGErYjICSGEEMIuicgJIYQQwi6JyAkhhBDCLonICeHM4L1IefljCCFsz42InOotwKeCNyLnJXuXCcal9XfH8HJE/XMeU+hbsykc9G3YnAPVW7NvgiV/SgRv6Na+rIG/VTwsZ+2xCSGcjxsROUvwv2Wl8E9DcOPJJn45TInP0b9BBpBXBREOG84J/9tne/jr7z2/LQU+upT1cY7+bcHUnA4hXA6bihwIlerumneZ/FtTfqfEO1sNKng8beTOGfXjqYDe8Y+UWwPtJ9E7bcA+u02w+ZoO77We4lQHCw5r+kdFDv92mDPXd6yHTx75FGnU5rlz0vH+sn3ao/MI/tG/mVb1H1QiB3nZFteo9lHbWespbPV37BRd8xwz9o/2aH9HcP/4k8DW/gM0zf80S88/7CdgHhXmlT1E90t81zY1bc6cDuG2sanIIb6BACxw3SCwcPVw7D3JAdh4UN43ih6wQzcIXI+U141JQ88+peo/UB/oAa7MPahvkkqYKHP6UR3OgPUjjaLJDxqyxHeoj2XmiDKfv6NzS6l853F6rfW3fF/50fPSlwCfOg+RVtW7hFY9aE/9rDboeHDNIc37VOHzQq97+w/qVx8gH20f8Q+uaSvtBT17KiGlbWqaX4cQ/sBFiRzd2FzU+LWCstz45hxifhCByra16W3KiMeG6BvgNQJfun/JHMEAqsMZcLzoN4xpNa6ngLbn3jG7AEaoRGuPai7qOtEDk2naXlW+8mNP5PCA1rDW3KzsA/Czt6lCk/broe99ctw3DCzX23/cTvXXiH+8PJiypypDqrQqLoSwE5GzlMqOKs7xjYlhxD7Uj4BNG332g5N3ZR5/bfjB6cztX1Uf/MdDXr+DufX3QL0ct1HWaL/VHuv2dG/T00ElCNy3LnJG5vUSKvuA90M5ReT0RGZv/3E7XeRM+cfLgyl7qjKkSqviQghXJnK4kSFfbyMcBXXoRjOyWZ4K7eadnPdR71i9j8iLMr3N8VLw8VN8rEeBP7Sc+s/rrA6fJT9XoR7OV4qdEZDv1LnUagv9hC0+D7RvLVtbc1zLwq/0JfJW9Shoy+fyCDpGai/7V7FU5AB/wqL4/NH5q3sP0Dkx4p9Wes8e9wFsYX6k+fpptRHCbWdTkYNF6k8/sEnw8OY1FjCviebpbQ5z4GbFeucegEuguGE/dKPWPtMuP7i2sHENeptuL20KnUM8eHRu6OGDaz0M5oocHt6cbyirbUzh8711cCs6Pxiq+V7F0V7aqG3qPK/s0XTORfpX663s8ZuFUbSvPi5uL9I1Pw995KO9UyJL5wnD6P6jY+m+bfmnas+Fi6e7mNI0hXORYarvIdxWNhU5l8boYXUpYPO8hs3M73wVxC85EMPlkkP2fFzbHhXCpbGZyPnwzp3D21evjt9fP3x4vMbnSdePHh2vl+B3riFcAmdZJ2e8/r/fe5CD+IzkpiCE09hM5Lx+8ODw8b17hzfPnx83yk+fPDnp87Nnzw4f3b17+PzpU28qhKtl7XVy7s+3L196F8JK+M9iIYT5bCZywCf37x83xt6d4Zzr3794cfjs8ePj9xD2wtrr5NzXIYRwqWwqckIIIYQQtiIiJ4QQQgi7JCInhBBCCLskIieEEAbxl/SFEC6bGxE5/jKxNcB7Om7Df2Xli8p6L0/z/xLPl5XdlH/Qbus9KtXbW3uMvgyweqHb2mzRxqUx94WKewLjPbfv/kLJteA6iOAKoc+NiJwlYDG3Dkq+tZQHXOtFdHsAG633z+8usRFXvroJkTMlPuccGsirggibPPvJN9USxM+p+xR6/duaLWzZyq974hzjgjkekRNCn01Fjr7+XOGduD6N0E3BX2GuhxvwtNGF708A2P650X4q/kr/ikrkOK08rY2W7c55ojLKWk9xKrGkL0pTkcP+OEueQujTGoSqL24XqeakPlXDJ21Vu3R+6BMAL8vyQOcyg/dV19HoGgG6bv1pxoh/Wmg5na/0CfrJ+tkm+4lr5lMfqT0a73nVXyOo79yvI/gc0fqA+pi+4LXGKZXI0TlOX2ieU8YrhGtkU5FDfMEDLGLdlLBQdQH2nuQALF6UrzaDFtUB0muD6CaxZMOo+g/U9upQBy0Bo7Q24ao+cC6R0+oDadlZ0eo366fI4TyomCtyYL/nr+qu+ujzF3loP75jvumc14NJDyXk0fpZFlT2VbYACobWdQvk0TrRngoOb7/yTwsdT68HYE4y3tc/2mFbOje0TnxXX3odrTnloJz6ysdohGpcPM7tm/JPJXKA5tU8p45XCNfIRYkc3Uh8wfu1grJcvL6IW3h7wA+mc8EDzqHYYKj8NLUxY9Nq9aGq75ygvZYtFCSjtPqtIoeH4lrjiDZdyFZitvKrl0HgYcP8egAxDp9eTg8ib2vqmlTxVZxT5VFB5rZW/mnR6iOp2iatNLfJRYCWa9XhoL/ex9F9hlRtuUjxPFP+8fKkJXLcNwyj4xXCNbILkbMEbw/ArpE2fJOYs1mgDQRsRCrOgG+clZ9ahz3ahg1VGqnqOxewp9ee93WKqj69U9fvYG79FaNCzO0CvfaZvyVyevPI25q6JlV8FedUeVTkjPinwvtZtVPFkVZa64An3Eeq9d+iN5ajTNnr+9uIf6r+gZYPThmvEK6VqxI5PMCRb+2NhyKhd8CsAe3mkwdtT/uE/lZ+qkQO6yJVHlDVB9CW23IqPn6Kj/Uo8I+WU5u9Tj8kwNyfq0B1B+1UfkVcNQaA+fUAYhzKVPURT/NrF830ifvD/dXCD0bYq22M+KdC64AtVT3eN6VKQ/80Ht8rEYD4qnwL9L+qZw6t9ijOPX3EPyMiB+U0T1VPCHtmU5GDBeZPP7CAKTB4jU2F10TzrLVQtR0EPwjOAQUJ+6GbG8UGbcGnb2KVgGFeDZ6H+Spgx8iBN4dWW6CXNoXOIfZR5wbrpp+1X0tEjo4XA+dIaz4TT8dYcoyRRrthI+zmvNZ5wLwaz2v0BdetOeRzp6pzBLbDtrTNnn96+DpAGxwb77/W6WsWQX2ua4HffW4j3n0zha+x0XnktmpfCOryuJ5/Kh+oPeo/5qUPlo5XCNfKpiLn0tlC5JxKJXJGqcQF6hrdsEfBJtuyEfFzD5gQ1qRaByGEfbKZyMFfLX776tXxu/8V48XXjx4dr09FnwQgXDK8M5sjTHhnl809XAJn2QsGrrFmvv+lrxyvn/6rf/su/c0HHxy/r81N9XPp9bn8EMJNspnIef3gweHje/cOb54/Py6uT588Oenzs2fPDh/dvXv4/OlTbyqEcMGsvRec+vn25Us3cRUurZ9Tn+fyQwg3yWYiB3xy//5xMfXuJuZc//7Fi8Nnjx8fv4cQroe194JTr8/FpfVz6jqEvbGpyAkhhBBC2IqInBBCCCHskoicEEIIIeySiJwQQggh7JKInBBCCCHskoicEEIIIeySiJwQQggh7JKInBBCCCHskoicEEIIIeySiJwQQggh7JKInBBCCCHskoicEEIIIeySiJwQQggh7JKInBBCCCHskoicEEIIIeySiJwQQggh7JKInBBCCCHskoicEEIIIeySiJwQQggh7JKInBBCCCHskoicEEIIIeySiJwQwtn47g+fHf7o7reO37/5nR9bagghnJeLEjnYDBm++o0feHK4UnC4vfjt7zz6yE9++otjmAJ5dH4woF4Ej9c6PQ0Hr/LzX/7qXdqXv/bt99KWojah/grYMdL3LUC/K9+cCtYx/Xspfb0psA7ghxDCdlyUyImw2R847Ht38HPGHAewiiW9xkGqhygObabhUw9vHrxM04MHdcyxaQrU1xI5LbwvW+F+ulRuyj9rsObcCiFMs7nI0Tty3/ynNgCkr3WnHbZhjac4hKKmKucHn4oLP7w1L+J9HrrNnLOeb4RK5OhTHu8Hf97R4P3SNLUT64NxfDKjbWs5twm4n6agrXxC4fXyCQ6DQ3sRRttd6h/4g3bik9/d/y3UVt2n8J37UtVP9QHa1LLuH/Ud+wn7aKsL9coeoPOL/a7SEFprM4S9sLnI6d3V6+Kr8kXkXBfYQKtxJL45T6EHnB9OLnJ0nvjhjXa5uVf2eV1rixzi7UzFw2b3ma8H+ohtav/UDq8HuJ9GQP0s4/Zpez4X8F376Nc9lvqHhzptdptaIK/PB/UT2mBfNY1ik3BsiI+dX1MEsT7aOmWPtsE6qrTqOoS9sbnIwaIb2Uh9IYfrA5ty604RYzt3fHkwVWV7d8V+9+qHq9M6RJeAetYSOYjTfjCoj+mjCi3jBypYKnJa1z4mLnKcKq5iqX9UJHhcD31qwqBiSutQH1Zjz3LuGwbN3+pnz56qTVLVV8WFsCc2FTlYTHx8yoOnRRbfdTN1l+x33CP0DnCdL/hsHTzIp20j3g+Fnjiby9xDpxePuCpeafnI+1SNzdoix8d4C5FTxZNTRE6P1lyrxl5FzpSvW/3s2VO1Sar6qrgQ9sSmIkcPFAgcXVxI00WPheyLFWVGNqVw87QOW7B0Y/U6tR6vE3l57Yc34nntYhtpfoggzu+yR5l76DC+ZV/1BEZxHxH/Gamqx/00gq/HlshBvS5yWmM5xVL/LBU5Ol8qWiIH3zUNdo/aClo+mbLH69W91Of2SP9DuGY2FTmAj1exEH0xYsEx3RcxFrbnD5dLb/PspbWg0PCAeB50LoKZzjTd4DGXOMd4+HBeOktEjs5lBraHT09zn8AOprkY8LJM9/jqgEVA3fCF/sThZf0wrGA/6DOU0Xa1n/SHrmttr/J7j7n+YX60T7uA29TCx5P+8T4zneJEfUC/s686bxlUjGi8+6dlD3AfqFDysR7pewjXzOYiZynVk51wmWDjbI2V3oWHEM5D7wliCLeJqxE5IYQQxhl5GhfC3onICSGEHcGfq/wnrhBuIxE5IYQQQtglETkhhBBC2CUROSGEEELYJRE5IYQQQtglETkhhEnwj1jxbpbWC+rOAd/jkv8OHUJYysWKnLX++yNfuFX9TwN/I2k4D/Bx9RZegANs5ND0l5gxoN7qpWpap6f5e3r8RXnhfThGfAHdFvBdS/ryvNsK5+fIOgkhvM9FipzRg8+pBIu+mbSiFR/WYUpIzvE/Dj4VS3rtTxhwMDINnyps9MWSFEgEdcyxKVwXvbl4ySzdE0O47WwucvSOvPUI2u/c+IpzLvTWHXdvA2sdXKjP7+wVvoo9LGONpziEoqYq5yIH31XI6Bhr3urtzG4z55znm6L19Kg3n5lXX+uvtvDPEzCvpusTqcperRN9VH/pnx9Amq4l/RMCvsb8KVprrBWW6dWrtvr61D2k2gcq3E4EX9eaxjbZFm2d+w4atRWB/vF6EXxOc6yZpunqH+0H+0kh77a27CHu91abPiYhXCqbixzfzBwsOt98ABYqN+0qHfTqbpVptUcicpYD3y4ZkxZ6EPuB4CJHN3YXOWiXm3tln9e1RORoGwDtaPnWfEYZpLX6AngwIq/2zfPptfcJbeq1+gH16bXa7aIQdih+3QJ1qH3uL20DtjAN8eovv56iGm/g7et40R8UEEx3geBUe4v22f3s/mD7bJfj5eID3110oC7Wh3TUNWUPbPF5x2tP8+sQLpXNRQ4Wmy9IBemtjQiLzg8bPfg0+Abki1vxwyGsQ+8gwAY5d5PEWKO+qizmhI6/zhEeEgy+WTsuCJbg8xHB5301n6uDiIcUadns7XndbA/B68A103w9aJrWWfmpiqvwfBxbAh9om0zzfK24Ft5v4n5D4Hhp/Sw/0ib653X2+qK2uZ065903CD5nvDyYsqcqQ6q0Ki6ES2NTkYNFhg2Uhx8WmNMTOVjIKN/aXFrlgG8Cim/q4XQwRkvHo4UfCooemvjUtlGGBxbyaduIVyEAOD9PYaR/1XxWW8moyPFyPap+E63L61VbXKi04io8n46tHuieVs2BKq5F5TvQG69TRE7PF17HHJEzhZcHU/ZUZUiVVsWFcGlsKnJ0Y4XAqRYcFr0vYgoibgj6XektOq+TVO0Rtjvn8Aj/jG/gih9wo3idWo/Xiby8duGAeF5zjDXN5wPikKclCiowF1v5e/PZ04DPa78mPbGua8+vXcjotR+MaEPrcV+1bHOq8WKf3Vb1h9sKRtsEai++04beeKltc0QOmBqT1ji7X/WnI52/LVo+6dnjPkA7rAefrbUXwiWzqcgBfESKxdZacB7PMlhUWFy89k2mWtj6iJ7tKr0NA/G+2YQxqrEgvbQWFBoeEE9hgKB1M51pOpaYBxx3nVM+P8ASkQN87rE9td3nMwWZluNhov30OlvptNnrVD+pDQjuA+0HyuGTa8/HpbWWFLWThyWviduqabzWOkZRP7it1Xi5bYxnPVO4bxHQf6+XfeIc9bFkOvvqPmA5Hw8tA1r2EPWB731axudICJfK5iJnBCzUre4SfCErWMgupMI0OABaBw/i/XAJf4AiJ4SbYslNSAiXykWKHNATH2uBAyULOlwSerccwk3Qu0kJ4dq4WJETQghhW/hzVURO2AsROSGEEELYJRE5IYQQQtglETkhhBBC2CUROSGEEELYJRE5IYQQQtglETkhhHD4w4vy8LnVqyX0pYJbtRnCbeLiRI6+yXPtt2r6+x/ynpxtgI9bL1UcffFj9SZXBL4l2OO1Tk/zl+3pW2DXnnO3CX8z8an4mLfm0Frw3Vxoa6t9AW1y/o2sgz2z9vwJAVykyDkX1QsGq7iwHlNCco7/IU70oNNr/nkAom+r9rcI82Bhmm6sqGOOTefA+3JNrOm73rwJbTJ/QvgDm4scvTvTpyp+1+bp+oTHNz8t27oTRx6/g+/FE9SXhbecNZ7iEIqaqpxv7PiuQkbHWPP60z3gNnN+eb4e/BkCZTl31Qb/e1BeToP2y59aqZ2Yp4zTl7qxTG8Nabtz5rs+BUOdWlbTaMsI3kcE+k7XI8eFaeyD9tPbpI9YTn3bs3WJf6bscf84busIU/NH90oEzh/4lXbik999nbVQW9U/+I6g813pzR+fB2rL1Ppq2QO0Xva7SkNo7V3hethc5Pjm6lTpmLw6gfUai8Q3Vp/UAPX6xgUwiav8JCJnOfBtNZ5krl91A/fNV4ULULHrIgftcvOq7PO6logcwA2cbbMtn4t+2Hr7CurrXdNHrJ9t4lp9oj7gQUH8ugXFFGHbxG84/HqKlg1+EOrYogyvfW0jzeeI+51oOfeHX/fo2aPt+VpxW/26R2v+ePtAx4SHOm12m1r4/MV3HRO0wb5q2tz5o3MWtNbXlD3aBuuo0qrrcH1sLnIwqXTCOdWi6sVxMSpVnC8QxRdTWAeMUcvn2HiqjbgHx7Uqy82KwQ8QTfPDw2kdEnNp1aN3tQxqR6tcFe9x1dwHvXyVD6o4B/WpnwEPUR+PalymaNkwJXIUFw491E7dE6pyVVyF5/Nxbs0BL9eKq/CxJojz8UDweTA1NxyMh9fp4pLoePXmj69ZBu1Xq589e6o2SVVfFReui01FDiYLHw9yEjvVourFVZt6FReRsy3wdTVuxO8oR6jGlehmhM/Wxop82jbifdPj/DyV1gY51fdWuSre41o+6uWrxqmKc6oDQ0VO72ZmhJYN5xA5PuZT5aq4Cs+n1z4P1mrTx5ogroonrH9qbjjeD0frmCNyptpu9bNnT9Umqeqr4sJ1sanI0QPFVTmpJrYfRH5o+WZa1YG4anKjrtaiQBrs9PrDNK3DFizdOLxOrcfrRF5e+0GIeF5zjDXN5wPikKeaPz3cJqK2VeicdvvcNp/r7iPitmg+xLs9Xm+FH0RoQ2099eahZYP6AG3o2HoZFw46hugz07VO5FHbl/oHeD69drHttrbm+hS9+dMbE7avc8Ptr9D1VKF16Fqcmj+9G1PQ8smUPe4DtMN5MbW+wvWxqcgBfHyIiVb9HqtBJ7g/4lcwETWtOoxaE78VDxDvkz6M0dscemktKDQ8IJ4bOYLWzXSmtQ5Hbq4IvgEC1lHNqxZoS+30ej3dfaLzXdeB+0HnrsZrneofHgy8Jm5P73BRdN3CZtTDvmq72v4UOh4Mephpm+wL1zHtAOyT+lb96sKG8eyHpi/xz5Q92g/uYa3x9PkzRWv+VL5FOvOjfdoF3KYWvgfTd95npnM8e/NH83s5Hw/3T8se4D7QudVbX+E62Vzk3CQ60XtxBAtnZDML74ONoXWY6V1mCDeBC8pw+4CYae1RYV9chMj58M6dw9tXr47fXz98eLzG50nXjx4drxU/fP1xaQhh//g+EG4nvRvcsB8uQuS8fvDg8PG9e4c3z58fBcqnT56c9PnZs2eHj+7ePXz+9Kk3FUK4xfBnmYic2wt/rvKfuMI+uQiRAz65f79+IrPw+vcvXhw+e/z4+D2EEEIIt4+LETkhhBBCCGsSkRNCCCGEXRKRE0IIIYRdEpETQgghhF0SkRNCCCGEXRKRE0IIIYRdEpETQgghhF0SkRNCCCGEXRKRE0IIIYRdEpETQgghhF0SkRNCCCGEXRKRE0IIIYRdEpETQgghhF0SkRNCCCGEXRKRE0IIIYRdEpETQgghhF0SkRNCCCGEXRKRE0IIIYRdEpETQgghhF0SkRNCCCGEXRKRE0IIIYRdEpETQgghhF0SkRNCCCGEXRKRE0IIIYRdEpETQgghhF0SkRNCCCGEXRKRE0IIIYRdEpETQgghhF0SkRNCCCGEXRKRE0IIIYRdEpETQgghhF0SkRNCCCGEXRKRE0IIIYRdEpETQgghhF0SkRNCCCGEXRKRE0IIIYRdEpETQgghhF0SkRNCCCGEXVKKnO//6C8Pf/z1+++FMMaP/+qvj/6CD0f4u7//9TH/n/zZ9zwp7Iw//4sfHcf6Z3/zt54UQgjhDHxB5Li40YADOfSJyBkHfZ6aUyN5roWInBBC2Jb3RA6f4PiBi+sqPpzObRU5nFM9ATOS55qIyAkhhG15T+Twic0//OM/afS7g1ipftLScnyi0UoHXgfKTMGDgkFB/d6m1smybpsfOp7uhyz9wYB6SfUkx/uJQF/chMhxWxz3sfpH7XU/KZ6mfaZ4YVD/kV6eVnzLNs4BrdPH1HEfKKwHftE8Po+0DsyBSuT43NA1wvyah3ZrX6q54/73teVzuKojhBCunXcih5tedeA4vrn7RjmVDvwQYei17wcfA/F4Bh4MrTY1jx86nt7qG0WNi5xWfvpiS5FTiUBvu+Vj9scPRw0cu6k+exvVmFd5WvazfM82r6/nb8/LMJWOQJHSmkcIFDmt+cg6qnTgcQjan1bbbLc1Pgh+IxJCCNfMIpHj6OED/KB39DDipqp1VHfZlX1sB59uQwUPDa2DBwLjvA5vl3XonbH2ZarvbueWIoe2af/ZHxx8evgRHyu9duHHPkz5AFAoVGNNPI+ON6H9yFPZxnTa5v53fLyBt0u7tH/abjWXNQ7+4rWOO/3Ieqv56nkA5zBFjLftc4z2V37sjVkIIVwbXxA5cw7b6s66Fa+bZ+sQ5Gbtj9YBy1TBDwW3h+iBSLTfekh6oF943brjbfWt8gno+b0qMxqq+lTQVLT8r+Uqe104VHa7P1zAVHieanwZWrZVfWKZagxH5pnbBaZ85Hl6T1MoaqrxYn+qANtbbRMfKzJVLoQQrpF3Ikc3P9/8mUb8brK1cVaHHeJaQqA6kEjv8NE7XeCHIes7ReQgAH53HxHv25SveodL5b/RUNVXHZpKy/9TB7j3qYpnoN8qoeB4Hh9XDa0DvuqT26KMzDO3C0z5yPP0RA7LVePVEzlIa7VNWmM1VS6EEK6RRf+7yjd53bBbVIcAAg8a3Xyrg49tuKDp4WVog9bBPuOzdQAorEMPTfWHi5wpX215uNC2qv9Ic9uAj1Vl7xy/8cB2v1R4nkqwKJVtVRntj+NzpsLtAtq/ai6rH3tCSHGfAZ9fFd62jw/tV5+wrV69IYRwbSx6Tw43xCqA3t0wD5ZWHb1NlpuzBz9YPPiTnCr4QeqBdrXuwHko+iHUaxOMHHZr0fMRafmYPqzs9UN0ZPy1nZag8Dw9+1sCbK7IAS0f9ASaC5LWPNI8rbnh81VFDvD8DFNzmPW25jBCCCHsiS+IHFBtko6mYXNlGW601UHnh4q307pDV/wA0gOgOgSru1Xf5PWwAm6XCy+9K0fQQ9pFDvC21FfVwXxu1B4Exw9f9XFlr4scMDX+OgYtkVPlqcaY9Va2LRE5oDfPRkSOxiHAjqk8bmeVn2gZtwW4/31t+Rzecv6FEMJWlCJnr/QOjdvAh3fuHN6+enX8/vrhw+M1Pi/l+s0HHxy/h3VQoeMiKIQQbgMRObeI1w8eHD6+d+/w5vnzo8D49MmTi/p8+/KlmxxWAE9p/GlkCCHcBiJybhmf3L9/FBS9Jyo3eR3WwX+O6v00F0IIe+VWiZwQQggh3B4ickIIIYSwSyJyQgghhLBLInJCCCGEsEsickIIIYSwSyJyQgghhLBLInJCCCGEsEsicib45nd+fPj5L3/l0bcC9PuP7n7rXfjuD595lhBCCOFi2b3IefHb321+OEMc/OSnv/DoqwP92Np3IYQQwlpsLnK++o0fvPdkQMWApxFc44kK05BPQR2ahrweX9XbQ59i+JOcnj2o39ucI3jcByz75a99+50tbMP9sDYjIgd2nduOEEIIYQmbihwIAz3wcUDy2tP0Gk9jcKhrmgoPihqAMnronvokB/W5yJmyZ+mTHPeB+gegTbQNRoWFiqa5wst/rqrKROSEEEK4VDYXOS2qNMa5UHHh4U9PFC87F28LeJ2e5xSRMwX7SLGzJRAzN9FuCCGEsIRdiBwFebUuLzuXqi2v0/OcS+Swby7kepzyJMdBnyNyQgghXAubixwVAzhoebDjUw9QFQo9UVGJmt713KcgLmBAzx6A70xH3lFR0vMPfzoCc+o8BQgktcfbpB2niMgQQgjhXGwqcgD/AS2C/1sOfdKAfB5PMcFrHLI8aDU4+jTDBUsLPjHRwMO8Zw/Rfs4RVZV/tI8Uf7w+N2qP+w7+8DEMIYQQLoXNRU7YDxBAcwRcCCGEsCWbiZwP79w5vH316vj99cOHx2t83tT1mw8+OH6vOIutjx4dr1ssanOizhBCCOE2s5nIef3gweHje/cOb54/Px7Qnz55cqOfb1++dBPfsbatnz17dvjo7t3D50+felPvmNvmSJ0hhBDCbWYzkQM+uX//eEB/4YnEDV33WNvW3794cfjs8ePj9xZz2xypM4QQQritbCpyQgghhBC2IiInhBBCCLskIieEEEIIuyQiJ4SwCvpuqxBCuAQicibwtxCvRV6id156/vW3a0/BlyHqix31hYx8MzdfINlre6/Mfemlv+ByLfh37CK4ToN+nDOml8ptXI9rsdYfYD5lvWMuzi2j7F7k+J9g2AK+lbiCg8WJc8rghRr9sxoO5sPU3whTsMg5Rv7nNPxveWHMW+1eOv6nSbbiXO3OGeNzc0m2zGHuzcAlMne9hy+yhsghS9b7qWO4ucjRP7GAA0HFgKcRXOufWXCn61010ugQja/q7aF/rsEHpWcP74A0aB/1zySwninYD7XJfXAu1IfuB+0rvrMvHEeUZXm/sz7nnWLPN3M27kossU9ARQ6+V+2OjrGidz3wm5bXNPUf/azz0oW2ri/kY7qWYfCxbuFrbNS3xDc9neP0Pa/pX7W35VuP9/mG7z4ntR8+7kvQvlT2ejr9gDy8g8anju0I6h/tI32g6ep7nVvcR3U81Vb1D/vBOcXypGUP0T0R9apNmubzeQS07XO5NX9gM4Lua9qmrz2mMb5VL2idbUDXkJ5fU7A99E/3XKK2eps9e7z/OpbuA84PnQOteoGvd+C2sw4tjzxz9xayqcjhIiBcwFWaXtOxmqaO0klRDUrl7FGqQZmyB997CxLp2vcR0AfdIFB2pF86mTWMtt1acCivafiu1/oERMeD+KGzFmiz5Re01epPBeqp7GMdTPe+K1z4c9C5xc2jSvNr2ONjQHxOYkz0uprnU6DvPrbVIdajardas9ovzY98Xh5UPkecjqfm8U3U1/QpVLYA95Vec3x0P3NfV/i+gD74OmW6j5/OJdSj63PEP8jP+rg2puxBfq0Hdei+oWl+PYL7GPTmD9pw+9hvr0vTUIePn/pL2+jNQz+/puA4cS2zLm/fx6tlj+/rqKc1R/zabXd/gWq9A18jfo1x0v1qDpuLnBZVGuN803NH8cBkULzsXLwt4HV6HnxvDQjKcvDnTOZqkCufrQ36UvlvpG3ehbn/zknPp765TMGN2mHfOe/wWS3oJfhcUqp5pXFur4+R3hV7Wq/dFtxgPVQ+a9FqV+2r+qXtTZXXOK+HeB84rmtQ2QKbvT3tC8vo+Fb1OO4bBJ2bXkfVjqbRX15n5R+vm3Fejvb4Puq06ptDtS7dJp0/np824tP7gUCfuf98zmJf0nKa1ju/pmitH7cTQX3dsqfyL/dU76PHuS1VXZ6HqL+qPIjrzZUeuxA5CvJqXV52LlVbXqfnqSbDqfiiAZXPHJ/MDCP2IQ8WPTc7XYCjbaO8230u4PfWWPu8GKGqDz6h75DGca/yLsHnklLNK43zOdLrr9oOeu22UF8spdWu+lP74X5ula/6znms16Qnjk+lssX74bCMjm9Vj+N9dLyOqh1NY10j/vG6Gdeyx/dRp1XfHFy0uN99/nj9tHFq/3D/6Vr0deLrVJlqx3H7SW+8evZUbW8hcgDzt8r15kqPzUWOdhCGa8d04NV5vhjUUT4ppq5VtY5QDUrPHqALCXnnqvMK1KcT1204B3oQujDySQd79A5N/Vz5nAJoTarFQXobSw/YqHNNx9LrrDYW5O/ZVeF+Qb20wdvQut0eT9M56te68SHebWgxmq+Frx0FffU+qZ1Ax0epfK59xnd/wlHVoyC/+38ELaP29nxH+3UfrPrkIH8vn6fpte8vfoc/5R+vG0zZgzZ1fDEu3Ffc17250sJ9PDV/cK3pOv/cVkXHCWg5X2vqV3z2zqspWj7pjVfPHvcP8uo4+JiorW5L1Q/Po6Atb9/TlrCpyAGYRHya4A7TJw06ORlHB/EaA8PFqMFBO0xrOdjBAHm9XHw9e4j2s7Uw5sDF3+vnOWBb6I9vGO4jMuUf30DXAHVxfCqqBTeK9lE3A+0n4Phov3A9t231mdYPtF0E9lnjAceGa8znTmWTpo/itiKMjKvPHQQfv9YBqWuL9bBNr1PTdK9AOfjGBUjLnlPmrPZVx7Lau9hnfKe4Zbzb28LHmuuW8bzmvkgf+9yiHaTlH28PQf3k6b6PeJvE/TPSdwf1+Z7fmz+cF5U9QO1BgM/UTrTla9HLqV+9j1pmCh8P94+n63xu2QO8//wEPkdYp+/zPtd0DXhZQl9U9ATmFJuLnLAMTIilg3xpoC8+wU8Fi6jlH7TlG10Ic8Dm7odIWAceiucAdbtQ6TEnb1iX1jyYO4bOZiIHfz377atXx+/+17Rv4vrNBx8cv1ecxdZHj47XS1D1fMpgr8Wp/un5/rZzqm/Xvj7HWF1aH6eu4YPqiUBYj95NyqmMitMlT/xvimtbQ73rX//X/368/v6XvnL0Pa95Zp56k7qZyHn94MHh43v3Dm+ePz924NMnT2708+3Ll27iO9a29bNnzw4f3b17+PzpU2/qKjnVPz3f33ZO9e3an+cYq0vr49TnOXwQ/oD+zBHGuLY1NPdzzTNzM5EDPrl//9iBlqLb+rrH2ra+/c1vDp89fnz8vgdO9U9oc6pv174+B5fWx6nrEC6Na1tDc69xZn7+/0XPqWwqckIIIYQQtiIiJ4QQQgi7JCInhBBCCLskIieEEEIIuyQiJ4QQQgi7JCInhBBCCLskIieEEEIIuyQiJ4QQQgi7JCInhBBCCLskIieEEEIIuyQiJ4QQQgi7JCInhBBCCLskIieEEEIIuyQiJ4QQQgi7JCInhBBCCLskIieEEEIIuyQiJ4QQQgi7JCInhBBCCLskIieEEEIIuyQiJ4QQQgi7JCInhBBCCLskIieEEEIIuyQiJ4QQQgi7JCInhBBCCLskIieEEEIIuyQiJ4QQQgi7JCInhBBCCLskIieEEEIIuyQiJ4QQQgi7JCInhBBCCLskIieEEEIIuyQiJ4QQQgi7JCInhBBCCLskIieEEEIIuyQiJ4QQQgi7JCInhBBCCLskIieEEEIIuyQiJ4QQQgi7pBQ53//RXx7++Ov33wthjB//1V8f/QUfjvB3f//rY/4/+bPvedJFwzmC/p4T96dfb8lNtn1TYF6iz5inIYRwbXxB5Li40ZCNbpq5B+ElihzY8w//+E8e/R6XJHJgK+LOTdW2s5UtWxGRE0K4Zt4TOTy4/MDlRufx4XQuTeRQ0E6JnK2YEhYUFVsIi0uyZSsickII18x7Iqd1wPEgVqqftLQcD4RWOvA6Rp4K/Plf/Oi9MooeMlWdLOu2/exv/lZq+aLtvsHTHwyol1QHofcTgb7YWuRUthCPR161j/7Dpz/J0X7rGKlvNB/zVv5SPF2ve+PtY6TzAONN23iIs35eM+i4uC3KGrbo2HBOajlfP47a7vNJ69U6fW5rHbCzEjkj7WhfPA3B5wXwte22ue1VHSGEoLwTOdyIRzYO32wYuOFNpQPf0EY2Lj+AGIjHM3CzbLWpeSoRoOmtvlWHcC8/fbGlyHHxxkCfe7yKHA2opyVyqsA8lS9cZDjuzxGRU7UzZQfiWmNfte2saQuDz/fe2vCyLN9LZyAj68PjEXrtoM7KN0wj3lcGCrve/AohhBaLRI7jj+l7hwHQg5ObmNbhd3Cgso/t4NNtqOAmrnXwYPODnni7rIOHFNC+TPXd7dxS5LgwqdC+AB0rHRevSw8hz0Nf8CCrfNfyl/vTr92fgGOk9moeFRa9pyP6lAV4285attBPbHdqjrAOtYu+RxpgG/S92orv1Zr0sV/SDtB1StQv2o6XYVtMZzugmk8hhKB8QeS0NtKK6g6tFa8bo29gxA9ORQ9RD6ynuhNVqgNH+62brQf6hdetw7HVt8onoOf3qsxoqOqr+ue+ZrwfdF6fj1XVbxcJXjeoyime7teVsND+eUB+t8vxpyuniBxvf8QWzlMe6FW9CseiChwfbZNQJKiAcZ9onqXtVOuSAe1O+bU1B1s2hxACeSdydCP1A5xpxO/oWptwdUgjrrWp+cGp9ESOb3K+qbK+U0QOAuB39xHxvk35qrWBg8p/o6Gqj1T9JLxm/1r2+Vh5v4EfQl43qMopnu7X7k+g/fLQO9DZJ4oLz+dtO2vZsqbIoa28PpfI6bXj61EDfDrl19YcbNkcQghk0f+u0o0P6J1vC9249ZDlZqgbuYoQsmRD8zK0Qetgn/E5dZgA1qFCTP3hG/aUr1ob+Fa4fbTtHCKHbanv2F7rgPN6/boaM++T43aBqh728RSRs8SWuSJnyi7A8i2RU61JnavV3K7wOoDPFUfbJu4XptMnoJpPIYSgLHpPTu/ODHAzrAI3v1YdvQ2Um5oHbHx6EHjgJthqE4F944bsgXbpxq+hdRD22gQtEXEOWn2jLUDjkL9lnx9c3m/gB1XlO45pa9y9Xr/2cUd61Q7bAm4X8fwMrbF11rJlrsgBXj9DS7wCF2C9uer1ePB0bcf9ooH5Wmub9bb2FJ+XIYSgfEHkgOowdHwjYpnepqQbH/B2Ru7IfDPUO7tqM9U69fDQPH6X7Xb5oaZ3ngh6QFUHobelvmqJiHPhfUNQdNzWFjmaj2V53Rp7r9evgfaJ9fgYq/2VXcDHFXC+gaptZw1blogcoG0g6LxmXE/kaBztr/LMbQdUa9PzuMjydel+9PELIQSnFDl7xQ+P28aHd+4c3r56dfz++uHD4zU+t7z+8b+4exwHXv/s3/z7fz7Q/tOfHt588MExb7i9qNAJIYRTici5Rbx+8ODw8b17hzfPnx8FxqdPnmz6+b//9L8dP//Hv/zX5efbly/d5HAL4VOf27pOQwjrEZFzy/jk/v2joPAnLFtd/6//8B+P13iig7HAp6aH24v+lOk/j4YQwhJulcgJIYQQwu0hIieEEEIIuyQiJ4QQQgi7JCInhBBCCLskIieEEEIIuyQiJ4QQQgi7JCInhBB2yM9/+avDN7/zY48OZwY+h+/3zpe/9m2PukiuSuR894fPDj/56S88+j3g+K9+4wceXcZdG39091tHHyDgO3jx29+9i18C66omLHyNNLY1B9SHxc46YOeW9MYbds2xhz7QfqhvOCdRL657bZ8btE27ruGQ2/JAGJnPW9rTg+ua4zgXlKnWdI8R/yyBc/Km5uKW6xF9XLIXX8NaVZbu6WuvL9Q15e+rEjmj6KSmQxm3poO3BpsWNiIE3cBGBnqK3gLrpbWAv2ETbFt705yi5w8szDn9gZ85Z3jwELShCx3j0mp3C+BzvQmg0Dw3W7SxJkvshV9vYu+4iXaX+GeEc9XbY+56D/+8f049TGhxE76eErGbiRy9wwR8gqB3KppHDwu9q6mcr3UhXTuNjZ5po3cTvKPhAY0w5ci10Lsp39xgA3zhqp+HestW5GVa6+6u55dWWmu8ABU77HV7AO1dcjcwRdUegV2jbVZiiSITqMjB9167js5L+pfzjeOl828K2OG2Vmh7o+icRB/dXg1aN+cHbGN/Oae1rM9zijOm+5z1vQOf1b7Qoup/zx61pcrTs5X9BszDOeP+q1gicnr2jOD+cX+r3Zxzvb2AeL20E3CP1zWk+z7CnDEm3IfAyPrSuY7AsYJdCPAnPukT7WvLB9ou66/OKPcPUHvmjqX2w8dExxTtsm2NZ1C/9+zxcn4jzvhqPmu67jFA53PlI9jcmxubiRzgBuohwQlA/BrAER6Ha62Xk1FBOTjcy/aAbTpIKOsTpUInuobRtt1HI3CCqC85kdxuxFdtVHGkSvPx8espuJhGBcco6F9rnObe1en8VHRDYJ1z6tXxAbpI8cn5S/8gvdoYlGptVLQ2ih6aX+0jvfo4zrTf86K+qm86N9Q/Pn+RrzXeLdwGpWVPL35qfeGa/VExqvW15mar3RYj9kxR5Xc7fL5pGsr31o3Sm0t+iCJvVW8Pr6O3vvDd7dHy+I58yE87mR/XU/sh2mP+am+p/OM+H53r7ivU7WNEtD/Ax1aZsqfqg+LzCMBOP2tdIJFqL5ya45uKHF3gQA2rjPS4yvmeB+hEVQf6BO6hGyup2lqbauJM4WV0IsFmF1y+8JmvRZU2Grc1vTGGfb6x9Kg2IsB+Ip2HbOXTFrxz08A6few8rkW1NtaC/WRweuPe8iFp9U3r1L55Wz73R/A6lJY9rfiR9dVqD/VVc0BptdtixJ4pKjuAxnsev7mrxtzLAF+vzIPy3g+EuXPc+95bX/j09rQvnl/jqr55nF87VbrbNDrXvQ9eVueJ+6i3l0zZU/VBqebz1B7hc9rLV+JU2VTkgJaSrZzjcZXzPQ/odXgUtw9UbTm+2Bnc7grkwYRDO1zkI/hG74vQ+1HR61uVNhq3Je4HBT6Ya19VH3zLsUQa/VzlbdGbnz52HtfCbyDOReVHv1aqdaS0+qZ16rr3tpb02+tQWva04kfWV6s9nwdVvla7LUbsmaKyA3C++z6sa4L5Khuqels+qObZEvwA760v74fj+TWustXj/Nqp0v2GfXSuu197+N7l46tM2VP1Qanmc2u+ALetKo+yvf5uLnJotDvDF2fl6CrOJybq7nV4FK+nGtC10UNzVBiB3kTAp/u6openShsZrx7wrW9Ap1LZSXoLqQcfUQOUV+HpdY7OO5Rr+araQKuFXYH8mg/lfM7C/p6fHD9s/Bpov9VfwH3ktPqmbejc8nmGfN7HKdx+pWWP7jNI59wdWV+tdPVbtSeClj0tRuyZolceNnu67lsAc6wacy/HOObFd/UJvlf1zMH3mKn15fmVKj/jtB/A5ymo+q94uq81fB+d68jbmjeI13p617rnjdij41elV/MZ9freiXFAvK47xnv5qTm/ucgBrcmrTz50ssFR/mREO4X6NN7Tl4A2vd0t0P73FhzhJETgBOI1fez90Ho13sshn6f5ZlbVOQVtrubAUlCXLyjllPlQ+Qa+ZhwXIf080i+dswjclLQdPtVjWyP16pj5xgHY1ig6vxgcrjn1BfByvkF6OsePfcC1ts+55+u9N+5Kbz737CGaprTWV+U7rVPLsX2mj9jTomXPFD3/ENTthzfQMrQd6Jyu7NF01M05T7xs1XYPriswsr4qexHPOef51V4to3308WBZt6kqq/OA30d94OPJ+eNtVvNDy+q+M2WP7ouj693LIei8U1tYj9rUmpPkRkTONcANNqwPfDu6YY+Cyd8aL7Tlm3XYBxjXtedS2A/YE/SwDfujuplTNhM5H965c3j76tXx++uHD4/X+Dzr9aNHx+u5tNToJXIjfu1cv/ngg+P3sA8ubX7h+v98/b8c1+b3v/SVL6Rn/i3jEse5dz1nnKcOwXC9jNzkbCZyXj94cPj43r3Dm+fPjxP20ydPzvr52bNnh4/u3j18/vSpm7Irtvbr1Ofbly/dxHDFXNr8mvrM/FtGxjnslc1EDvjk/v3jBO0p9DWv3/7mN4fPHj8+ft8zW/t16jrsi0ubX1PXYRkZ57BHNhU5IYQQQghbEZETQgghhF0SkRNCCCGEXRKRE0IIIYRdEpETwpVSvcQrnBe8XmLqv6yGEC6HTUUO37SIT7y7gO8vYHzvrYU99G2UDt+QuORdCXwrI99Y6dDu6rDhWxrdJr6DZ4k9p1C9KdLtp806DsxziRt7z4e9NMXfPKxjU72plPgbOt23QN/yubb/qvZ6VG8OXgP6qFoDewNjPjqvtgT+931mCTqnQ9gLm4ocbrR8C6UuTCywpSKH9BZ6L60FNm7aVW3iOCwqm9EWD5LW23aX2HMKLaHmdvgmzjGr+nmTtPwKRl4QpbgP9Fq/U5wTtEGhwVe8a5qWRblL8CFsaPntFNyHYTvWfqvvmnWFcNNsKnIADwIcArrp8zEw7yR8ofnfr6hoxYNWGuus7nBxMGEDQXxVviVy/ICtylZx56Ql1NwOFzmg8g1BnVWZc9Nrs5dWQR9U5dw/eq0ix9Oqujxuie/8CdKcpznARQ6f1CFw3vKatqFfc9ce1zLtw3eff9oPXzMVtJX2qO1E/ePtAW0T9Yz6T5/4zRkz7luA5dmm2s/+KL00HRP0Wf3f8gHHRMt6vcDHErjt7FdVPoRLYnOR04ILk1BgACw6XUwukEi1OEmVhoWqm5xfT9ESOd5WtSl6nh58mlKFUWBryw6tr8rT88uSg/pU1nyKA1RAOzpOqFuv/UkO/YDvlQ0+5nN9p22Q6iDv4SIHVPZ6v0nL9943xvVEoKdV9Tqwnz7goas2aR0+F1yU6qHdw/cb3pCNwjWGttTXPnZ+rX3RcUd5bR/l6Ftf536NfCxbzSdQjaXvddWcCeESuSiRo4tINyQ9hBiqhVjFEU+rFmkV18MXPvG2RjeSm8DtqGy9NHo29tJa0AdVWR5QCH4IYa7onCSteeS+nos/xWEYOahJJXKA2uZiQH2AMFVe47we4n1AqHzmqP2sT+PcR1onbNG0au1WYF64rdVcaVH5BvZ6nQjqW43Xuef1oV+M87HzOC/r1604oPGtPCFcGlchckY3lN7C87TqIKrierREjtfhbbfiWvjmrOFU3I5RX98U8G11yAK/cx/FfaBoGnyjbfvhoXOh8mMVNwdfI0toiRz1nfbZfdoqX/kQcS2Rs9QXUyJH651az6M2jOZrUfnG/er0fOf1bSVydL9r5Qnh0rgKkYPvI5t7b+FVab55VRtEjxGRgzyjh8JN4Ha4T3pQfPU267Vxe5VeWg8v1ztQ/N846HyB73TOalmk+VyZ+3MV8KdJc2mJFABbvE++LtF+Vd79BFAX8+K7P42o6pmiJ3L0sGe6zk33tV+3QP2nzPHKN6A3lmob+ubzTn2H+tlGJZ7cJ4pft+IIfTpnnwzhJrkIkYOFqY9rsan4kwosen2CoYvan25wQ2g9ASFetre4K1oiR+ttbWRz2zoH2KzURv4sOGobyo8eFGvQO6Cn7tpb+LzSOUL/ILBdzk2do5wDHHe9a2aeyrYlIsfnrLbXQ21p2YS6q7HXn4tZD9v0OjVN1x/Koa/aX/8Z2u1xtO+oG+VRL8eCIsdt5fj4WFdrt4X7b2Tcqv1H+1ilc575HtLzHW1j3W4r6/T1Tn9wzH08tCyBz0b6HsKlcBEi51ppiZwRqsPk2sCmOHLArkVvc4U/t7QlhNtI70YjhEvkIkTOh3fuHN6+enX8/vrhw+M1Pm/q+s0HHxy/T8G7rdbTmgredfYO7BDW5NLW19T16Pq7dK7N773r//nv/vPx+vtf+spx/3qX/ujRMT2ES+UiRM7rBw8OH9+7d3jz/Plx4Xz65MmNfr59+dJNDOFqubT1NfW5l/V3bX6f+/nZs2eHj+7ePXz+9Kl3PYSL4SJEDvjk/v3jwmndSWx9HcKeuLT1NXW9F67N73Ovf//ixeHzx4+P30O4RC5G5IQQQgghrElETgghhBB2SUROCCGEEHZJRE4IIYQQdklETgghhBB2SUROCCGEEHbJ/wOgxUbChoeNNQAAAABJRU5ErkJggg==>

[image5]: <data:image/png;base64,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>

[image6]: <data:image/png;base64,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+CiUF3SekT5HMsyvhx56SCdvnQ0+CmWdzjPS56YiGWp+o+HGG2+0i/aEPi4zUZ3G0826Mt76482biD6RX1n/miTmKKZr2vnmheuiPfVSt/XQ+voMcCOtbLuVZSytEwa+V+x+GvKPyEqTtv+Zz3ymq/10s66Mt/548yaiz3tV1j88iDuK53Cd51boe/X6/F4WuC7atWj9bpKhtLqcp+VrIt8jLX0dzyZDjds7Z36+/uq7kPobriO33nprtdzO82z5pz/96fiRQI189atfrdlWuO6ZZ55Zndfsg6l2WuPJ133iwX79z1uwYEF1ma997WvV8maSZVF89tQ3FC6nCwD/wWo/hI444ohqub4F4mlaj64Ll2+2Dcsv8+1vf7tm2SeffLLhNvSoL/8lBnn7298e3X333fG4lvvd735XXUdfivDCbejD336Z/fbbr1ouE9U3lObX8Vp6UINNhvarbPrC+KJFi+JxlevBkZ5fzj7K529/+1vDIDQqayZcNrn6isf1xI9w3t577x1deuml8bjdfjit8d///vdN58m1115bV65jGY+WcSgDe+obCpf74he/WDOtb4Xoq6ZywgknxMnQC5fTePiYPLtvO+2F5cmNvYbzfIKTiZKh3Ya+IebHw3JPyX+fffapTusq2T74oZk0H9Qgdn91bDKUcLrZeDitv42+GmQ1Kmvk5z//ed2y4b6sZvMmqvuvfvWrmnl2mb///e91ZZbmO5SBPfV19J9E2PGVDPViHWq2nbC82TJes/m23E9/5StfiQ455JCG8yZKhuFX9b773e/W9ZXTTjstfqxfqFk9JqLl4kinxO6vTqNkqO8dXnXVVfF4OM8u56f1t9FgNSprRK8mzRpRo200mzdR3fWd6XCerX+z4wgly6D47KmvowcX6KElnpKhffqS307y85jRI488UlNux/303Llzq88wtPM9W+6nTz311GjevHkN502UDH39JPyv0f/Vb7do3A4hO91Msm5q7P7qNEqGorIPfOAD8Ze+w7KQn9YlvQ/geOz6zfz5z3+uW9ZP62/4MYfwx2+arWPH/fSOHTtq5tllJsJj/0tlwsf+6wnWuoHi2X+TxU83K7fjrUx7ttxPN3oIq5/Wley3vvWtmvIwGV588cXVeXqf3dZf9wqUUMdj992MlnMpsvurM14ytOWa1iuH6PI5nB+O33PPPXXrii0b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>