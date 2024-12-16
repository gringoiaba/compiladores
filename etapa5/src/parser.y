%{
       #include <stdio.h>
       #include <string.h>
       #include "stack.h"
       #include "ast.h"
       int yylex(void);
       void yyerror (char const *mensagem);
       int get_line_number();

       extern void *arvore;
       extern TableStack *stack;

       char *functionCallLabel(char *id);
       Node *binOp(char *op, Node *left, Node *right);
       Node *unOp(char *op, Node *operand);
%}

%code requires { 
    #include "ast.h" 
    #include "lex_value.h" 
    #include "symbolTable.h"
    #include "stack.h"
    #include "errors.h"
}
%union {
       LexValue *lexical_value;
       Node *node;
}

%token TK_PR_INT TK_PR_FLOAT
       TK_PR_IF TK_PR_ELSE TK_PR_WHILE
       TK_PR_RETURN
       TK_OC_LE TK_OC_GE
       TK_OC_EQ TK_OC_NE
       TK_OC_AND TK_OC_OR
       TK_ERRO

%token <lexical_value> TK_IDENTIFICADOR
                       TK_LIT_INT TK_LIT_FLOAT


%type <node> program 
             functionList function
             nonEmptyParamList 
             command commandList commandBlock functionCommandBlock
             varDeclaration idList id
             selectionCommand
             assignmentCommand
             functionCall functionID argumentsList
             expression expression1 expression2 expression3 expression4
             term factor operand
             literal identifier
             type

%define parse.error verbose

%%
start: createGlobalScope program closeGlobalScope

createGlobalScope:
       {
              SymbolTable *symbolTable = newSymbolTable();
              stack = newStack(symbolTable);
       }

closeGlobalScope:
       {
              freeStack(stack);
       }

/* A program is composed of an optional list of functions*/
program: functionList { $$ = $1; arvore = $$; /*printNodeGraphviz((Node *) arvore);*/}
       | /* empty */  { $$ = NULL; arvore = $$; }
       ;

functionList: function popScope functionList 
       { 
              $$ = $1;  
              addChild($1, $3);
              concatCode($1->code, $3->code);
       }
            | function popScope              { $$ = $1; }
            ;

function: functionID '=' pushScope nonEmptyParamList '>' type functionCommandBlock 
       { 
              $$ = $1;
              if ($7 != NULL) {
                     addChild($$, $7);
                     // $$->code = $7->code;
              }
              Symbol *symbol = newSymbol(get_line_number(), FUNCTION, $6->type, $1->label); 
              insertSymbol(stack->prev->symbolTable, symbol);
       }
        | functionID '=' pushScope '>' type functionCommandBlock
       { 
              $$ = $1;
              if ($6 != NULL) {
                     addChild($$, $6);
                     // $$->code = $6->code;
              }
              Symbol *symbol = newSymbol(get_line_number(), FUNCTION, $5->type, $1->label);
              insertSymbol(stack->prev->symbolTable, symbol); 
       };

nonEmptyParamList: functionID '<' '-' type                            
       { 
              $$ = NULL;
              Symbol *symbol = newSymbol(get_line_number(), VARIABLE, $4->type, $1->label); 
              insertSymbol(stack->symbolTable, symbol);
       }
                 | functionID '<' '-' type TK_OC_OR nonEmptyParamList
       { 
              $$ = NULL;
              Symbol *symbol = newSymbol(get_line_number(), VARIABLE, $4->type, $1->label);
              insertSymbol(stack->symbolTable, symbol);
       }
                 ;

functionID: TK_IDENTIFICADOR 
       { 
              $$ = newNode($1->value);
              freeLexValue($1); 
       };

functionCommandBlock: '{' commandList { printStack(stack);} '}'     { $$ = $2; }
                    | '{' { printStack(stack); }'}'                 { $$ = NULL; }
                    ;

commandBlock: '{' pushScope commandList popScope'}' { $$ = $3; }
            | '{' '}'                      { $$ = NULL; }
            ;

commandList: command ';'                   { $$ = $1; }
           | command ';' commandList 
       { 
              $$ = $1;
              if ($$ != NULL) { 
                     if ($3 != NULL) {
                            addChild($$, $3);
                            // concatCode($$->code, $3->code);
                     }
              }
              else $$ = $3;
       }
           | varDeclaration ';'             { $$ = $1; }
           | varDeclaration ';' commandList 
       {
              $$ = $1;
              if ($$ != NULL) {
                     if ($3 != NULL) {
                            Node *lastNode = getLastNode($$);
                            addChild(lastNode, $3);
                            // if (lastNode->code != NULL) {
                            //        concatCode(lastNode->code, $3->code);
                            // } else { 
                            //        $$->code = $3->code;
                            // }    
                     }
              }
              else $$ = $3;
       };

command: commandBlock                                { $$ = $1; }
       | selectionCommand                            { $$ = $1; }              
       | functionCall                                { $$ = $1; }
       | assignmentCommand                           { $$ = $1; }     
       | TK_PR_RETURN expression                     { $$ = newNode("return"); addChild($$, $2); }  
       | TK_PR_WHILE '(' expression ')' commandBlock { $$ = newNode("while"); addChild($$, $3); if ($5 != NULL) addChild($$, $5); }
       ;

varDeclaration: type idList 
{ 
       $$ = $2;
       setUndefinedType(stack->symbolTable, $1->type);
}

/* It is possible to declare multiple variables at a time */ 
idList: id            { $$ = $1; }
      | id ',' idList 
      { 
              $$ = $1;
              if ($$ != NULL) { 
                     if ($3 != NULL) addChild($$, $3); 
              }
              else $$ = $3; 
       }
      ;

