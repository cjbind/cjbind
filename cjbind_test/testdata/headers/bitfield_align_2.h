// cjbind-options: --clang-arg --target=x86_64-unknown-linux-gnu
enum MyEnum {
    ONE,
    TWO,
    THREE,
    FOUR
};

struct TaggedPtr {
    enum MyEnum tag : 2;
    long   ptr : 62;
};
