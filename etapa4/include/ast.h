#ifndef AST_H
#define AST_H

#include "types.h"

typedef struct node {
    char *label;
    int numChildren;
    Type type;
    struct node **children;
} Node;

Node *newNode(const char *label);
Node *getLastNode(Node *root);
void addChild(Node *parent, Node *child);
void freeNode(Node *root);
void printNode(Node *root);
void printNodeGraphviz(Node *root);

extern void exporta(void *arvore);

#endif