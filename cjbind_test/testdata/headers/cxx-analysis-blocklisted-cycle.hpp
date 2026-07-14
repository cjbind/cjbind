// cjbind-options: --blocklist-type ^ExternalPtr$ --allowlist-function ^entry$ -- -x c++ -std=c++14

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
