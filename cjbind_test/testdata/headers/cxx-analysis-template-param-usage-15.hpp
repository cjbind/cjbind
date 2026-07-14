// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

template <typename T>
class BaseUsesT {
    T* usage;
};

template <typename U>
class CrtpIgnoresU : public BaseUsesT<CrtpIgnoresU<U>> {
    int y;
};

struct TemplateParamUsage15Holder {
    CrtpIgnoresU<double> value;
};
