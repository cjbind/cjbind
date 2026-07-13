// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --vtable-generation

template<typename T>
class BaseWithVtable {
public:
    T item;
    virtual T get() const;
};

class DerivedWithoutNewVirtual : public BaseWithVtable<char*> {};

class DerivedWithVirtual : public BaseWithVtable<char*> {
public:
    virtual int extra();
};

template<typename T>
struct PlainBase {
    T value;
};

struct PlainDerived : public PlainBase<int> {
    short tag;
};
