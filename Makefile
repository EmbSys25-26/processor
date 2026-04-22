CC      = gcc
CFLAGS  = -Wall -Wextra -g

LEXER_DIR    = Lexer
PARSER_DIR   = Parser
UTILS_DIR    = Util
SEM_DIR      = Semantic
IR_DIR       = IR
REGALLOC_DIR = RegAlloc

SRCS    = $(PARSER_DIR)/parser.tab.c \
          $(LEXER_DIR)/lex.yy.c      \
          $(PARSER_DIR)/ASTree.c     \
          $(PARSER_DIR)/ASTPrint.c   \
          $(UTILS_DIR)/logger.c      \
          $(SEM_DIR)/arena.c         \
          $(SEM_DIR)/type.c          \
          $(SEM_DIR)/symbol.c        \
          $(SEM_DIR)/diagnostics.c   \
          $(SEM_DIR)/semantic_ast_helpers.c\
          $(SEM_DIR)/semantic_pass1.c\
          $(SEM_DIR)/semantic_pass2.c\
          $(SEM_DIR)/semantic.c      \
          $(IR_DIR)/ir.c             \
          $(IR_DIR)/ir_lower.c       \
          $(IR_DIR)/ir_lower_decl.c  \
          $(IR_DIR)/ir_lower_expr.c  \
          $(IR_DIR)/ir_lower_stmt.c

TARGET  = compiler

all: $(TARGET)

# Generate parser (bison output stays in parser/)
$(PARSER_DIR)/parser.tab.c $(PARSER_DIR)/parser.tab.h: $(PARSER_DIR)/parser.y
	bison -d $(PARSER_DIR)/parser.y -o $(PARSER_DIR)/parser.tab.c

# Generate lexer (flex output stays in lexer/, needs parser.tab.h for token defs)
$(LEXER_DIR)/lex.yy.c: $(LEXER_DIR)/lexer.l $(PARSER_DIR)/parser.tab.h
	flex -o $(LEXER_DIR)/lex.yy.c $(LEXER_DIR)/lexer.l

$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^

# ── Etapa 1: liveness analysis standalone test ──────────────────────────────
LIVENESS_SRCS = $(REGALLOC_DIR)/liveness.c \
                $(IR_DIR)/ir.c

test_liveness: $(LIVENESS_SRCS) $(REGALLOC_DIR)/test_liveness.c
	$(CC) $(CFLAGS) -o $@ $^

# ── Etapa 2: interference graph standalone test ─────────────────────────────
INTERFERENCE_SRCS = $(REGALLOC_DIR)/liveness.c     \
                    $(REGALLOC_DIR)/interference.c \
                    $(IR_DIR)/ir.c

test_interference: $(INTERFERENCE_SRCS) $(REGALLOC_DIR)/test_interference.c
	$(CC) $(CFLAGS) -o $@ $^

# Aggregate test target — runs everything in sequence
test: test_liveness test_interference
	./test_liveness
	./test_interference

clean:
	rm -f $(PARSER_DIR)/parser.tab.c \
	      $(PARSER_DIR)/parser.tab.h \
	      $(LEXER_DIR)/lex.yy.c      \
	      $(TARGET)                  \
	      test_liveness              \
	      test_interference
