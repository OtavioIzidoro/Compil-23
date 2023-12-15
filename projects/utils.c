/*  
    +=============================================================
    |           UNIFAL - Universidade Federal de Alfenas.
    |               BACHARELADO EM CIENCIA DA COMPUTACAO.
    | Trabalho..: R e gi s t r o e v e r i f i c a c a o de t i p o s
    | Disciplina: Teoria de Linguagens e Compiladores
    | Professor.: Luiz Eduardo da Silva
    | Aluno.....: Davi C. Bernardes - 2019.1.08.021
    | Data......: 15/12/2023
    +=============================================================
*/ 
#include <stdio.h>
#include <string.h>

// Tabela de simbolos

#define TAM_TAB 100

typedef struct camposTabSimbolos *ptno;

struct camposTabSimbolos{
    char id[100];
    int tip;
    int pos;
    int dsl;
    int tam;
    ptno prox;
}; 

//acrescentar campos na tabela
struct elemTabSimbolos {
    char id[100];   // nome do identificador
    int end;        // endereco
    int tip;
    int tam;
    int pos;        
    ptno campos; 
} tabSimb[TAM_TAB], elemTab;

enum{
    INT,
    LOG,
    REG
};

//Duas modificações, duas rotinas: inserir na lista encadeada, e percorrer a lista.

// criar uma estrutura e operações para manipular uma lista de campos

char nomeTipo[3][4] = {"INT", "LOG", "REG"};

int posTab = 0; // indica a proxima posicao livre para inserir
int posLista = 0; // indica a proxima posicao livre para inserir


ptno busca(ptno l, char id[100]){
    while(l && strcmp(l->id, id)!= 0){
        l = l->prox;
    }
    return l;
}

ptno insere(ptno l,char id[100], int tip, int pos, int dsl, int tam) {
    //tratar o problema de campo repetido, com o mesmo nome.
    int i;
    ptno p, novo;
    ptno campo;
    novo = (ptno)malloc(sizeof(struct camposTabSimbolos));

    if (busca(l, id) != NULL) {
        char msg[200];
        sprintf(msg, "Campo [%s] ja existe no registro.\n", id);
        yyerror(msg);
    }

    strcpy(novo->id, id);
    novo->tip = tip;
    novo->pos = pos;
    novo->dsl = dsl;
    novo->tam = tam;
    novo->prox = NULL;
    p = l;
    while(p && p->prox)
    {
        p = p->prox;
    }
    if (p)
    {
        p->prox = novo;
    }else{
        l = novo;
    }
    return l;
}



void mostra(ptno l) {
    while (l) 
    {
        if(l->prox){
            printf("(%s, %s, %d, %d, %d)=> ", l->id, nomeTipo[l->tip], l->pos, l->dsl, l->tam);
        }else{
            printf("(%s, %s, %d, %d, %d) ", l->id, nomeTipo[l->tip], l->pos, l->dsl, l->tam);
        }
        l = l->prox;
    }

}


int buscaSimbolo (char *s){
    int i;
    for (i = posTab - 1; strcmp(tabSimb[i].id, s) && i >= 0; i--); // strcmp(tabSimb[i].id, s) se for igual é true (1) false (0) e para

    if(i == -1){
        char msg[200];
        sprintf(msg, "Identificador [%s] não encontrado na busca!", s);
        yyerror(msg);
    }
    return i;
}

int buscaCampo (char *s){
    int i;
    ptno l;

    for (i = posTab - 1; i >= 0; i--){
        if(tabSimb[i].tip == REG){
            l = busca(tabSimb[i].campos, s);
            if(l!=NULL)
                break;
        }
    }

    if(i == -1){
        char msg[200];
        sprintf(msg, "Identificador [%s] não encontrado na busca Campo!", s);
        yyerror(msg);
    }
    
    return i;
}




void insereSimbolo (struct elemTabSimbolos elem){
    int i;

    if(posTab == TAM_TAB){
        yyerror ("Tabela de simbolo cheia!");
    }

    for (i = posTab - 1; strcmp(tabSimb[i].id, elem.id) && i >= 0; i--); // strcmp(tabSimb[i].id, s) se for igual é true (1) false (0) e para

    if (i != -1)
    {
        char msg[200];
        sprintf(msg, "Identificador [%s] não encontrado!", elem.id);
        yyerror(msg);
    }
    tabSimb[posTab++] = elem;
    
}

void mostraTabela () {
    for (int i = 0; i < 40; i++)
        printf("-");
    printf ("TABELA DE SIMBOLOS");
    for (int i = 0; i < 42; i++)
        printf("-");
    printf("\n%30s | %s | %s | %s | %s | %s \n", "ID", "END", "TIP", "TAM", "POS", "CAMPOS");
    for (int i = 0; i < 100; i++)
        printf("-");
    for (int i = 0; i < posTab; i++){
        printf("\n%30s | %3d | %3s | %3d | %3d |", 
            tabSimb[i].id, 
            tabSimb[i].end, 
            nomeTipo[tabSimb[i].tip],
            tabSimb[i].tam,
            tabSimb[i].pos
            );
        if(tabSimb[i].tip==REG)
            mostra(tabSimb[i].campos);
    }
    puts("");
}

// Pilha semantica
#define TAM_PILHA 100

int pilha[TAM_PILHA];
int topo = -1;

void empilha (int valor){
    if(topo == TAM_PILHA)
        yyerror ("Pilha semantica cheia!");

    pilha[++topo] = valor;
}

int desempilha (){
    if (topo == -1)
        yyerror("Pilha vazia!");
    return pilha[topo--];
}

// tipo1 e tipo2 são os tipos esperados na expressão 
// ret é o tipo que será empilhado com resultado da expressão

void testaTipo (int tipo1, int tipo2, int ret){
    int t1 = desempilha();
    int t2 = desempilha();
    if (t1 != tipo1 || t2 != tipo2)
        yyerror("Incompatibilidade de tipo testa tipo!");
    empilha(ret);
}

int calculaTamanho(ptno l){
    int tamanho = 0;
    while (l){
        tamanho += l->tam;
        l = l->prox;
    }

    return tamanho;
}