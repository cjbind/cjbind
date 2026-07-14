// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --enable-cxx-namespaces --blocklist-function ^api::Outer_f1$ --no-debug ^api::Outer_Inner$

namespace api {
struct Outer {
    struct Inner {
        int value;
    };

    int f();
    int f(int value);
};
}
