#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "symbolTable.h"
#include "errors.h"

#define SYMBOL_SIZE 4

SymbolTable *newSymbolTable() 
{
    SymbolTable *symbolTable = NULL;
    symbolTable = calloc(1, sizeof(SymbolTable));

    if (symbolTable == NULL) {
        fprintf(stderr, "Error: %s could not allocate memory.\n", __FUNCTION__);
        return NULL;
    }

    symbolTable->head = NULL;
    symbolTable->offset = 0;
    symbolTable->size = 0;

    return symbolTable;
}

Symbol *newSymbol(int lineno, Nature nature, Type type, char *value) 
{
    Symbol *symbol = NULL;
    symbol = calloc(1, sizeof(Symbol));

    if (symbol == NULL) {
        fprintf(stderr, "Error: %s could not allocate memory.\n", __FUNCTION__);
        return NULL;
    }

    symbol->lineno = lineno;
    symbol->nature = nature;
    symbol->type = type;
    symbol->value = strdup(value);
    symbol->next = NULL;
    symbol->offset = -1;
    return symbol;
}

void insertSymbol(SymbolTable *symbolTable, Symbol *symbol) 
{
    if (symbolTable == NULL || symbol == NULL) return;
    
    Symbol *existing = searchSymbol(symbolTable, symbol->value);
    if (existing != NULL) {
        fprintf(stderr, "Error on line %d: Redeclaration of identifier %s (%s) already declared on line %d \n",
                 symbol->lineno, symbol->value, symbol->nature == VARIABLE ? "variable" : "function", existing->lineno);
        exit(ERR_DECLARED);
    }
    symbol->next = symbolTable->head;
    symbolTable->head = symbol;

    symbol->offset = symbolTable->size;
    symbolTable->size += SYMBOL_SIZE;
}

Symbol *searchSymbol(SymbolTable *symbolTable, char *value) 
{
    Symbol *head = symbolTable->head;
    while (head != NULL) {
        if (strcmp(head->value, value) == 0) {
            return head;
        }
        head = head->next;
    }
    return NULL;
}

void setUndefinedType(SymbolTable *symbolTable, Type type) 
{
    if (symbolTable == NULL) return;

    Symbol *head = symbolTable->head;
    while (head != NULL) {
        if (head->type == UNDEFINED) {
            head->type = type;
        }
        head = head->next;
    }
}

void freeSymbol(Symbol *symbol) 
{
    if (symbol == NULL) {
        printf("Error: %s was passed as param symbol = %p.\n", __FUNCTION__, symbol);
        return;
    }

    free(symbol->value);
    free(symbol);
}

void freeSymbolTable(SymbolTable *symbolTable) 
{
    Symbol *head = symbolTable->head;
    
    while (head != NULL) {
        Symbol *temp = head;
        head = head->next;
        freeSymbol(temp);
    }
    free(symbolTable);
}

void printSymbolTable(SymbolTable *symbolTable) {

    if (symbolTable == NULL || symbolTable->head == NULL) {
        printf(" | Symbol Table empty.\n");
        return;
    }

    Symbol *temp = symbolTable->head;
    while (temp) {
        fprintf(stdout," | %-20s | %-6d | %-10s | %-6s |\n",
               temp->value,
               temp->lineno,
               temp->nature == VARIABLE ? "VARIABLE" : "FUNCTION",
               temp->type == INT ? "INT" : "FLOAT");
        temp = temp->next;
    }
}