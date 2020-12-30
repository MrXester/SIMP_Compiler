#include "auxFile.h"

unsigned long hashFun(char *str){
    unsigned long hash = 5381;
    int c;

    while (c = *str++)
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */

    return hash % HASHSZ;
}

VAR_LIST new_list(char* name, int type, int pos){
	VAR_LIST new = (VAR_LIST) malloc(sizeof(struct var_list));

	new -> name = strdup(name);
	new -> type = type;
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

void aloca(HASH_TABLE hash_table, char* var_name, int type){
	int key = (int) hashFun(var_name);
	VAR_LIST elem = lookup(hash_table,var_name);

	if( elem != NULL){
		flagError = REALLOC;
	}

	else{
		VAR_LIST allocate = new_list(var_name, type, hash_table->used);
		allocate->prox = hash_table->table[key];
		hash_table->table[key] = allocate;
		hash_table->used++;
	}

	switch(type){
		case FLOT:
		printf("PUSHF 0\n");
		break;

		case STRI:
		printf("PUSHS \"\\0\"\n");
		break;

		default:
		printf("PUSHI 0\n");
		break;
	}
}


void atribui(char* var_name, char*inst_var_val, HASH_TABLE tabID, int type){
	VAR_LIST elem = lookup(hash_table,var_name);
	if (elem == NULL){
		flagError = NOALLOC;
		return;
	}

	if (elem -> type != type){
		flagError = TYPDIFF;
		return;
	}	

	printf("%sSTOREG %d\n",inst_var_val,elem->pos);
}



VAR_LIST lookup(HASH_TABLE hash_table, char* var_name){
	int key = (int) hashFun(var_name);

	VAR_LIST curr = hash_table->table[key];

	while(curr != NULL && strcmp(curr->name,var_name) != 0 ){
		curr = curr -> prox;
	}

	return curr;
}



void fetch_var(char** instruction, char* var_name, HASH_TABLE tabID, int type){
	VAR_LIST elem = lookup(tabID,var_name);

	if (elem == NULL){
		flagError = NOALLOC;
		return;
	}

	if (elem -> type != type){
		flagError = TYPDIFF;
		return;
	}	


	asprintf(instruction, "PUSHG %d\n", r->pos);
}


