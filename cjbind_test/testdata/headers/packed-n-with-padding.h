#pragma pack(push, 2)
struct Packed {
    char a;
    short b;
    char c;
    int d;
};
#pragma pack(pop)

#pragma pack(push, 2)
struct PackedLongWithChars {
    unsigned long x;
    char a;
    char b;
    char c;
};
#pragma pack(pop)
