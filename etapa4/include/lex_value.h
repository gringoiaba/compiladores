#ifndef LEX_VALUE_H
#define LEX_VALUE_H

#include "types.h"

typedef struct lexValue {
    int lineno;
    LexType type;
    char *value;
} LexValue;

LexValue *newLexValue(int lineno, LexType type, char *value);
void freeLexValue(LexValue *lexValue);

#endif