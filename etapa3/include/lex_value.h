#ifndef LEX_VALUE_H
#define LEX_VALUE_H

typedef enum lextType {
    LITERAL,
    IDENTIFIER
} LexType;

typedef struct lexValue {
    int lineno;
    LexType type;
    char *value;
} LexValue;

LexValue *newLexValue(int lineno, LexType type, char *value);
void freeLexValue(LexValue *lexValue);

#endif