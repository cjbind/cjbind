// cjbind-options: --with-derive-default --with-derive-hash --with-derive-eq --with-derive-ord --blocklist-type ^ExternalCapabilities$ --blocklisted-traits-yes

struct ExternalCapabilities {
    int toString;
    int hashCode;
    int __cjbindPartialCompare;
};

struct ExternalCapabilitiesHolder {
    ExternalCapabilities external;
    int visible;
};
