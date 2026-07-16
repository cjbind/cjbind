package cjbind_ffi

public type baz = Int32

@C
public struct Foo {
    public var bar: CFunc<(x: Int32, y: Int32) -> baz>
    public init(bar: CFunc<(x: Int32, y: Int32) -> baz>) {
        this.bar = bar
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Foo>()
        if (size != 8) {
            throw Exception("Size of Foo is not 8 but ${size} bytes")
        }
        let align = alignOf<Foo>()
        if (align != 8) {
            throw Exception("Alignment of Foo is not 8 but ${align} bytes")
        }
}
