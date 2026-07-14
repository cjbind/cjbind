package cjbind_ffi

@C
public struct foo__cjbind_ty_1__cjbind_ty_1 {
    public let a: UInt32
    public let b: UInt32
    public func clone(): foo__cjbind_ty_1__cjbind_ty_1 {
        return this
    }
    public func toString(): String {
        var output = "foo__cjbind_ty_1__cjbind_ty_1 {"
        output += " a: "
        output += this.a.toString()
        output += ", b: "
        output += this.b.toString()
        output += " }"
        return output
    }
    public init(a: UInt32, b: UInt32) {
        this.a = a
        this.b = b
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo__cjbind_ty_1__cjbind_ty_1>()
        if (size != 8) {
            throw Exception("Size of foo__cjbind_ty_1__cjbind_ty_1 is not 8 but ${size} bytes")
        }
        let align = alignOf<foo__cjbind_ty_1__cjbind_ty_1>()
        if (align != 4) {
            throw Exception("Alignment of foo__cjbind_ty_1__cjbind_ty_1 is not 4 but ${align} bytes")
        }
}

@C
public struct foo_foo {
    public let __cjbind_anon_1: foo__cjbind_ty_1__cjbind_ty_1
    public func clone(): foo_foo {
        return this
    }
    public func toString(): String {
        var output = "foo_foo {"
        output += " __cjbind_anon_1: "
        output += this.__cjbind_anon_1.toString()
        output += " }"
        return output
    }
    public init(__cjbind_anon_1: foo__cjbind_ty_1__cjbind_ty_1) {
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
