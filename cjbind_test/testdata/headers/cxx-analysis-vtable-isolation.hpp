// cjbind-options: --vtable-generation -- -x c++ -std=c++14

struct VirtualArgument {
    virtual int value() const;
};

template <typename T>
struct PlainTemplate {
    int marker;
};

struct TemplateArgumentMustNotAddVtable : PlainTemplate<VirtualArgument> {
    int payload;
};

struct FieldMustNotAddVtable {
    VirtualArgument member;
    int payload;
};

struct OuterMustNotUseNestedVtable {
    struct NestedVirtual {
        virtual void run();
    };

    int payload;
};

struct AnalysisVtableIsolationHolder {
    TemplateArgumentMustNotAddVtable templateArgument;
    FieldMustNotAddVtable field;
    OuterMustNotUseNestedVtable nested;
};
