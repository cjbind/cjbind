package cjbind_ffi

@C
public struct foo__cjbind_ty_1 {
    public let x: UInt32
    public let y: UInt32
    public init(x: UInt32, y: UInt32) {
        this.x = x
        this.y = y
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
public struct foo_foo {
    public let bar: foo__cjbind_ty_1
    public let __cjbind_anon_1: foo__cjbind_ty_1
    public init(bar: foo__cjbind_ty_1, __cjbind_anon_1: foo__cjbind_ty_1) {
        this.bar = bar
        this.__cjbind_anon_1 = __cjbind_anon_1
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo_foo>()
        if (size != 8) {
            throw Exception("Size of foo_foo is not 8 but ${size} bytes")
        }
        let align = alignOf<foo_foo>()
        if (align != 4) {
            throw Exception("Alignment of foo_foo is not 4 but ${align} bytes")
        }
}