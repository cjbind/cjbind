package cjbind_ffi

@C
public struct foo_foo {
    let _cjbind_opaque_blob: VArray<UInt8, $16>
    public func clone(): foo_foo {
        return this
    }
    public func toString(): String {
        var output = "foo_foo {"
        output += " <opaque>"
        output += " }"
        return output
    }
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $16>>() }
    }
}
