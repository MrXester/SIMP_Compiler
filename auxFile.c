#include "auxFile.h"

unsigned long hashFun(char *str){
    unsigned long hash = 5381;
    int c;

    while (c = *str++)
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */

    return hash % HASHSZ;
}

VAR_LIST new_list(char* name, int pos){
	VAR_LIST new = (VAR_LIST) malloc(sizeof(struct var_list));

	new -> name = strdup(name);
	new -> pos = pos;
	new -> prox = NULL;

	return new;
}

HASH_TABLE new_hash_table(){
   
   HASH_TABLE new = (HASH_TABLE) malloc(sizeof(struct hash_table));
   
   int i;
   
   for(i = 0; i < HASHSZ; i++){
   	new->table[i] = NULL;
   }

   new -> used = 0;

   return new;
}

void aloca(char**instruction,HASH_TABLE hash_table, char* var_name, int *flagError){
	int key = (int) hashFun(var_name);
	VAR_LIST elem = lookup(hash_table,var_name);

	if( elem != NULL){
		printf("REALLOC\n");
		*flagError = REALLOC;
		return;
	}


	VAR_LIST allocate = new_list(var_name, hash_table->used);
	allocate->prox = hash_table->table[key];
	hash_table->table[key] = allocate;
	hash_table->used++;
	asprintf(instruction,"PUSHI 0\n");

}


void atribui(char**instruction, char* var_name, char*inst_var_val, HASH_TABLE tabID, int *flagError){
	VAR_LIST elem = lookup(tabID,var_name);
	if (elem == NULL){
		printf("NOALLOC\n");
		*flagError = NOALLOC;
		return;
	}	

	asprintf(instruction,"%sSTOREG %d\n",inst_var_val,elem->pos);
}



VAR_LIST lookup(HASH_TABLE hash_table, char* var_name){
	int key = (int) hashFun(var_name);

	VAR_LIST curr = hash_table->table[key];

	while(curr != NULL && strcmp(curr->name,var_name) != 0 ){
		curr = curr -> prox;
	}

	return curr;
}



void fetch_var(char** instruction, char* var_name, HASH_TABLE tabID, int *flagError){
	VAR_LIST elem = lookup(tabID,var_name);

	if (elem == NULL){
		printf("NOALLOC\n");
		*flagError = NOALLOC;
		return;
	}

	asprintf(instruction, "PUSHG %d\n", elem->pos);
}


void escreve(char** instruction, char* var_name, HASH_TABLE tabID, int *flagError){
	VAR_LIST elem = lookup(tabID,var_name);

	if (elem == NULL){
		printf("NOALLOC\n");
		*flagError = NOALLOC;
		return;
	}

	asprintf(instruction, "PUSHG %d\nWRITEI\n", elem->pos);
}

void le(char**instruction,char* var_name, HASH_TABLE tabID, int *flagError){
	VAR_LIST elem = lookup(tabID,var_name);

	if (elem == NULL){
		printf("NOALLOC\n");
		*flagError = NOALLOC;
		return;
	}


	asprintf(instruction, "READ\nATOI\nSTOREG %d\n", elem->pos);
}
