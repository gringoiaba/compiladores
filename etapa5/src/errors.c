#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "errors.h"

void checkDeclaration(TableStack *stack, char *value, int lineno)
{
    Entry *entry = searchEntryInStack(stack, value);
    if (entry == NULL)
    {
        fprintf(stderr, "Error on line %d: Identifier %s not declared\n", lineno, value);
        exit(ERR_UNDECLARED);
    }
}

void checkNature(TableStack *stack, char *value, Nature nature, int lineno)
{
    Entry *entry = searchEntryInStack(stack, value);
    if (entry->nature == FUNCTION && nature == VARIABLE)
    {
        fprintf(stderr, "Error on line %d: Identifier %s is a function defined on line %d, not a variable\n", lineno, entry->lineno, value);
        exit(ERR_VARIABLE);
    }
    else if (entry->nature == VARIABLE && nature == FUNCTION)
    {
        fprintf(stderr, "Error on line %d: Identifier %s is a variable defined on line %d, not a function\n", lineno, entry->lineno, value);
        exit(ERR_FUNCTION);
    }
}
