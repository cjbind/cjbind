// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --represent-cxx-operators

struct Number {
    Number();
    Number(const Number& other);
    Number(Number&& other);
    Number& operator=(const Number& other);
    Number operator+(const Number& other) const;
    int& value();
    const int& value() const;
    void removed() = delete;
};
