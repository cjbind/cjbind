// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --blocklist-type ^ExternalPtr$

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
