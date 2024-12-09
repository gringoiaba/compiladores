#ifndef TABLE_H
#define TABLE_H

#include "types.h"

typedef enum nature {
    VARIABLE,
    FUNCTION
} Nature;

typedef struct entry {
    int lineno;
    Nature nature;
    Type type;
    char *value;
    struct entry *next;
} Entry;

typedef struct table {
    Entry *head;
} Table;


Table *newTable();
void freeTable(Table *table);

void insertEntry(Table *table, Entry *entry);
Entry *searchEntry(Table *table, char *value);
void setUndefinedType(Table *table, Type type);

Entry *newEntry(int lineno, Nature nature, Type type, char *value);
void freeEntry(Entry *entry);

#endif // TABLE_H