Ler Livro GCC  (todos) SABADO  
→ Preprocessor: defines, includes e macros  
→ Compile C: ver o que o codigo do Tiny ja tem e implementar outras coisas relevantes (anotar coisas para acrescentar)  
→ Ler livro do dragão 4-12: estrutura geral do compiler; Capitulo 3 e 4 (optional)  
→ Entender lexer do tiny  
→ Entender parser do tiny

→ overview do compiler  
→ powerpoint

→ refactor assembler  
→ definir dígitos, registos,  number, hexadecimal, etc….

Mariana  
Mendes  
Bruno  
Pedro  
Marco  
Rui  
Vasco  
Tiago  
Marco estrangeiro

**O que temos de fazer:**  
tabela de opcodes/statements- **Mendes**  
lexer do assembler- **Bruno**  
parser do assembler- **Tiago**  
code generator do assembler- **Mariana**  
lexer do compilador- **Pedro**  
main que junta e inicializa tudo- **Marco**  
ficheiro teste de assembly que teste maior parte das coisas e que possamos comparar- **Vasco**  
makefile para que depois tenhamos os ficheiros hexa- **Vasco**  
modificar o ficheiro .m4- **Rui**

**MARIANA**

C Compiler  
Tokens that the compiler should recognize to use C language 

**LEXER LEVEL**

int, char, float, double, void  
if, else, switch, case, default  
for, while, do  
break, return  
struct, union, enum  
typedef, sizeof  
static, extern, const, volatile  
signed, unsigned, long, short  
inline, bool

Handle comments (`//`, `/* */`)

Ignore whitespace

Support preprocessor tokens (`#`): \#define (eg: \#define ARRAY\_SIZE 512\)

\#undef (to change previous definition) use case: \# define..; \#undef..; \#define

\#include (insert file name to use it), ways to use it: \#include \<iostream.h\> for system header files **(vamos usar??? Como iriamos buscar as bibliotecas?)**

\#include “scanner.h” for user header files      “ ” quotes means compiler is searching for files in current working directory

**Operators**  
Arithmetic: \+, \-, \*, /, %, \++, \- \-  
Assignment: \=, \+=, \-=, \*=, /=, %=, &=, |=, ^=, \<\<=, \>\>=  
Comparison: \==, \!=, \<, \>, \<=, \>=  
Logical: &&,  ||,  \!  
Bitwise: &, |, ^, \~, \<\<, \>\>  
Pointer: \*, &, \-\>   
Comments:   
Other:   
. Member access operator: Used to access a member of a struct or union through a value  
, Separator OR comma operator  
; End of statement  
: Case label, bitfield  
? : ternary  
( ) Calls, grouping, casts, control conditions  
{ } Block/scope, struct body, initializer  
\[ \] Array declaration and indexing

**PARSER LEVEL (bison/yacc is shift-reduce)**

Basic Types- int, char, float, double, void; Modifiers- signed, unsigned, short, long  
Arrays- int arr\[10\]; int matrix\[5\]\[5\];  
Functions- Declaration: int add(int a, int b); Definition: int add(int a, int b) {…}; Pointers: int (\*fp)(int, int);  
Pointers- Pointers can chain arbitrarily. int \*p; int \*\*pp;  
Struct-  
struct Point {  
int x;  
int y;  
};  
Union (accepts different types)-  
union Data {  
int i;  
float f;  
};  
Enum- enum Color { RED, GREEN, BLUE };  
MUST IMPLEMENT PRECEDENCE AND ASSOCIATIVITY for expressions  
Quando se pretende definir um token e simultaneamente especificar a sua precedência e associatividade usa-se as declarações %left, %right ou %nonassoc  
**A precedência relativa de diferentes operadores é controlado pela ordem em que são declarados** A primeira declaração %left ou %right num ficheiro declara os operadores de menor precedência, e a próxima declaração declara os operadores com precedência ligeiramente superior aos anteriores  
e assim sucessivamente  
Declara-se operadores de igual precedencia em grupo, ou seja na mesma lista depois de %left/right  
Para precedência dependente do contexto usa-se o modificador de regras %prec para declarar a precedência de uma regra

