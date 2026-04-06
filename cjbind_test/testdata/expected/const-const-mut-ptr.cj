package cjbind_ffi

@C
public struct foo_foo {
    public let bar: CPointer<CPointer<CPointer<CPointer<Int32>>>>
    public init(bar: CPointer<CPointer<CPointer<CPointer<Int32>>>>) {
        this.bar = bar
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo_foo>()
        if (size != 8) {
            throw Exception("Size of foo_foo is not 8 but ${size} bytes")
        }
        let align = alignOf<foo_foo>()
        if (align != 8) {
            throw Exception("Alignment of foo_foo is not 8 but ${align} bytes")
        }
}
