// cjbind-options: --generate types,methods -- -x c++ -std=c++14

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
