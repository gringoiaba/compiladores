#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "ast.h"

#define OUTPUT_FILE "output.dot"

/* AST FUNCTIONS ADAPTED FROM TUTORIAL */ 

Node *newNode(char *label) 
{
    Node *t = NULL;
    t = calloc(1, sizeof(Node));
    if (t != NULL) {
        t->label = label;
        t->numChildren = 0;
        t->children = NULL;
    }
    return t;
}

void addChild(Node *parent, Node *child) 
{
    if (parent != NULL && child != NULL) {
        parent->numChildren++;
        parent->children = realloc(parent->children, parent->numChildren * sizeof(Node *));
        parent->children[parent->numChildren - 1] = child;
    } else {
        fprintf(stderr, "Error: %s tree = %p / %p.\n", __FUNCTION__, parent, child);
    }
}

void freeNode(Node *root) 
{
    if (root != NULL) {
        for (int i = 0; i < root->numChildren; i++) {
            freeNode(root->children[i]);
        }
        free(root->children);
        free(root->label);
        free(root);
    } else {
        fprintf(stderr, "Error: %s tree = %p.\n", __FUNCTION__, root);
    }
}

static void _printNode(FILE *foutput, Node *root, int depth) 
{
    if (root != NULL) {
        fprintf(foutput, "%d%*s: Node %s has %d children\n", depth, depth*2, "", root->label, root->numChildren);
        for (int i = 0; i < root->numChildren; i++) {
            _printNode(foutput, root->children[i], depth+1);
        }
    } else {
        fprintf(stderr, "Error: %s tree = %p.\n", __FUNCTION__, root);
    }
}   

void printNode(Node *root) 
{
    FILE *foutput = stderr;
    if (root != NULL) {
        _printNode(foutput, root, 0);
    } else {
        fprintf(stderr, "Error: %s tree = %p.\n", __FUNCTION__, root);
    }
}

/* Exports a tree to a .dot file 
 * It can be used to visualize the tree using Graphviz 
 */
static void _printNodeGraphviz(FILE *foutput, Node *root) 
{
    if (root != NULL) {
        fprintf(foutput, "  %ld [ label=\"%s\" ];\n", (long)root, root->label);
        for (int i = 0; i < root->numChildren; i++) {
            fprintf(foutput, "  %ld -> %ld;\n", (long)root, (long)root->children[i]);
            _printNodeGraphviz(foutput, root->children[i]);
        }
    } else {
        fprintf(stderr, "Error: %s tree = %p.\n", __FUNCTION__, root);
    }
}

void printNodeGraphviz(Node *root) 
{
    FILE *foutput = fopen(OUTPUT_FILE, "w+");
    if (foutput == NULL) {
        fprintf(stderr, "Error: %s could not open file [%s].\n", __FUNCTION__, OUTPUT_FILE);
        return;
    }
    if (root != NULL) {
        fprintf(foutput, "digraph G {\n");
        _printNodeGraphviz(foutput, root);
        fprintf(foutput, "}\n");
    } else {
        fprintf(stderr, "Error: %s tree = %p.\n", __FUNCTION__, root);
    }
}

void exporta(void *arvore) 
{
    if (arvore == NULL) {
        return;
    }

    Node *root = (Node *)arvore;
        fprintf(stdout, "%p [label=\"%s\"];\n", root, root->label);

    for (int i = 0; i < root->numChildren; i++) {
        exporta(root->children[i]);
        fprintf(stdout, "%p, %p;\n", root, root->children[i]);
    }

    freeNode(root);

    return;
}