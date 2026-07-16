package cjbind_ffi

public type detail_PointerType_Type<T> = CPointer<T>

@C
public struct detail_PointerType {
    let _cjbind_empty: UInt8
    private init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@C
public struct UniquePtr {
    let _cjbind_empty: UInt8
    private init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}
