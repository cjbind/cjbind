package cjbind_ffi

@C
public struct max_align_t_max_align_t {
    let _cjbind_opaque_blob: VArray<UInt8, $32>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $32>>() }
    }
}
