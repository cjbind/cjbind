package cjbind_ffi

@C
public struct Foo_open0_bool_int_close0 {
    public let t: Bool
    public let u: Int32
    public init(t: Bool, u: Int32) {
        this.t = t
        this.u = u
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Foo_open0_bool_int_close0>()
        if (size != 8) {
            throw Exception("Size of Foo_open0_bool_int_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<Foo_open0_bool_int_close0>()
        if (align != 4) {
            throw Exception("Alignment of Foo_open0_bool_int_close0 is not 4 but ${align} bytes")
        }
}
