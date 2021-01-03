%{

#include <stdio.h>
#include "string.h"      
#include "lex.yy.c"
#include "auxFile.c"


int flagError = 0;
HASH_TABLE tabID;

extern int yylineno;

%}

%union{ int intg; char*string;}
%token AND OR NOT
%token EQ NE LT LE GT GE
%token TRUE FALSE 
%token <string> DECLARE ID MAIN INT WRITE READ

%type <string> Header ListIds ListId Main Cmds Cmd Atrib Write Read ExprCmpInt ExprInt Termo Fator


%%
Programa: Header Main           { printf("%s%s",$1,$2); }
        ;

Spacing:
	   | '\n' Spacing
	   ;

Header: DECLARE '{' ListIds '}' {$$ = strdup($3);}
      ;

ListIds: ListIds ListId    				  { asprintf(&$$, "%s%s", $1,$2); }
	   | ListId		            				{ $$ = strdup($1); }
	   ;


ListId: ID 										{ aloca(&$$,tabID,$1,&flagError); }
	  | ListId ',' ID 							{ aloca(&$$,tabID,$3,&flagError); asprintf(&$$,"%s%s",$$,$1);}
	  ;


Main: MAIN '{' Cmds '}' 				{ asprintf(&$$,"START\n%s",$3); }
    ;


Cmds : Cmd  									{ $$ = strdup($1); }
     | Cmds Cmd 						  { asprintf(&$$, "%s%s", $1,$2); }
     ;


Cmd : Atrib             						{ $$ = strdup($1); }
    | Read  									      { $$ = strdup($1); }
    | Write 									      { $$ = strdup($1); }
//    | Condic 										   {}
//    | Repeat
    ;


//Condic: IF ExprCmpInt THEN Spacing '{' Spacing Cmds Spacing '}' Spacing ELSE '{' Spacing Cmds Spacing '}' {asprintf()} 
//printf(" expr (JUMPZ E0) Cmds (JUMP E1) .E0 Cmds .E1")

Atrib : ID    '='    ExprCmpInt              	{ atribui(&$$,$1,$3,tabID,&flagError); }
      ;


Write: WRITE '(' ExprCmpInt ')'                	{ asprintf(&$$,"%sWRITEI\n", $3); }
     ;


Read: READ '(' ID ')'                       	{ le(&$$,$3, tabID,&flagError); }
    ;


ExprCmpInt: ExprInt 								{ asprintf(&$$, "%s",$1); }
		  | ExprCmpInt EQ ExprCmpInt                { asprintf(&$$, "%s%sEQUAL\n",$1,$3); }
          | ExprCmpInt NE ExprCmpInt                { asprintf(&$$, "%s%sEQUAL\nNOT",$1,$3); }
          | ExprCmpInt LT ExprCmpInt                { asprintf(&$$, "%s%sINF\n",$1,$3); }
          | ExprCmpInt LE ExprCmpInt                { asprintf(&$$, "%s%sINFEQ\n",$1,$3); }
          | ExprCmpInt GT ExprCmpInt                { asprintf(&$$, "%s%sSUP\n",$1,$3); } 
          | ExprCmpInt GE ExprCmpInt                { asprintf(&$$, "%s%sSUPEQ\n",$1,$3); }
          | NOT ExprCmpInt  						{ asprintf(&$$, "%sNOT\n",$2); }
          ;


ExprInt: Termo                                { asprintf(&$$, "%s",$1); }
       | ExprInt '+' Termo                    { asprintf(&$$, "%s%sADD\n",$1,$3); }
       | ExprInt '-' Termo                    { asprintf(&$$, "%s%sSUB\n",$1,$3); }
       | ExprInt OR Termo					  {	asprintf(&$$, "%s%sADD\n",$1,$3);}
       ;

Termo : Fator                                 { asprintf(&$$, "%s",$1); }
    | Termo '*' Fator                         { asprintf(&$$, "%s%sMUL\n",$1,$3); }
    | Termo '/' Fator                         { asprintf(&$$, "%s%sDIV\n",$1,$3); }
    | Termo AND Fator						  {asprintf(&$$, "%s%sMUL\n",$1,$3); }
    ;


Fator : INT                                   { asprintf(&$$,"PUSHI %d\n",$1); }
    | '-' INT                                 { asprintf(&$$,"PUSHI -%d\n",$2); }
    | TRUE									  { asprintf(&$$,"PUSHI 1\n"); }
    | FALSE									  { asprintf(&$$,"PUSHI 0\n"); }
    | ID                                      { fetch_var(&$$, $1, tabID, &flagError); }
    | '(' ExprCmpInt ')'                      { asprintf(&$$,"%s",$2);}
    ;



%%

void yyerror(const char* msg){
  printf("Frase invalida: %s, l: %d\n",msg, yylineno);
}

int main(){
	tabID = new_hash_table();
    yyparse();
    printf("STOP\n");
    return 0;
}











