#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "errors.h"

void checkDeclaration(TableStack *stack, char *value, int lineno)
{
    Symbol *symbol = searchSymbolInStack(stack, value);
    if (symbol == NULL)
    {
        fprintf(stderr, "Error on line %d: Identifier %s not declared\n", lineno, value);
        exit(ERR_UNDECLARED);
    }
}

void checkNature(TableStack *stack, char *value, Nature nature, int lineno)
{
    Symbol *symbol = searchSymbolInStack(stack, value);
    if (symbol->nature == FUNCTION && nature == VARIABLE)
    {
        fprintf(stderr, "Error on line %d: Identifier %s is a function defined on line %d, not a variable\n", lineno, symbol->lineno, value);
        exit(ERR_VARIABLE);
    }
    else if (symbol->nature == VARIABLE && nature == FUNCTION)
    {
        fprintf(stderr, "Error on line %d: Identifier %s is a variable defined on line %d, not a function\n", lineno, symbol->lineno, value);
        exit(ERR_FUNCTION);
    }
}
