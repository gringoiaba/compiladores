#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "table.h"
#include "errors.h"

Table *newTable() 
{
    Table *table = NULL;
    table = calloc(1, sizeof(Table));
    table->head = NULL;
    return table;
}

Entry *newEntry(int lineno, Nature nature, Type type, char *value) 
{
    Entry *entry = NULL;
    entry = calloc(1, sizeof(Entry));

    if (entry == NULL) return NULL;

    entry->lineno = lineno;
    entry->nature = nature;
    entry->type = type;
    entry->value = strdup(value);
    entry->next = NULL;
    return entry;
}

void insertEntry(Table *table, Entry *entry) 
{
    if (table == NULL || entry == NULL) return;
    
    Entry *existing = searchEntry(table, entry->value);
    if (existing != NULL) {
        fprintf(stderr, "Error on line %d: Redeclaration of identifier %s (%s) already declared on line %d \n",
                 entry->lineno, entry->value, entry->nature == VARIABLE ? "variable" : "function", existing->lineno);
        exit(ERR_DECLARED);
    }
    entry->next = table->head;
    table->head = entry;
}

Entry *searchEntry(Table *table, char *value) 
{
    Entry *head = table->head;
    while (head != NULL) {
        if (strcmp(head->value, value) == 0) {
            return head;
        }
        head = head->next;
    }
    return NULL;
}

void setUndefinedType(Table *table, Type type) 
{
    if (table == NULL) return;

    Entry *head = table->head;
    while (head != NULL) {
        if (head->type == UNDEFINED) {
            head->type = type;
        }
        head = head->next;
    }
}

void freeEntry(Entry *entry) 
{
    if (entry == NULL) {
        printf("Error: %s was passed as param entry = %p.\n", __FUNCTION__, entry);
        return;
    }

    free(entry->value);
    free(entry);
}

void freeTable(Table *table) 
{
    Entry *head = table->head;
    
    while (head != NULL) {
        Entry *temp = head;
        head = head->next;
        freeEntry(temp);
    }
    free(table);
}
