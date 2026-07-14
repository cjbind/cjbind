// cjbind-options: --generate types,destructors -- -x c++ -std=c++14

struct TrivialValue {
    int value;
};

struct OwnDestructor {
    int value;
    ~OwnDestructor();
};

struct DeletedDestructor {
    int value;
    ~DeletedDestructor() = delete;
};

struct ContainsDestructor {
    OwnDestructor value;
};

struct InheritsDestructor : OwnDestructor {
    int marker;
};

struct DeepDestructor {
    ContainsDestructor value;
};

struct PointerOnlyDestructor {
    OwnDestructor* value;
};

union UnionOwnDestructor {
    int value;
    ~UnionOwnDestructor();
};

template <typename T>
struct TemplateOwnDestructor {
    T value;
    ~TemplateOwnDestructor();
};

template <typename T>
struct TemplateField {
    T value;
};

struct DestructorTemplateHolder {
    TemplateOwnDestructor<int> own;
    TemplateField<OwnDestructor> propagated;
    TemplateField<TrivialValue> trivial;
};

struct IntegerOnly {
    int value;
};

struct DirectFloat {
    float value;
};

struct FloatArray {
    double values[3];
};

struct ContainsFloat {
    DirectFloat value;
};

struct InheritsFloat : DirectFloat {
    int marker;
};

using FloatAlias = float;

struct AliasedFloat {
    FloatAlias value;
};

struct FloatPointerOnly {
    float* value;
};

template <typename T>
struct TemplateArgumentFloat {
    T value;
};

template <typename T>
struct TemplateDefinitionFloat {
    T value;
    float fixed;
};

struct FloatAnalysisHolder {
    IntegerOnly integerOnly;
    DirectFloat direct;
    FloatArray array;
    ContainsFloat contained;
    InheritsFloat inherited;
    AliasedFloat aliased;
    FloatPointerOnly pointerOnly;
    TemplateArgumentFloat<float> argumentFloat;
    TemplateArgumentFloat<int> argumentInteger;
    TemplateDefinitionFloat<int> definitionFloat;
};
