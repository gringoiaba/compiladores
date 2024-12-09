#ifndef TYPES_H
#define TYPES_H

typedef enum lexType {
    LITERAL,
    IDENTIFIER
} LexType;

typedef enum type {
    INT,
    FLOAT
} Type;

Type typeInfer(Type type1, Type type2);

#endif // TYPES_H