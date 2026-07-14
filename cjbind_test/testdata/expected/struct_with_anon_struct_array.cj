package cjbind_ffi

@C
public struct foo__cjbind_ty_1__cjbind_ty_1 {
    public let a: Int32
    public let b: Int32
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
    public init(a: Int32, b: Int32) {
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
public struct foo__cjbind_ty_2__cjbind_ty_2 {
    public let a: Int32
    public let b: Int32
    public func clone(): foo__cjbind_ty_2__cjbind_ty_2 {
        return this
    }
    public func toString(): String {
        var output = "foo__cjbind_ty_2__cjbind_ty_2 {"
        output += " a: "
        output += this.a.toString()
        output += ", b: "
        output += this.b.toString()
        output += " }"
        return output
    }
    public init(a: Int32, b: Int32) {
        this.a = a
        this.b = b
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo__cjbind_ty_2__cjbind_ty_2>()
        if (size != 8) {
            throw Exception("Size of foo__cjbind_ty_2__cjbind_ty_2 is not 8 but ${size} bytes")
        }
        let align = alignOf<foo__cjbind_ty_2__cjbind_ty_2>()
        if (align != 4) {
            throw Exception("Alignment of foo__cjbind_ty_2__cjbind_ty_2 is not 4 but ${align} bytes")
        }
}

@C
public struct foo_foo {
    public let bar: VArray<foo__cjbind_ty_1__cjbind_ty_1, $2>
    public let baz: VArray<VArray<VArray<foo__cjbind_ty_2__cjbind_ty_2, $4>, $3>, $2>
    public func clone(): foo_foo {
        return this
    }
    public func toString(): String {
        var output = "foo_foo {"
        output += " bar: "
        output += "["
        for (__cjbindDebugIndex0 in 0..2) {
            if (__cjbindDebugIndex0 != 0) {
                output += ", "
            }
            output += this.bar[__cjbindDebugIndex0].toString()
        }
        output += "]"
        output += ", baz: "
        output += "["
        for (__cjbindDebugIndex0 in 0..2) {
            if (__cjbindDebugIndex0 != 0) {
                output += ", "
            }
            output += "["
            for (__cjbindDebugIndex1 in 0..3) {
                if (__cjbindDebugIndex1 != 0) {
                    output += ", "
                }
                output += "["
                for (__cjbindDebugIndex2 in 0..4) {
                    if (__cjbindDebugIndex2 != 0) {
                        output += ", "
                    }
                    output += this.baz[__cjbindDebugIndex0][__cjbindDebugIndex1][__cjbindDebugIndex2].toString()
                }
                output += "]"
            }
            output += "]"
        }
        output += "]"
        output += " }"
        return output
    }
    public init(bar: VArray<foo__cjbind_ty_1__cjbind_ty_1, $2>,
        baz: VArray<VArray<VArray<foo__cjbind_ty_2__cjbind_ty_2, $4>, $3>, $2>) {
        this.bar = bar
        this.baz = baz
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo_foo>()
        if (size != 208) {
            throw Exception("Size of foo_foo is not 208 but ${size} bytes")
        }
        let align = alignOf<foo_foo>()
        if (align != 4) {
            throw Exception("Alignment of foo_foo is not 4 but ${align} bytes")
        }
}
