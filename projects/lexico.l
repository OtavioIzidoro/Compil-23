%{
/*  
    +=============================================================
    |           UNIFAL - Universidade Federal de Alfenas.
    |               BACHARELADO EM CIENCIA DA COMPUTACAO.
    | Trabalho..: R e gi s t r o e v e r i f i c a c a o de t i p o s
    | Disciplina: Teoria de Linguagens e Compiladores
    | Professor.: Luiz Eduardo da Silva
    | Aluno.....: Davi C. Bernardes - 2019.1.08.021
    | Aluno.....: Otávio Augusto Marcelino Izidoro - 2018.1.08.041
    | Data......: 15/12/2023
    +=============================================================
*/ 
%}

%{
   #include "sintatico.h"
   int yyerror(char *);
   int numLinha = 1;
   char atomo[100];
%}

identificador  [a-zA-Z]([a-zA-Z0-9])*
numero         [0-9]+
espaco         [ \t\r]+
novalinha      [\n]

%x coment

%%

programa             return T_PROGRAMA;
inicio               return T_INICIO;
fimprograma          return T_FIM;

def                  return T_DEF;
fimdef               return T_FIMDEF;

leia                 return T_LEIA;
escreva              return T_ESCREVA;

se                   return T_SE;
entao                return T_ENTAO;
senao                return T_SENAO;
fimse                return T_FIMSE;

enquanto             return T_ENQTO;
faca                 return T_FACA;
fimenquanto          return T_FIMENQTO;

"+"                  return T_MAIS;
"-"                  return T_MENOS;
"*"                  return T_VEZES;
div                  return T_DIV;

">"                  return T_MAIOR;
"<"                  return T_MENOR;
"="                  return T_IGUAL;

e                    return T_E;
ou                   return T_OU;
nao                  return T_NAO;

"<-"                 return T_ATRIB;
"("                  return T_ABRE;
")"                  return T_FECHA;

inteiro              return T_INTEIRO; 
logico               return T_LOGICO; 
registro             return T_REGISTRO;
V                    return T_V;
F                    return T_F;

"//".*                /* nada */
"/*"                 BEGIN(coment);
<coment>"*/"         BEGIN(INITIAL);
<coment>.            /* nada */
<coment>\n           numLinha++;  


{identificador}      { strcpy(atomo, yytext); return T_IDENTIF; }
{identificador}"."   { 
                        strcpy(atomo, yytext); 
                        atomo[strlen(atomo)-1] = 0;
                        return T_IDPONTO; 
                     }
{numero}             { strcpy(atomo, yytext); return T_NUMERO; }
{espaco}             /* nao faz nada */
{novalinha}          numLinha++;
.                    yyerror ("lexico");

%%

int yywrap(void) { return 1; }

int yyerror (char *s) {
   printf("ERRO na linha %d: %s\n", numLinha, s);
   exit(100);
   
}