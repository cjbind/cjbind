package cjbind_ffi

// This is a constant that has a docstring
//
// And expected to be found in generated bindings code too.
public const FOO_FOO: Int32 = 1

// This is a constant that has a docstring
//
// And expected to be found in generated bindings code too.
@C
public struct Bar_Bar {
    public let baz: Int32
    public func clone(): Bar_Bar {
        return this
    }
    public func toString(): String {
        var output = "Bar_Bar {"
        output += " baz: "
        output += this.baz.toString()
        output += " }"
        return output
    }
    public init(baz: Int32) {
        this.baz = baz
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Bar_Bar>()
        if (size != 4) {
            throw Exception("Size of Bar_Bar is not 4 but ${size} bytes")
        }
        let align = alignOf<Bar_Bar>()
        if (align != 4) {
            throw Exception("Alignment of Bar_Bar is not 4 but ${align} bytes")
        }
}
