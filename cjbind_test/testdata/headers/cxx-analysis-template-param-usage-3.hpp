// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

template <typename T>
class UsesTemplateParameter {
    T t;

public:
    template <typename U>
    class AlsoUsesTemplateParameterAndMore {
        T also;
        U more;
    };
};

struct TemplateParamUsage3Holder {
    UsesTemplateParameter<unsigned char> value;
    UsesTemplateParameter<unsigned char>::AlsoUsesTemplateParameterAndMore<short> nested;
};
