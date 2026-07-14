// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

template <typename T, typename U>
class DoesNotUse {
    using Aliased = T;
    typedef U Typedefed;

    class IndirectUsage {
        Aliased member;
        Typedefed another;
    };
};

struct TemplateParamUsage9Holder {
    DoesNotUse<long, float> value;
    DoesNotUse<char, short> other;
};
