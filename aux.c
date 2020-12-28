#include "aux.h"

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

int insert(HASH_TABLE hash_table, char* var_name, int type){
	int key = (int) hashFun(var_name);
	int r = -1;
	VAR_LIST elem = lookup(hash_table,var_name);

	if( elem != NULL && type == elem->type){
			r = elem->pos;
	}

	else{
		
		VAR_LIST allocate = new_list(var_name, type, hash_table->used);
		allocate->prox = hash_table->table[key];
		hash_table->table[key] = allocate;
		hash_table->used++;
		r = allocate -> pos;
    }
    return r;
}

VAR_LIST lookup(HASH_TABLE hash_table, char* var_name){
	int key = (int) hashFun(var_name);

	VAR_LIST curr = hash_table->table[key];

	while(strcmp(curr->name,var_name) != 0 && curr != NULL){
		curr = curr -> prox;
	}

	return curr;
}

void aloca_variavel(char* var_name, char* var_val, HASH_TABLE tabID, int type){
	int r = insert(tabID,var_name,type);
	
	if(r < 0){printf("ERROR\n");}
	
	else{printf("%sSTOREG %d\n",var_val,r);}
}

void fetch_var(char** instruction, char* var_name, HASH_TABLE tabID, int type){ // LEMBRAR O ERRO DO JP
	VAR_LIST r = lookup(tabID,var_name);
	if(r != NULL){
		asprintf(instruction, "PUSHG %d\n", r->pos);
	}

	//else {raise error}
}