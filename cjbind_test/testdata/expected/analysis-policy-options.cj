package cjbind_ffi

// cjbind-options: --blocklist-type ^NeverType$ --blocklist-function ^neverFunction$ --blocklist-item ^NeverItem$ --blocklist-var ^NEVER_VAR$ --blocklist-file ^never/file$ --opaque-type ^NeverOpaque$ --allowlist-type PolicyOptionFixture --allowlist-function ^neverAllowedFunction$ --allowlist-item ^neverAllowedItem$ --allowlist-var ^NEVER_ALLOWED_VAR$ --allowlist-file ^never/allowed/file$ --no-recursive-allowlist --no-record-matches --disable-untagged-union --no-size_t-is-usize
@C
public struct PolicyOptionFixture {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PolicyOptionFixture>()
        if (size != 4) {
            throw Exception("Size of PolicyOptionFixture is not 4 but ${size} bytes")
        }
        let align = alignOf<PolicyOptionFixture>()
        if (align != 4) {
            throw Exception("Alignment of PolicyOptionFixture is not 4 but ${align} bytes")
        }
}()
