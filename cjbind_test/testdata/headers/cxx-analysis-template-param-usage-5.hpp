// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

template <typename T>
class IndirectlyUsesTemplateParameter {
    using Aliased = T;

    Aliased aliased;
};

struct TemplateParamUsage5Holder {
    IndirectlyUsesTemplateParameter<long long> value;
};
