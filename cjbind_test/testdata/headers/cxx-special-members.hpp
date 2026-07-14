// cjbind-options: --respect-cxx-access-specs -- -x c++ -std=c++14

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
