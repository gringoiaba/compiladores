#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "ast.h"

#define OUTPUT_FILE "output.dot"

Tree *newTree(char *label) 
{
    Tree *t = NULL;
    t = calloc(1, sizeof(Tree));
    if (t != NULL) {
        t->label = label;
        t->numChildren = 0;
        t->children = NULL;
    }
    return t;
}

void addChild(Tree *parent, Tree *child) 
{
    if (parent != NULL && child != NULL) {
        parent->numChildren++;
        parent->children = realloc(parent->children, parent->numChildren * sizeof(Tree *));
        parent->children[parent->numChildren - 1] = child;
    } else {
        fprintf(stderr, "Error: %s tree = %p / %p.\n", __FUNCTION__, parent, child);
    }
}

void freeTree(Tree *root) 
{
    if (root != NULL) {
        for (int i = 0; i < root->numChildren; i++) {
            freeTree(root->children[i]);
        }
        free(root->children);
        free(root->label);
        free(root);
    } else {
        fprintf(stderr, "Error: %s tree = %p.\n", __FUNCTION__, root);
    }
}

static void _printTree(FILE *foutput, Tree *root, int depth) 
{
    if (root != NULL) {
        fprintf(foutput, "%d%*s: Node %s has %d children\n", depth, depth*2, "", root->label, root->numChildren);
        for (int i = 0; i < root->numChildren; i++) {
            _printTree(foutput, root->children[i], depth+1);
        }
    } else {
        fprintf(stderr, "Error: %s tree = %p.\n", __FUNCTION__, root);
    }
}   

static void printTree(Tree *root) 
{
    FILE *foutput = stderr;
    if (root != NULL) {
        _printTree(foutput, root, 0);
    } else {
        fprintf(stderr, "Error: %s tree = %p.\n", __FUNCTION__, root);
    }
}

static void _printTreeGraphviz(FILE *foutput, Tree *root) 
{
    if (root != NULL) {
        fprintf(foutput, "  %ld [ label=\"%s\" ];\n", (long)root, root->label);
        for (int i = 0; i < root->numChildren; i++) {
            fprintf(foutput, "  %ld -> %ld;\n", (long)root, (long)root->children[i]);
            _printTreeGraphviz(foutput, root->children[i]);
        }
    } else {
        fprintf(stderr, "Error: %s tree = %p.\n", __FUNCTION__, root);
    }
}

void printTreeGraphviz(Tree *root) 
{
    FILE *foutput = fopen(OUTPUT_FILE, "w+");
    if (foutput == NULL) {
        fprintf(stderr, "Error: %s could not open file [%s].\n", __FUNCTION__, OUTPUT_FILE);
        return;
    }
    if (root != NULL) {
        fprintf(foutput, "digraph G {\n");
        _printTreeGraphviz(foutput, root);
        fprintf(foutput, "}\n");
    } else {
        fprintf(stderr, "Error: %s tree = %p.\n", __FUNCTION__, root);
    }
}