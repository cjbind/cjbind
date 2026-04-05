package cjbind_ffi

@C
public struct Foo_Foo {}

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