#include <stdlib.h>
#include <stdio.h>
#include "stack.h"

TableStack *newStack(Table *table)
{
    TableStack *stack = NULL;
    stack = (TableStack *)malloc(sizeof(TableStack));

    if (stack == NULL) {
        fprintf(stderr, "Error: %s could not allocate memory for stack.\n", __FUNCTION__);
        exit(1);
    }
    stack->table = table;
    stack->next = NULL;
    return stack;
}

void pushTable(TableStack **stack, Table *table)
{
    if (*stack == NULL || stack == NULL) {
        fprintf(stderr, "Error: %s received as param stack %p.\n", __FUNCTION__, stack);
        exit(1);
    }

    TableStack *new = newStack(table);
    new->table = table;
    new->next = *stack;
    *stack = new;
}

void popTable(TableStack **stack)
{
    if (*stack == NULL || stack == NULL) {
        fprintf(stderr, "Error: %s received as param stack %p.\n", __FUNCTION__, stack);
        exit(1);
    }

    TableStack *temp = *stack;
    *stack = (*stack)->next;
    freeTable(temp->table);
    free(temp);
}

Entry *searchEntryInStack(TableStack *stack, char *value)
{
    if (stack == NULL) return NULL;

    TableStack *temp = stack;
    while (temp != NULL) {
        Entry *entry = searchEntry(temp->table, value);
        if (entry != NULL) return entry;
        temp = temp->next;
    }
    return NULL;
}

void freeStack(TableStack *stack)
{
    if (stack == NULL) return;

    TableStack *temp = NULL;
    while (stack != NULL) {
        temp = stack;
        stack = stack->next;
        if (temp->table != NULL) freeTable(temp->table);
        free(temp);
    }
}