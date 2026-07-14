// cjbind-options: --enable-cxx-namespaces --allowlist-type ^std::string$ -- -x c++ -std=c++14

namespace std {
inline namespace implementation {
using string = const char*;
}
}
