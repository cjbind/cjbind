// cjbind-options: -- -x c++ -std=c++14

template<typename T, unsigned Capacity>
struct FixedArray {
    T values[Capacity];
};

template<typename T>
using Fixed16 = FixedArray<T, 16>;

using FixedInts = FixedArray<int, 4>;

template<typename T, typename U = int>
struct PairWithDefault {
    T first;
    U second;
};

struct AliasHolder {
    Fixed16<char> chars;
    FixedArray<bool, 8> flags;
    FixedInts integers;
    PairWithDefault<bool> defaulted;
};
