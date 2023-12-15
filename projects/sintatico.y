%{
/*  
    +=============================================================
    |           UNIFAL - Universidade Federal de Alfenas.
    |               BACHARELADO EM CIENCIA DA COMPUTACAO.
    | Trabalho..: R e gi s t r o e v e r i f i c a c a o de t i p o s
    | Disciplina: Teoria de Linguagens e Compiladores
    | Professor.: Luiz Eduardo da Silva
    | Aluno.....: Davi C. Bernardes - 2019.1.08.021
    | Aluno.....: Otavio A. M. Izidoro - 2018.1.08.041
    | Data......: 15/12/2023
    +=============================================================
*/    
%}

%{
    #include "stdio.h"
    #include "stdlib.h"
    #include "string.h"

    #include "lexico.c"
    #include "utils.c"

    int contaVar = 0;
    int rotulo = 0;
    int ehRegistro = 0;
    int ehVariavel = 0;
    int tipo;
    int tam = 0;
    int pos = 0;
    int dsl = 0;
    int ultimoReg = 2;
    ptno l;
    int inicia = 0;
    
%}

%token T_DEF
%token T_REGISTRO
%token T_FIMDEF
%token T_IDPONTO

%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_IDENTIF
%token T_LEIA
%token T_ESCREVA
%token T_ENQTO
%token T_FACA
%token T_ENTAO
%token T_FIMENQTO
%token T_SE
%token T_SENAO
%token T_FIMSE
%token T_ATRIB
%token T_VEZES
%token T_DIV
%token T_MAIS
%token T_MENOS
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_V
%token T_F
%token T_NUMERO
%token T_NAO
%token T_ABRE
%token T_FECHA
%token T_LOGICO
%token T_INTEIRO

%start programa 

%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

%%

programa
    : cabecalho define_registro variaveis 
        { 
            mostraTabela();
            
            empilha(contaVar);
            if(contaVar)
                fprintf(yyout, "\tAMEM\t%d\n", contaVar); 
        }
    T_INICIO lista_comandos T_FIM
        { 
            int conta = desempilha();
            if(conta)
                fprintf(yyout, "\tDMEM\t%d\n", conta);
        }
        {   fprintf(yyout, "\tFIMP\n"); }
    ;

cabecalho
    : T_PROGRAMA T_IDENTIF
        { 
            fprintf(yyout, "\tINPP\n"); 

            strcpy(elemTab.id, "inteiro");
            elemTab.end = -1;
            elemTab.tip = INT;
            elemTab.tam = 1;
            elemTab.pos = 0;
            insereSimbolo(elemTab);
            pos++;

            strcpy(elemTab.id, "logico");
            elemTab.end = -1;
            elemTab.tip = LOG;
            elemTab.tam = 1;
            elemTab.pos = 1;
            insereSimbolo(elemTab);
            pos++;

        }
    ;

tipo
    : T_LOGICO
        { 
            tipo = LOG;
            pos = 1;
            tam = 1;
            //#TODO 1
            // Alem do tipo, precisa guardar o TAM(tamanho) do tipo
            // e a POS(posicao) do tipo na tab de símbolos
        }
    | T_INTEIRO
        { 
            tipo = INT; 
            tam = 1;
            pos = 0;
            // Alem do tipo, precisa guardar o TAM(tamanho) do tipo
            // e a POS(posicao) do tipo na tab de símbolos
        }
    | T_REGISTRO T_IDENTIF
        { 
            tipo = REG;
            int elem = buscaSimbolo(atomo);
            tam = tabSimb[elem].tam;
            pos = tabSimb[elem].pos;

            //#TODO2
            // aqui tem uma chamada de buscaSimbolo para encontrar
            // as informacoes de TAM e POS do registro 
        }
    ;

define_registro
    : define define_registro
    | 
    ;

