// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --enable-cxx-namespaces --conservative-inline-namespaces

namespace api {
inline namespace v1 {
using Word = int;
}
using Word = long long;
}

struct UsesInlineAlias {
    api::v1::Word value;
};
