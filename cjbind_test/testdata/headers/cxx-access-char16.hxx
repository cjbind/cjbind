// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --respect-cxx-access-specs --use-distinct-char16-t

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
