package cjbind_ffi

foreign func f(a: Int32, ...): Unit

@C
public struct Foo_Foo {
    public let f: CPointer<Unit>
    public func clone(): Foo_Foo {
        return this
    }
    public func toString(): String {
        var output = "Foo_Foo {"
        output += " f: "
        output += CPointer<Unit>(this.f).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(f: CPointer<Unit>) {
        this.f = f
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
