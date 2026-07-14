// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

template <typename T>
class BaseIgnoresT {
    int x;
};

template <typename U>
class CrtpIgnoresU : public BaseIgnoresT<CrtpIgnoresU<U>> {
    int y;
};

struct TemplateParamUsage14Holder {
    CrtpIgnoresU<float> value;
};
