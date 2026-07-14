// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

template <typename T>
class BaseIgnoresT {
    int x;
};

template <typename U>
class CrtpUsesU : public BaseIgnoresT<CrtpUsesU<U>> {
    U usage;
};

struct TemplateParamUsage13Holder {
    CrtpUsesU<unsigned short> value;
};
