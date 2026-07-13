// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++17 --enable-cxx-namespaces

namespace alpha {
class Forward;
}

namespace beta {
struct Holder {
    alpha::Forward* pointer;
};
}

namespace alpha {
class Forward {
public:
    int value;
};

namespace nested {
int evaluate(Forward* value);
}
}

namespace alpha {
namespace nested {
double evaluate(double value);
}
}
