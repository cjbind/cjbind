// cjbind-options: --generate types -- -x c++ -std=c++14

struct SelectedType {
    static const int Constant = 7;
    SelectedType();
    ~SelectedType();
    int method() const;
    int value;
};

int omitted_function();
