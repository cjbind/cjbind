package cjbind_ffi

@C
public struct foo_foo {
    public let foo: Int32
    public func clone(): foo_foo {
        return this
    }
    public func toString(): String {
        var output = "foo_foo {"
        output += " foo: "
        output += this.foo.toString()
        output += " }"
        return output
    }
    public init(foo: Int32) {
        this.foo = foo
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo_foo>()
        if (size != 4) {
            throw Exception("Size of foo_foo is not 4 but ${size} bytes")
        }
        let align = alignOf<foo_foo>()
        if (align != 4) {
            throw Exception("Alignment of foo_foo is not 4 but ${align} bytes")
        }
}

@C
public struct bar_bar {
    public let u: foo_foo
    public func clone(): bar_bar {
        return this
    }
    public func toString(): String {
        var output = "bar_bar {"
        output += " u: "
        output += this.u.toString()
        output += " }"
        return output
    }
    public init(u: foo_foo) {
        this.u = u
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<bar_bar>()
        if (size != 4) {
            throw Exception("Size of bar_bar is not 4 but ${size} bytes")
        }
        let align = alignOf<bar_bar>()
        if (align != 4) {
            throw Exception("Alignment of bar_bar is not 4 but ${align} bytes")
        }
}

public type bar_t_bar_t = bar_bar

@C
public struct baz_baz {
    public let f: foo_foo
    public func clone(): baz_baz {
        return this
    }
    public func toString(): String {
        var output = "baz_baz {"
        output += " f: "
        output += this.f.toString()
        output += " }"
        return output
    }
    public init(f: foo_foo) {
        this.f = f
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<baz_baz>()
        if (size != 4) {
            throw Exception("Size of baz_baz is not 4 but ${size} bytes")
        }
        let align = alignOf<baz_baz>()
        if (align != 4) {
            throw Exception("Alignment of baz_baz is not 4 but ${align} bytes")
        }
}
