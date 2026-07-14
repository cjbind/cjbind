// cjbind-options: --with-derive-default --with-derive-hash --with-derive-eq --with-derive-ord --opaque-type ^ConflictTemplate<int>$

template <typename T>
struct DerivedTemplate {
    T value;
};

template <typename T>
struct ConflictTemplate {
    T toString;
    T hashCode;
    T __cjbindPartialCompare;
};

struct TemplateDerivesHolder {
    DerivedTemplate<int> visible;
    ConflictTemplate<int> opaque;
};
