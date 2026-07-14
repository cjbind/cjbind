// cjbind-options: --vtable-generation --generate-pure-virtual-functions --use-specific-virtual-function-receiver -- -x c++ -std=c++14

struct Base {
    int base;
    virtual int run(int input) = 0;
    virtual ~Base();
};

struct Extra {
    long long extra;
};

struct Derived : Base, Extra {
    int value;
    int run(int input) override;
};

struct Interface {
    virtual int apply(int input) = 0;
};

struct TailBase {
    virtual int tag();
    int payload;
    char marker;
};

struct TailDerived : TailBase {
    char tail;
    int tag() override;
};

struct Plain {
    int plain;
};

struct Poly {
    virtual int act();
    int poly;
};

struct Reordered : Plain, Poly {};

struct VirtualBase {
    int value;
};

struct VirtualDerived : virtual VirtualBase {
    int own;
};
