package cjbind_ffi

@C
public struct foo_foo {
    public let bar: Float64
    public init(bar: Float64) {
        this.bar = bar
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo_foo>()
        if (size != 16) {
            throw Exception("Size of foo_foo is not 16 but ${size} bytes")
        }
        let align = alignOf<foo_foo>()
        if (align != 16) {
            throw Exception("Alignment of foo_foo is not 16 but ${align} bytes")
        }
}