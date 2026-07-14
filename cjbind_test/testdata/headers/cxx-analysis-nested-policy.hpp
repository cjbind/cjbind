// cjbind-options: --enable-cxx-namespaces --blocklist-function ^api::Outer_f1$ -- -x c++ -std=c++14

namespace api {
struct Outer {
    struct Inner {
        int value;
    };

    int f();
    int f(int value);
};
}
