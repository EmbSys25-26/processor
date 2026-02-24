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
//#include "../main.h"

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
		            int16_t  disp       = (int32_t)label_addr
		                            - (int32_t)(stmt_lc + LC_INSTRUCTION);
		            imm4 = (int16_t)(disp & 0xF);
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

void generate_code(void)
{
    uint32_t count = get_statement_count();
    uint32_t lc    = 0;

    for (uint32_t i = 0; i < count; i++) {

        statement_t s = get_statement(i);

        /* ── Directives ──────────────────────────────────────── */
        switch (s.opcode) {

            case DIR_ORG:
                /* .org just sets the location counter — nothing to emit */
                lc = (uint32_t)(uint16_t)s.imm;
                continue;

            case DIR_EQU:
                /* .equ defines a symbol — nothing to emit */
                continue;

            case DIR_WORD:
                /* emit a 32-bit word as two 16-bit hex values (big-endian) */
                printf("%04X\n", (uint16_t)((s.imm >> 16) & 0xFFFF));
                printf("%04X\n", (uint16_t)( s.imm        & 0xFFFF));
                lc += LC_WORD;
                continue;

            case DIR_BYTE:
                /* emit a single byte, zero-extended to 16 bits for display */
                printf("%02X\n", (uint8_t)(s.imm & 0xFF));
                lc += LC_BYTE;
                continue;

            default:
                break;   /* fall through to instruction encoding */
        }

        /* ── Instructions ────────────────────────────────────── */
        uint16_t code = encode_statement(s, lc);
        printf("%04X\n", code);
        lc += LC_INSTRUCTION;
    }
}


