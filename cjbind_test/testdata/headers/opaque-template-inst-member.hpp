// cjbind-options: --opaque-type OpaqueTemplate

template<typename T>
class OpaqueTemplate {
    T mData;
    bool mCannotDebug[400];
};

class ContainsOpaqueTemplate {
    OpaqueTemplate<int> mBlah;
    int mBaz;
};

class InheritsOpaqueTemplate : public OpaqueTemplate<bool> {
    char* wow;
};
