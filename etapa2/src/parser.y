%{
       #include <stdio.h>
       int yylex(void);
       void yyerror (char const *mensagem);
       int get_line_number();
%}

%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_IF
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_RETURN
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token TK_IDENTIFICADOR
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_ERRO

%define parse.error verbose

%%

/* A program is composed of an optional list of functions*/
program: functionList
       | /* empty */
       ;

functionList: functionList function
            | function
            ;

function: TK_IDENTIFICADOR '=' nonEmptyParamList '>' type commandBlock;
        | TK_IDENTIFICADOR '=' '>' type commandBlock;

nonEmptyParamList: TK_IDENTIFICADOR '<' '-' type
                 | nonEmptyParamList TK_OC_OR TK_IDENTIFICADOR '<' '-' type
                 ;

commandBlock: '{' commandList '}'
            | '{' '}'
            ;

commandList: commandList command ';'
           | command ';'
           ;

command: commandBlock
       | varDeclaration
       | selectionCommand                               /* Conditional expressions */
       | functionCall     
       | TK_IDENTIFICADOR '=' expression                /* Assignment */
       | TK_PR_RETURN expression                        /* Return expression */
       | TK_PR_WHILE '(' expression ')' commandBlock
       ;
       
varDeclaration: type idList

/* It is possible to declare multiple variables at a time */ 
idList: id 
      | idList ',' id
      ;

/* A variable can be optionaly initialized if followed by TK_OC_LE '<=' and a literal */
id: TK_IDENTIFICADOR
  | TK_IDENTIFICADOR TK_OC_LE literal
  ;

/* The selection command IF is followed by an optional ELSE */
selectionCommand: TK_PR_IF '(' expression ')' commandBlock TK_PR_ELSE commandBlock
                | TK_PR_IF '(' expression ')' commandBlock
                ;

functionCall: TK_IDENTIFICADOR '(' argumentsList ')';

argumentsList: argumentsList ',' expression
            | expression
            ;

expression: expression TK_OC_OR expression1
          | expression1
          ;

expression1: expression1 TK_OC_AND expression2
           | expression2
           ;

expression2: expression2 TK_OC_NE expression3
           | expression2 TK_OC_EQ expression3
           | expression3
           ;

expression3: expression3 TK_OC_GE expression4
           | expression3 TK_OC_LE expression4
           | expression3 '>' expression4
           | expression3 '<' expression4
           | expression4
           ;

expression4: expression4 '+' term
           | expression4 '-' term
           | term
           ;

term: term '%' factor
    | term '*' factor
    | term '/' factor
    | factor
    ;

factor: '!' operand
      | '-' operand
      | operand
      ;

operand: '(' expression ')'
       | TK_IDENTIFICADOR
       | functionCall
       | literal
       ;

literal: TK_LIT_INT
       | TK_LIT_FLOAT
       ; 

type: TK_PR_INT
    | TK_PR_FLOAT
    ;

%%

void yyerror (char const *mensagem) 
{
        fprintf(stderr, "%s on line %d\n", mensagem, get_line_number());
}
