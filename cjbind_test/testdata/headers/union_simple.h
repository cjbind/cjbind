// Test union with basic types
union SimpleUnion {
    int i;
    float f;
    char c;
};

// Test union with different alignments
union AlignedUnion {
    char c;
    double d;
};

// Test union inside struct
struct HasUnion {
    int tag;
    union SimpleUnion data;
};
