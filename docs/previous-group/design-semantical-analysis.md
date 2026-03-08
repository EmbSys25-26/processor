  
**Design da Análise Semântica**

Two pass:  
**1st Pass**\- Travessia preorder(visita-se primeiro a **raiz**, depois percorre-se a **subárvore esquerda** e por fim a **subárvore direita**. ) para a construção da tabela de símbolos  
A tabela de símbolos deve fazer coisas diferentes:  
→ Declaração (variáveis, arrays, funções…): Inserir símbolo na tabela com NOME, TIPO, SCOPE, MEM LOCATION (se já existir dá erro de redefinição- APENAS QUEREMOS NOMES ÚNICOS)  
→ Uso de identificadores: Procura símbolo na tabela→ Se encontrar liga o nó ao símbolo, senão dá erro  
→ Gestão de Scope … Avisar tabela?? 

**2nd Pass-** Travessia postorder(percorre-se primeiro a **subárvore esquerda**, depois a **subárvore direita** e só no fim visita-se a **raiz**.) para colorir a árvore e encontrar erros  
Ou seja começa por guardar tipos das variáveis; com identificadores copiar o tipo do símbolo para o nó; verifica a compatibilidade de operandos; controlo de fluxo; compara se o tipo do retorno é igual ao tipo da função; verifica se funções estão implementadas e compara parâmetros esperados; const nao pode ser alterado; índice de arrays

**Porquê duas passagens?**   
Porque em C podemos chamar uma função antes de a definir (em certos contextos). Se fosse numa só passagem, quando encontrássemos a chamada ainda não tínhamos inserido a função na tabela.

Regras para verificar neste 2nd pass:

**Verificar tipo de nó**  
    
    NODE\_OPERATOR → ver regras de operator definidas em baixo           
    NODE\_TERNARY→ tem 3 children (condição, true action, false, action); nenhum dos children deve ser string ou void. os dois ultimos children devem ser do mesmo tipo, senao erro                         
    NODE\_IDENTIFIER→ verificar se existe na tabela de símbolos; se este nó tiver um child significa que precisa de um cast, senao tiver é só guardar o tipo   
    NODE\_STRING → guardar tipo            
    NODE\_INTEGER → guardar tipo             
    NODE\_FLOAT → guardar tipo    
    NODE\_CHAR → guardar tipo  

    NODE\_IF                
    NODE\_WHILE             
    NODE\_DO\_WHILE  
    NODE\_ SWITCH → os children nao podem ser nem string nem void senao da erro  
           
    NODE\_RETURN → verifica se a função existe na tabela de simbolos; veirfica se tem um rtorno vendo se tem children. obtem o tipo da função e verifica se o tipo da função e do retorno sao iguais           
      
    NODE\_CASE→ verificar se os children são inteiros ou char, senao da erro e nao podemos fazer switch case            

    NODE\_REFERENCE → NOT SURE \!\!\!\!             
            
    NODE\_POINTER\_CONTENT → ve se existe na tabela de simbolos; ve se o simbolo é um pointer; define o seu tipo  
    NODE\_TYPE\_CAST → faz cast e atribuir novo tipo         

"++"    
"--" :  
    NODE\_POST\_DEC             
    NODE\_PRE\_DEC              
    NODE\_POST\_INC            
  NODE\_PRE\_INC  → aplica se aos anteriores de pre/pos inc/dec: ve se é um símbolo (com um dos tipos básicos), se este for constante da erro. se for pointer passa também passa.

    NODE\_ARRAY\_INDEX →verifica a tabela de símbolos para ver se o array existe; verifica o tipo de indice (int, long, short)

    NODE\_FUNCTION,  
    NODE\_FUNCTION\_CALL → ve se função existe na tabela de simbolos e esta implementada; se tiver children é porque tem argumentos; define o tipo da função

HÁ OUTROS NOS QUE TEM DE SER TRATADOS QUANDO CONSTRUIMOS A TABELA DE SIMBOLOS  
Operandos: Neste caso encontramo nos num nó de um operando e analisamos os childs para saber se os tipos correspondem e a operação pode ser efetuada

FAZER ISTO COM SWITCH CASE AO RECEBER O NÓ DO OPERADOR

Ver NodeTypes.h para os nomes

**varType ja se encontra na estrutura da árvore- é com este atributo que se pode verificar o tipo**

**"\~" (bitwise) , "\!"  (logical):**  verifica o único child que tem.   
Neste exemplo: **\~a**, o child seria “a”  → este só pode ser do tipo inteiro, se não for dá erro

**"+=",  "-=",  "="  :**   verifica 2 childs- → ex: a \+=1  a: child1  1:child2  
Vê o tipo do operando da esquerda (Lvalue) vê se o outro child precisa de CAST (e tenta fazer se for implicito), ou ve se é um simbolo. Se não for nenhum destes é porque corresponde ao tipo do child1 ou deve dar erro

De seguida, verifica-se se os tipos são compatíveis. Regra geral, os dois operandos devem ter o mesmo tipo, caso contrário é gerado erro semântico (com exceção de alguns casos específicos, como certas atribuições envolvendo ponteiros e strings).

Valida se o **lado esquerdo** pode receber o valor:  
Variável normal → ok  
Ponteiro → chamada a `pointerAssignCheck`  
Função → erro  
Conteúdo de ponteiro ou array → restrições adicionais  
Se tudo estiver correto → tipo do nó é o tipo do lado esquerdo  
Qualquer incompatibilidade → erro semântico

**"/" (dividir):** se o denominador (child2) for 0 dá logo erro; após isto verifica o tipo de cada child: não podem ser string nem void e os tipos tem de ser iguais, senão dá erro. AQUI NAO VAMOS ARRISCAR FAZER IMPLICIT CAST, nao pode ser string ou void

**"+", "-" , "\*" , "==", "\!=", "\<=", "\>=", "\<" , "\>" , "&&", "||" :**   
2 children → verificar tipos dos operandos, se necessário tentar fazer cast do tipo menor para o tipo maior. Se forem diferentes dar erro. Também não pode ser do tipo string ou void

**"&=", "|=", "^=",  "\<\<", "\>\>", "&", "|", "^", "%" :**   2 children, tipos permitidos → int, char, short, long, senao da erro

**"\<\<=" , "\>\>="  :**  2 children. só podem ser inteiros, se não falha.

**Fazer funções de set memory location, set variable type, build symbol table, verificar nó, verificar operador, verificar apontadores, criar erro semantico E FUNÇÃO GERAL PARA EXECUTAR ANÁLISE SEMÂNTICA.**

