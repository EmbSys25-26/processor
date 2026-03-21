.include "../tools/abi.inc"

    ; ============================
    ; Constants / addresses
    ; ============================
    .equ RESET_VEC,  0x0100
    .equ STACK_TOP,  0x03FF

    ; ============================
    ; 0x0100 — reset / main
    ; ============================
    .org RESET_VEC
reset:
    LI   sp, #STACK_TOP         ; => IMM #0x03F    [8|03F] = 0x803F  (prefix: upper 12 bits of STACK_TOP=0x03FF)	| MEM_ADDR = 0x0100
                                ; => ADDI sp,zero,#0xF  [1|D|0|F] = 0x1D0F  (sp = 0x03FF with prefix)			| MEM_ADDR = 0x0102

    J main                      ; => IMM #0x010    [8|010] = 0x8010  (prefix: main_byte_addr=0x10E, 0x10E>>4=0x10)	| MEM_ADDR = 0x0104
                                ; => JAL r0,r0,#0xE [0|0|0|E] = 0x000E  (pc = 0 + 0x10E, lr discarded)			| MEM_ADDR = 0x0106

loop1: 
    ADDI r1, r0, #1             ; [1|1|0|1] = 0x1101									| MEM_ADDR = 0x0108
    BEQ loop2                   ; [9|2|00] = 0x9200  (disp=0, loop2 is next word)					| MEM_ADDR = 0x010A
    
loop2:
    ADDI r1, r0, #1             ; [1|1|0|1] = 0x1101									| MEM_ADDR = 0x010C
    
main:

    ; Deactivate TimerH int_en -- MMIO write requires input address to be (final_address >>1)
    IMM  #0x408                 ; [8|408] = 0x8408  (prefix: upper 12 bits of MMIO word-address 0x8100)			| MEM_ADDR = 0x010E
    SW   r0, r0, #0             ; [6|0|0|0] = 0x6000  (MEM[0+0x8100] = r0 = 0, using prefix)				| MEM_ADDR = 0x0110
    
    ; do an instruction that updates CC
    LI r1, 0                    ; => IMM #0x000    [8|000] = 0x8000  (prefix: 0>>4 = 0)					| MEM_ADDR = 0x0112
                                ; => ADDI r1,zero,#0  [1|1|0|0] = 0x1100  (r1 = 0, sets CC: Z=1)			| MEM_ADDR = 0x0114
    BEQ loop1                   ; [9|2|F8] = 0x92F8  (disp=-8: loop1_byte=0x108, next_PC=0x118)				| MEM_ADDR = 0x0116

main_loop:
    BR   #-1                    ; [9|0|FF] = 0x90FF  (always branch, disp=-1: infinite loop)				| MEM_ADDR = 0x0118
