IDIR=include
SDIR=src
ODIR=build
CC=gcc
CFLAGS=-I$(IDIR)
LFLAGS=-lfl

_DEPS = parser.tab.h ast.h lex_value.h
DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))

_OBJ = main.o lex.yy.o parser.tab.o ast.o lex_value.o
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

etapa3: $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

$(IDIR)/parser.tab.h: $(SDIR)/parser.y
	bison -d -v -o $(SDIR)/parser.tab.c $(SDIR)/parser.y
	mv $(SDIR)/parser.tab.h $(IDIR)/parser.tab.h

$(SDIR)/lex.yy.c: $(SDIR)/scanner.l $(IDIR)/parser.tab.h
	flex -o $@ $<

$(ODIR)/parser.tab.o: $(SDIR)/parser.tab.c $(IDIR)/parser.tab.h
	$(CC) -c -o $@ $< $(CFLAGS)

$(ODIR)/%.o: $(SDIR)/%.c $(DEPS)
	mkdir -p build
	$(CC) -c -o $@ $< $(CFLAGS)

.PHONY: clean

clean:
	rm -fr $(ODIR) *~ core $(INCDIR)/*~ etapa3 $(SDIR)/lex.yy.c $(SDIR)/parser.tab.c $(IDIR)/parser.tab.h $(SDIR)/parser.output