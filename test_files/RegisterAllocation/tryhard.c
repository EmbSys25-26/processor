/* Funções externas para forçar o uso da ABI e do Balcão de Atendimento (r1-r3) */
int ext1(int x);
int ext2(int x, int y, int z);

int final_boss(int a, int b, int c) {
    /* 1. Sobrevivência Extrema: 'z' nasce no início e só morre no return.
          Vai ter de atravessar o inferno todo e ficar trancado no Cofre. */
    int z = c + 100; 
    
    /* 2. Acumuladores de Loop: Vivos durante múltiplas iterações e chamadas */
    int acc = 0;
    int i = 0;

    /* 3. O Loop do Inferno: CFG complexo (Control Flow Graph) com ramificações */
    while (i < 10) {
        int step;
        
        /* 4. If/Else com diferentes necessidades de argumentos */
        if (a > b) {
            /* Aqui, 'a', 'b', 'z', 'acc', e 'i' estão TODOS vivos. 
               O ext1 esmaga r1-r7. */
            step = ext1(a);
        } else {
            /* Chamada com 3 argumentos. Obriga a alinhar no r1, r2, r3 exatos! */
            step = ext2(b, i, a);
        }
        
        acc = acc + step;
        i = i + 1;
    }

    /* 5. Nested Calls (Chamadas Aninhadas): 
          O ext1(acc) vai correr primeiro, devolver no r1. 
          Depois o 'b' e o 'a' têm de ser alinhados no r2 e r3 sem destruir o retorno do ext1! */
    int magic = ext2(ext1(acc), b, a);

    /* 6. Pressão Máxima na Secretária (Temporários):
          Nenhuma destas variáveis atravessa um CALL. 
          O teu compilador devia atirar isto tudo para o r4, r5, r6, r7! */
    int t1 = magic + 1;
    int t2 = magic + 2;
    int t3 = magic + 3;
    int t4 = magic + 4;
    int t5 = t1 + t2;
    int t6 = t3 + t4;
    int t7 = t5 + t6;

    /* O 'z' ressuscita aqui no fim, exigindo estar intacto desde a linha 1 */
    return t7 + z;
}