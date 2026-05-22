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

#define MEM_SIZE    0x10000
static int g_codegen_error = 0;


/* ===========================================================
 * Code generation functions 
 * ============================================================ */

static uint16_t encode_statement(statement_t stmt, uint32_t stmt_lc) {
	
	uint16_t code = 0;

	switch (stmt.format) {

		// -- RR: op(4) rd(4) rs(4) fn(4)
		case FMT_RR:
			code = ((uint16_t)(stmt.opcode & 0xF) << 12)
			     | ((uint16_t)(stmt.rd & 0xF) << 8) 
			     | ((uint16_t)(stmt.rs & 0xF) << 4) 
			     | (uint16_t)(stmt.fn & 0xF);
			break;
		        
		// -- RI: op(4) rd(4) fn(4) imm(4)
		case FMT_RI: {
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
		        
		 // -- RRI: op(4) rd(4) rs(4) imm(4)
		case FMT_RRI: {
			int32_t imm4 = stmt.imm;
			if (stmt.misc == LABEL) {
					int16_t label_addr = get_symbol_value((uint16_t)stmt.imm);
					imm4 = label_addr & 0xF;
			}
		
			code = ((uint16_t)(stmt.opcode & 0xF) << 12)
			     | ((uint16_t)(stmt.rd & 0xF) << 8) 
			     | ((uint16_t)(stmt.rs & 0xF) << 4) 
			     | (uint16_t)(imm4 & 0xF);
			break;
		}
		        
		// -- I12: op(4) imm(12)
		case FMT_I12: {
			int32_t imm12 = stmt.imm;
			if (stmt.misc == LABEL) {
					int16_t full_addr = get_symbol_value((uint16_t)stmt.imm);
					imm12 = (full_addr >> 4) & 0xFFF;
			}

			code = ((uint16_t)(stmt.opcode & 0xF) << 12)
						|  (uint16_t)(imm12 & 0xFFF);
			break;
		}
		
		// -- BR: op(4) cond(4) disp(8)
		case FMT_BR: {
			int32_t disp8 = stmt.imm;  
			if (stmt.misc == LABEL) {
				uint32_t label_addr = get_symbol_value((uint32_t)stmt.imm);
				int32_t  disp       = ((int32_t)label_addr - (int32_t)(stmt_lc))/2;

				if (disp < -128 || disp > 127) {
						LOG_ERROR("Line %u: branch to label out of range (%d bytes)",
											stmt.line_num, disp);
						g_codegen_error = 1;
				}

				disp8 = (int32_t)(disp & 0xFF);
			}

			code = ((uint16_t)(stmt.opcode & 0xF) << 12)
					 | ((uint16_t)(stmt.cond   & 0xF) <<  8)
					 |  (uint16_t)(disp8       & 0xFF);
			break;
		}
		
		// -- FIXED: op(4) misc(12)
		case FMT_FIXED:
			switch (stmt.opcode) {
				case CLI_OPCODE: 
					code = CLI_ENCODING; 
					break;
				case STI_OPCODE: 
					code = STI_ENCODING; 
					break;
				case NOP_OPCODE: 
					code = NOP_ENCODING; 
					break;
				
				default:
					LOG_ERROR("encode_statement: unknown FIXED opcode %d", stmt.opcode);
					g_codegen_error = 1;
					break;
			}
			break; 
			
		default:
			LOG_ERROR("encode_statement: unknown instruction format '%c'", stmt.format);
			g_codegen_error = 1;
			break;
		
	} // end switch case 

	return code;
}

/* ===========================================================
 * Generate code from the statement list, write to hex file
 * ============================================================ */

int generate_code(void)
{
    g_codegen_error = 0;

    // -- 1. Allocate memory and fill with NOP (0xF000)
    uint8_t *mem = malloc(MEM_SIZE);
    if (!mem) {
        LOG_ERROR("generate_code: out of memory");
        return 1;
    }
    for (uint32_t addr = 0; addr < MEM_SIZE; addr += 2) {
        mem[addr]     = (NOP_ENCODING >> 8) & 0xFF;   // 0xF0
        mem[addr + 1] =  NOP_ENCODING       & 0xFF;   // 0x00
    }

    // -- 2. Walk the statement list, write memory, track max_lc
    uint32_t count  = get_statement_count();
    uint32_t lc     = 0;
    uint32_t max_lc = 0;

    for (uint32_t i = 0; i < count; i++) {
        statement_t s = get_statement(i);

        switch (s.opcode) {
            case DIR_ORG:
                lc = (uint32_t)(uint16_t)s.imm;
                continue;

            case DIR_EQU:
                continue;

            case DIR_WORD: {
                uint32_t v = (uint32_t)s.imm;
                if (lc + 3 < MEM_SIZE) {
                    mem[lc]     = (v >> 24) & 0xFF;
                    mem[lc + 1] = (v >> 16) & 0xFF;
                    mem[lc + 2] = (v >>  8) & 0xFF;
                    mem[lc + 3] =  v        & 0xFF;
                } else {
                    LOG_ERROR("Line %u: .WORD at address 0x%X exceeds memory bounds", s.line_num, lc);
                    g_codegen_error = 1;
                }
                
								lc += LC_WORD;
                break;
            }

            case DIR_BYTE:
                if (lc < MEM_SIZE) { 
                    mem[lc] = (uint8_t)(s.imm & 0xFF);
								} else {
									LOG_ERROR("Line %u: .BYTE at address 0x%X exceeds memory bounds", s.line_num, lc);
									g_codegen_error = 1;
								}

                lc += LC_BYTE;
                break;

            default: {
                uint16_t code = encode_statement(s, lc);
                if (lc + 1 < MEM_SIZE) {
                    mem[lc]     = (code >> 8) & 0xFF;
                    mem[lc + 1] =  code       & 0xFF;
                } else { 
									LOG_ERROR("Line %u: instruction at address 0x%X exceeds memory bounds", s.line_num, lc);
									g_codegen_error = 1;
								}
								
                lc += LC_INSTRUCTION;
                break;
            }
        }

				// Update max_lc after each statement, to track the highest address written to
        if (lc > max_lc) max_lc = lc;
    }

    // Round max_lc up to the next even number, since instructions are 2 bytes and .BYTE can write 1 byte
    if (max_lc & 1) max_lc++;

    // -- 3. Write the memory image to the hex file
    FILE *fptr = fopen("bleh.hex", "w");
    if (!fptr) {
        LOG_ERROR("generate_code: cannot open output file");
        free(mem);
        return 1;
    }

    // Emit one 16-bit word per line, big-endian, from address 0
    // up to max_lc (inclusive of the last written address).
    for (uint32_t addr = 0; addr < max_lc; addr += 2) {
        uint16_t word = ((uint16_t)mem[addr] << 8) | mem[addr + 1];
        fprintf(fptr, "%04X\n", word);
    }

		// -- 4. Clean up and return error status
		if (g_codegen_error) {
			LOG_WARNING("Code generation completed with errors. Output file may be incomplete or invalid.");
		}
    fclose(fptr);
    free(mem);
    return g_codegen_error;
}
