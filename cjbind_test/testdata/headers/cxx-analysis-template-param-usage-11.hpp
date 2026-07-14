// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

template <typename T>
class DoesNotUseT {
    static T but_static_member_does;
};

struct TemplateParamUsage11Holder {
    DoesNotUseT<double> value;
};
