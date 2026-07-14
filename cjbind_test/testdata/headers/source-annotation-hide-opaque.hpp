// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

/** <div cjbind hide></div> */
struct SourceAnnotationHiddenRecord {
    int hiddenValue;
};

/** <div cjbind opaque></div> */
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
