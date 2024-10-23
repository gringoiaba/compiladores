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
       | functionCall                                   /* Function call */       
       | TK_IDENTIFICADOR '=' expression                /* Assignment */
       | TK_PR_RETURN expression                        /* Return expression */
       | TK_PR_WHILE '(' expression ')' commandBlock
       ;
       
/* It is possible to declare multiple variables at a time
 * a variable can be optionaly initialized if followed by TK_OC_LE and a literal */
varDeclaration: type TK_IDENTIFICADOR
              | type TK_IDENTIFICADOR TK_OC_LE literal
              | type TK_IDENTIFICADOR ',' varDeclaration
              | type TK_IDENTIFICADOR TK_OC_LE literal ',' varDeclaration
              ;      

/* The selection command IF is followed by an optional ELSE */
selectionCommand: TK_PR_IF '(' expression ')' commandBlock TK_PR_ELSE commandBlock
                | TK_PR_IF '(' expression ')' commandBlock
                ;

functionCall: TK_IDENTIFICADOR '(' optionalArguments ')';

/* Optional arguments passed in a function call */
optionalArguments: argumentList
                 | /* empty */
                 ;

argumentList: argumentList ',' expression
            | expression
            ;

/* TODO: Check for precedencia */
expression: expression TK_OC_OR term
          | expression TK_OC_AND term
          | expression TK_OC_NE term
          | expression TK_OC_EQ term
          | expression TK_OC_GE term
          | expression TK_OC_LE term
          | expression '>' term
          | expression '<' term
          | expression '-' term
          | expression '+' term
          | term
          ;

term: term '%' factor
    | term '*' factor
    | term '/' factor
    | factor
    ;

factor: '!' factor
      | '-' factor
      | '(' expression ')'
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
