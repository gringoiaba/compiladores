#ifndef AST_H
#define AST_H

typedef struct node {
    char *label;
    int numChildren;
    struct node **children;
    struct node *lastChild;
} Node;

Node *newNode(const char *label);
Node *getLastNode(Node *root, int minChildren);
void addChild(Node *parent, Node *child);
void freeNode(Node *root);
void printNode(Node *root);
void printNodeGraphviz(Node *root);

extern void exporta(void *arvore);

#endif