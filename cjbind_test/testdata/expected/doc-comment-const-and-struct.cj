package cjbind_ffi

// This is a constant that has a docstring
//
// And expected to be found in generated bindings code too.
public const FOO: Int32 = 1

// This is a constant that has a docstring
//
// And expected to be found in generated bindings code too.
@C
public struct Bar {
    public var baz: Int32
    public init(baz: Int32) {
        this.baz = baz
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Bar>()
        if (size != 4) {
            throw Exception("Size of Bar is not 4 but ${size} bytes")
        }
        let align = alignOf<Bar>()
        if (align != 4) {
            throw Exception("Alignment of Bar is not 4 but ${align} bytes")
        }
}
