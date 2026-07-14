// cjbind-options: --with-derive-default --with-derive-hash --with-derive-eq --with-derive-ord --impl-debug --impl-partialeq --disable-untagged-union --opaque-type ^OpaqueWord$ --blocklist-type ^Blocked$ --blocklisted-traits-manually --no-hash ^NoHash$ --no-partialeq ^NoPartialEq$

struct OrderPair {
    int first;
    int second;
};

struct FloatRecord {
    float value;
};

struct LargeArray {
    int values[40];
};

struct PointerDefault {
    int* value;
};

struct VtableDefault {
    virtual void call();
};

struct OpaqueWord {
    unsigned long long bits;
};

union ScalarUnion {
    unsigned long long bits;
    double number;
};

struct Blocked {
    int hidden;
};

struct ManualDebug {
    Blocked blocked;
    int visible;
};

struct NoHash {
    int value;
};

struct NoPartialEq {
    int value;
};

struct NameConflicts {
    unsigned clone : 1;
    unsigned toString : 1;
    unsigned hashCode : 1;
    unsigned compare : 1;
    unsigned __cjbindPartialCompare : 1;
};

struct ContainsNameConflicts {
    NameConflicts value;
};
