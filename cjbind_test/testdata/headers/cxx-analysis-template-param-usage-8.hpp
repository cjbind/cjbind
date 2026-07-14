// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

template <typename T, typename U>
class IndirectUsage {
    typedef T Typedefed;
    using Aliased = U;

    Typedefed member1;
    Aliased member2;
};

struct TemplateParamUsage8Holder {
    IndirectUsage<unsigned int, double> value;
};
