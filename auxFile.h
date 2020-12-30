#define INTE 0
#define FLOT 1
#define STRI 2
#define HASHSZ 1024

#define REALLOC 1
#define NOALLOC 2
#define TYPDIFF 3  

typedef struct var_list{
	char* name;
	int type;
	int pos;
	struct var_list* prox;
}*VAR_LIST;

typedef struct hash_table{
	VAR_LIST table[HASHSZ];
	int used;
}*HASH_TABLE;

VAR_LIST new_list(char* name, int type, int pos);

HASH_TABLE new_hash_table();

int insert(HASH_TABLE hash_table, char* var_name, int type);

VAR_LIST lookup(HASH_TABLE hash_table, char* var_name);
