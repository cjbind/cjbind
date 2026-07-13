package cjbind_ffi

@C
public struct Bar_Bar {
    let _cjbind_opaque_blob: VArray<UInt8, $16>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $16>>() }
    }
}

@C
public struct Baz_Baz {
    let _cjbind_opaque_blob: VArray<UInt8, $16>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $16>>() }
    }
}
