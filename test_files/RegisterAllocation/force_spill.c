/* Funções externas de teste */
int get_val(int x);
void consome_tudo(int a, int b, int c, int d, int e, int f);

int force_spill_real(void) {
    /* * O compilador avalia os argumentos da esquerda para a direita.
     * 1. Chama get_val(1). Guarda o resultado no r8 (cofre).
     * 2. Chama get_val(2). Guarda o resultado no r9 (cofre).
     * 3. Chama get_val(3). Guarda o resultado no r10 (cofre).
     * 4. Chama get_val(4). Guarda o resultado no r11 (cofre). O COFRE ESTÁ CHEIO!
     * 5. Chama get_val(5). Ups... os retornos de 1 a 4 estão vivos. Não há mais 
     * espaço seguro para guardar este! SPILL OBRIGATÓRIO!
     * 6. Chama get_val(6).
     * 7. Chama consome_tudo(...)
     */
    consome_tudo(
        get_val(1),
        get_val(2),
        get_val(3),
        get_val(4),
        get_val(5),
        get_val(6)
    );

    return 0;
}
