#include <stdio.h>
#include <stdlib.h>
#include "lex_value.h"

LexValue *newLexValue(int lineno, LexType type, char *value) 
{
    LexValue *lexVal = NULL;
    lexVal = calloc(1, sizeof(LexValue));
    if (lexVal != NULL) {
        lexVal->lineno = lineno;
        lexVal->type = type;
        lexVal->value = strup(value);
    }
    return lexVal;
}

void freeLexValue(LexValue *lexValue) 
{
    if (lexValue != NULL) {
        free(lexValue->value);
        free(lexValue);
    } else {
        fprintf(stderr, "Error: %s lexValue = %p.\n", __FUNCTION__, lexValue);
    }
}