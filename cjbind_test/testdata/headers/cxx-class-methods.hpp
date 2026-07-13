// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --respect-cxx-access-specs

class Widget {
public:
    Widget();
    explicit Widget(int initial);
    ~Widget();

    int get() const noexcept;
    void set(int next);
    static int twice(int input);

private:
    int value;
    void hidden();
};

int overloaded(int input);
double overloaded(double input);

namespace C {
struct E {
    E();
};
}

namespace D {
struct E {
    ~E();
};
}

struct ManglingArgument {
    ManglingArgument(C::E value);
};
