// cjbind-options: --represent-cxx-operators -- -x c++ -std=c++14

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