define
    : T_DEF 
    {
        //TODO#3
        //iniciar a lista de campos
        l = NULL;
        dsl = 0;
    }
    definicao_campos T_FIMDEF T_IDENTIF
    {
        //#TODO4
        
        strcpy(elemTab.id, atomo);
        elemTab.end = -1;
        elemTab.tip = REG;
        elemTab.tam = calculaTamanho(l);
        elemTab.pos = ultimoReg;
        elemTab.campos = l;
        insereSimbolo(elemTab);
        ultimoReg++;
        //inserir esse novo tipo na tabela de simbolos (insereSimbolo)
        // com a lista que foi montada
    }
    ;

definicao_campos
    : tipo lista_campos definicao_campos
    | tipo lista_campos
    ;

lista_campos
    : lista_campos T_IDENTIF
    {
        
        // TODO #5
        // acrescentar esse campo na lista de campos que
        // esta sendo construida
        // o deslocamento (esdereço) do proximo campo
        // sera o deslocamento anterior mais o tamanho desse campos
        l = insere(l, atomo, tipo, pos, dsl, tam);
        dsl = dsl + tam;
    }
    | T_IDENTIF
    {
        // TODO #5
        // acrescentar esse campo na lista de campos que
        // esta sendo construida
        // o deslocamento (esdereço) do proximo campo
        // sera o deslocamento anterior mais o tamanho desse campos

        l = insere(l, atomo, tipo, pos, dsl, tam);
        dsl = dsl + tam;
    }
    ;

variaveis
    : /*vazio*/
    | declaracao_variaveis
    ;

declaracao_variaveis
    : tipo lista_variaveis declaracao_variaveis
    | tipo lista_variaveis
    ;

lista_variaveis
    : lista_variaveis 
    T_IDENTIF
        { 
            strcpy(elemTab.id, atomo);
            elemTab.end = contaVar;
            elemTab.tip = tipo;
            elemTab.pos = pos;
            elemTab.tam = tam;
            
            insereSimbolo (elemTab);
            if(tipo == REG){
                contaVar = contaVar + tam;
            }else{
                contaVar++;
            }
            // TODO#7
            // Se a variavel for registro
            // contaVar= contaVar + TAM (tamanho do registro)
        } 
    
    | T_IDENTIF
        { 
            strcpy(elemTab.id, atomo);
            elemTab.end = contaVar;
            elemTab.tip = tipo;
            elemTab.pos = pos;
            elemTab.tam = tam;
            // tem outros campos para acrescentar na tab. simbolos
            insereSimbolo (elemTab);
            if(tipo == REG){
                contaVar = contaVar + tam;
            }else{
                contaVar++;
            }

            // Se a variavel for registro
            // contaVar= contaVar + TAM (tamanho do registro)
        } 
    ;


lista_comandos
    : /* vazio */
    | comando lista_comandos
    ;

comando
    : entrada_saida
    | atribuicao
    | selecao
    | repeticao
    ;

entrada_saida
    : entrada
    | saida 
    ;

entrada
    : T_LEIA expressao_acesso
        {    
            // TODO #8
            for(int i = 0; i < tam; i++){
                fprintf(yyout, "\tLEIA\n"); 
                fprintf(yyout, "\tARZG\t%d\n", dsl + i); 
            }
        }
    ;

saida
    : T_ESCREVA expressao
        { 
            desempilha();
            // TODO #9
            // Se for registro, tem que fazer uma repeticao do
            // TAM do registro de escritas
            for(int i = 0; i < tam; i++)
                fprintf(yyout, "\tESCR\n"); 
    
        }

    ;

atribuicao
    : expressao_acesso 
        { 

            // TODO#10
            // Tem que guardar o TAM, DES e o TIPO (POS do tipo, se for registro)
            empilha(tam);
            empilha(dsl);
            empilha(tipo);

        }
    T_ATRIB expressao
        { 
            int tipexp = desempilha();
            int tipvar = desempilha();
            int dsl = desempilha();
            int tam = desempilha();

            if(tipexp != tipvar)
                yyerror("Incompatibilidade de tipo na atribuicao!");
            // TODO #11
            // Se for registro, tem que fazer uma repetição do
            // TAM do registro de ARZG
            for(int i = 0; i < tam; i++)
                fprintf(yyout, "\tARZG\t%d\n", dsl + i); 
        }
    ;

