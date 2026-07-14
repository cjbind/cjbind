// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

template <typename T>
class UsesTemplateParameter {
    T t;
};

struct TemplateParamUsage0Holder {
    UsesTemplateParameter<int> value;
};
