// cjbind-options: --enable-cxx-namespaces --conservative-inline-namespaces -- -x c++ -std=c++14

namespace api {
inline namespace v1 {
struct Item {
    int value;
};

int ping(Item input);
}
}