selecao
    : T_SE expressao T_ENTAO
        { 
            int t = desempilha();
            if(t != LOG)
                yyerror("Incompatibilidade de tipo na selecao!");
            fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo);
            empilha(rotulo); 
        }
     lista_comandos T_SENAO 
        { 
            fprintf(yyout, "\tDSVS\tL%d\n", ++rotulo);
            int rot = desempilha();
            fprintf(yyout, "L%d\tNADA\n", rot); 
            empilha(rotulo);
        }
     lista_comandos T_FIMSE
        { 
            int rot = desempilha();
            fprintf(yyout, "L%d\tNADA\n", rot); 
        }
    ;

repeticao
    : T_ENQTO 
        { 
            fprintf(yyout, "L%d\tNADA\n",++rotulo); 
            empilha(rotulo);
        }
     expressao T_FACA
        { 
            int t = desempilha();
            if(t != LOG)
                yyerror("Incompatibilidade de tipo na repeticao");
            fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo); 
            empilha(rotulo);
        }
        
     lista_comandos T_FIMENQTO
        { 
            int rot1 = desempilha();
            int rot2 = desempilha();
            fprintf(yyout, "\tDSVS\tL%d\n", rot2); 
            fprintf(yyout, "L%d\tNADA\n", rot1); 
        }
    ;

expressao
    : expressao T_VEZES expressao
        { 
            testaTipo(INT,INT,INT);
            fprintf(yyout, "\tMULT\n"); 
        }
    | expressao T_DIV expressao
        { 
            testaTipo(INT,INT,INT);
            fprintf(yyout, "\tDIVI\n"); 
        }
    | expressao T_MAIS expressao
        { 
            testaTipo(INT,INT,INT);
            fprintf(yyout, "\tSOMA\n"); 
        }
    | expressao T_MENOS expressao
        { 
            testaTipo(INT,INT,INT);
            fprintf(yyout, "\tSUBT\n"); 
        }
    | expressao T_MAIOR expressao
        {
            testaTipo(INT,INT,LOG);
            fprintf(yyout, "\tCMMA\n"); 
        }
    | expressao T_MENOR expressao
        { 
            testaTipo(INT,INT,LOG);
            fprintf(yyout, "\tCMME\n"); 
        }
    | expressao T_IGUAL expressao
        { 
            testaTipo(INT,INT,LOG);
            fprintf(yyout, "\tCMIG\n"); 
        }
    | expressao T_E expressao
        { 
            testaTipo(LOG,LOG,LOG);
            fprintf(yyout, "\tCONJ\n"); 
        }
    | expressao T_OU expressao
        { 
            testaTipo(LOG,LOG,LOG);
            fprintf(yyout, "\tDISJ\n"); 
        }
    | termo
    ;

