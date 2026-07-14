package cjbind_ffi

public type baz_baz = Int32

@C
public struct Foo_Foo {
    public let bar: CFunc<(x: Int32, y: Int32) -> baz_baz>
    public func clone(): Foo_Foo {
        return this
    }
    public func toString(): String {
        var output = "Foo_Foo {"
        output += " bar: "
        output += CPointer<Unit>(this.bar).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(bar: CFunc<(x: Int32, y: Int32) -> baz_baz>) {
        this.bar = bar
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Foo_Foo>()
        if (size != 8) {
            throw Exception("Size of Foo_Foo is not 8 but ${size} bytes")
        }
        let align = alignOf<Foo_Foo>()
        if (align != 8) {
            throw Exception("Alignment of Foo_Foo is not 8 but ${align} bytes")
        }
}
