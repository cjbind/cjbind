// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --blocklist-type ^ExternalPtr$ --allowlist-function ^entry$

template <typename>
class ExternalPtr;

class Cycle;

class Api {
    using Alias = Cycle;
};

template <typename T>
class UsesExternal {
    ExternalPtr<T> value;
};

template <typename>
class Ignores {};

class Base {
    Ignores<UsesExternal<int>> value;
};

class Cycle : Base {};

Api entry();
