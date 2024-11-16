#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lex_value.h"

LexValue newLexValue(int lineno, LexType type, char *value) 
{
    LexValue lexVal;

    lexVal.lineno = lineno;
    lexVal.type = type;
    lexVal.value = strdup(value);

    return lexVal;
}

void freeLexValue(LexValue lexValue) 
{
    if (lexValue.value != NULL) {
        free(lexValue.value);
    } else {
        fprintf(stderr, "Error: %s lexValue = %p.\n", __FUNCTION__, lexValue);
    }
}