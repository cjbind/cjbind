// cjbind-options: --default-alias-style new_type --type-alias ^(PlainAlias|AliasCallback|AliasModeCallback)$ --new-type-alias ^StrongAlias$ --new-type-alias-deref ^AccessibleAlias$ --default-enum-style newtype

typedef int DefaultStrongAlias;
typedef int PlainAlias;
typedef unsigned int StrongAlias;
typedef long long AccessibleAlias;
typedef float FloatAlias;
typedef void VoidAlias;

static const PlainAlias PLAIN_ALIAS_CONST = -3;
static const StrongAlias STRONG_ALIAS_CONST = 5;
static const AccessibleAlias ACCESSIBLE_ALIAS_CONST = -7;
static const FloatAlias FLOAT_ALIAS_CONST = 1.5f;

typedef AccessibleAlias (*AliasCallback)(
    StrongAlias strong,
    AccessibleAlias accessible,
    StrongAlias *pointer
);

enum AliasMode {
    ALIAS_MODE_ZERO,
    ALIAS_MODE_ONE,
    ALIAS_MODE_TWO
};

typedef enum AliasMode AliasModeAlias;
typedef enum AliasMode (*AliasModeCallback)(enum AliasMode value);

enum AliasMode alias_mode_round_trip(enum AliasMode value);
AliasModeAlias alias_mode_alias_round_trip(AliasModeAlias value);

struct AliasBits {
    StrongAlias strong : 3;
    AccessibleAlias accessible : 5;
    PlainAlias plain : 4;
    enum AliasMode mode : 2;
};

DefaultStrongAlias alias_round_trip(
    PlainAlias plain,
    StrongAlias strong,
    AccessibleAlias accessible
);

FloatAlias float_alias_round_trip(FloatAlias value);
void update_strong_alias(StrongAlias *value);
