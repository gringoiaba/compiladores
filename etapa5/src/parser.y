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
       void genBinOpCode(Node *head, Node *op1, Node *op2, OpCode opCode);
       void check(TableStack *stack, char *label, Nature nature, int line);
%}

%code requires { 
    #include "ast.h" 
    #include "lex_value.h" 
    #include "symbolTable.h"
    #include "stack.h"
    #include "errors.h"
    #include "iloc.h"
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
program: functionList 
       { 
              $$ = $1;
              arvore = $$; 
              
              // if ($$->code->head != NULL) {
              //        Code *code = newCode();
              //        appendInstruction(code, newBinOpInstruction(LOADI, "0", "rfp"));
              //        concatCode(code, $$->code);
              //        $$->code = code;
              // }
              
              // Is this really necessary?
              Code *code = newCode();
              appendInstruction(code, newBinOpInstruction(LOADI, "0", "rfp"));
              concatCode(code, $$->code);
              $$->code = code;
              printCode($$->code); /*printNodeGraphviz((Node *) arvore);*/}
       | /* empty */  { $$ = NULL; arvore = $$; }
       ;

functionList: function popScope functionList 
       { 
              $$ = $1;  
              addChild($1, $3);
              $$->code = newCode();
              concatCode($$->code, $1->code);
              concatCode($$->code, $3->code);
       }
            | function popScope              { $$ = $1; }
            ;

function: functionID '=' pushScope nonEmptyParamList '>' type functionCommandBlock 
       { 
              $$ = $1;
              if ($7 != NULL) {
                     addChild($$, $7);
                     $$->code = $7->code;
              }
              Symbol *symbol = newSymbol(get_line_number(), FUNCTION, $6->type, $1->label); 
              insertSymbol(stack->prev->symbolTable, symbol);
       }
        | functionID '=' pushScope '>' type functionCommandBlock
       { 
              $$ = $1;
              if ($6 != NULL) {
                     addChild($$, $6);
                     $$->code = $6->code;
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

functionCommandBlock: '{' commandList /*{ printStack(stack); }*/ '}'     { $$ = $2; }
                    | '{' '}'                 { $$ = NULL; }
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
                            concatCode($$->code, $3->code);
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
                            concatCode($$->code, $3->code);
                            // if (lastNode->code != NULL) {
                            //        concatCode($$>code, $3->code);
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
       | TK_PR_RETURN expression                     
       { 
              $$ = newNode("return"); addChild($$, $2);
              $$->code = NULL;
              // TODO: what does return produces as IR?
              // $$->code = $2->code;
              // appendInstruction($$->code, newUnOpInstruction(RET, $2->temp));
       }  
       | TK_PR_WHILE '(' expression ')' commandBlock 
       { 
              $$ = newNode("while"); addChild($$, $3); if ($5 != NULL) addChild($$, $5); 

              char *cond = newLabel();
              char *tBranch = newLabel();
              char *fBranch = newLabel();

              $$->code = newCode();
              appendInstruction($$->code, newLabelInstruction(cond));
              concatCode($$->code, $3->code);
              appendInstruction($$->code, newTriOpInstruction(CBR, $3->temp, tBranch, fBranch));
              appendInstruction($$->code, newLabelInstruction(tBranch));
              concatCode($$->code, $5->code);
              appendInstruction($$->code, newUnOpInstruction(JUMPI, cond));
              appendInstruction($$->code, newLabelInstruction(fBranch));
       }
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
                     concatCode($$->code, $3->code);
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

       $$->code = newCode();
       $$->temp = $3->temp;
       char *offsetStr = getOffsetStr(symbol);
       IlocInstruction *load = newBinOpInstruction(LOADI, $3->label, $$->temp);
       IlocInstruction *store = newTriOpInstruction(STOREAI, $$->temp, "rfp", offsetStr);
       appendInstruction($$->code, load);
       appendInstruction($$->code, store);
};

/* The selection command IF is followed by an optional ELSE */
selectionCommand: TK_PR_IF '(' expression ')' commandBlock TK_PR_ELSE commandBlock
       { 
              $$ = newNode("if");
              addChild($$, $3);
              if ($5 != NULL) addChild($$, $5);
              if ($7 != NULL) addChild($$, $7);

              char *tBranch = newLabel();
              char *fBranch = newLabel();
              char *end = newLabel();

              $$->code = newCode();
              concatCode($$->code, $3->code);
              appendInstruction($$->code, newTriOpInstruction(CBR, $3->temp, tBranch, fBranch));
              appendInstruction($$->code, newLabelInstruction(tBranch));
              concatCode($$->code, $5->code);
              appendInstruction($$->code, newUnOpInstruction(JUMPI, end));
              appendInstruction($$->code, newLabelInstruction(fBranch));
              concatCode($$->code, $7->code);
              appendInstruction($$->code, newLabelInstruction(end));
       }
                | TK_PR_IF '(' expression ')' commandBlock
       { 
              $$ = newNode("if");
              addChild($$, $3); 
              if ($5 != NULL) addChild($$, $5); 

              char *tBranch = newLabel();
              char *fBranch = newLabel();

              $$->code = newCode();
              concatCode($$->code, $3->code);
              appendInstruction($$->code, newTriOpInstruction(CBR, $3->temp, tBranch, fBranch));
              appendInstruction($$->code, newLabelInstruction(tBranch));
              concatCode($$->code, $5->code);
              appendInstruction($$->code, newLabelInstruction(fBranch));
       };

functionCall: identifier '(' argumentsList ')' 
{ 
       check(stack, $1->label, FUNCTION, get_line_number());
       $$ = newNode(functionCallLabel($1->label));
       addChild($$, $3); 
       $$->code = newCode();
};

assignmentCommand: identifier '=' expression 
{      
       check(stack, $1->label, VARIABLE, get_line_number());
       $$ = newNode("="); 
       addChild($$, $1); 
       addChild($$, $3);
       Symbol *thisSymbol = searchSymbolInStack(stack, $1->label);
       $$->type = thisSymbol->type; 

       $$->code = $3->code;
       $$->temp = $3->temp;
       char *offsetStr = getOffsetStr(thisSymbol);
       IlocInstruction *store = newTriOpInstruction(STOREAI, $3->temp, "rfp", offsetStr);
       appendInstruction($$->code, store);
}
                 ;

argumentsList: expression ',' argumentsList { $$ = $1; addChild($1, $3); }
            | expression                    { $$ = $1; }
            ;

expression: expression TK_OC_OR expression1 
       { 
              $$ = binOp("|", $1, $3);
              genBinOpCode($$, $1, $3, OR);
       }
          | expression1                     { $$ = $1; }
          ;

expression1: expression1 TK_OC_AND expression2 
       { 
              $$ = binOp("&", $1, $3);
              genBinOpCode($$, $1, $3, AND);
       }
           | expression2                       { $$ = $1; }
           ;

expression2: expression2 TK_OC_NE expression3 
       { 
              $$ = binOp("!=", $1, $3);
              genBinOpCode($$, $1, $3, CMP_NE);
       }
           | expression2 TK_OC_EQ expression3 
       { 
              $$ = binOp("==", $1, $3); 
              genBinOpCode($$, $1, $3, CMP_EQ);
       }
           | expression3                      { $$ = $1; }
           ;

expression3: expression3 TK_OC_GE expression4 
       { 
              $$ = binOp(">=", $1, $3);
              genBinOpCode($$, $1, $3, CMP_GE);
       }
           | expression3 TK_OC_LE expression4 
       { 
              $$ = binOp("<=", $1, $3); 
              genBinOpCode($$, $1, $3, CMP_LE);
       }
           | expression3 '>' expression4      
       { 
              $$ = binOp(">", $1, $3); 
              genBinOpCode($$, $1, $3, CMP_GT);
       }
           | expression3 '<' expression4      
       { 
              $$ = binOp("<", $1, $3); 
              genBinOpCode($$, $1, $3, CMP_LT);
       }
           | expression4 { $$ = $1; }
           ;

expression4: expression4 '+' term 
       { 
              $$ = binOp("+", $1, $3);
              genBinOpCode($$, $1, $3, ADD);
       }
           | expression4 '-' term 
       { 
              $$ = binOp("-", $1, $3); 
              genBinOpCode($$, $1, $3, SUB);
       }
           | term { $$ = $1; }
           ;

term: term '%' factor 
       { 
              $$ = binOp("%", $1, $3); 
              $$->temp = NULL;
              $$->code = NULL;
       }
    | term '*' factor 
       { 
              $$ = binOp("*", $1, $3);
              genBinOpCode($$, $1, $3, MULT);
       }
    | term '/' factor 
       { 
              $$ = binOp("/", $1, $3);
              genBinOpCode($$, $1, $3, DIV);
       }
    | factor          { $$ = $1; }
    ;

factor: '!' operand 
       { 
              $$ = unOp("!", $2);
              // TODO: Decide what I wanna do here 
              $$->code = $2->code;
              $$->temp = newTemp();
              char *aux = newTemp();
              IlocInstruction *loadI = newBinOpInstruction(LOADI, "0", aux);
              IlocInstruction *cmp = newTriOpInstruction(CMP_EQ, $2->temp, aux, $$->temp);

              appendInstruction($$->code, loadI);
              appendInstruction($$->code, cmp);
       }
      | '-' operand 
       { 
              $$ = unOp("-", $2);

              $$->code = newCode();
              concatCode($$->code, $2->code);
              $$->temp = newTemp();
              appendInstruction($$->code, newTriOpInstruction(MULTI, $2->temp, "-1", $$->temp));
       }
      | operand     { $$ = $1; }
      ;

operand: '(' expression ')' { $$ = $2; }
       | functionCall       { $$ = $1; }
       | literal            { $$ = $1; }
       | TK_IDENTIFICADOR   
       { 
              check(stack, $1->value, VARIABLE, get_line_number());
              $$ = newNode($1->value);
              $$->type = searchSymbolInStack(stack, $1->value)->type; 

              $$->code = newCode();
              $$->temp = newTemp();
              char *offsetStr = getOffsetStr(searchSymbolInStack(stack, $1->value));
              IlocInstruction *loadAI = newTriOpInstruction(LOADAI, "rfp", offsetStr, $$->temp);
              appendInstruction($$->code, loadAI);
              freeLexValue($1);
       }
       ;

literal: TK_LIT_INT   
{ 
       $$ = newNode($1->value);
       $$->type = INT;
       $$->temp = newTemp();
       $$->code = newCode();
       appendInstruction($$->code, newBinOpInstruction(LOADI, $$->label, $$->temp));
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

void genBinOpCode(Node *head, Node *op1, Node *op2, OpCode opCode)
{
       head->code = newCode();
       head->temp = newTemp();
       concatCode(head->code, op1->code);
       concatCode(head->code, op2->code);
       IlocInstruction *op = newTriOpInstruction(opCode, op1->temp, op2->temp, head->temp);
       appendInstruction(head->code, op);
}

void check(TableStack *stack, char *label, Nature nature, int line)
{
       checkDeclaration(stack, label, line);
       checkNature(stack, label, nature, line);
}