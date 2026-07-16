// cjbind-options: --allowlist-type ^SupportHolder$ --no-recursive-allowlist

struct SupportHolder {
    double _Complex value;
    void (*callback)(int, ...);
};
