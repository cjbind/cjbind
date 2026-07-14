package cjbind_ffi

@C
public struct Foo_Foo {
    public func clone(): Foo_Foo {
        return this
    }
    public func toString(): String {
        var output = "Foo_Foo {"
        output += " }"
        return output
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Foo_Foo>()
        if (size != 0) {
            throw Exception("Size of Foo_Foo is not 0 but ${size} bytes")
        }
        let align = alignOf<Foo_Foo>()
        if (align != 1) {
            throw Exception("Alignment of Foo_Foo is not 1 but ${align} bytes")
        }
}
