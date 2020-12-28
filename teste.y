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

%union{ float flt; int intg; char valC; char*string;}
%token <intg>NUM
%token <flt>FLT
%token <string>ID
%token <string>STR IDstr

%token AND OR NOT
%token EQ NE LT LE GT GE
%token TRUE FALSE

%type <string> Expr Termo Fator FatorStr ExprStr ExprInt ExprBool 
%type <string> ExprFloat ExprCmp Bool ExprCmpInt ExprCmpStr ExprCmpFloat
%type <string> TermoF FatorF


%%

cmd : Atrib
    | Atrib cmd
    ;

Atrib :  ID   '='  Expr   '\n'      { printf("%sSTOREG %d\n",$3,hashFun($1));}
      ;

Expr : ExprInt
     | ExprStr
     | ExprBool
     | ExprFloat
     ;

///////////////////////////////////////////////////////////////////////////////////////

ExprBool: ExprCmp                             { asprintf(&$$, "%s",$1); }      
        | NOT ExprBool                        { asprintf(&$$, "%sNOT\n",$2); }
        | ExprBool AND ExprBool               { asprintf(&$$, "%s%sMUL\n",$1,$3); }
        | ExprBool OR ExprBool                { asprintf(&$$, "%s%sADD\n",$1,$3); }
        ;

ExprCmp: Bool                                 { asprintf(&$$, "%s",$1); }
       | ExprCmpInt                           { asprintf(&$$, "%s",$1); }
       | ExprCmpStr                           { asprintf(&$$, "%s",$1); }
       | ExprCmpFloat                         { asprintf(&$$, "%s",$1); }
       ;

Bool: ID                                      { asprintf(&$$,"PUSHG %d\n",hashFun($1)); }
    | TRUE                                    { asprintf(&$$,"PUSHI 1\n"); }
    | FALSE                                   { asprintf(&$$,"PUSHI 0\n"); }
    ;

ExprCmpInt: ExprInt EQ ExprInt                { asprintf(&$$, "%s%sEQUAL\n",$1,$3); }
          | ExprInt NE ExprInt                { asprintf(&$$, "%s%sEQUAL\nNOT",$1,$3); }
          | ExprInt LT ExprInt                { asprintf(&$$, "%s%sINF\n",$1,$3); }
          | ExprInt LE ExprInt                { asprintf(&$$, "%s%sINFEQ\n",$1,$3); }
          | ExprInt GT ExprInt                { asprintf(&$$, "%s%sSUP\n",$1,$3); } 
          | ExprInt GE ExprInt                { asprintf(&$$, "%s%sSUPEQ\n",$1,$3); }  
          ;

ExprCmpStr: ExprStr EQ ExprStr                { asprintf(&$$, "%s%sEQUAL\n",$1,$3); }
          ;


ExprCmpFloat: ExprFloat EQ ExprFloat          { asprintf(&$$, "%s%sFEQUAL\n",$1,$3); }
            | ExprFloat NE ExprFloat          { asprintf(&$$, "%s%sFEQUAL\nNOT",$1,$3); }
            | ExprFloat LT ExprFloat          { asprintf(&$$, "%s%sFINF\n",$1,$3); }
            | ExprFloat LE ExprFloat          { asprintf(&$$, "%s%sFINFEQ\n",$1,$3); }
            | ExprFloat GT ExprFloat          { asprintf(&$$, "%s%sFSUP\n",$1,$3); } 
            | ExprFloat GE ExprFloat          { asprintf(&$$, "%s%sFSUPEQ\n",$1,$3); }  
            ;

//////////////////////////////////////////////////////////////////////////////////////

ExprInt: Termo                                { asprintf(&$$, "%s",$1); }
       | ExprInt '+' Termo                    { asprintf(&$$, "%s%sADD\n",$1,$3); }
       | ExprInt '-' Termo                    { asprintf(&$$, "%s%sSUB\n",$1,$3); }
       ;

Termo : Fator                                 { asprintf(&$$, "%s",$1); }
    | Termo '*' Fator                         { asprintf(&$$, "%s%sMUL\n",$1,$3); }
    | Termo '/' Fator                         { asprintf(&$$, "%s%sDIV\n",$1,$3); }
    ;


Fator : NUM                                   { asprintf(&$$,"PUSHI %d\n",$1); }
    | '-' NUM                                 { asprintf(&$$,"PUSHI -%d\n",$2); }
    | ID                                      { asprintf(&$$,"PUSHG %d\n",hashFun($1)); }
    | '(' Expr ')'                            { asprintf(&$$,"%s",$2);}
    ;


///////////////////////////////////////////////////////////////////////////////////////
ExprStr: FatorStr                             { asprintf(&$$, "%s",$1); }
       | ExprStr '+' FatorStr                 { asprintf(&$$,"%s%sCONCAT\n",$1,$3); }
       ;

FatorStr: STR                                 { asprintf(&$$,"PUSHS %s\n",$1); }
        | ID                                  { asprintf(&$$,"PUSHG %d\n",hashFun($1)); }
        ;

/////////////////////////////////////////////////////////////////////////////////////////

ExprFloat: TermoF                             { asprintf(&$$, "%s",$1); }
         | ExprFloat '+' TermoF               { asprintf(&$$, "%s%sFADD\n",$1,$3); }
         | ExprFloat '-' TermoF               { asprintf(&$$, "%s%sFSUB\n",$1,$3); }
         ;

TermoF : FatorF                               { asprintf(&$$, "%s",$1); }
       | TermoF '*' FatorF                    { asprintf(&$$, "%s%sFMUL\n",$1,$3); }
       | TermoF '/' FatorF                    { asprintf(&$$, "%s%sFDIV\n",$1,$3); }
       ;


FatorF : FLT                                  { asprintf(&$$,"PUSHF %d\n",$1); }
       | '-' FLT                              { asprintf(&$$,"PUSHF -%d\n",$2); }
       | ID                                   { asprintf(&$$,"PUSHF %d\n",hashFun($1)); }
       | '(' Expr ')'                         { asprintf(&$$,"%s",$2); }
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





