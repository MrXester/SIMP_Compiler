%{
#include "y.tab.h"
#include "string.h"
#include <stdio.h>
#include <ctype.h>
%}

%option noyywrap
%option yylineno


%%

[+\-*/()=\{\},%\[\]]					{return yytext[0];}
(?i:false)								{return FALSE;}
(?i:true)								{return TRUE;}
(?i:or)									{return OR;}
(?i:and)								{return AND;}
(?i:main)           					{return MAIN;}
(?i:declare)        					{return DECLARE;}
(?i:if)                                 {return IF;}
(?i:WHILE)                              {return WHILE;}
(?i:FOR)                                {return FOR;}
(?i:then)                               {return THEN;}
(?i:else)                               {return ELSE;}
(?i:repeat)                             {return REPEAT;}
(?i:until)                              {return UNTIL;}
(?i:skip)                               {return SKIP;}
(?i:return)                             {return RETURN;}
"=="									{return EQ;}
"!="									{return NE;}
"<="									{return LE;}
"<"										{return LT;}
">="									{return GE;}
">"										{return GT;}
"not"									{return NOT;}
"read"									{return READ;}
"write"									{return WRITE;}
[a-zA-Z]+								{yylval.string = strdup(yytext);return ID;}
[0-9]+									{yylval.intg = atoi(yytext);return INT;}
~[ ](.)*								{;} // comentario
[~][/][^/]*[/]+([^/~][^/]*[/]+)*[~]     {;} // comentario multi linha
.            							{;}
[\n]									{;}
%%
