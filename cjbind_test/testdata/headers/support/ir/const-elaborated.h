typedef unsigned long PlainAlias;
struct PlainRecord { int value; };
enum PlainEnum { PLAIN_ENTRY = 0 };

extern const PlainAlias constant_alias;
extern PlainAlias mutable_alias;
extern const struct PlainRecord constant_record;
extern struct PlainRecord mutable_record;
extern const enum PlainEnum constant_enum;
extern enum PlainEnum mutable_enum;

void inspect_aliases(const PlainAlias *frozen, PlainAlias *mutable_value);

static inline const PlainAlias *identity(const PlainAlias *value) {
    return value;
}
