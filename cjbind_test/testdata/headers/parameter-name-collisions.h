// cjbind-options: --default-alias-style new_type

void unnamed_first(int, int arg1);
void unnamed_last(int arg1, int);
void keyword_collision(int type, int type_, int type__1);
int identity(int identity);
typedef int Strong;
Strong alias_collision(Strong arg1, Strong);
Strong alias_shadow(Strong alias_shadow);
typedef int (*Callback)(int arg1, int);
struct Callbacks { int (*callback)(int arg1, int); };
