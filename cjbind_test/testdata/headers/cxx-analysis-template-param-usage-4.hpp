// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

template <typename T>
class UsesTemplateParameter {
    T t;

    template <typename U>
    class DoesNotUseTemplateParameters {
        int x;
    };
};

struct TemplateParamUsage4Holder {
    UsesTemplateParameter<unsigned short> value;
};
