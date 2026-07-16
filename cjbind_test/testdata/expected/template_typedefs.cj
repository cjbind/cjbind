package cjbind_ffi

public type foo = CFunc<(arg1: Int32) -> Unit>

public type Foo_Char<T> = T

public type Foo_FooPtrTypedef<T> = CPointer<Foo_Char<T>>

public type Foo_nsCOMArrayEnumFunc<T> = CFunc<(aElement: CPointer<T>, aData: CPointer<Unit>) -> Bool>

@C
public struct Foo {
    let _cjbind_empty: UInt8
    private init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}
