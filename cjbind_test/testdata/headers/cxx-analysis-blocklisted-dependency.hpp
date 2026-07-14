// cjbind-options: --allowlist-type ^PublicRecord$ --blocklist-type ^InternalRecord$ -- -x c++ -std=c++14

struct InternalRecord {
    int value;
};

using InternalAlias = InternalRecord;

struct PublicRecord {
    InternalRecord* internal;
    InternalAlias* aliased;
};