![][image1]

if (condition) statement;  
else statement; …..

switch (x) {  
case 1: break;  
default: break;  
}

while (...)  
do ... while (...);  
for (init; cond; inc)

return;  
break;

**If you're writing a small C compiler, implement in this order:**

1. **Expressions only**   
2. **Simple statements**  
3. **Functions**  
4. **Global variables**  
5. **Pointers**  
6. **Arrays**  
7. **Structs**  
8. **Typedef**  
9. **Full declaration grammar**  
10. **Preprocessor**

**FOR FUTURE.. (análise semântica)**

 identifiers (names for variables, functions, etc.) must follow strict rules  
we cannot use:  
spaces  
this symbols: \! @ \# $ % ^ & \* ( ) \- \+ \= { } \[ \] | \\ : ; " ' \< \> , . ? / \~ \`  
starting with a digit  
C keywords

**ASSEMBLER**

Passos: Leitura do ficheiro .asm → pré processamento das macros → Passo 1 para construção da tabela de símbolos → Passo 2 para geração do código em hexa → output

Diretivas que vamos implementar:   
**.equ**  
**.org**  
**.word**  
**.byte**

**Pré-processamento** (Depois desta fase, o código já não tem macros.Fica apenas ISA pura \+ diretivas. ):  
Transformar pseudo-instruções e macros em instruções reais da ISA  
Podemos usar o .m4 file que já tínhamos, mas trocar os define dos registos por .equ  
EX:  
define(\`a0’ , \`r1’)  → .equ a0,    r1

Também ver como podemos alterar isto para não ter os defines ao definir que instruções definem a MACRO (se der):  
define(\`PUSH', \`ADDI sp, sp, \#-1  
SW $1, sp, \#0')

**Passo 1**  
Construção da tabela de símbolos  
.org 0x1000  → LC (location counter) \= 0x1000  
LOOP(label) → symbol\_table\["LOOP"\] \= LC  
.equ SIZE, 64 → symbol\_table\["SIZE"\] \= 64  
Instrução normal → LC+=2 (2 bytes para a próxima instrução)  
.word 5 → LC \+=4

.word LOOP \+ 4 → verificar operadores e calcular os endereços

**Passo 2**  
Geração do código  
Ignorar labels e substituí-las pelo valor que se encontra na tabela de símbolos

**Ao passar do Passo 1 para um 2 guardar uma representação intermédia para facilitar o 2º passo**

Detetar erros\!\!\! importante

MENDES Tabela de simbolos  : 

A tabela de símbolos é basicamente um array de apontadores onde cada posição pode apontar para uma struct ou para uma lista ligada de structs dependendo de haver colisões ou não. Cada struct tem o nome do símbolo, o valor/endereço e um link para a próxima struct caso haja colisão. A função hash pega no nome do símbolo e transforma num índice do array, e o % MAX\_HASH\_TABLE que o stor usa garante que nunca sai fora dos limites. Quando dois nomes diferentes produzem o mesmo hash, em vez de haver problema, simplesmente a nova struct fica ligada à anterior pelo campo link, formando essa lista ligada. Para procurar um símbolo vais à posição do array que o hash indica e depois percorres a lista comparando os nomes até encontrares o certo.  
há duas formas de implementar isto. O stor usa um array estático com tamanho MAX\_HASH\_TABLE definido à partida, o que é simples mas desperdiça memória porque está sempre alocado independentemente de quantos símbolos há. Os compiladores reais mesmo o TCC acho usam malloc por cada símbolo que aparece, alocando só o que precisas, e o próprio array de apontadores também podia ser dinâmico.  array maior significa menos colisões e listas ligadas mais curtas, tornando a pesquisa mais rápida. Com um array de tamanho 1 até funcionava, só ficava tudo numa lista ligada gigante. com malloc so se tem de ter em atenção fazer free no fim .

o stor para resolver quando ha hash maiores que o tamanho do array faz : 

sum \= abs(sum) % MAX\_HASH\_TABLE; 

mas assim vai haver bue listas ligadas juntas 

PRECISAMOS DE CODIFICAR:  
tabela de simbolos com tabela de hash  
lexer(já temos mas tem de ser modificado) e parser

**MENDES:**  
Para resolver a precedencia e associatividade ha 2 formas com o left e right e hierarquia gramatica ( os de a 2 anos fizeram assim  , misturaram com left e right tambem)  
basicamente é ter mais nao terminais numa ordem que obrigue a passar por regras de maior precedencia antes de chegar a raiz , fica mais verboso mas mais facil de ver se esta correto .   
pode se usar left e right para associatividade e para precedencia a hierarquia .

Exemplo :   
2+3\*4   
com hierarquia   
exp \-\>  exp \+ term | term  
term \-\> term \* factor | factor  
factor \-\> NUM ( tokens em maisculo)

em bison fica : 

%%  
exp    : exp PLUS term       { $$ \= $1 \+ $3; }  
       | term                { $$ \= $1; }  
       ;

term   : term MULTIPLY fator { $$ \= $1 \* $3; }  
       | fator               { $$ \= $1; }  
       ;

fator  : NUM                 { $$ \= $1; }  
       ;

a parse tree ia ficar tipo

![][image2]

com o  left seria : 

E \-\> E \+ E | E \* E | NUM 

%left PLUS      // Prioridade mais baixa  
%left MULTIPLY  // Prioridade mais alta (ganha ao PLUS)

%%  
E : E PLUS E       { $$ \= $1 \+ $3; }  
  | E MULTIPLY E   { $$ \= $1 \* $3; }  
  | NUM            { $$ \= $1; }  
  ;

o bison ve a ambiguidade na CFG e segue a regra definida em cima de   
em bison As declarações mais abaixo têm maior precedência  
Em 2 \+ 3 \* 4, quando o parser vê 2 \+ 3 e o próximo símbolo é \*, ele compara precedências

a parser tree iria ficar assim : 

![][image3]

com uma parser tree mais simples fica mais facil fazer a AST ( menos coisas para remover da parser tree ) a parser tree é mais facil usando left right .

tambem ha o %nonassoc que serve para dizer que o operador nao pode ser encadeado ( usar o mesmo operador na mesma expressao sem () mas tem o mesmo nivel de precedencia )   
ele é usado em operadores de comparação e igualdade

sem nonassoc é aceite fzer ( a \< b \< c ) o que poderia acontecer seria tipo 5 \< 100 \< 10 \- \> 1 \< 100 \- \> true  ( ta errado porque 10 nao é menor que  100\) com nonassoc da erro de sintaxe e tens de meter (5 \< 10 && 10 \< 2\)

%nonassoc LESS\_THAN EQUAL   
%precedence serve para dizer a prioridade de um token(precedencia sem associatividade) pode ser usado no \-5 porque  o \- é usado para representar numeros negativos e subtraçoes 

tipo \-2 \+ 5 , assim o \- fica associado ao 2 fica

exp \-\> exp \+ exp  
exp \-\> exp \* exp  
exp \-\> \- exp %prec UMINUS  
exp \-\> NUM

%left '+'  
%left '\*'  
%precedence UMINUS

%%  
E : E PLUS E { $$ \= $1 \+ $3; }  
| E MULTIPLY E { $$ \= $1 \* $3; }  
| MINUS E %prec UMINUS { $$ \= \-$2; }  
| NUM { $$ \= $1; }  
;  
%%

%precedence tambem é usado para resolver o problema dos if else 

if a   
	if b  
		ananas  
else c

a qual if o else esta associado , a forma de resolver isso é colocar o else associado ao ultimo if que nao tem um else . ou seja else c  tem de ser associado a if (b) 

stmt \-\> IF '(' exp ')' stmt %prec THEN  
stmt \-\> IF '(' exp ')' stmt ELSE stmt  
stmt \-\> exp ';'

%precedence THEN    , este token é so para conseguir fazer a precedencia  
%precedence ELSE    

…

stmt : IF '(' exp ')' stmt %prec THEN       
     | IF '(' exp ')' stmt ELSE stmt        
     ;

assim o parser ja sabe ao que associar o else e nao ha ambiguidade 

tokens ( simbolos terminais ):

char, short, if, goto, switch  
float, long, else, do, case  
int, union, return, typedef, break  
double, sizeof, extern, define, continue  
void, static, register, default  
const, volatile, enum, while  
struct, unsigned, signed, for

, \-- , || , /= , \>

, & , \= , &= , \>=  
/ , | , \== , % \= , \<=

, \! , \!= , \+= , \>\>  
% , ^ , |= , \-= , \<\<  
/ , \! , \=\! , \*= , :  
\++ , && , ^= , \< , ;  
\= , ( , ) , {  
| , \[ , \] , ? , \#  
\-\> , \\0 , \\n , \\t

usar %left em : ',' '||' '&&' '|' '^' '&' '\<\<' '\>\>' '+' '-' '\*' '/' '%' '.' '-\>' '\[' '\]'

usar % right em Atribuições	\=, \+=, \-=, \*=, /=, %=, &=, ^=, \`  
Ternário	?  
Unários	\!, \~, \++, \--, sizeof, & (address-of), \* (pointer)

usar %nonassoc em : '==' '\!=' '\<' '\>' '\<=' '\>='

usar %precedence em: UMINUS ← menos unário, conflito com '-' binário then ( é um token inventado para saber qual o ultimo if sem else , else  .  
DEVE SER MAIS AO MENOS ISTO .

depois no bison importa a ordem a que se coloca as coisas .

Flags de linha de comandos

Bison  
\-d  
    gera o ficheiro .tab.h com os \#define dos tokens  
    OBRIGATÓRIO se o flex precisar dos tokens do bison  
    sem isto o flex não sabe o que é TOKEN\_IF, TOKEN\_NUM, etc

\-v  
    gera ficheiro .output com todos os estados do parser  
    mostra conflitos shift/reduce em detalhe  
    o mais útil para debug de gramática

\-o ficheiro.c  
    define o nome do ficheiro de saída  
    por defeito gera parser.tab.c

\-Wall  
    ativa todos os warnings  
    conflitos, regras inacessíveis, etc

\--defines=ficheiro.h  
    igual ao \-d mas defines o nome do .h gerado

\-r all  
    no ficheiro .output mostra tudo  
    estados, itens, lookaheads, tabelas completas

\-t  
    ativa o código de trace em runtime  
    equivalente ao %define parse.trace  
    precisas de yydebug \= 1 no main()

\-g (ou \--graph)

Gera o ficheiro .dot para desenhar a Máquina de Estados.  
Usas o Graphviz (dot) para transformar em imagem e ver a lógica das transições. \- esta shit nao fica bom ( pode ajudar a fazer desenhos da AST segundo o chat)

Flex  
\-o ficheiro.c  
    define o nome do ficheiro de saída  
    por defeito gera lex.yy.c

\-d  
    modo debug  
    imprime para stderr qual regra fez match em cada token

\-v  
    mostra estatísticas do scanner  
    número de estados, tamanho das tabelas

\-C  
    comprime as tabelas do scanner  
    ficheiro gerado mais pequeno, scanner ligeiramente mais lento

\-l  
    modo compatibilidade com lex antigo  
    raramente necessário

\-f

Fast: Gera um scanner muito mais rápido mas com tabelas muito maiores (não comprime nada).

\-p

Gera um relatório de performance (onde é que o scanner perde mais tempo).

## 

## NOTAS JÁ DAS IMPLEMENTAÇÕES:

**Pedro-Lexer do compilador:**

* **Estrutura do ficheiro:**  
  - %{código C%} \<- configuração  
  - definições de regex\<-é dar nome as coisas que vamos usar tipo dizer o que é um digito  
  - %% \<-regras  
  - %% funções C auxiliares ( tipo por ex a que vê o define, includes, etc…)  
      
* **Configs:**  
  - %x INCOMMENT e INITIAL \<- é tipo o modo do lexer, ele pode estar em normal (ler codigo C) ou comentário (se tiver lido um /\* até encontrar um \*/)  
  - Sempre que tiver um INCOMMENT ingora as regras normais e só faz as regras marcadas com \<INCOMMENT\>  
  - line\_number \<- serve para saber em que linha está e incrementa quando ler um /n  
  - char pp\_name\[256\] e pp\_value\[512\]  servem para guardar informação tipo se encontrares um \#define ARRAY\_SIZE 512 o pp\_name fica com o ARRAY\_SIZE e o pp\_value fica com o 512  
  - a lista de todos os tokens, serve para identificar o que é cada um, assim quando houver um return, é devolvido o numero inteiro correspondente(no codigo está tudo bem dividido para saber qual é qual, e de que tipo são)  
* **Definições de regex: (é igual, não penso que falte nada)**  
  - digit       \[0-9\]  
  - number      {digit}+  
  - hexNumber   0\[xX\]\[0-9a-fA-F\]+  
    * `0` — começa com zero  
    * `[xX]` — seguido de x ou X  
    * `[0-9a-fA-F]+` — um ou mais dígitos hexadecimais  
  - floatNumber {digit}\*"."{digit}+(\[eE\]\[-+\]?{digit}+)?  
    * `{digit}*` — zero ou mais dígitos antes do ponto (`*` \= zero ou mais, ao contrário do `+`)  
    * `"."` — o ponto decimal obrigatório  
    * `{digit}+` — um ou mais dígitos depois do ponto  
    * `([eE][-+]?{digit}+)?` — expoente opcional: `e` ou `E`, sinal opcional, dígitos  
  - identifier  \[a-zA-Z\_\]\[a-zA-Z0-9\_\]\*  
    * `[a-zA-Z_]` — começa por letra maiúscula, minúscula, ou underscore  
    * `[a-zA-Z0-9_]*` — seguido de zero ou mais letras, dígitos ou underscore  
    * ou seja, vê que começa com uma letra depois pode ter mais letras, números, underscore até ter algo diferente a um espaço branco  
  - string      \\"(\[^"\\\\\\n\]|\\\\.|\\\\\\n)\*\\" \-\> para reconhecer tipo “hello”, “heloo\\n”, “”  
  - charlit     '(\[^'\\\\\\n\]|\\\\.)'            \-\> para reconhecer as plicas   
  - whitespace  \[ \\t\\r\]+  
  - newline     \\n  
* **REGRAS:**  
  - Tem um padrão e uma ação, se reconhecer uma sequencia de caracteres, dá return a qualquer coisa (não se meteu os logs pra já como combinado)  
  - O flex reconhece a palavra que dá mais match tipo:  
  - **KEYWORDS**  
    * escrever “integer”:  
      * “int” casa com 3 chars: i n t  
      * {identifier} casa com os 7 chars: i n t e g e r  
      * como ultrapassa  3 letras basicamente já não é o int  
    * Mas se escrever “int”  
      * o int fica certinho, por isso não é um identifier, se o programador quiser chamar uma função “int” é pedreiro máx  
  - **Preprocessador:**  
    * "\#define"\[ \\t\]+ : Se o flex encontrar um define seguido de um ou mais espaços (é o que significa \[ \\t\]+) então há um define, chama a função read pp define que depois dá um return )  
    * o mesmo para undef  
    * para include como podemos ter \#include \<xxx\> ou \#include\<xxx\> ou \#include”xxx” ou \#include “xxx” usa-se o zero ou mais (\[ \\t\]\*)   
  - **oPERADORES, literais,:**  
    * USA também o longest match para ver qual é qual  
    * A ordem de definição importa\!\!\!\!\!  
  - **Whitespace:**  
    * **é espaço branco ou trocar a linha que aumenta o line number**   
  - **Comentários:**  
    * basicamente tem dois estados tal como disse se fizer “/\*” entra no INCOMMENT e só vê as regras de INCOMENT até ver um \*/ que volta ao inicial  
    * o erro aqui é o ficheiro acabar e nao ter fechado o comentario  
  - **erro:**  
    * **qualquer token que não dê match a nenhuma regra é retornado como erro**

* **Funções auxiliares:**  
  - **Read\_pp\_define:**   
    * temos um \#define ARRAY\_SIZE \[512\]\\n  
    * Como vimos em cima vai ver o \#define e depois há varios espaços à frente, houve portanto um define salta pra esta função  
    * usamos o input() uma função do flex que lê um caractere de cada vez do ficheiro sem passar pelas regras  
    * le caractere a caractere enq não há erro, não há espaço, não há umtab, nao muda de linha  
    * cada caractere é guardado em pp\_name e guarda-se o sizeof  
    * depois até encontrar algo diferente de espaço, ou seja até encontrar um valor, consome os espaços brancos  
    * vê se há um valor, se nao é erro ou mudança de linha e guarda o valor no pp\_value  
  - **read\_pp\_Undef:**  
    * **igual ao passo 1 do de cima**

       

**Demonstração:**  
**![][image4]**

linha 1 — \#define MAX 10  
  regra "\#define"\[ \\t\]+ casa  
  chama read\_pp\_define()  
    lê 'M','A','X'       → pp\_name  \= "MAX"  
    lê '1','0'           → pp\_value \= "10"  
  devolve TOKEN\_PP\_DEFINE

linha 2 — \#include \<stdio.h\>  
  regra "\#include"\[ \\t\]\*"\<" casa  (consome até ao '\<')  
  chama read\_pp\_include\_sys()  
    lê 's','t','d','i','o','.','h'  → pp\_name \= "stdio.h"  
    lê '\>'  → para  
  devolve TOKEN\_PP\_INCLUDE\_SYS

linha 3 — linha vazia  
  '\\n' → line\_number++   ignorado

linha 4 — int x \= MAX;  
  "int"  → TOKEN\_INT  
  "x"    → TOKEN\_ID  
  "="    → TOKEN\_ASSIGN  
  "MAX"  → TOKEN\_ID     
  ";"    → TOKEN\_SEMI

**\----------------------------------------------------------------------------------------------------------------**  
**Tiago- Parser do Assembler**

**Inputs**   
Recebe o fluxo de tokens identificados pelo lexer, e o seu tipo.  
	e.g. 	ADD r1,r2  
	input	TOKEN\_ADD TOKEN\_REG TOKEN\_COMMA TOKEN\_REG  
   
**Como definir a gramática**

**Símbolos terminais-** os tokens (e.g. `TOKEN_ADD`, `TOKEN_REG`, `TOKEN_COMMA`, `TOKEN_NUMBER`)

**Símbolos não-terminais-** as regras criadas por nós (e.g. programa, linha, instrucao, operando)

**Exemplo de uma regra**

* A instrução de soma é composta por “ADD”, seguida de um registo de destino, uma vírgula, e um registo de origem.   
* O Lexer vai ler `ADD r1, r2` e dar: `TOKEN_ADD`, `TOKEN_REG`, `TOKEN_COMMA`, `TOKEN_REG`.  
* Criamos uma regra (símbolo não-terminal) add\_stmt que exige essa sequência ($2 refere-se ao token 2,e $4 ao token 4\)

![][image5]  
**Agrupar as regras**

Recursividade (uma regra que se chama a si própria) para ler o ficheiro inteiro

Isto lê-se “Um programa pode ser um programa anterior mais uma linha nova OU uma linha nova (início do programa)”  
![][image6]

Depois “Uma linha\_nova pode ser uma instrução OU…”

Por sua vez, “Uma instrução pode ser um add statement OU um sub statement OU…”  
![][image7]

e por aí fora sempre assim

**O que faz o parser**

* **Validação sintática-** verifica se a ordem dos tokens faz sentido de acordo com as regras sintáticas definidas em parser.y. se não fizer, chama yyerror().  
    
* **Ações-** quando o Parser identifica uma instrução válida, executa a ação associada à regra. Envolve:  
  * **Atualizar o LC-** \+2 bytes   
  * **Atualizar a tabela de símbolos-** guarda o nome do símbolo (a string) e associa-o a um valor. Se for uma label, o valor associado é o LC. Se for uma diretiva constante (MAX`.equ 10)`, associa o número inteiro fornecido.  
  * **Criar IR-** linked list. cada nó tem o Opcode, Registos, Imediatos/Labels guardados  
    

Quando o Parser chega ao fim do ficheiro (`TOKEN_END_FILE`), o trabalho dele termina, não gera código.

**Outputs** 

* Tabela de símbolos completa  
* Representação intermédia