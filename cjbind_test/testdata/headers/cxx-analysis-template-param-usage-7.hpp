// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

template <typename T, typename U, typename V>
class DoesNotUseU {
    T t;
    V v;
};

using Alias = DoesNotUseU<int, bool, char>;

struct TemplateParamUsage7Holder {
    Alias value;
};
