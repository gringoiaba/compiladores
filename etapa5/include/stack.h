#ifndef TABLE_STACK_H
#define TABLE_STACK_H

#include "symbolTable.h"
#include "types.h"

/* The stack consists of a table and a pointer to the previous stack */
typedef struct stack {
    SymbolTable *symbolTable;
    struct stack *prev;
} TableStack;

/* Inserts a symbol table to a new stack */
TableStack *newStack(SymbolTable *symbolTable);

/* Pushes a symbol table in a given stack  */
void pushTable(TableStack **stack, SymbolTable *symbolTable);

/* Pops a symbol table from a stack */
void popTable(TableStack **stack);

/* Searches for a symbol in the hole stack, even in lower hierchical symbol tables */
Symbol *searchSymbolInStack(TableStack *stack, char *value);

/* Free allocated stack memory */
void freeStack(TableStack *stack);

/* Prints the stack */
void printStack(TableStack *stack);

#endif // TABLE_STACK_H