%{
       #include <stdio.h>
       #include <string.h>
       int yylex(void);
       void yyerror (char const *mensagem);
       int get_line_number();
       extern void *arvore;
       char *functionCallLabel(char *id);
%}

%code requires { 
    #include "ast.h" 
    #include "lex_value.h" 
}
%union {
       LexValue *lexical_value;
       Node *node;
}

%token <lexical_value> TK_PR_INT TK_PR_FLOAT
                       TK_PR_IF TK_PR_ELSE TK_PR_WHILE
                       TK_PR_RETURN
                       TK_OC_LE TK_OC_GE
                       TK_OC_EQ TK_OC_NE
                       TK_OC_AND TK_OC_OR
                       TK_IDENTIFICADOR
                       TK_LIT_INT TK_LIT_FLOAT
                       TK_ERRO

%type <lexical_value> literal

%type <node> program 
             functionList function
             nonEmptyParamList 
             command commandList commandBlock
             varDeclaration idList id
             selectionCommand
             functionCall argumentsList
             expression expression1 expression2 expression3 expression4
             term factor operand

%define parse.error verbose

%%

/* A program is composed of an optional list of functions*/
program: functionList { $$ = $1; arvore = $$; }
       | /* empty */  { $$ = NULL; arvore = $$; }
       ;

functionList: function functionList { $$ = $1; addChild($1, $2); }
            | function              { $$ = $1; }
            ;

function: TK_IDENTIFICADOR '=' nonEmptyParamList '>' type commandBlock 
              { $$ = newNode($1->value); if ($6 != NULL) addChild($$, $6); }
        | TK_IDENTIFICADOR '=' '>' type commandBlock
              { $$ = newNode($1->value); if ($5 != NULL) addChild($$, $5); }
        ;

nonEmptyParamList: TK_IDENTIFICADOR '<' '-' type                            { $$ = NULL;}
                 | nonEmptyParamList TK_OC_OR TK_IDENTIFICADOR '<' '-' type { $$ = NULL; }
                 ;

commandBlock: '{' commandList '}' { $$ = $2; }
            | '{' '}'             { $$ = NULL; }
            ;

commandList: commandList command ';' { 
              if ($1 != NULL) {
                     $$ = $1;
                     if ($2 != NULL) {
                            addChild($$, $2);
                     }
              } else {
                     $$ = $2;
              } 
       }
           | command ';'             { $$ = $1; }
           ;

command: commandBlock                                { $$ = $1; }
       | varDeclaration                              { $$ = $1; }
       | selectionCommand                            { $$ = $1; }              
       | functionCall                                { $$ = $1; }
       | TK_IDENTIFICADOR '=' expression             { $$ = newNode("="); addChild($$, newNode($1->value)); addChild($$, $3); }
       | TK_PR_RETURN expression                     { $$ = newNode("return"); addChild($$, $2); }  
       | TK_PR_WHILE '(' expression ')' commandBlock { $$ = newNode("while"); addChild($$, $3); if ($5 != NULL) addChild($$, $5); }
       ;
       
varDeclaration: type idList { $$ = $2; }

/* It is possible to declare multiple variables at a time */ 
idList: id            { $$ = $1; }
      | id ',' idList { 
              if ($1 != NULL) {
                     $$ = $1;
                     if ($3 != NULL) {
                            addChild($$, $3);
                     }
              } else {
                     $$ = $3; } }
      ;

/* A variable can be optionaly initialized if followed by TK_OC_LE '<=' and a literal */
id: TK_IDENTIFICADOR                  { $$ = NULL; }
  | TK_IDENTIFICADOR TK_OC_LE literal { $$ = newNode("<="); addChild($$, newNode($1->value)); addChild($$, newNode($3->value)); }
  ;

/* The selection command IF is followed by an optional ELSE */
selectionCommand: TK_PR_IF '(' expression ')' commandBlock TK_PR_ELSE commandBlock
                     { $$ = newNode("if"); addChild($$, $3); if ($5 != NULL) addChild($$, $5); newNode("else"); if ($7 != NULL) addChild($$, $7); }
                | TK_PR_IF '(' expression ')' commandBlock
                     { $$ = newNode("if"); addChild($$, $3); if ($5 != NULL) addChild($$, $5); }
                ;

functionCall: TK_IDENTIFICADOR '(' argumentsList ')' { $$ = newNode(functionCallLabel($1->value)); addChild($$, $3); };

argumentsList: argumentsList ',' expression { $$ = $1; addChild($1, $3); }
            | expression                    { $$ = $1; }
            ;

expression: expression TK_OC_OR expression1 { $$ = newNode("|"); addChild($$, $1); addChild($$, $3); }
          | expression1                     { $$ = $1; }
          ;

expression1: expression1 TK_OC_AND expression2 { $$ = newNode("&"); addChild($$, $1); addChild($$, $3); }
           | expression2                       { $$ = $1; }
           ;

expression2: expression2 TK_OC_NE expression3 { $$ = newNode("!="); addChild($$, $1); addChild($$, $3); }
           | expression2 TK_OC_EQ expression3 { $$ = newNode("=="); addChild($$, $1); addChild($$, $3); }
           | expression3                      { $$ = $1; }
           ;

expression3: expression3 TK_OC_GE expression4 { $$ = newNode(">="); addChild($$, $1); addChild($$, $3); }
           | expression3 TK_OC_LE expression4 { $$ = newNode("<="); addChild($$, $1); addChild($$, $3); }
           | expression3 '>' expression4      { $$ = newNode(">"); addChild($$, $1); addChild($$, $3); }
           | expression3 '<' expression4      { $$ = newNode("<"); addChild($$, $1); addChild($$, $3); }
           | expression4                      { $$ = $1; }
           ;

expression4: expression4 '+' term { $$ = newNode("+"); addChild($$, $1); addChild($$, $3); }
           | expression4 '-' term { $$ = newNode("-"); addChild($$, $1); addChild($$, $3); }
           | term                 { $$ = $1; }
           ;

term: term '%' factor { $$ = newNode("%"); addChild($$, $1); addChild($$, $3); }
    | term '*' factor { $$ = newNode("*"); addChild($$, $1); addChild($$, $3); }
    | term '/' factor { $$ = newNode("/"); addChild($$, $1); addChild($$, $3); }
    | factor          { $$ = $1; }
    ;

factor: '!' operand { $$ = newNode("!"); addChild($$, $2); }
      | '-' operand { $$ = newNode("-"); addChild($$, $2); }
      | operand     { $$ = $1; }
      ;

operand: '(' expression ')' { $$ = $2; }
       | TK_IDENTIFICADOR   { $$ = newNode($1->value); }
       | functionCall       { $$ = $1; }
       | literal            { $$ = newNode($1->value); }
       ;

literal: TK_LIT_INT   { $$ = $1; }
       | TK_LIT_FLOAT { $$ = $1; }
       ; 

type: TK_PR_INT
    | TK_PR_FLOAT
    ;

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
