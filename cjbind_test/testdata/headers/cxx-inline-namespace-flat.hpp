// cjbind-options: -- -x c++ -std=c++14

namespace api {
inline namespace v1 {
struct Item {
    int value;
};

int ping(Item input);
}
}
