CC      = gcc
CFLAGS  = -Wall -Wextra -g 

LEXER_DIR  = Lexer
PARSER_DIR = Parser
UTILS_DIR  = Util

SRCS    = $(PARSER_DIR)/parser.tab.c \
          $(LEXER_DIR)/lex.yy.c      \
          $(PARSER_DIR)/ASTree.c     \
          $(PARSER_DIR)/ASTPrint.c   \
          $(UTILS_DIR)/logger.c

TARGET  = parser

all: $(TARGET)

# Generate parser (bison output stays in parser/)
$(PARSER_DIR)/parser.tab.c $(PARSER_DIR)/parser.tab.h: $(PARSER_DIR)/parser.y
	bison -d $(PARSER_DIR)/parser.y -o $(PARSER_DIR)/parser.tab.c

# Generate lexer (flex output stays in lexer/, needs parser.tab.h for token defs)
$(LEXER_DIR)/lex.yy.c: $(LEXER_DIR)/lexer.l $(PARSER_DIR)/parser.tab.h
	flex -o $(LEXER_DIR)/lex.yy.c $(LEXER_DIR)/lexer.l

$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -f $(PARSER_DIR)/parser.tab.c \
	      $(PARSER_DIR)/parser.tab.h \
	      $(LEXER_DIR)/lex.yy.c      \
	      $(TARGET)
