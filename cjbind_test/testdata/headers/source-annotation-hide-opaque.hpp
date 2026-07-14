// cjbind-options: -- -x c++ -std=c++14

/** <div cjbind hide></div> */
struct SourceAnnotationHiddenRecord {
    int hiddenValue;
};

/** <div cjbind hide/> */
enum SourceAnnotationHiddenEnum {
    SourceAnnotationHiddenEnumValue,
};

enum SourceAnnotationVariantHide {
    SourceAnnotationVisibleVariant,
    SourceAnnotationHiddenVariant, /**< <div cjbind hide></div> */
    SourceAnnotationFollowingVariant,
};

/** <div cjbind opaque>Opaque record documentation.</div> */
struct SourceAnnotationOpaqueRecord {
    int concealedValue;
};

struct SourceAnnotationOpaqueReference {
    SourceAnnotationOpaqueRecord* value;
};

/** <div cjbind hide opaque></div> */
struct SourceAnnotationHiddenOpaqueRecord {
    int hiddenConcealedValue;
};
