// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --blocklist-type ^ExternalPtr$

template <typename>
struct ExternalPtr {};

template <typename T>
struct NestedHolder {
    T value;
};

template <typename U>
struct ExternalHandle {
    ExternalPtr<NestedHolder<U>> value;
};

struct BlocklistedNestedArgumentHolder {
    ExternalHandle<int> value;
};
