%{

#include <stdio.h>
#include "string.h"      
#include "lex.yy.c"
#include "auxFile.c"


int flagError = 0;
HASH_TABLE tabID;
int tag_num = 0;

extern int yylineno;

%}

%union{ int intg; char*string;}
%token AND OR NOT
%token EQ NE LT LE GT GE
%token TRUE FALSE IF THEN ELSE REPEAT UNTIL FOR WHILE
%token <string> DECLARE ID MAIN WRITE READ SKIP
%token <intg> INT

%type <string> Header ListIds ListId Main Cmds Cmd Atrib Write Read ExprCmpInt ExprInt Termo Fator Condic Repeat ForL While Identificador


%%
Programa: Header Main              { printf("%s%sSTOP\n",$1,$2); }
        ;

Header: DECLARE '{' ListIds '}'     { $$ = strdup($3); }
      ;

ListIds: ListIds ListId    				  { asprintf(&$$, "%s%s", $1,$2); }
	   | ListId		            				{ $$ = strdup($1); }
	   ;


ListId: Identificador									       
	  | ListId ',' Identificador			{ asprintf(&$$,"%s%s",$1,$3);}
	  ;

Identificador: ID                    { aloca(&$$,tabID,$1,INTEG,1,1,&flagError); }
			 | ID'['INT']'                 { aloca(&$$,tabID,$1,ARRAY,$3,1,&flagError); }
       | ID'['INT']''['INT']'        { aloca(&$$,tabID,$1,ARRTD,$3,$6,&flagError); }
			 ;

Main: MAIN '{' Cmds '}' 				     { asprintf(&$$,"START\n%s",$3); }
    ;


Cmds : Cmd  									       { $$ = strdup($1); }
     | Cmds Cmd 						         { asprintf(&$$, "%s%s", $1,$2); }
     ;


Cmd : Atrib             						  { $$ = strdup($1); }
    | Read  									        { $$ = strdup($1); }
    | Write 									        { $$ = strdup($1); }
	  | Condic 										      { $$ = strdup($1); }
	  | Repeat									        { $$ = strdup($1); }
    | While                           { $$ = strdup($1); }
    | ForL                            { $$ = strdup($1); }
	  | SKIP                            { $$ = strdup(""); }
    ;


Condic: IF ExprCmpInt THEN  '{'  Cmds  '}'  ELSE '{'  Cmds  '}'          {asprintf(&$$,"%sJZ E%d\n%sJUMP E%d\nE%d:\n%sE%d:\n",$2, tag_num, $5,tag_num+1,tag_num,$9,tag_num+1);tag_num += 2;} 
      ;

Repeat: REPEAT '{' Cmds '}' UNTIL ExprCmpInt                             {asprintf(&$$,"E%d:\n%s%sJZ E%d\n", tag_num, $3, $6, tag_num); tag_num++;}
      ;

While: WHILE ExprCmpInt '{' Cmds '}'                                     {asprintf(&$$,"E%d:\n%sJZ E%d\n%sJUMP E%d\nE%d:\n",tag_num,$2,tag_num+1,$4,tag_num,tag_num+1); tag_num +=2;}
     ;

ForL: FOR '(' Cmd ',' ExprCmpInt ',' Cmd ')' '{' Cmds '}'              {asprintf(&$$,"%sE%d:\n%sJZ E%d\n%s%sJUMP E%d\nE%d:\n",$3,tag_num,$5,tag_num+1,$10,$7,tag_num,tag_num+1); tag_num +=2;}
    ; 

Atrib : ID    '='    ExprCmpInt                                 { atribui(&$$,$1,$3,"","",tabID,INTEG,&flagError); }
      | ID'['ExprInt']' '=' ExprCmpInt                          { atribui(&$$,$1,$6,$3,"",tabID,ARRAY,&flagError); }
      | ID'['ExprInt']''['ExprInt']' '=' ExprCmpInt             { atribui(&$$,$1,$9,$3,$6,tabID,ARRTD,&flagError); }
      ;


Write: WRITE '(' ExprCmpInt ')'                      { asprintf(&$$,"%sWRITEI\n", $3); }
     ;


Read: READ '(' ID ')'                                { le(&$$,$3,INTEG,"","",tabID,&flagError); }
    | READ '(' ID '['ExprInt']' ')'                  { le(&$$,$3,ARRAY,$5,"",tabID,&flagError); }
    | READ '(' ID '['ExprInt']' '['ExprInt']' ')'    { le(&$$,$3,ARRTD,$5,$8,tabID,&flagError); }
    ;


ExprCmpInt: ExprInt 								                { asprintf(&$$, "%s",$1); }
		      | ExprCmpInt EQ ExprCmpInt                { asprintf(&$$, "%s%sEQUAL\n",$1,$3); }
          | ExprCmpInt NE ExprCmpInt                { asprintf(&$$, "%s%sEQUAL\nNOT",$1,$3); }
          | ExprCmpInt LT ExprCmpInt                { asprintf(&$$, "%s%sINF\n",$1,$3); }
          | ExprCmpInt LE ExprCmpInt                { asprintf(&$$, "%s%sINFEQ\n",$1,$3); }
          | ExprCmpInt GT ExprCmpInt                { asprintf(&$$, "%s%sSUP\n",$1,$3); } 
          | ExprCmpInt GE ExprCmpInt                { asprintf(&$$, "%s%sSUPEQ\n",$1,$3); }
          | NOT ExprCmpInt  						            { asprintf(&$$, "%sNOT\n",$2); }
          ;


ExprInt: Termo                                { asprintf(&$$, "%s",$1); }
       | ExprInt '+' Termo                    { asprintf(&$$, "%s%sADD\n",$1,$3); }
       | ExprInt '-' Termo                    { asprintf(&$$, "%s%sSUB\n",$1,$3); }
       | ExprInt OR Termo					            {	asprintf(&$$, "%s%sADD\n",$1,$3);}
       ;

Termo : Fator                                 { asprintf(&$$, "%s",$1); }
    | Termo '*' Fator                         { asprintf(&$$, "%s%sMUL\n",$1,$3); }
    | Termo '/' Fator                         { asprintf(&$$, "%s%sDIV\n",$1,$3); }
    | Termo '%' Fator                         { asprintf(&$$, "%s%sMOD\n",$1,$3); }
    | Termo AND Fator						              { asprintf(&$$, "%s%sMUL\n",$1,$3); }
    ;


Fator : INT                                   { asprintf(&$$,"PUSHI %d\n",$1); }
    | '-' INT                                 { asprintf(&$$,"PUSHI -%d\n",$2); }
    | TRUE									                  { asprintf(&$$,"PUSHI 1\n"); }
    | FALSE									                  { asprintf(&$$,"PUSHI 0\n"); }
    | ID                                      { fetch_var(&$$,$1,INTEG,"","",tabID,&flagError); }
    | ID '['ExprInt']'                        { fetch_var(&$$, $1,ARRAY,$3,"",tabID,&flagError); }
    | ID '['ExprInt']''['ExprInt']'           { fetch_var(&$$, $1,ARRTD,$3,$6,tabID,&flagError); }
    | '(' ExprCmpInt ')'                      { asprintf(&$$,"%s",$2);}
    ;

%%

void yyerror(const char* msg){
  printf("Frase invalida: %s, line: %d\n",msg, yylineno);
}

int main(){
	tabID = new_hash_table();
  yyparse();
  return 0;
}