expressao_acesso
    : T_IDPONTO 
        {   //--- Primeiro nome do registro
            if (!ehRegistro){
  
                ehRegistro = 1;
                int pos = buscaSimbolo(atomo);

                if(tabSimb[pos].tip == REG){
                    tam = tabSimb[pos].tam;
                    pos = tabSimb[pos].pos;
                    dsl = tabSimb[pos].end;
                }else {
                    char msg[200];
                    sprintf(msg, "Simbolo não é do tipo registro");
                    yyerror(msg);
                }
            
                // TODO#12
                // 1. buscar o simbolo na tabela de simbolos
                // 2. se nao for do tipo registro tem erro
                // 3. guardar o TAM, POS e DSL(deslocamento) desse T_IDENTIF
            } else{
                //--- Campo que eh registro

                int pos = buscaCampo(atomo);

                ptno campo = (ptno)malloc(sizeof(struct camposTabSimbolos));
                campo = busca(tabSimb[pos].campos, atomo);

                if(!campo){
                    char msg[200];
                    sprintf(msg, "Campo [%s] inexistente no registro", atomo);
                    yyerror(msg);
                }else{
                    if(campo->tip != REG){
                        char msg[200];
                        sprintf(msg, "Campo [%s] não é do tipo registro", atomo);
                        yyerror(msg);
                    } else {
                        tam = campo->tam;
                        pos = campo->pos;
                        dsl = campo->dsl;
                    }
                    
                }
                // 1. busca esse campo na lista de campos
                // 2. se não encontrar, erro (não existe esse campo no registro)
                // 3. se encontrar e não for registro, erro
                // 4. guardar TAM, POS e DSL desse campo 
            }
        }
    expressao_acesso
    | T_IDENTIF
        {     
            if(ehRegistro){

                int pos = buscaCampo(atomo);
                
                
                

                ptno campo = (ptno)malloc(sizeof(struct camposTabSimbolos));
                campo = busca(tabSimb[pos].campos, atomo);
                if(!campo){
                    char msg[200];
                    sprintf(msg, "Campo não esta na lista de campos");
                    yyerror(msg);
                }else{
                    tam = campo->tam;
                    dsl = campo->dsl;
                    tipo = campo->pos;
                }
                //TODO #13
                // 1. buscar esse campos na lista de campos
                // 2. se não encontrar, erro
                // 3. se encontrar, guardar o TAM, DSL e TIPO desse campo 
                //      o tipo (TIP) nesse caso é a posicao do tipo 
                //      na tabela de simbolos
            }
            else {
                //TODO #14
                int pos = buscaSimbolo(atomo);
                ehVariavel = 1;
                tam = tabSimb[pos].tam;
                dsl = tabSimb[pos].end;
                tipo = tabSimb[pos].tip;

               
                // guardar TAM, DSL, TIPO dessa variável
            }
            ehRegistro = 0;
        }
    
    ;

termo
    : expressao_acesso
    {
       
       
        
   
                // ptno campo = (ptno)malloc(sizeof(struct camposTabSimbolos));
       
        printf("ehvariavel %d\n", ehVariavel);
       
        printf("dsl %d\n", dsl);
        printf("tam %d\n", tam);
        printf("tipo %d\n", tipo);
      
        printf("atomo %s\n", atomo);



          // TODO #15
          // Se for registro, tem que fazer uma repetição do
          // TAM do registro de CRVG (em ondem inversa)

            if(ehVariavel == 1){
                for(int i = (tam - 1); i >= 0; i--){
                    fprintf(yyout, "\tCRVG\t%d\n", dsl + i); 
                }
            }
            else{
                int teste = buscaCampo(atomo);
                printf("tabelaSimbolos %d\n", tabSimb[teste].pos);
                for(int i = tam ; i > 0; i--){
                fprintf(yyout, "\tCRVG\t%d\n",  tabSimb[teste].pos + i ); 
             
            }
            }

          
        empilha(tipo); 
         ehVariavel = 0;  
    }
    | T_NUMERO
        { 
            fprintf(yyout, "\tCRCT\t%s\n", atomo); 
            empilha(INT);
        }
    | T_V
        { 
            fprintf(yyout, "\tCRCT\t1\n"); 
            empilha(LOG);
        }
    | T_F
        { 
            fprintf(yyout, "\tCRCT\t0\n"); 
            empilha(LOG);
            
        }
    | T_NAO termo
        { 
            int t = desempilha();
            if(t != LOG)
                yyerror("Incompatibilidade de tipo na negacao!");
            fprintf(yyout, "\tNEGA\n"); 
            empilha(LOG);
            
        }
    | T_ABRE expressao T_FECHA
    ;
%%

int main(int argc, char *argv[]){
    char *p, nameIn[100], nameOut[100];
    argv++;
    if(argc < 2){
        puts("\n Compilador da linguagem SIMPLES");
        puts(" \n\t USO: ./simples <NOME>[.simples]\n\n");
        exit(1);
    }
    p = strstr(argv[0], ".simples");
    if (p) *p = 0;
    strcpy(nameIn, argv[0]);
    strcat(nameIn, ".simples");
    strcpy(nameOut, argv[0]);
    strcat(nameOut, ".mvs");

    yyin = fopen(nameIn, "rt");
    if(!yyin){
        puts("Programa fonte nao encontrado!");
        exit(2);
    }

    yyout = fopen(nameOut, "wt");
    yyparse();
    printf("programa OK!\n\n");
    return 0;
}