// cjbind-options: --with-derive-default --with-derive-hash --with-derive-eq --with-derive-ord

using DeriveCallback = int (*)(int value);

struct FunctionPointerDerives {
    DeriveCallback callback;
};
