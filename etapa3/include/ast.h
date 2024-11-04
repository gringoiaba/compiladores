#ifndef TREE_H
#define TREE_H

typedef struct tree {
    char *label;
    int numChildren;
    struct tree **children;
} Tree;

Tree *newTree(char *label);
void addChild(Tree *parent, Tree *child);
void freeTree(Tree *root);
void printTree(Tree *root);
void printTreeGraphviz(Tree *root);

#endif