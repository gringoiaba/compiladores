#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "iloc.h"

int tempCounter = 0;
int labelCounter = 0;


IlocInstruction *newUnOpInstruction(OpCode opCode, char *target, Arrow arrow)
{
    IlocInstruction *instruction = malloc(sizeof(IlocInstruction));
    if (instruction == NULL) {
        fprintf(stderr, "Error: %s could not allocate memory.\n", __FUNCTION__);
        return NULL;
    }

    instruction->label = NULL;
    instruction->opCode = opCode;
    instruction->arg1 = NULL;
    instruction->arg2 = NULL;
    instruction->arg3 = target;
    instruction->arrow = arrow;
    instruction->numArgs = 1;
    instruction->next = NULL;
    
    return instruction;
}

IlocInstruction *newBinOpInstruction(OpCode opCode, char *arg1, char *target, Arrow arrow)
{
    IlocInstruction *instruction = malloc(sizeof(IlocInstruction));
    if (instruction == NULL) {
        fprintf(stderr, "Error: %s could not allocate memory.\n", __FUNCTION__);
        return NULL;
    }

    instruction->label = NULL;
    instruction->opCode = opCode;
    instruction->arg1 = arg1;
    instruction->arg2 = NULL;
    instruction->arg3 = target;
    instruction->arrow = arrow;
    instruction->numArgs = 2;
    instruction->next = NULL;
    
    return instruction;
}

IlocInstruction *newTriOpInstruction(OpCode *opCode, char *arg1, char *arg2, char *target, Arrow arrow)
{
    IlocInstruction *instruction = malloc(sizeof(IlocInstruction));
    if (instruction == NULL) {
        fprintf(stderr, "Error: %s could not allocate memory.\n", __FUNCTION__);
        return NULL;
    }

    instruction->label = NULL;
    instruction->opCode = opCode;
    instruction->arg1 = arg1;
    instruction->arg2 = arg2;
    instruction->arg3 = target;
    instruction->arrow = arrow;
    instruction->numArgs = 3;
    instruction->next = NULL;
    
    return instruction;
}

IlocInstruction *newLabelInstruction(char *label)
{
    IlocInstruction *instruction = malloc(sizeof(IlocInstruction));
    if (instruction == NULL) {
        fprintf(stderr, "Error: %s could not allocate memory.\n", __FUNCTION__);
        return NULL;
    }

    instruction->label = label;
    instruction->opCode = NOP;
    instruction->arg1 = NULL;
    instruction->arg2 = NULL;
    instruction->arg3 = NULL;
    instruction->numArgs = 0;
    instruction->next = NULL;
    
    return instruction;
}

// TODO freeInstruction
void freeInstruction(IlocInstruction *instruction);

// TODO printInstruction
void printInstruction(IlocInstruction *instruction);

Code *newCode()
{
    Code *code = malloc(sizeof(Code));
    if (code == NULL) {
        fprintf(stderr, "Error: %s could not allocate memory.\n", __FUNCTION__);
        return NULL;
    }

    code->head = NULL;
    code->tail = NULL;
}

void *concatCode(Code *code1, Code *code2)
{
    /* The final code is in code1
     * if code1 is NULL, then assigns code2 to code1
     * if code2 is NULL, no changes
     * if neither is NULL, concatenates both
     */
    if (code1 == NULL) {
        if (code2 == NULL) return;
        code1->head = code2->head;
        code1->tail = code2->tail;
    } 
    else {
        if (code2 == NULL) return;
        code1->tail->next = code2->head;
        code1->tail = code2->tail;
    }
}

void *appendInstruction(Code *code, IlocInstruction *instruction)
{
    if (code == NULL || instruction == NULL) return;

    if (code->head == NULL) {
        code->head = instruction;
        code->tail = instruction;
    } else {
        code->tail->next = instruction;
        code->tail = instruction;
    }
}

// TODO freeCode
void freeCode(Code *code);

void printCode(Code *code)
{
    if (code == NULL) {
        // fprintf(stderr, "Error: %s received as param code = %p.\n", __FUNCTION__, code);
        return;
    }
    IlocInstruction *temp = code->head;
    while (temp != NULL) {
        printInstruction(temp);
        temp = temp->next;
    }
}

char *newTemp()
{
    return newString('t', &tempCounter);
}

char *newLabel()
{
    return newString('l', &labelCounter);
}

char *newString(char c, int *counter)
{
    int size = snprintf(NULL, 0, "%c%d", c, *counter);
    char *string = NULL;
    string = (char *)malloc(size + 1);

    if (string == NULL) {
        fprintf(stderr, "Memory allocation error\n");
        exit(1);
    }

    sprintf(string, size, "%c%d", c, (*counter)++);
    return string;
}