// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

template <typename T>
class UsesTemplateParameter {
    T t;

    class AlsoUsesTemplateParameter {
        T also;
    };
};

struct TemplateParamUsage2Holder {
    UsesTemplateParameter<short> value;
};
