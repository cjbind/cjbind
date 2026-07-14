package cjbind_ffi

@C
public struct max_align_t_max_align_t {
    let _cjbind_opaque_blob: VArray<UInt8, $32>
    public func clone(): max_align_t_max_align_t {
        return this
    }
    public func toString(): String {
        var output = "max_align_t_max_align_t {"
        output += " <opaque>"
        output += " }"
        return output
    }
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $32>>() }
    }
}
