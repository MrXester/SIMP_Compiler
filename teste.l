%{
#include "y.tab.h"
#include "string.h"
#include <stdio.h>
#include <ctype.h>
%}

%option noyywrap



%%

[+\-*/()=\n\r#\{\}]		{return yytext[0];}
(?i:false)			{return FALSE;}
(?i:true)			{return TRUE;}
(?i:or)				{return OR;}
(?i:and)			{return AND;}
(?i:main)           {return MAIN;}
(?i:declare)        {return DECLARE;}
(?i:int)            {return INTEGER;}
(?i:str)            {return STRING;}
(?i:float)          {return FLOAT;}
(?i:bool)           {return BOOL;}
"=="				{return EQ;}
"!="				{return NE;}
"<="				{return LE;}
"<"					{return LT;}
">="				{return GE;}
">"					{return GT;}
"not"				{return NOT;}
"read"				{return READ;}
"write"				{return WRITE;}
[a-zA-Z]+			{yylval.string = strdup(yytext);return ID;}
\"([^\"]|\\\")*\"	{yylval.string = strdup(yytext);return STR;}
\n 					{return '\n';} 
[0-9]+				{yylval.intg = atoi(yytext);return INT;}
[0-9]+(\.[0-9]+) 	{yylval.flt = atof(yytext);return FLT;}
.            		{;}
%%
