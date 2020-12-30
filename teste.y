%{

#include <stdio.h>
#include "string.h"      
#include "lex.yy.c"
#include "auxFile.c"

HASH_TABLE tabID;
int flagError;

%}

%union{ float flt; int intg; char valC; char*string;}
%token <intg> INT INTEGER FLOAT STRING BOOL
%token <flt> FLT
%token <string>ID DECLARE MAIN NOME
%token <string> STR IDstr

%token AND OR NOT
%token EQ NE LT LE GT GE
%token TRUE FALSE

%type <string> Termo Fator FatorStr ExprStr ExprInt ExprBool 
%type <string> ExprFloat ExprCmp Bool ExprCmpInt ExprCmpStr ExprCmpFloat
%type <string> TermoF FatorF
%type <intg> Tipo


%%

Programa: Header Blocos Main
        ;

Header: DECLARE '{''\n' Declares '}'
       ;

Declares: Declares Declare'\n'
        | Declare'\n'
        ;

Declare: Atrib
       | Var
       ;

Tipo: INTEGER  {$$ = INTE;}
    | FLOAT    {$$ = FLOT;}
    | STRING   {$$ = STRI;}
    | BOOL     {$$ = INTE;}
    ;

Var : Tipo ID   {aloca(tabID,$2,$1); $$ = strdup($2);}
    | ID        {$$ = strdup($1);}
    ;

Expr: ExprInt
    | ExprStr
    | ExprBool
    | ExprFloat
    ;

Blocos: Blocos Bloco
      | Bloco
      ;

Bloco: NOME '{' cmd '}'
     |
     ;

Main: MAIN '{' cmd '}'
    |
    ;

cmd : Atrib
    | Atrib cmd
    ;

Atrib : Var    '='    ExprInt   '\n'            { atribui($1,$3,tabID,INTE); }
      | Var    '='    ExprStr   '\n'            { atribui($1,$3,tabID,STRI); }
      | Var    '='    ExprBool  '\n'            { atribui($1,$3,tabID,INTE); }
      | Var    '='    ExprFloat '\n'            { atribui($1,$3,tabID,FLOT); }
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

Bool: ID                                      { fetch_var(&$$, $1, tabID, INTE); }
    | TRUE                                    { asprintf(&$$,"PUSHI 1\n"); }
    | FALSE                                   { asprintf(&$$,"PUSHI 0\n"); }
    | '(' ExprBool ')'                        { asprintf(&$$,"%s",$2);}
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


Fator : INT                                   { asprintf(&$$,"PUSHI %d\n",$1); }
    | '-' INT                                 { asprintf(&$$,"PUSHI -%d\n",$2); }
    | ID                                      { fetch_var(&$$, $1, tabID, INTE); }
    | '(' ExprInt ')'                         { asprintf(&$$,"%s",$2);}
    ;


///////////////////////////////////////////////////////////////////////////////////////
ExprStr: FatorStr                             { asprintf(&$$, "%s",$1); }
       | ExprStr '+' FatorStr                 { asprintf(&$$,"%s%sCONCAT\n",$1,$3); }
       ;

FatorStr: STR                                 { asprintf(&$$,"PUSHS %s\n",$1); }
        | ID                                  { fetch_var(&$$, $1, tabID, STRI); }
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


FatorF : FLT                                  { asprintf(&$$,"PUSHF %f\n",$1); }
       | '-' FLT                              { asprintf(&$$,"PUSHF -%f\n",$2); }
       | ID                                   { fetch_var(&$$, $1, tabID, FLOT); }
       | '(' ExprFloat ')'                    { asprintf(&$$,"%s",$2); }
       ;



%%




int yyerror(char* s){
    printf("Frase invalida: %s\n",s);
}

int main(){
	tabID = new_hash_table();
	int i;

    printf("START\n");
    yyparse();
    printf("STOP\n");
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


