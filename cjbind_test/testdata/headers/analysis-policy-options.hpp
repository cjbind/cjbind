// cjbind-options: --blocklist-type ^NeverType$ --blocklist-function ^neverFunction$ --blocklist-item ^NeverItem$ --blocklist-var ^NEVER_VAR$ --blocklist-file ^never/file$ --opaque-type ^NeverOpaque$ --allowlist-type PolicyOptionFixture --allowlist-function ^neverAllowedFunction$ --allowlist-item ^neverAllowedItem$ --allowlist-var ^NEVER_ALLOWED_VAR$ --allowlist-file ^never/allowed/file$ --no-recursive-allowlist --no-record-matches --disable-untagged-union --no-size_t-is-usize --no-derive-copy --no-derive-debug --with-derive-default --with-derive-hash --with-derive-eq --with-derive-partialord --no-copy ^NeverCopy$ --no-debug ^NeverDebug$ --no-default ^NeverDefault$ --no-hash ^NeverHash$ --no-partialeq ^NeverPartialEq$

struct PolicyOptionFixture {
    int value;
};
