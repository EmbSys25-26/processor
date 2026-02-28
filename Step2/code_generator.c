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
		case FMT_RI:
			code = ((uint16_t)(stmt.opcode & 0xF) << 12)
			     | ((uint16_t)(stmt.rd & 0xF) << 8) 
			     | ((uint16_t)(stmt.fn & 0xF) << 4) 
			     | (uint16_t)(stmt.imm & 0xF);
		        break;
		        
		 /* ── RRI : op(4) rd(4) rs(4) imm(4) ────────────────── */
		case FMT_RRI:
			int16_t imm4 = stmt.imm;    
		        if (stmt.misc == LABEL || stmt.misc == LINK) {
		      
		            int16_t label_addr = get_symbol_value(stmt.imm);

			    if (stmt.opcode == JAL_OPCODE) {
			        // JAL needs a relative displacement
			        int16_t disp = (int32_t)label_addr - (int32_t)(stmt_lc + LC_INSTRUCTION);
			        imm4 = (int16_t)(disp & 0xF);
			    } else {
			        // .equ constant — use the value directly
			        imm4 = label_addr & 0xF;
			    }
		        }
		
			code = ((uint16_t)(stmt.opcode & 0xF) << 12)
			     | ((uint16_t)(stmt.rd & 0xF) << 8) 
			     | ((uint16_t)(stmt.rs & 0xF) << 4) 
			     | (uint16_t)(imm4 & 0xF);
			break;
		        
		/* ── I12 : op(4) imm(12) ─────────────────────────────  */
		case FMT_I12:
		        code = ((uint16_t)(stmt.opcode & 0xF) << 12)
		    	     |  (uint16_t)(stmt.imm    & 0xFFF);
		        break;
		
		case FMT_BR: {
		        int16_t disp8 = stmt.imm;  
		        if (stmt.misc == LABEL) {
				uint32_t label_addr = get_symbol_value((uint32_t)stmt.imm);
				int32_t  disp       = (int32_t)label_addr
				                    - (int32_t)(stmt_lc + LC_INSTRUCTION);

				if (disp < -128 || disp > 127) {
				    LOG_ERROR("Line %u: branch to label out of range (%d bytes)",
				              stmt.line_num, disp);
				}

				disp8 = (int16_t)(disp & 0xFF);
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

#define MEM_SIZE    0xFFFF 

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
        mem[addr]     = (NOP_ENCODING >> 8) & 0xFF;   /* 0xF0 big endian*/
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



