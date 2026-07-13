// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --generate types,methods

class Selection {
public:
    Selection(int value);
    ~Selection();
    int get() const;
    static int scale(int value);

private:
    int stored;
};

int free_function(int value);
