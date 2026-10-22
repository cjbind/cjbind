#define INT_ZERO 0
#define INT_NEG -1
#define INT_MAX 2147483647
#define UINT_MAX 4294967295U
#define HEX_HIGH 0x80000000
#define ULONG_ZERO 0UL
#define LONG_NEG (-2147483647L - 1)
#define ULL_MAX 18446744073709551615ULL
#define LL_MIN (-9223372036854775807LL - 1)
#define SHORT_NEG ((short)-32768)
#define USHORT_MAX ((unsigned short)65535)
#define SCHAR_NEG ((signed char)-128)
#define CHAR_NEG ((char)-1)
#define UCHAR_MAX ((unsigned char)255)
#define CHAR_ZERO ((char)'\0')
#define C_CHAR 'A'
#define PROMOTED_CHAR (((unsigned char)1) + ((unsigned char)2))
typedef long MacroLong;
#define TYPEDEF_LONG ((MacroLong)1)

#define FLOAT_ZERO 0.f
#define DOUBLE_ZERO ((double)0.f)
#define FLOAT_NEG_ZERO (-0.0f)
#define DOUBLE_NEG_ZERO (-0.0)
#define FLOAT_MAX 0x1.fffffep127f
#define FLOAT_MIN_SUB 0x1p-149f
#define DOUBLE_MIN_SUB 0x1p-1074
#define FLOAT_THIRD (1.0f / 3.0f)
#define DOUBLE_THIRD (1.0 / 3.0)
#define LONG_DOUBLE 1.0L
#define FLOAT_INFINITY __builtin_inff()
#define DOUBLE_NAN __builtin_nan("")
#ifdef __FLT16_MANT_DIG__
#define HALF_ONE ((_Float16)1.5)
#define HALF_MIN_SUB ((_Float16)0x1p-24)
#define HALF_NEG_ZERO ((_Float16)-0.0)
#endif
#ifdef __SIZEOF_INT128__
#define WIDE_INT (((__int128)1) << 100)
#endif

enum MacroEnum { enum_negative = -2, enum_positive = 2 };
#define ENUM_NEG enum_negative
#define ENUM_CAST ((enum MacroEnum)-1)

#ifdef __cplusplus
#define BOOL_TRUE true
#define BOOL_FALSE false
#define WCHAR_NEG ((wchar_t)-1)
#define WCHAR_VALUE L'\u03a9'
#define CHAR16_HIGH ((char16_t)65535)
#define CHAR32_HIGH ((char32_t)4294967295U)
#define CHAR16_VALUE u'\u03a9'
#define CHAR32_VALUE U'\U0001f600'
enum class MacroStrongEnum : unsigned short { high = 65535 };
#define SCOPED_ENUM MacroStrongEnum::high
#else
#define BOOL_TRUE ((_Bool)1)
#define BOOL_FALSE ((_Bool)0)
#endif
