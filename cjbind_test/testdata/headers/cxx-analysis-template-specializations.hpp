// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

template <typename T>
struct ExplicitBox {
    T value;
};

template <>
struct ExplicitBox<char> {
    long value;
    char discriminator;
};

template <typename T>
struct PartialBox {
    T value;
};

template <typename T>
struct PartialBox<T*> {
    T* pointer;
    unsigned count;
};

template <typename T>
struct SpecializationBase {
    T base;
};

template <typename T>
struct PartialDerived {
    bool primary;
};

template <typename T>
struct PartialDerived<T*> : SpecializationBase<T*> {
    int first;
    int second;
};

struct TemplateSpecializationHolder {
    ExplicitBox<int> primary;
    ExplicitBox<char> explicitSpecialization;
    PartialBox<int*> partialSpecialization;
    PartialDerived<int*> inheritedPartialSpecialization;
};
