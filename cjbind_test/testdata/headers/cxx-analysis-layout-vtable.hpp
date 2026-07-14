// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --vtable-generation

struct Empty {};

struct EmptyDerived : Empty {};

struct InheritsEmpty : Empty {
    bool value;
};

struct ContainsEmpty {
    Empty empty;
    bool value;
};

struct ContainsEmptyArray {
    Empty values[4];
};

template <typename T>
struct EmptyTemplate {};

template <typename T>
struct DependentSize {
    T value;
};

struct TemplateEmptyBase : EmptyTemplate<int> {
    unsigned char value;
};

struct TemplateEmptyMember {
    EmptyTemplate<double> empty;
    unsigned char value;
};

struct DeepEmptyBase : EmptyDerived {
    unsigned char value;
};

template <typename T>
struct BaseWithVtable {
    T value;
    virtual T get() const;
};

struct DerivedFromVtable : BaseWithVtable<char*> {};

struct DerivedAddsVirtual : BaseWithVtable<char*> {
    virtual int extra();
};

template <typename T>
struct BaseWithoutVtable {
    T value;
};

struct DerivedIntroducesVtable : BaseWithoutVtable<int> {
    virtual void run();
};

struct DerivedWithoutVtable : BaseWithoutVtable<int> {};

struct VirtualRoot {
    virtual VirtualRoot* root();
};

struct VirtualMiddle : VirtualRoot {};

struct VirtualLeaf : VirtualMiddle {};

struct RecursiveDerived;

struct RecursiveBase {
    virtual RecursiveDerived* derived();
};

struct RecursiveDerived : RecursiveBase {
    RecursiveDerived* derived() override;
};

struct LayoutAnalysisHolder {
    Empty empty;
    EmptyDerived emptyDerived;
    InheritsEmpty inherits;
    ContainsEmpty contains;
    ContainsEmptyArray array;
    TemplateEmptyBase templateBase;
    TemplateEmptyMember templateMember;
    DeepEmptyBase deepBase;
    DependentSize<int> dependentNonZero;
    DerivedFromVtable* inheritedVtable;
    DerivedIntroducesVtable* introducedVtable;
    DerivedWithoutVtable* noVtable;
    VirtualLeaf* deepVtable;
    RecursiveDerived* recursiveVtable;
};
