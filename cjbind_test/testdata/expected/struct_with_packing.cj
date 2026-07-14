package cjbind_ffi

@C
public struct a_a {
    let _cjbind_opaque_blob: VArray<UInt8, $3>
    public func clone(): a_a {
        return this
    }
    public func toString(): String {
        var output = "a_a {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $3>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<a_a>()
        if (size != 3) {
            throw Exception("Size of a_a is not 3 but ${size} bytes")
        }
        let align = alignOf<a_a>()
        if (align != 1) {
            throw Exception("Alignment of a_a is not 1 but ${align} bytes")
        }
}
