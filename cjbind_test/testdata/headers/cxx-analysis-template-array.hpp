// cjbind-options: -- -x c++ -std=c++14

template <typename T, int N>
struct ArrayOfParameter {
    T values[N];
};

template <typename T, int N>
struct AliasArrayOfParameter {
    using Element = T;
    Element values[N];
};

template <typename T>
struct ContainsParameterArray {
    ArrayOfParameter<T, 3> nested;
};

template <typename T>
struct InheritsParameterArray : ArrayOfParameter<T, 2> {
    int marker;
};

template <typename T>
struct DeepParameterArray {
    ContainsParameterArray<T> nested;
};

template <typename T>
struct FirstParameterArrayOwner {
    ArrayOfParameter<T, 3> nested;
};

template <typename T>
struct SecondParameterArrayOwner {
    ArrayOfParameter<T, 3> nested;
};

template <typename T, int N>
struct ParameterArrayWrapper {
    ArrayOfParameter<T, N> nested;
};

template <typename T, int N>
struct FixedIntegerArray {
    int values[N];
};

template <typename T>
struct PointerToParameter {
    T* values;
};

template <typename T>
struct ScalarParameter {
    T value;
};

struct TemplateArrayAnalysisHolder {
    ArrayOfParameter<int, 4> direct;
    AliasArrayOfParameter<double, 2> alias;
    ContainsParameterArray<short> contained;
    InheritsParameterArray<unsigned char> inherited;
    DeepParameterArray<long long> deep;
    FirstParameterArrayOwner<int> firstOwner;
    SecondParameterArrayOwner<short> secondOwner;
    ParameterArrayWrapper<unsigned int, 6> parameterized;
    FixedIntegerArray<float, 5> fixedInteger;
    PointerToParameter<double> pointerOnly;
    ScalarParameter<float> scalarOnly;
};
