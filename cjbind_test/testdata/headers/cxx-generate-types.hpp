// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --generate types

struct SelectedType {
    static const int Constant = 7;
    SelectedType();
    ~SelectedType();
    int method() const;
    int value;
};

int omitted_function();
