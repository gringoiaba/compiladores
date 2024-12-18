#ifndef ILOC_H
#define ILOC_H

typedef enum opCode {
    NOP,
    ADD,
    SUB,
    MULT,
    DIV,
    ADDI,
    SUBI,
    RSUBI,
    MULTI,
    DIVI,
    RDIVI,
    AND,
    OR,
    RET,
    LOADI,
    LOAD,
    LOADAI,
    STORE,
    STOREAI,
    JUMP,
    JUMPI,
    CBR,
    CMP_LT,
    CMP_LE,
    CMP_EQ,
    CMP_GE,
    CMP_GT,
    CMP_NE,
} OpCode;

typedef struct ilocInstruction {
    char *label;
    OpCode opCode;
    char *arg1;
    char *arg2;
    char *arg3;
    int numArgs;
    struct ilocInstruction *next;
} IlocInstruction;

typedef struct code {
    IlocInstruction *head;
    IlocInstruction *tail;
} Code;

IlocInstruction *newUnOpInstruction(OpCode opCode, char *target);
IlocInstruction *newBinOpInstruction(OpCode opCode, char *arg1, char *target);
IlocInstruction *newTriOpInstruction(OpCode opCode, char *arg1, char *arg2, char *target);
IlocInstruction *newLabelInstruction(char *label);
void freeInstruction(IlocInstruction *instruction);
void printInstruction(IlocInstruction *instruction);

Code *newCode();
void concatCode(Code *code1, Code *code2);
void appendInstruction(Code *code, IlocInstruction *instruction);
void freeCode(Code *code);
void printCode(Code *code);

char *newTemp();
char *newLabel();
char *newString(char c, int *counter);
char *opCodeToString(OpCode opCode);

#endif // ILOC_H