__SIZE_TYPE__ strlen(const char *s);
typedef __typeof__(strlen("")) BuiltinSize;
extern const BuiltinSize frozen_size;
void inspect_sizes(const BuiltinSize *immutable, BuiltinSize *mutable_value);
