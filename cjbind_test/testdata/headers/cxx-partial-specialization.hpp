// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14

template<typename T>
struct Storage {
    T value;
};

template<typename T>
struct Storage<T*> {
    T* first;
    T* second;
};

struct PartialHolder {
    Storage<int> scalar;
    Storage<int*> pointers;
};
