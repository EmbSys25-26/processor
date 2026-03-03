#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>  
#include <math.h>    
#include <unistd.h>
#include "../Util/logger.h"
#include "../Step2/code_generator.h"
#include "../Util/asm_operations.h"
#include "../Util/symbol_table.h"
#include "../Util/statements_list.h"

static uint16_t encode_statement(statement_t stmt, uint32_t stmt_lc){
	
	uint16_t code = 0;
	
	switch (stmt.format){
		/* ── RR : op(4) rd(4) rs(4) fn(4) ─────────────────── */
		case FMT_RR:
			code = ((uint16_t)(stmt.opcode & 0xF) << 12)
			     | ((uint16_t)(stmt.rd & 0xF) << 8) 
			     | ((uint16_t)(stmt.rs & 0xF) << 4) 
			     | (uint16_t)(stmt.fn & 0xF);
		        break;
		        
		/* ── RI : op(4) rd(4) fn(4) imm(4) ─────────────────── */
		case FMT_RI: {
		        /*
		         * FIX BUG5: se misc == LABEL, imm e o indice da symbol table.
		         * Resolve o valor aqui no passo 2.
		         */
		        int32_t imm4 = stmt.imm;
		        if (stmt.misc == LABEL) {
		            imm4 = get_symbol_value((uint16_t)stmt.imm);
		        }
			code = ((uint16_t)(stmt.opcode & 0xF) << 12)
			     | ((uint16_t)(stmt.rd & 0xF) << 8) 
			     | ((uint16_t)(stmt.fn & 0xF) << 4) 
			     | (uint16_t)(imm4 & 0xF);
		        break;
		}
		        
		 /* ── RRI : op(4) rd(4) rs(4) imm(4) ────────────────── */
		case FMT_RRI: {
		        int32_t imm4 = stmt.imm;
		        if (stmt.misc == LABEL) {
		            /*
		             * FIX BUG3: era calculado um deslocamento relativo para JAL.
		             * JAL usa endereco ABSOLUTO: os 4 bits gravados sao os bits [3:0]
		             * do endereco destino. O hardware combina (IMM_prefix << 4) | imm4
		             * para formar o endereco completo.
		             * O mesmo aplica-se a ADDI/LW/SW/etc com .equ label: usa valor direto.
		             */
		            int16_t label_addr = get_symbol_value((uint16_t)stmt.imm);
		            imm4 = label_addr & 0xF;
		        }
		
			code = ((uint16_t)(stmt.opcode & 0xF) << 12)
			     | ((uint16_t)(stmt.rd & 0xF) << 8) 
			     | ((uint16_t)(stmt.rs & 0xF) << 4) 
			     | (uint16_t)(imm4 & 0xF);
			break;
		}
		        
		/* ── I12 : op(4) imm(12) ─────────────────────────────  */
		case FMT_I12: {
		        /*
		         * FIX BUG2/BUG5: se misc == LABEL, imm e o indice da symbol table.
		         * O IMM prefix deve conter os bits [15:4] do endereco destino,
		         * ou seja, (addr >> 4) & 0xFFF.
		         * Isto e o que permite J(label) e CALL(label) funcionarem
		         * de forma identica a J(0x050) e CALL(0x050).
		         */
		        int32_t imm12 = stmt.imm;
		        if (stmt.misc == LABEL) {
		            int16_t full_addr = get_symbol_value((uint16_t)stmt.imm);
		            imm12 = (full_addr >> 4) & 0xFFF;
		        }
		        code = ((uint16_t)(stmt.opcode & 0xF) << 12)
		    	     |  (uint16_t)(imm12 & 0xFFF);
		        break;
		}
		
		case FMT_BR: {
		        int32_t disp8 = stmt.imm;  
		        if (stmt.misc == LABEL) {
				uint32_t label_addr = get_symbol_value((uint32_t)stmt.imm);
				int32_t  disp       = (int32_t)label_addr
				                    - (int32_t)(stmt_lc + LC_INSTRUCTION);

				if (disp < -128 || disp > 127) {
				    LOG_ERROR("Line %u: branch to label out of range (%d bytes)",
				              stmt.line_num, disp);
				}

				disp8 = (int32_t)(disp & 0xFF);
			}

		        code = ((uint16_t)(stmt.opcode & 0xF) << 12)
		             | ((uint16_t)(stmt.cond   & 0xF) <<  8)
		             |  (uint16_t)(disp8       & 0xFF);
		        break;
		}
		    
		 case FMT_FIXED:
		        switch (stmt.opcode) {
				case CLI_OPCODE: code = CLI_ENCODING; break;
				case STI_OPCODE: code = STI_ENCODING; break;
				case NOP_OPCODE: code = NOP_ENCODING; break;
				default:
				    LOG_ERROR("encode_statement: unknown FIXED opcode %d", stmt.opcode);
				    break;
			    }
		        break;
	
	}
	return code;

}

