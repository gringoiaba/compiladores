#ifndef STACK_H
#define STACK_H

#include "table.h"
#include "types.h"

typedef struct stack {
    Table *table;
    struct stack *next;
} TableStack;

TableStack *newStack(Table *table);
void pushTable(TableStack **stack, Table *table);
void popTable(TableStack **stack);
Entry *searchEntryInStack(TableStack *stack, char *value);
void freeStack(TableStack *stack);

#endif // STACK_H