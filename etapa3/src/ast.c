#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "ast.h"

#define OUTPUT_FILE "output.dot"

/* AST FUNCTIONS ADAPTED FROM TUTORIAL */ 

Node *newNode(const char *label) 
{
    Node *t = NULL;
    t = calloc(1, sizeof(Node));
    if (t != NULL) {
        t->label = strdup(label);
        t->numChildren = 0;
        t->children = NULL;
        t->lastChild = NULL;
    }
    return t;
}

void addChild(Node *parent, Node *child) 
{
    if (parent != NULL && child != NULL) {
        parent->numChildren++;
        parent->children = realloc(parent->children, parent->numChildren * sizeof(Node*));
        parent->children[parent->numChildren-1] = child;
    } else {
        fprintf(stderr, "Error: %s received as param tree = %p / %p.\n", __FUNCTION__, parent, child);
    }
}

Node *getLastNode(Node *root, int minChildren)
{
    if (root != NULL) {
        int n = root->numChildren;
        while(root->children[n-1] != NULL && n > minChildren) {
            root = root->children[n-1];
            n = root->numChildren;
        }
    return root;
    }
    else{
        printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, root);
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
        fprintf(stderr, "Error: %s received as param tree = %p.\n", __FUNCTION__, root);
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
        fprintf(stderr, "Error: %s received as param tree = %p.\n", __FUNCTION__, root);
    }
}   

void printNode(Node *root) 
{
    FILE *foutput = stderr;
    if (root != NULL) {
        _printNode(foutput, root, 0);
    } else {
        fprintf(stderr, "Error: %s received as param tree = %p.\n", __FUNCTION__, root);
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
        fprintf(stderr, "Error: %s received as param tree = %p.\n", __FUNCTION__, root);
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
        fprintf(stderr, "Error: %s received as param tree = %p.\n", __FUNCTION__, root);
    }
}

void printEdges(Node *node)
{
    if (node == NULL) {
        return;
    }

    for (int i = 0; i < node->numChildren; i++) {
        if (node->children[i] != NULL) {
            fprintf(stdout, "%p, %p;\n", node, node->children[i]);
            printEdges(node->children[i]);
        }
    }
}

void printLabels(Node *node)
{
    if (node == NULL) {
        return;
    }

    fprintf(stdout, "%p [label=\"%s\"];\n", node, node->label);

    for (int i = 0; i < node->numChildren; i++) {
        if (node->children[i] != NULL) {
            printLabels(node->children[i]);
        }
    }
}

/* Prints the tree in the specified format */
void exporta(void *arvore) 
{
    if (arvore == NULL) {
        return;
    }

    Node *root = (Node *)arvore;
    printEdges(root);
    fprintf(stdout, "\n");
    printLabels(root);

    freeNode(root);

    return;
}
