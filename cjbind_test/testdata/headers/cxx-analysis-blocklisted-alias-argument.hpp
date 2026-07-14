// cjbind-options: --blocklist-type ^ExternalPtr$ -- -x c++ -std=c++14

template <typename>
struct ExternalPtr {};

template <typename T>
struct HasExternalPtr {
    using Alias = T;
    ExternalPtr<Alias> value;
};

using ConcreteExternalAlias = HasExternalPtr<int>;

struct BlocklistedAliasArgumentHolder {
    ConcreteExternalAlias value;
};
