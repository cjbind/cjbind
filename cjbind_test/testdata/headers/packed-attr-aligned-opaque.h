/// Packed records use opaque storage because the current Cangjie FFI cannot
/// declare packed field layout directly.
struct AlignedToOne {
    int i;
} __attribute__ ((packed,aligned(1)));

/// The opaque storage must preserve the explicit two-byte alignment.
struct AlignedToTwo {
    int i;
} __attribute__ ((packed,aligned(2)));

#pragma pack(1)

/// The translation unit reports the effective one-byte alignment even though
/// the packing directive is not attached to the record cursor.
struct PackedToOne {
    int x;
    int y;
};

#pragma pack()

#pragma pack(2)

/// The opaque storage must preserve the two-byte alignment introduced by the
/// packing directive.
struct PackedToTwo {
    int x;
    int y;
};

#pragma pack()
