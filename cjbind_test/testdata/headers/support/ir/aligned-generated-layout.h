typedef int AlignedInt __attribute__((aligned(8)));
typedef AlignedInt NestedAlignedInt;

struct AlignedAliasRecord { char prefix; AlignedInt value; };
struct NestedAliasRecord { char prefix; NestedAlignedInt value; };

enum __attribute__((aligned(8))) AlignedEnum { AlignedEnumValue = 1 };
struct AlignedEnumRecord { char prefix; enum AlignedEnum value; };

struct __attribute__((aligned(8))) AlignedInner { char byte; };
struct AlignedOuter { int before; struct AlignedInner inner; };

struct Pair { int first; int second; };
typedef struct Pair AlignedPair __attribute__((aligned(8)));
struct AlignedArrayRecord { char prefix; AlignedPair values[1]; };
struct AlignedZeroArrayRecord { char prefix; AlignedPair values[0]; char tail; };

typedef unsigned int UnderAlignedInt __attribute__((aligned(2)));
struct UnderAlignedRecord {
    char before;
    UnderAlignedInt bits : 31;
    char mid;
    UnderAlignedInt inner;
    char tail;
};

/* Total size/alignment match despite the ordinary field's wrong natural offset. */
struct SameSizeWrongOffset { char before; UnderAlignedInt value; long long tail; };

struct BitfieldGap { char before; int bits : 30; char after; };

void aligned_record_value(struct AlignedAliasRecord value);
void aligned_record_pointer(struct AlignedAliasRecord *value);
