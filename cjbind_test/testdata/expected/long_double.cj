package cjbind_ffi

@C
public struct foo_foo {
    let _cjbind_opaque_blob: VArray<UInt8, $16>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $16>>() }
    }
}
