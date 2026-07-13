// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --respect-cxx-access-specs

class OverloadedCtor {
    OverloadedCtor();

public:
    explicit OverloadedCtor(int value);
    explicit OverloadedCtor(double value);
    ~OverloadedCtor();
    int value() const;

private:
    int stored;
};

namespace lifetime {
struct OutOfLine {
    int marker;
    OutOfLine();
    ~OutOfLine();
};
}
