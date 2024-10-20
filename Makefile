etapa2:
    flex scanner.l
    bison -d parser.y
    gcc -I. main.c lex.yy.c parser.tab.c -o etapa2
clean:
    rm parser.tab.c parser.tab.h
    rm etapa2
    rm lex.yy.c