#ifndef ERRORS_H
#define ERRORS_H

#include <stdio.h>
#include <stdlib.h>
#include "stack.h"

#define ERR_UNDECLARED       10 //2.3
#define ERR_DECLARED         11 //2.3
#define ERR_VARIABLE         20 //2.4
#define ERR_FUNCTION         21 //2.4

void checkDeclaration(TableStack *stack, char *value, int lineno);
void checkNature(TableStack *stack, char *value, Nature nature, int lineno);

#endif // ERRORS_H