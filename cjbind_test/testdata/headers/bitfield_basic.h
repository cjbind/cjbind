// Test basic bitfield struct
struct BitfieldStruct {
    unsigned int a : 4;
    unsigned int b : 4;
    unsigned int c : 8;
    unsigned int d : 16;
};

// Test bitfield mixed with normal fields
struct MixedBitfield {
    int normal_field;
    unsigned char x : 3;
    unsigned char y : 5;
    int another_normal;
};

// Test signed bitfield
struct SignedBitfield {
    signed int val : 4;
    unsigned int uval : 4;
};
