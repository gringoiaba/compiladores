%{
       #include <stdio.h>
       int yylex(void);
       void yyerror (char const *mensagem);
       int get_line_number();
%}
%code requires { #include "ast.h" }
%code requires { #include "lex_value.h " }

%union {
       LexValue lexical_value;
       Tree *tree;
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
/* Uncertaint Tree types:
 * - program
 */
%type <tree> functionList function
             nonEmptyParamList 
             command commandList commandBlock
             varDeclaration idList 
             selectionCommand 
             functionCall argumentsList
             expression expression1 expression2 expression3
             term factor operand 
             


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
