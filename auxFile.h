#define INTE 0
#define FLOT 1
#define STRI 2
#define HASHSZ 1024

#define REALLOC 1
#define NOALLOC 2
#define TYPDIFF 3

#define INTEG 1
#define ARRAY 2
#define ARRTD 3

typedef struct var_list{
	char* name;
	int pos;
	int type;
	struct var_list* prox;
}*VAR_LIST;

typedef struct hash_table{
	VAR_LIST table[HASHSZ];
	int used;
}*HASH_TABLE;

VAR_LIST new_list(char* name, int pos);

HASH_TABLE new_hash_table();

int insert(HASH_TABLE hash_table, char* var_name);

VAR_LIST lookup(HASH_TABLE hash_table, char* var_name);
