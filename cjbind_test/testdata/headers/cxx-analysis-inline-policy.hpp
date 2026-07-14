// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --enable-cxx-namespaces --allowlist-type ^std::string$

namespace std {
inline namespace implementation {
using string = const char*;
}
}
