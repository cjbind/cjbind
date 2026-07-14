// cjbind-options: --enable-cxx-namespaces --conservative-inline-namespaces -- -x c++ -std=c++14

namespace api {
inline namespace v1 {
using Word = int;
}
using Word = long long;
}

struct UsesInlineAlias {
    api::v1::Word value;
};
