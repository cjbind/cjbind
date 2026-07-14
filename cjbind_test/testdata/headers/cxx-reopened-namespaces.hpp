// cjbind-options: --enable-cxx-namespaces -- -x c++ -std=c++17

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
