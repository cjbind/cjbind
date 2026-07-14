template <typename T>
class BaseUsesT {
    T* t;
};

template <typename U>
class CrtpUsesU : public BaseUsesT<CrtpUsesU<U>> {
    U usage;
};
