// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

class Outer {
public:
    int value;

    class Inner {
    public:
        int value;
        int get() const;
    };

    class Deferred;

    template<typename T>
    struct Box {
        T value;
    };
};

class Outer::Deferred {
public:
    long long payload;
};

struct NestedHolder {
    Outer::Inner inner;
    Outer::Deferred* deferred;
    Outer::Box<int> boxed;
};

Outer::Inner pass_inner(Outer::Inner value);
