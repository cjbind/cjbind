// cjbind-options: --blocklist-type ^ExternalPtr$ -- -x c++ -std=c++14

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

struct BlocklistedPointerHolder {
    ExternalPtr<int>* value;
};
