package cjbind_ffi

public type DoesNotUse_Aliased<T> = T

public type DoesNotUse_Typedefed<U> = U

@C
public struct DoesNotUse {
    let _cjbind_empty: UInt8
    private init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}
