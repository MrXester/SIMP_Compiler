#define INTE 0
#define FLOT 1
#define STRI 2
#define VOID 3
#define HASHSZ 1024

#define REALLOC 1
#define NOALLOC 2
#define TYPDIFF 3
#define NORETRN 4
#define NODEFIN 5
#define REDEFIN 6

#define INTEG 1
#define ARRAY 2
#define ARRTD 3

typedef struct var_list{
	char* name;
	int pos;
	int type;
	int line;
	struct var_list* prox;
}*VAR_LIST;

typedef struct fun_list{
	char* name;
	int tag;
	int type;
	struct fun_list* prox;
}*FUN_LIST;

typedef struct hash_table{
	VAR_LIST table[HASHSZ];
	FUN_LIST fun_table[HASHSZ];
	int used;
}*HASH_TABLE;



VAR_LIST new_list(char* name, int pos);

HASH_TABLE new_hash_table();

int insert(HASH_TABLE hash_table, char* var_name);

VAR_LIST lookup(HASH_TABLE hash_table, char* var_name);

FUN_LIST new_fun_list(char*name);

// x[a][b]    x[y][z]
// b*y + a
