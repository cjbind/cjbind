package cjbind_ffi

public const POINTER_WIDTH_POINTER_WIDTH: UInt64 = 64

@C
public struct Foo_Foo {
    let _cjbind_opaque_blob: VArray<UInt64, $4>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt64, $4>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Foo_Foo>()
        if (size != 32) {
            throw Exception("Size of Foo_Foo is not 32 but ${size} bytes")
        }
        let align = alignOf<Foo_Foo>()
        if (align != 8) {
            throw Exception("Alignment of Foo_Foo is not 8 but ${align} bytes")
        }
}
