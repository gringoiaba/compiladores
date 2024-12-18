#include <stdlib.h>
#include <stdio.h>
#include "stack.h"

TableStack *newStack(SymbolTable *symbolTable)
{
    TableStack *stack = NULL;
    stack = (TableStack *)malloc(sizeof(TableStack));

    if (stack == NULL) {
        fprintf(stderr, "Error: %s could not allocate memory for stack.\n", __FUNCTION__);
        exit(1);
    }
    stack->symbolTable = symbolTable;
    stack->prev = NULL;
    return stack;
}

void pushTable(TableStack **stack, SymbolTable *symbolTable)
{
    if (*stack == NULL || stack == NULL) {
        fprintf(stderr, "Error: %s received as param stack %p.\n", __FUNCTION__, stack);
        exit(1);
    }

    TableStack *new = newStack(symbolTable);
    new->symbolTable = symbolTable;
    new->prev = *stack;
    *stack = new;
}

void popTable(TableStack **stack)
{
    if (*stack == NULL || stack == NULL) {
        fprintf(stderr, "Error: %s received as param stack %p.\n", __FUNCTION__, stack);
        exit(1);
    }

    TableStack *temp = *stack;
    *stack = (*stack)->prev;
    freeSymbolTable(temp->symbolTable);
    free(temp);
}

Symbol *searchSymbolInStack(TableStack *stack, char *value)
{
    if (stack == NULL) return NULL;

    TableStack *temp = stack;
    while (temp != NULL) {
        Symbol *symbol = searchSymbol(temp->symbolTable, value);
        if (symbol != NULL) return symbol;
        temp = temp->prev;
    }
    return NULL;
}

void freeStack(TableStack *stack)
{
    if (stack == NULL) return;

    TableStack *temp = NULL;
    while (stack != NULL) {
        temp = stack;
        stack = stack->prev;
        if (temp->symbolTable != NULL) freeSymbolTable(temp->symbolTable);
        free(temp);
    }
}

void printStack(TableStack *stack)
{
    if (stack == NULL || stack->symbolTable == NULL) {
        printf("Stack is empty\n");
        return;
    }
    fprintf(stdout, " +------+----------------------+--------+------------+--------+ \n");
    fprintf(stdout, " | %-4s | %-20s | %-6s | %-10s | %-6s | \n", "off", "symbol", "line", "nature", "type");

    while (stack) {        
        printf(" +------+----------------------+--------+------------+--------+ \n");

        printSymbolTable(stack->symbolTable);
        stack = stack->prev;
    }
    printf(" +------+----------------------+--------+------------+--------+ \n"); 
}