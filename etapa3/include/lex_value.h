#ifndef LEX_VALUE_H
#define LEX_VALUE_H

typedef struct lexValue {
    int lineno;
    TokenType type;
    char *value;
} LexValue;

enum TokenType {
    ID,
    LITERAL
};

#endif