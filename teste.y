%{

#include <stdio.h>
#include "string.h"      
#include "lex.yy.c"
#define HASHSZ 1024


unsigned long hashFun(char *str){
    unsigned long hash = 5381;
    int c;

    while (c = *str++)
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */

    return hash % HASHSZ;
}

%}

%union{ float valN; char valC; char*string;}
%token <valN>NUM
%token <string>ID
%token <string>STR IDstr

%token AND OR
%token EQ NE LT LE GT GE
%token  TRUE FALSE

%type <string> Expr Termo Fator FatorStr ExprStr ExprInt


%%

cmd : Atrib
    | Atrib cmd
    ;

Atrib :  ID   '='  Expr   '\n'      { printf("%sSTOREG %d\n",$3,hashFun($1));}
      ;

Expr : ExprInt
     | ExprStr
     ;

ExprInt: Termo                      { asprintf(&$$, "%s",$1); }
       | ExprInt '+' Termo          { asprintf(&$$, "%s%sADD\n",$1,$3); }
       | ExprInt '-' Termo          { asprintf(&$$, "%s%sSUB\n",$1,$3); }
       ;

Termo : Fator                       { asprintf(&$$, "%s",$1); }
    | Termo '*' Fator               { asprintf(&$$, "%s%sMUL\n",$1,$3); }
    | Termo '/' Fator               { asprintf(&$$, "%s%sDIV\n",$1,$3); }
    ;

Fator : NUM                         { asprintf(&$$,"PUSHI %f\n",$1); }
    | '-' NUM                       { asprintf(&$$,"PUSHI -%f\n",$2); }
    | ID                            { asprintf(&$$,"PUSHG %d\n",hashFun($1)); }
    | '(' Expr ')'                  { asprintf(&$$,"%s",$2);}
    ;


ExprStr: FatorStr                   { asprintf(&$$, "%s",$1); }
       | ExprStr '+' FatorStr       { asprintf(&$$,"%s%sCONCAT\n",$1,$3); }
       ;

FatorStr: STR                       { asprintf(&$$,"PUSHS %s\n",$1); }
        | ID                        { asprintf(&$$,"PUSHG %d\n",hashFun($1)); }
        ;



%%




int yyerror(char* s){
    printf("Frase invalida: %s\n",s);
}

int main(){
    printf("INICIO DO PARSING\n");
    yyparse();
    printf("FIM DO PARSING\n");
    return 0;
}

//ExprR : Expr                     
//    | Expr EQ Expr          
//    | Expr NE Expr          {  }
//    | Expr LT Expr          {  }
//    | Expr LE Expr          {  }
//    | Expr GT Expr          {  } 
//    | Expr GE Expr          {  }  
//;
