#objective
EXEC = teste# <==== nome do arquivo a ser gerado, os demais arquivos em flex e yacc deverão estar em função deste nome, i.e., "calc.y"  "calc.l" 
CFLAGS = -Wall#flags <===== altere aqui as flags de sua preferência para o GCC

###################################################################################################
#							   			v3.5 - by MrXester						  		  		  #
#						COPYRIGHTS © MrXester, 2020-2021 All rights reserved		  		  	  #
###################################################################################################

#files
LX = $(EXEC).l#filtro léxico
TB = $(EXEC).y#filtro yacc

#COMPILADORES
CC = gcc#compilador
FX = flex#flex
YC = yacc#yacc

#RESIDUOS
TBH = y.tab.h#H do yacc
TBC = y.tab.c#C do yacc
LXC = lex.yy.c#C do flex
RESIDUAL = $(TBC) $(TBH) $(LXC)# arquivos a serem removidos após a criação do executável

all: exec clean

lex: $(LX)
	$(FX) $(LX)

header: $(TB)
	$(YC) -d $(TB)

tab: $(TB)
	$(YC) $(TB)

exec: header lex tab
	$(CC) $(CFLAGS) -o $(EXEC) $(TBC)

clean:
	rm -r -f $(RESIDUAL)


