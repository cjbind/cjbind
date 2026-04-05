package cjbind_ffi

@C
public struct foo_foo {
    public let my_signed: VArray<Int64, $2>
    public let my_unsigned: VArray<UInt64, $2>
    public init(my_signed: VArray<Int64, $2>, my_unsigned: VArray<UInt64, $2>) {
        this.my_signed = my_signed
        this.my_unsigned = my_unsigned
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo_foo>()
        if (size != 32) {
            throw Exception("Size of foo_foo is not 32 but ${size} bytes")
        }
        let align = alignOf<foo_foo>()
        if (align != 16) {
            throw Exception("Alignment of foo_foo is not 16 but ${align} bytes")
        }
}
