#define MACRO_SMALL 0.0000001
#define MACRO_PI 3.14159265358979323846
#define MACRO_ZERO 0.0
#define MACRO_NEG_ZERO (-0.0)
#define MACRO_MIN_SUB 0x1p-1074
#define MACRO_FLOAT_SMALL 0.0000001f
#define MACRO_FLOAT_MIN_SUB 0x1p-149f

static const double CONST_SMALL = 0.0000001;
static const double CONST_PI = 3.14159265358979323846;
static const double CONST_ZERO = 0.0;
static const double CONST_NEG_ZERO = -0.0;
static const double CONST_MIN_SUB = 0x1p-1074;
static const float CONST_FLOAT_SMALL = 0.0000001f;
static const float CONST_FLOAT_NEG_ZERO = -0.0f;
static const float CONST_FLOAT_MIN_SUB = 0x1p-149f;
static const int CONST_INTEGER = 42;
typedef const int ImmutableValue;
static ImmutableValue CONST_ALIAS = 43;
static const char CONST_BYTES[] = "ok";
typedef const char ImmutableBytes[3];
static ImmutableBytes CONST_ARRAY_ALIAS = "ok";
static const char *const CONST_POINTER = "ok";

static int MUTABLE_INTEGER = 1;
static double MUTABLE_FLOAT = 0.1;
static char MUTABLE_BYTES[] = "bad";
static const char *MUTABLE_POINTER = "bad";
static const volatile int VOLATILE_INTEGER = 4;
static const volatile char VOLATILE_BYTES[] = "bad";
typedef const volatile int VolatileValue;
static VolatileValue VOLATILE_ALIAS = 5;

#ifdef __SIZEOF_INT128__
#define WIDE_HIGH (((__int128)1) << 80)
#define WIDE_LOW ((((unsigned __int128)1) << 80) + 7)
#define WIDE_SMALL ((__int128)7)
#endif
