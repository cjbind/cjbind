package cjbind_ffi

@C
public struct foo__cjbind_ty_1 {
    public var a: Int32
    public var b: Int32
    public init(a: Int32, b: Int32) {
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
public struct foo__cjbind_ty_2 {
    public var a: Int32
    public var b: Int32
    public init(a: Int32, b: Int32) {
        this.a = a
        this.b = b
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo__cjbind_ty_2>()
        if (size != 8) {
            throw Exception("Size of foo__cjbind_ty_2 is not 8 but ${size} bytes")
        }
        let align = alignOf<foo__cjbind_ty_2>()
        if (align != 4) {
            throw Exception("Alignment of foo__cjbind_ty_2 is not 4 but ${align} bytes")
        }
}

@C
public struct foo {
    public let bar: VArray<foo__cjbind_ty_1, $2>
    public let baz: VArray<VArray<VArray<foo__cjbind_ty_2, $4>, $3>, $2>
    public init(bar: VArray<foo__cjbind_ty_1, $2>, baz: VArray<VArray<VArray<foo__cjbind_ty_2, $4>, $3>, $2>) {
        this.bar = bar
        this.baz = baz
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo>()
        if (size != 208) {
            throw Exception("Size of foo is not 208 but ${size} bytes")
        }
        let align = alignOf<foo>()
        if (align != 4) {
            throw Exception("Alignment of foo is not 4 but ${align} bytes")
        }
}
