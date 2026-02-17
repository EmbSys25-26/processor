CC = gcc
CFLAGS = -Wall -Wextra -O2
LEX = flex
M4 = m4

ASM = assembler
SPLIT = split_mem

ABI = abi.m4
IN  = test.asm

EXP = program.asm
HEX = program.hex
HI  = memH.hex
LO  = memL.hex

all: $(HEX) $(HI) $(LO)

$(EXP): $(IN) $(ABI)
	$(M4) $(ABI) $(IN) > $(EXP)

$(ASM): assembler.l
	$(LEX) -o lex.yy.c $<
	$(CC) $(CFLAGS) -o $@ lex.yy.c -lfl

$(HEX): $(ASM) $(EXP)
	./$(ASM) $(EXP) > $(HEX)

$(SPLIT): split_mem.c
	$(CC) $(CFLAGS) -o $@ $<

$(HI) $(LO): $(SPLIT) $(HEX)
	./$(SPLIT) $(HEX) $(HI) $(LO)

clean:
	rm -f lex.yy.c $(ASM) $(SPLIT) $(EXP) $(HEX) $(HI) $(LO)

.PHONY: all clean


