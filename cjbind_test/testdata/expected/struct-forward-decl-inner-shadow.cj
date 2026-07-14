package cjbind_ffi

@C
public struct foo {
    public let foo: Int32
    public init(foo: Int32) {
        this.foo = foo
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo>()
        if (size != 4) {
            throw Exception("Size of foo is not 4 but ${size} bytes")
        }
        let align = alignOf<foo>()
        if (align != 4) {
            throw Exception("Alignment of foo is not 4 but ${align} bytes")
        }
}

@C
public struct bar {
    public let u: foo
    public init(u: foo) {
        this.u = u
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<bar>()
        if (size != 4) {
            throw Exception("Size of bar is not 4 but ${size} bytes")
        }
        let align = alignOf<bar>()
        if (align != 4) {
            throw Exception("Alignment of bar is not 4 but ${align} bytes")
        }
}

public type bar_t = bar

@C
public struct baz {
    public let f: foo
    public init(f: foo) {
        this.f = f
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<baz>()
        if (size != 4) {
            throw Exception("Size of baz is not 4 but ${size} bytes")
        }
        let align = alignOf<baz>()
        if (align != 4) {
            throw Exception("Alignment of baz is not 4 but ${align} bytes")
        }
}
