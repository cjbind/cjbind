// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

template<typename T>
struct RecoveredBase {
    T baseValue;
};

template<typename T>
struct RecoveredDerived : RecoveredBase<T> {
    short derivedValue;
};

struct TemplateBaseRecoveryHolder {
    RecoveredDerived<int> value;
};
