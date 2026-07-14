// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

template <typename T>
class DoesNotUseTemplateParameter {
    int x;
};

struct TemplateParamUsage1Holder {
    DoesNotUseTemplateParameter<double> value;
};
