#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include "types.h"

typedef enum nature {
    VARIABLE,
    FUNCTION
} Nature;

typedef struct symbol {
    int lineno;
    Nature nature;
    Type type;
    char *value;
    int offset;
    struct symbol *next;
} Symbol;

typedef struct table {
    Symbol *head;
    int size;
    int offset;
} SymbolTable;

/* ================================== Symbol Table Operations ================================== */

/* Creates a new empty 'symbolSymbolTable' */
SymbolTable *newSymbolTable();

/* Free allocated symbol table */
void freeSymbolTable(SymbolTable *symbolTable);

/* Prints in stdout the symbol table */
void printSymbolTable(SymbolTable *symbolTable);

/* Insert a 'symbol' in the table */
void insertSymbol(SymbolTable *symbolTable, Symbol *symbol);

/* Given symbol label, returns symbol in the symbolTable
 * Returns NULL if not defined in symbol table */
Symbol *searchSymbol(SymbolTable *symbolTable, char *value);

/* Searches and replaces UNDEFINED variable types in symbol table for given type*/
void setUndefinedType(SymbolTable *symbolTable, Type type);

/* ================================== Symbol Operations ================================== */

/* Crates new 'symbol' */
Symbol *newSymbol(int lineno, Nature nature, Type type, char *value);

/* Frees allocated symbol */
void freeSymbol(Symbol *symbol);

char *getOffsetStr(Symbol *symbol);

#endif // SYMBOL_TABLE_H