/* A variable can be optionaly initialized if followed by TK_OC_LE '<=' and a literal */
id: identifier                  
{ 
       Symbol *symbol = newSymbol(get_line_number(), VARIABLE, UNDEFINED, $1->label);
       insertSymbol(stack->symbolTable, symbol);
       $$ = NULL;
}
  | identifier TK_OC_LE literal 
{
       Symbol *symbol = newSymbol(get_line_number(), VARIABLE, UNDEFINED, $1->label);
       insertSymbol(stack->symbolTable, symbol);
       $$ = newNode("<=");
       addChild($$, $1);
       addChild($$, $3); 
};

/* The selection command IF is followed by an optional ELSE */
selectionCommand: TK_PR_IF '(' expression ')' commandBlock TK_PR_ELSE commandBlock
       { 
              $$ = newNode("if");
              addChild($$, $3);
              if ($5 != NULL) addChild($$, $5);
              if ($7 != NULL) addChild($$, $7);
       }
                | TK_PR_IF '(' expression ')' commandBlock
       { 
              $$ = newNode("if");
              addChild($$, $3); 
              if ($5 != NULL) addChild($$, $5); 
       };

functionCall: identifier '(' argumentsList ')' 
{ 
       checkDeclaration(stack, $1->label, get_line_number());
       checkNature(stack, $1->label, FUNCTION, get_line_number());
       $$ = newNode(functionCallLabel($1->label));
       addChild($$, $3); 
};

assignmentCommand: identifier '=' expression 
{      
       checkDeclaration(stack, $1->label, get_line_number());
       checkNature(stack, $1->label, VARIABLE, get_line_number());
       $$ = newNode("="); 
       addChild($$, $1); 
       addChild($$, $3);
       $$->type = searchSymbolInStack(stack, $1->label)->type; 

       // $$->code = $3->code;
       // char *temp = newTemp();
       // appendTac($$->code, newTac("loadI", temp, NULL));
}
                 ;

argumentsList: expression ',' argumentsList { $$ = $1; addChild($1, $3); }
            | expression                    { $$ = $1; }
            ;

expression: expression TK_OC_OR expression1 { $$ = binOp("|", $1, $3); }
          | expression1                     { $$ = $1; }
          ;

expression1: expression1 TK_OC_AND expression2 { $$ = binOp("&", $1, $3); }
           | expression2                       { $$ = $1; }
           ;

expression2: expression2 TK_OC_NE expression3 { $$ = binOp("!=", $1, $3); }
           | expression2 TK_OC_EQ expression3 { $$ = binOp("==", $1, $3); }
           | expression3                      { $$ = $1; }
           ;

expression3: expression3 TK_OC_GE expression4 { $$ = binOp(">=", $1, $3); }
           | expression3 TK_OC_LE expression4 { $$ = binOp("<=", $1, $3); }
           | expression3 '>' expression4      { $$ = binOp(">", $1, $3); }
           | expression3 '<' expression4      { $$ = binOp("<", $1, $3); }
           | expression4                      { $$ = $1; }
           ;

expression4: expression4 '+' term { $$ = binOp("+", $1, $3); }
           | expression4 '-' term { $$ = binOp("-", $1, $3); }
           | term                 { $$ = $1; }
           ;

term: term '%' factor { $$ = binOp("%", $1, $3); }
    | term '*' factor { $$ = binOp("*", $1, $3); }
    | term '/' factor { $$ = binOp("/", $1, $3); }
    | factor          { $$ = $1; }
    ;

factor: '!' operand { $$ = unOp("!", $2); }
      | '-' operand { $$ = unOp("-", $2); }
      | operand     { $$ = $1; }
      ;

operand: '(' expression ')' { $$ = $2; }
       | functionCall       { $$ = $1; }
       | literal            { $$ = $1; }
       | TK_IDENTIFICADOR   
       { 
              checkDeclaration(stack, $1->value, get_line_number());
              checkNature(stack, $1->value, VARIABLE, get_line_number());
              $$ = newNode($1->value);
              $$->type = searchSymbolInStack(stack, $1->value)->type; 
              freeLexValue($1);


       }
       ;

literal: TK_LIT_INT   
{ 
       $$ = newNode($1->value);
       $$->type = INT;
       freeLexValue($1);
}
       | TK_LIT_FLOAT 
{ 
       $$ = newNode($1->value); 
       $$->type = FLOAT;
       freeLexValue($1); 
};

identifier: TK_IDENTIFICADOR 
{ 
       $$ = newNode($1->value); 
       freeLexValue($1); 
};

type: TK_PR_INT   { $$ = newNode("int"); $$->type = INT; }
    | TK_PR_FLOAT { $$ = newNode("float"); $$->type = FLOAT; }
    ;

pushScope: 
{ 
       SymbolTable *symbolTable = newSymbolTable();
       symbolTable->offset = stack->symbolTable->size;
       pushTable(&stack, symbolTable);
};

popScope: 
{ 
       popTable(&stack); 
};

%%

void yyerror (char const *mensagem) 
{
        fprintf(stderr, "Error at line %d: %s\n",get_line_number(), mensagem);
}

/* Returns label string for a function call as "call functionID' */
char *functionCallLabel(char *id)
{
       char *label = (char *) malloc(strlen(id) + strlen("call ") + 2);

       if (label == NULL) {
              return NULL;
       }

       strcpy(label, "call ");
       strcat(label, id);

       return label;
}

Node *binOp(char *op, Node *left, Node *right)
{
       Node *node = newNode(op);
       addChild(node, left);
       addChild(node, right);
       node->type = typeInfer(left->type, right->type);
       return node;
}

Node *unOp(char *op, Node *operand)
{
       Node *node = newNode(op);
       addChild(node, operand);
       node->type = operand->type;
       return node;
}