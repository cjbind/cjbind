// cjbind-options: --opaque-type OpaqueTemplate

template<typename T>
class OpaqueTemplate {
    T mData;
};

class ContainsOpaqueTemplate {
    OpaqueTemplate<int> mBlah;
    int mBaz;
};

class InheritsOpaqueTemplate : public OpaqueTemplate<bool> {
    char* wow;
};
