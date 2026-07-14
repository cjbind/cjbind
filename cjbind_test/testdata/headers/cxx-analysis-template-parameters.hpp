// cjbind-options: -- -x c++ -std=c++14

template <typename T>
struct DirectUse {
    T value;
};

template <typename T>
struct UnusedParameter {
    int value;
};

template <typename T>
struct NestedUse {
    struct Inner {
        T value;
    };

    Inner inner;
};

template <typename T>
struct NestedTemplateUse {
    template <typename U>
    struct Inner {
        T outer;
        U inner;
    };

    Inner<long> value;
};

template <typename T>
struct NestedTemplateIgnore {
    template <typename U>
    struct Inner {
        int value;
    };

    Inner<long> value;
};

template <typename T>
struct AliasUse {
    using Alias = T;
    Alias value;
};

template <typename T>
struct AliasOnly {
    using Alias = T;
    int value;
};

template <typename T, typename U, typename V>
struct SkipMiddleParameter {
    T first;
    V third;
};

template <typename T, typename U>
struct TypedefAndAliasUse {
    typedef T First;
    using Second = U;

    First first;
    Second second;
};

template <typename T, typename U>
struct NestedAliasOnly {
    using First = T;
    typedef U Second;

    struct Inner {
        First first;
        Second second;
    };
};

template <typename T, typename U, typename NeverUsed>
struct DoublyIndirectUse {
    using First = T;
    typedef U Second;

    struct Inner {
        First first;
        Second second;
    };

    Inner value;
};

template <typename T>
struct StaticOnlyUse {
    static T staticValue;
    int value;
};

template <typename T>
struct BaseUsesParameter {
    T* value;
};

template <typename T>
struct BaseIgnoresParameter {
    int value;
};

template <typename U>
struct CrtpDirectUse : BaseUsesParameter<CrtpDirectUse<U>> {
    U value;
};

template <typename U>
struct CrtpUseWithIgnoringBase : BaseIgnoresParameter<CrtpUseWithIgnoringBase<U>> {
    U value;
};

template <typename U>
struct CrtpIgnoreWithIgnoringBase : BaseIgnoresParameter<CrtpIgnoreWithIgnoringBase<U>> {
    int value;
};

template <typename U>
struct CrtpIndirectUse : BaseUsesParameter<CrtpIndirectUse<U>> {
    int value;
};

template <typename T>
struct DependentLeaf {
    T value;
};

template <typename T>
struct DependentMiddle {
    DependentLeaf<T> value;
};

template <typename T>
struct DependentOuter {
    DependentMiddle<T> value;
};

struct TemplateParameterAnalysisHolder {
    DirectUse<int> direct;
    UnusedParameter<double> unused;
    NestedUse<short> nested;
    NestedTemplateUse<unsigned char> nestedTemplate;
    NestedTemplateIgnore<unsigned short> nestedTemplateIgnore;
    AliasUse<long long> aliasUse;
    AliasOnly<float> aliasOnly;
    SkipMiddleParameter<int, bool, char> skipMiddle;
    TypedefAndAliasUse<unsigned int, double> aliases;
    NestedAliasOnly<long, float> nestedAliasOnly;
    DoublyIndirectUse<long, float, bool> doublyIndirect;
    StaticOnlyUse<double> staticOnly;
    CrtpDirectUse<short> crtpDirect;
    CrtpUseWithIgnoringBase<unsigned short> crtpIgnoringBase;
    CrtpIgnoreWithIgnoringBase<float> crtpIgnore;
    CrtpIndirectUse<double> crtpIndirect;
    DependentOuter<unsigned long long> dependent;
};
