package cjbind_ffi

@C
public struct foo__cjbind_ty_1 {
    public var a: UInt32
    public var b: UInt32
    public init(a: UInt32, b: UInt32) {
        this.a = a
        this.b = b
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo__cjbind_ty_1>()
        if (size != 8) {
            throw Exception("Size of foo__cjbind_ty_1 is not 8 but ${size} bytes")
        }
        let align = alignOf<foo__cjbind_ty_1>()
        if (align != 4) {
            throw Exception("Alignment of foo__cjbind_ty_1 is not 4 but ${align} bytes")
        }
}

@C
public struct foo {
    var _storage: VArray<UInt32, $2> = unsafe { zeroValue<VArray<UInt32, $2>>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo>()
        if (size != 8) {
            throw Exception("Size of foo is not 8 but ${size} bytes")
        }
        let align = alignOf<foo>()
        if (align != 4) {
            throw Exception("Alignment of foo is not 4 but ${align} bytes")
        }
}
