#ifndef AST_H
#define AST_H

typedef struct node {
    char *label;
    int numChildren;
    struct node **children;
} Node;

Node *newNode(const char *label);
void addChild(Node *parent, Node *child);
void freeNode(Node *root);
void printNode(Node *root);
void printNodeGraphviz(Node *root);

extern void exporta(void *arvore);

#endif