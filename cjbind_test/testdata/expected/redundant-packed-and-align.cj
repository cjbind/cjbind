package cjbind_ffi

@C
public struct redundant_pragma_packed_redundant_pragma_packed {
    public let a: UInt8
    public let b: UInt16
    public init(a: UInt8, b: UInt16) {
        this.a = a
        this.b = b
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<redundant_pragma_packed_redundant_pragma_packed>()
        if (size != 4) {
            throw Exception("Size of redundant_pragma_packed_redundant_pragma_packed is not 4 but ${size} bytes")
        }
        let align = alignOf<redundant_pragma_packed_redundant_pragma_packed>()
        if (align != 4) {
            throw Exception("Alignment of redundant_pragma_packed_redundant_pragma_packed is not 4 but ${align} bytes")
        }
}