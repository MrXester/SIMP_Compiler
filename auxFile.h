#define INT 0
#define FLT 1
#define STR 2
#define HASHSZ 1024

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
