%{

#include <stdio.h>
#include "string.h"      
#include "lex.yy.c"
#include "auxFile.c"

HASH_TABLE tabID;
int flagError = 0;

int yydebug = 1;
%}

%union{ float flt; int intg; char valC; char*string;}
%token <intg> INT INTEGER FLOAT STRING BOOL
%token <flt> FLT
%token <string>ID DECLARE MAIN NOME
%token <string> STR IDstr

%token AND OR NOT
%token EQ NE LT LE GT GE
%token TRUE FALSE
%token READ WRITE

%type <string> Termo Fator FatorStr ExprStr ExprInt ExprBool Var
%type <string> ExprFloat ExprCmp Bool ExprCmpInt ExprCmpStr ExprCmpFloat
%type <string> TermoF FatorF
%type <intg> Tipo


%%

Programa: Header '\n' Main
        ;

Header: DECLARE '{''\n' Declares '}'
      ;

Declares: Declares Declare
        | Declare
        ;

Declare: Atrib '\n'
       | Var '\n'
       ;

Tipo: INTEGER  {$$ = INTE;}
    | FLOAT    {$$ = FLOT;}
    | STRING   {$$ = STRI;}
    | BOOL     {$$ = INTE;}
    ;

Var : Tipo ID   {aloca(tabID,$2,$1,&flagError); $$ = strdup($2);}
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

Bloco: NOME '{' Cmd '}'
     |
     ;

Main: MAIN '{''\n' Cmds '}' { asprintf(&$$,"START\n%s",$4); }
    ;

Cmds : Cmd
     | Cmds Cmd
     ;

Cmd : Atrib '\n'
    | Read '\n'
    | Write '\n' 
//    | Condic 
//    | Repeat
    ;

Atrib : Var    '='    ID                    { printf("bruh"); } 
      | Var    '='    ExprInt               { atribui($1,$3,tabID,INTE,&flagError); }
      | Var    '='    ExprStr               { atribui($1,$3,tabID,STRI,&flagError); }
      | Var    '='    ExprBool              { atribui($1,$3,tabID,INTE,&flagError); }
      | Var    '='    ExprFloat             { atribui($1,$3,tabID,FLOT,&flagError); }
      ;

Write: WRITE '(' ID ')'                     { escreve($3, tabID, &flagError); }
     | WRITE '(' ExprInt ')'                { asprintf(&$$,"%sWRITEI\n", $3); }  
     | WRITE '(' ExprStr ')'                { asprintf(&$$,"%sWRITES\n", $3); }
     | WRITE '(' ExprFloat ')'              { asprintf(&$$,"%sWRITEF\n", $3); }
     | WRITE '(' ExprBool ')'               { asprintf(&$$,"%sWRITEI\n", $3); }
     ;

Read: READ '(' ID ')'                       { le($3, tabID,&flagError); }
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
//       | ExprCmpFloat                         { asprintf(&$$, "%s",$1); }
       ;

Bool: ID                                      { fetch_var(&$$, $1, tabID, INTE,&flagError); }
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
    | ID                                      { fetch_var(&$$, $1, tabID, INTE,&flagError); }
    | '(' ExprInt ')'                         { asprintf(&$$,"%s",$2);}
    ;


///////////////////////////////////////////////////////////////////////////////////////
ExprStr: FatorStr                             { asprintf(&$$, "%s",$1); }
       | ExprStr '#' FatorStr                 { asprintf(&$$,"%s%sCONCAT\n",$1,$3); }
       ;

FatorStr: STR                                 { asprintf(&$$,"PUSHS %s\n",$1); }
        | ID                                  { fetch_var(&$$, $1, tabID, STRI,&flagError); if (flagError) return; }
        ;

/////////////////////////////////////////////////////////////////////////////////////////
//
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
       | ID                                   { fetch_var(&$$, $1, tabID, FLOT,&flagError); }
       | '(' ExprFloat ')'                    { asprintf(&$$,"%s",$2); }
       ;



%%




int yyerror(char* s){
  printf("Frase invalida: %s\n",s);
}

int main(){
	tabID = new_hash_table();
	int i;
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


