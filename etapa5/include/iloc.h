#ifndef ILOC_H
#define ILOC_H

typedef enum arrow {
    NORMAL,
    CONTROL
} Arrow;

typedef enum opCode {
    ADD,
    SUB,
    MULT,
    MULTI,
    DIV,
    ADDI,
    SUBI,
    AND,
    OR,
    LOADI,
    LOADAI,
    STOREAI,
    CBR,
    CMP_LT,
    CMP_LE,
    CMP_EQ,
    CMP_GE,
    CMP_GT,
    CMP_NE,
    JUMPI,
    NOP,
    RET,
} OpCode;

typedef struct ilocInstruction {
    char *label;
    char *opCode;
    char *arg1;
    char *arg2;
    char *arg3;
    Arrow arrow;
    int numArgs;
    struct ilocInstruction *next;
} IlocInstruction;

typedef struct code {
    IlocInstruction *head;
    IlocInstruction *tail;
} Code;

IlocInstruction *newUnOpInstruction(OpCode opCode, char *target, Arrow arrow);
IlocInstruction *newBinOpInstruction(OpCode opCode, char *arg1, char *target, Arrow arrow);
IlocInstruction *newTriOpInstruction(OpCode *opCode, char *arg1, char *arg2, char *target, Arrow arrow);
IlocInstruction *newLabelInstruction(char *label);
void freeInstruction(IlocInstruction *instruction);
void printInstruction(IlocInstruction *instruction);

Code *newCode();
void *concatCode(Code *code1, Code *code2);
void *appendInstruction(Code *code, IlocInstruction *instruction);
void freeCode(Code *code);
void printCode(Code *code);

char *newTemp();
char *newLabel();
char *newString(char c, int *counter);

#endif // ILOC_H