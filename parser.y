%{
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

programa:       lista_funcoes | ;

lista_funcoes:  funcao | funcao lista_funcoes;

funcao:         cabecalho corpo;

cabecalho:      nome '=' opt_param '>' tipo;

opt_param:      lista_param | ;

lista_param:    param | param '|' lista_param;

corpo:          bloco_comando

bloco_comando:  '[' lista_comandos ']'

lista_comandos: comando | comando ';' lista_comandos 

param: 


%%

void yyerror (char const *mensagem) 
{
        fprintf(stderr, "%s\n", mensagem);
}

