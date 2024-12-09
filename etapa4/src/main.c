#include <stdio.h>
#include "stack.h"
#include "errors.h"

extern int yyparse(void);
extern int yylex_destroy(void);
void *arvore = NULL;
TableStack *stack = NULL;

void exporta (void *arvore);
int main (int argc, char **argv)
{
  int ret = yyparse(); 
  exporta (arvore);
  yylex_destroy();
  return ret;
}
