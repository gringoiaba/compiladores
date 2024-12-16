#ifndef AST_H
#define AST_H

#include "types.h"
#include "iloc.h"

typedef struct node {
    char *label;
    int numChildren;
    Type type;
    struct node **children;

    Code *code;
    char *temp;
} Node;

/* Creates an AST 'node' */
Node *newNode(const char *label);

/* Adds 'node' child to a parents 'node' */
void addChild(Node *parent, Node *child);

/* Gets the right-most (right recursion) deepest node of the AST.
 * Used during variable declaration, as the head of the 
 * production should always be the last declared variable
 */
Node *getLastNode(Node *root);

/* Frees allocated node and its children */
void freeNode(Node *root);

/* Auxiliary funtion for visualiazing the AST and its nodes */
void printNode(Node *root);

/* Prints the AST in the syntax of application Graphviz */
void printNodeGraphviz(Node *root);

/* Exports the AST as specified in the documentation */
extern void exporta(void *arvore);

#endif