// cjbind-options: --respect-cxx-access-specs -- -x c++ -std=c++14

enum class Color : unsigned short {
    Red = 1,
    Blue = 2,
};

class Access {
public:
    static const int Answer = 42;
    int open;
protected:
    short guarded;
private:
    char16_t code;
    static const int Secret = 7;
    struct Hidden {
        int value;
    };
public:
    struct Visible {
        int value;
    };
};

struct __attribute__((packed)) Packed {
    char first;
    int second;
};
