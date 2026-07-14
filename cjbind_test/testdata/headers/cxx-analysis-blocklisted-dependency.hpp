// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --allowlist-type ^PublicRecord$ --blocklist-type ^InternalRecord$

struct InternalRecord {
    int value;
};

struct PublicRecord {
    InternalRecord* internal;
};
