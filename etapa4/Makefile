IDIR=include
SDIR=src
ODIR=build
CC=gcc
CFLAGS=-I$(IDIR)
LIBS=-lfl

_DEPS = parser.tab.h ast.h lex_value.h errors.h stack.h table.h types.h
DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))

_OBJ = main.o lex.yy.o parser.tab.o ast.o lex_value.o errors.o stack.o table.o types.o
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

etapa4: $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

$(OBJ): | init

init:
	mkdir -p $(ODIR)

$(IDIR)/parser.tab.h: $(SDIR)/parser.y
	bison -d -v -o $(SDIR)/parser.tab.c $(SDIR)/parser.y
	mv $(SDIR)/parser.tab.h $(IDIR)/parser.tab.h

$(SDIR)/lex.yy.c: $(SDIR)/scanner.l $(IDIR)/parser.tab.h
	flex -o $@ $<

$(ODIR)/parser.tab.o: $(SDIR)/parser.tab.c $(IDIR)/parser.tab.h
	$(CC) -c -o $@ $< $(CFLAGS)

$(ODIR)/%.o: $(SDIR)/%.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)



## [Testes] ====================================================================
## Criados de maneira experimental para ajudar no debug manual
## Dica:  use ==>   export i=$((i + 1)); make t num=$(printf "%02d" "$i")
OPEN = xdg-open
num ?= 53
TESTE = testes/E3/z$(num)
REF = $(TESTE).ref.dot

t: tst

tst: png
	dot $(REF) -Tpng -o outputs/ref.png
	$(OPEN) outputs/ref.png 
	$(OPEN) outputs/grafo.png

png: $(ETAPA) 
	mkdir -p outputs
	./etapa4 < $(TESTE)
	dot output.dot -Tpng -o outputs/grafo.png

print_teste: 
	printf ">>>> Teste: $(TESTE)"

## ==============================================================================

.PHONY: clean print_teste

clean:
	rm -fr $(ODIR) *~ core $(IDIR)/*~ etapa4 $(SDIR)/lex.yy.c $(SDIR)/parser.tab.c $(IDIR)/parser.tab.h $(SDIR)/parser.output
