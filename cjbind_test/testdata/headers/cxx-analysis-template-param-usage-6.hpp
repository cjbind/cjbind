// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

template <typename T>
class DoesNotUseTemplateParameter {
    using ButAliasDoesUseIt = T;

    int x;
};

template <typename T, typename U, typename V>
using EndpointCallback = T (*)(V);

struct TemplateParamUsage6Holder {
    DoesNotUseTemplateParameter<float> value;
};
