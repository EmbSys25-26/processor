all: lexer

lexer_demo: lex.yy.c
	gcc -o lexer lex.yy.c

lex.yy.c: lexer_demo.l
	flex -o lex.yy.c lexer.l

clean:
	rm -f lexer lex.yy.c
