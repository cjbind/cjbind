// cjbind-options: --with-derive-default --with-derive-eq --impl-debug --impl-partialeq --blocklist-type ^ManualExternal$ --blocklisted-traits-manually

struct ManualExternal {
    int toString;
};

struct ManualExternalHolder {
    ManualExternal external;
    int visible;
};
