// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --enable-cxx-namespaces

namespace api {
inline namespace v1 {
struct Item {
    int value;
};

int ping(Item input);
}
}
