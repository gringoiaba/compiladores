%{
#include <stdio.h>
int yylex(void);
void yyerror (char const *mensagem);
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

%%

/* A program is composed of a optional list of functions*/
program: function_list;

function_list: function_list function
             | /* empty */ 
             ;

function: TK_IDENTIFICADOR '=' param_list '>' type command_block;

/* TODO: currently wrong example: " | param" */
/* A parameters list is composed of zero or more parameters separeted by TK_OC_OR */
/* TODO: check this out*/
param_list: param_list TK_OC_OR param 
          | /* empty */
          ;

/* Parameters are defined by the name followed by <- and their type */
param: TK_IDENTIFICADOR '<' '-' type;


command: variable_declaration
       | TK_IDENTIFICADOR '=' expression        /* Assignment */
       | TK_IDENTIFICADOR '(' opt_argument ')'  /* Function call */
       | TK_PR_RETURN expression                /* Return expression */
       | TK_PR_WHILE command_block
       | selection_command                      /* Conditional expressions */
       ;
       
/* TODO: right recursion maybe not accepted*/
command_list: command ';' command_list
            | /* empty */
            ;

command_block: '{' command_list '}';

/* The selection command IF is followed by an optional ELSE */
selection_command: TK_PR_IF '(' expression ')' command_block TK_PR_ELSE command_block
                 | TK_PR_IF '(' expression ')' command_block
                 ;

/* It's possible to declare multiple variables at a time
 * a variable can be optionaly initialized if followed by TK_OC_LE and a literal */
variable_declaration: type identifier_list 
                    | type identifier_list TK_OC_LE literal
                    ;

identifier_list: TK_IDENTIFICADOR
               | identifier_list ',' TK_IDENTIFICADOR
               ;

/* Optional arguments passed in a function call */
opt_argument: argument_list
            | /* empty */
            ;

/* TODO: right recursion */
argument_list: argument ',' argument_list
             | argument
             ;

/* TODO: WHAT IS AN ARGUMENT; */
argument: expression;

/* TODO: check for precedencia */
expression: literal
          | TK_IDENTIFICADOR                    /* Identifier    */
          | TK_IDENTIFICADOR '(' expression ')' /* Function call */
          | expression '+' expression
          | expression '-' expression
          | expression '*' expression
          | expression '/' expression
          | expression '%' expression
          | expression '<' expression
          | expression '>' expression
          | expression TK_OC_LE expression
          | expression TK_OC_GE expression
          | expression TK_OC_EQ expression
          | expression TK_OC_NE expression
          | expression TK_OC_AND expression
          | '-' expression
          | '!' expression
          | '(' expression ')'
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
        fprintf(stderr, "%s\n", mensagem);
}

