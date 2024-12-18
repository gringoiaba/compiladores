#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "iloc.h"

int tempCounter = 0;
int labelCounter = 0;


IlocInstruction *newUnOpInstruction(OpCode opCode, char *target)
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
    instruction->numArgs = 1;
    instruction->next = NULL;
    
    return instruction;
}

IlocInstruction *newBinOpInstruction(OpCode opCode, char *arg1, char *target)
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
    instruction->numArgs = 2;
    instruction->next = NULL;
    
    return instruction;
}

IlocInstruction *newTriOpInstruction(OpCode opCode, char *arg1, char *arg2, char *target)
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
void freeInstruction(IlocInstruction *instruction)
{
    return;
}

// TODO printInstruction
void printInstruction(IlocInstruction *instruction)
{
    if (instruction->label != NULL) {
        printf("%s:\n", instruction->label);
    }

    OpCode op = instruction->opCode;
    char arrow[3];

    if (op >= JUMP) {
        strcpy(arrow, "->");
    } else { 
        strcpy(arrow, "=>");
    }

    if (op == NOP) {
        // fprintf(stdout, "nop\n");
    }
    else if (op == STOREAI || op == CBR) {
        fprintf(stdout, "%-7s %s %s %s, %s\n", 
            opCodeToString(op),
            instruction->arg1,
            arrow, 
            instruction->arg2, 
            instruction->arg3);
    } 
    else if (instruction->numArgs == 1) {
        fprintf(stdout, "%-7s %s %s\n", 
            opCodeToString(op),
            arrow,
            instruction->arg3);
    }
    else if (instruction->numArgs == 2) {
        fprintf(stdout, "%-7s %s %s %s\n", 
            opCodeToString(op),
            instruction->arg1,
            arrow,
            instruction->arg3);
    }
    else {
        fprintf(stdout, "%-7s %s, %s %s %s\n", 
            opCodeToString(op),
            instruction->arg1,
            instruction->arg2,
            arrow,
            instruction->arg3);
    }
}

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

void concatCode(Code *code1, Code *code2)
{
    /* The final code is in code1
     * if code1 is NULL, then assigns code2 to code1
     * if code2 is NULL, no changes
     * if neither is NULL, concatenates both
     */
    if (code1 == NULL) {
        if (code2 == NULL) {
            code1 = newCode(); 
            return;
        }
        code1->head = code2->head;
        code1->tail = code2->tail;
    } 
    else {
        if (code2 == NULL) return;
        if (code1->tail == NULL) {
            code1->head = code2->head;
            code1->tail = code2->tail;
            return;
        }
        code1->tail->next = code2->head;
        code1->tail = code2->tail;
    }
}

void appendInstruction(Code *code, IlocInstruction *instruction)
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
    return newString('r', &tempCounter);
}

char *newLabel()
{
    return newString('L', &labelCounter);
}

char *newString(char c, int *counter)
{
    int size = snprintf(NULL, 0, "%c%d", c, *counter) + 1;
    char *string = (char *)malloc(size);

    if (string == NULL) {
        fprintf(stderr, "Memory allocation error\n");
        return NULL;
    }

    snprintf(string, size, "%c%d", c, (*counter)++);
    return string;
}

char *opCodeToString(OpCode opCode)
{
    switch (opCode)
    {
    case NOP:
        return "nop";
        break;
    case ADD:
        return "add";
        break;
    case SUB:
        return "sub";
        break;
    case MULT:
        return "mult";
        break;
    case DIV:
        return "div";
        break;
    case ADDI:
        return "addI";
        break;
    case SUBI:  
        return "subI";
        break;
    case RSUBI:
        return "rsubI";
        break;
    case MULTI:
        return "multI";
        break;
    case DIVI:
        return "divI";
        break;
    case RDIVI:
        return "rdivI";
        break;
    case AND:
        return "and";
        break;
    case OR:
        return "or";
        break;
    case LOADI: 
        return "loadI";
        break;
    case LOAD:
        return "load";
        break;
    case LOADAI:
        return "loadAI";
        break;
    case STORE:
        return "store";
        break;
    case STOREAI:
        return "storeAI";
        break;
    case JUMPI:
        return "jumpI";
        break;
    case JUMP:
        return "jump";
        break;
    case CBR:
        return "cbr";
        break;
    case CMP_LT:    
        return "cmp_LT";
        break;
    case CMP_LE:
        return "cmp_LE";
        break;
    case CMP_EQ:
        return "cmp_EQ";
        break;
    case CMP_GE:
        return "cmp_GE";
        break;
    case CMP_GT:
        return "cmp_GT";
        break;
    case CMP_NE:
        return "cmp_NE";
        break;
    default:
        break;
    }
}