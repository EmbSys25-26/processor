# Toolchain Definitions
M4        := m4
ASM       := ./assembler
ABI_DEFS  := abi.m4
SPLITTER  := awk

# Build Flags
M4_FLAGS  := 
ASM_FLAGS := 

# Target Files (derived from SRC variable)
SRC       ?= teste1.asm
BASENAME  := $(basename $(SRC))
PRE       := build/$(BASENAME).asm
HEX       := build/$(BASENAME).hex
HI_HEX    := build/$(BASENAME)_hi.hex
LO_HEX    := build/$(BASENAME)_lo.hex

.PHONY: all clean

all: $(HI_HEX) $(LO_HEX)

# Step 0: Create the assembler
Compile: 
	@gcc main.c Util/symbol_table.c Util/statements_list.c Util/logger.c	Step1/lex.yy.c Step1/parser.tab.c Step2/code_generator.c -I. -IStep1 -o assembler

# Step 1: Preprocess with m4
# Merges ABI definitions and expands PUSH/POP macros
$(PRE): $(SRC) $(ABI_DEFS) Compile
	@mkdir -p build
	$(M4) $(M4_FLAGS) $(ABI_DEFS) $(SRC) > $(PRE)

# Step 2: Assemble to 16-bit hex
$(HEX): $(PRE)
	$(ASM) $(PRE)
	@mv *.hex build/
	@mv build/*.hex $(HEX)

# Step 3: Split into High and Low byte files
# Extracts the top 8 bits (HI) and bottom 8 bits (LO) from each 4-digit hex line
$(HI_HEX): $(HEX)
	$(SPLITTER) '{ print substr($$1, 1, 2) }' $(HEX) > $(HI_HEX)

$(LO_HEX): $(HEX)
	$(SPLITTER) '{ print substr($$1, 3, 2) }' $(HEX) > $(LO_HEX)

clean:
	rm -rf build/
	rm assembler