/*
 * FIX BUG1: era 0xFFFF (65535 bytes).
 * O espaco de enderecamento e 16 bits = 65536 posicoes.
 * Com 0xFFFF, o loop de inicializacao fazia mem[65535] com um
 * array de 65535 bytes — buffer overflow garantido.
 */
#define MEM_SIZE    0x10000

void generate_code(void)
{
    /* ── 1. Allocate memory and fill with NOP (0xF000) ── */
    uint8_t *mem = malloc(MEM_SIZE);
    if (!mem) {
        LOG_ERROR("generate_code: out of memory");
        return;
    }

    /* Fill every 16-bit aligned word with NOP_ENCODING (0xF000).
     * We store bytes big-endian: high byte first. */
    for (uint32_t addr = 0; addr < MEM_SIZE; addr += 2) {
        mem[addr]     = (NOP_ENCODING >> 8) & 0xFF;   /* 0xF0 */
        mem[addr + 1] =  NOP_ENCODING       & 0xFF;   /* 0x00 */
    }

    /* ── 2. Walk the statement list, write memory, track max_lc ── */
    uint32_t count  = get_statement_count();
    uint32_t lc     = 0;
    uint32_t max_lc = 0;

    for (uint32_t i = 0; i < count; i++) {
        statement_t s = get_statement(i);

        switch (s.opcode) {
            case DIR_ORG:
                lc = (uint32_t)(uint16_t)s.imm;
                continue;   /* ORG just repositions lc, don't update max_lc */

            case DIR_EQU:
                continue;   /* no bytes emitted */

            case DIR_WORD: {
                /*
                 * FIX BUG4: s.imm e agora int32_t — nao ha truncagem.
                 * .word 0xDEADBEEF escreve os 4 bytes corretos.
                 */
                uint32_t v = (uint32_t)s.imm;
                if (lc + 3 < MEM_SIZE) {
                    mem[lc]     = (v >> 24) & 0xFF;
                    mem[lc + 1] = (v >> 16) & 0xFF;
                    mem[lc + 2] = (v >>  8) & 0xFF;
                    mem[lc + 3] =  v        & 0xFF;
                }
                lc += LC_WORD;
                break;
            }

            case DIR_BYTE:
                if (lc < MEM_SIZE)
                    mem[lc] = (uint8_t)(s.imm & 0xFF);
                lc += LC_BYTE;
                break;

            default: {
                uint16_t code = encode_statement(s, lc);
                if (lc + 1 < MEM_SIZE) {
                    mem[lc]     = (code >> 8) & 0xFF;
                    mem[lc + 1] =  code       & 0xFF;
                }
                lc += LC_INSTRUCTION;
                break;
            }
        }

        if (lc > max_lc) max_lc = lc;
    }

    /* Round up to next even address */
    if (max_lc & 1) max_lc++;

    /* ── 3. Write the memory image to the hex file ───────────── */
    FILE *fptr = fopen("bleh.hex", "w");
    if (!fptr) {
        LOG_ERROR("generate_code: cannot open output file");
        free(mem);
        return;
    }

    /* Emit one 16-bit word per line, big-endian, from address 0
     * up to max_lc (inclusive of the last written address). */
    for (uint32_t addr = 0; addr < max_lc; addr += 2) {
        uint16_t word = ((uint16_t)mem[addr] << 8) | mem[addr + 1];
        fprintf(fptr, "%04X\n", word);
    }

    fclose(fptr);
    free(mem);
}
