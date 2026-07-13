package cjbind_ffi

@C
public struct JNINativeInterface__JNINativeInterface_ {
    let _cjbind_opaque_blob: VArray<UInt64, $2>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt64, $2>>() }
    }
}
